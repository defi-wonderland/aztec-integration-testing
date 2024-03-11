
// https://github.com/AztecProtocol/aztec-packages/blob/827afd10edfca8b2c8273742717f039981543194/noir-projects/aztec-nr/aztec/src/oracle/context.nr

contract LocalOracle {

    use dep::std::test::OracleMock;

    use dep::aztec::{
        oracle::context::get_portal_address,
        protocol_types::address::{AztecAddress, EthAddress},
    };

    #[aztec(private)]
    fn constructor() {}

    #[test]
    fn test_sqrt() {
        let input = [9];
        let sqrt = get_sqrt(input);
        assert(sqrt[0].pow_32(2) as u64 == input[0] as u64);
    }

    #[oracle(getSqrt)]
    unconstrained fn sqrt(input: [Field; 1]) -> pub [Field; 1] { }

    unconstrained fn get_sqrt(input: [Field; 1]) -> pub [Field; 1] {
        sqrt(input)
    }
}