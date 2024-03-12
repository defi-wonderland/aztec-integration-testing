// A contract used along with `Parent` contract to test nested calls.
contract UnitTest {
    use dep::std::option::Option;
    use dep::std::test::OracleMock;

    use dep::aztec::{
        context::{PrivateContext, PublicContext, Context}, log::emit_unencrypted_log,
        state_vars::{public_state::PublicState, singleton::Singleton},
        oracle::rand::rand,
        note::note_header::NoteHeader
    };
    use dep::aztec::protocol_types::{
        abis::{function_selector::FunctionSelector, side_effect::{SideEffect, SideEffectLinkedToNoteHash}},
        address::AztecAddress,
        constants::{VIEW_NOTE_ORACLE_RETURN_LENGTH}, hash::hash_args
    };
    use dep::field_note::field_note::{FieldNote, FIELD_NOTE_LEN};

    struct Storage {
        admin: PublicState<AztecAddress>,
        admin_pvt: Singleton<FieldNote>,
    }
    
    impl Storage {
        fn init(context: Context) -> Self {
            Storage {
                admin: PublicState::new(context, 1),
                admin_pvt: Singleton::new(context, 2)
            }
        }
    }

    #[aztec(private)]
    fn constructor() {}

    //////////////////////
    // test a plain and simple function:
    //////////////////////
    #[aztec(private)]
    fn add(a: Field, b: Field) -> Field {
        a + b
    }
    #[test]
    unconstrained fn test_add() {
        let priv_circ_pub_inputs = add(dep::std::unsafe::zeroed(), 1, 2);
        assert_eq(priv_circ_pub_inputs.return_values[0], 3);
    }

    //////////////////////
    // test the simplest oracle call
    //////////////////////
    #[aztec(private)]
    fn add_rand(b: Field) -> Field {
        rand() + b
    }
    #[test]
    unconstrained fn test_add_rand() {
        // bug where times has to be > 1.
        OracleMock::mock("getRandomField").returns(3).times(2);
        let priv_circ_pub_inputs = add_rand(dep::std::unsafe::zeroed(), 2);
        assert(2.lt(priv_circ_pub_inputs.return_values[0]), "Is not less than!!");
    }

    //////////////////////
    // Test public Storage
    //////////////////////
    #[aztec(public)]
    fn init(new_admin: AztecAddress) {
        storage.admin.write(new_admin);
    }
    #[aztec(public)]
    fn get_admin() -> AztecAddress {
        storage.admin.read()
    }

    // TODO: Unknown foreign call storageWrite
    #[test]
    unconstrained fn test_public_storage() {
        // currently can't check how many times a mock was called. Feature needed!
        // For now, You know the `init()` fn called the right oracle with the right params, else it would have crashed.
        let admin = AztecAddress { inner: 10 };
        let serializedAdminValue = admin.serialize(); // [10]
        let randomHashValue = [1];
        let _mock1 = OracleMock::mock("storageWrite").with_params((1, serializedAdminValue)).returns(randomHashValue);
        init(dep::std::unsafe::zeroed(), admin);
        _mock1.clear();

        OracleMock::mock("storageRead").with_params((1, 1)).returns(serializedAdminValue);
        let pub_circ_pub_inputs = get_admin(dep::std::unsafe::zeroed());
        assert_eq(AztecAddress::from_field(pub_circ_pub_inputs.return_values[0]), admin);
    }

    //////////////////////
    // test private storage
    //////////////////////
    #[aztec(private)]
    fn init_pvt(admin: AztecAddress) {
        let mut admin_note = FieldNote::new(admin.to_field());
        storage.admin_pvt.initialize(&mut admin_note, false);
    }
    #[aztec(private)]
    fn update_pvt(admin: AztecAddress) {
        let mut admin_note = FieldNote::new(admin.to_field());
        storage.admin_pvt.replace(&mut admin_note, false);
    }

    #[aztec(private)]
    fn get_admin_pvt() -> [Field; 1] {
        let field_note = storage.admin_pvt.view_note();
        field_note.serialize_content()
    }

    // TODO: Unknown foreign call notifyCreatedNote
    #[test]
    unconstrained fn test_private_storage() {
        let admin_pvt_addr = AztecAddress { inner: 10 };
        let mut admin_note = FieldNote::new(10);

        // create mock
        let storage_slot = 2;

        // set header to empty except the storage slot
        let header = NoteHeader { contract_address: AztecAddress { inner: 0 }, storage_slot, nonce: 0, is_transient: false };
        admin_note.set_header(header);

        let inner_hash = dep::aztec::note::utils::compute_inner_note_hash(admin_note);
        let note_type_id = FieldNote::get_note_type_id();
        // mock needs to return 0 (assert success in create note)
        let _mock1 = OracleMock::mock("notifyCreatedNote").with_params((storage_slot, note_type_id ,admin_note.serialize_content(), inner_hash)).returns(0);

        // call fn 
        let pvt_circ_pub_inputs = init_pvt(dep::std::unsafe::zeroed(), admin_pvt_addr);
        // check 1 commitment was created:
        // pvt_circ_pub_inputs.new_commitments is a fixed size array of `SideEffect` objects - each with a counter
        // There should be just 1 non empty SideEffect object!
        assert(pvt_circ_pub_inputs.new_commitments[0] != SideEffect::empty()); // has some note hash!
        // check all subsequent commitments have 0 counter/ 0 value
        // note that side effect objects are typically sorted decreasingly so no need to check others 
        // if we check the `counter` on pvt_circ_pub_inputs.new_commitments[0]
        assert_eq(pvt_circ_pub_inputs.new_commitments[1], SideEffect::empty());

        // check 1 nullifier was created
        assert(pvt_circ_pub_inputs.new_nullifiers[0] != SideEffectLinkedToNoteHash::empty()); // has some nullifier
        // check all other are 0s..
        // ...
        _mock1.clear();

        // test reading the note:
        let mut returnVal = [0; VIEW_NOTE_ORACLE_RETURN_LENGTH];
        returnVal[0] = 1; // return header - num_notes
        returnVal[1] = 1; // return header - num_contract_address
        returnVal[2] = 1; // return header - nonce
        returnVal[3] = 0; // return header - is_transient
        returnVal[4] = admin_note.value; // note 1 - value
        // TODO: mock individual items. (print value going to `get_notes_oracle() in notes.nr)
        OracleMock::mock("getNotes").returns(returnVal).times(2);
        let pvt_circ_pub_inputs = get_admin_pvt(dep::std::unsafe::zeroed());
        assert_eq(pvt_circ_pub_inputs.return_values[0], 10);
    }

    // //////////////////////
    // // mock another function call
    // //////////////////////
    // #[aztec(private)]
    // fn calls_public_and_private_from_private(admin: AztecAddress) {
    //     context.call_public_function(
    //         context.this_address(),
    //         FunctionSelector::from_signature("init((Field))"),
    //         [admin.to_field()]
    //     );
    //     context.call_private_function(
    //         context.this_address(),
    //         FunctionSelector::from_signature("update_pvt((Field))"),
    //         [admin.to_field()]
    //     );
    // }
    // #[aztec(public)]
    // fn calls_public_from_public(admin: AztecAddress) {
    //     context.call_public_function(
    //         context.this_address(),
    //         FunctionSelector::from_signature("init((Field))"),
    //         [admin.to_field()]
    //     );
    // }

    // authwits

    // l1<>l2

    unconstrained fn compute_note_hash_and_nullifier(
        contract_address: AztecAddress,
        nonce: Field,
        storage_slot: Field,
        note_type_id: Field,
        serialized_note: [Field; 0]
    ) -> pub [Field; 4] {
        [0, 0, 0, 0]
    }
}
