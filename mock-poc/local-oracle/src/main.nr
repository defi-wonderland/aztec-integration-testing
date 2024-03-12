
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

    #[test]
    fn test_deploy() {
        let contract = deploy_contract();
        assert(1 == 1);
    }

    #[oracle(deployContract)]
    unconstrained fn deploy() -> pub [AztecAddress; 1] { }

    unconstrained fn deploy_contract() -> pub [AztecAddress; 1] {
        deploy()
    }
}