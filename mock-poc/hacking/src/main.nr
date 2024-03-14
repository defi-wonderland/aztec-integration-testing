// A contract used along with `Parent` contract to test nested calls.
contract UnitTest {
    use dep::aztec::prelude::{AztecAddress, PrivateMutable};
    use dep::field_note::field_note::FieldNote;

    #[aztec(private)]
    fn constructor() {}
}
