
contract MeaningOfLife {
    use dep::aztec::prelude::{AztecAddress,PrivateImmutable};
    use dep::field_note::field_note::FieldNote;
    
    struct Storage {
        value: PrivateImmutable<FieldNote>,
    }

    #[aztec(private)]
    fn constructor() {}

    unconstrained fn get_meaning_of_life() -> pub u32 {
        42
    }

    #[aztec(private)]
    fn set_value(value: Field) {
        let mut note = FieldNote::new(value);
        storage.value.initialize(&mut note, false);
    }

}   