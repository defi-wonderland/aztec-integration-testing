
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
    fn test_deploy() {
        let thing = deploy_contract();
        assert(1 == 1);
    }

    #[oracle(deployContract)]
    unconstrained fn deploy() -> pub AztecAddress { }

    unconstrained fn deploy_contract() -> pub AztecAddress {
        deploy()
    }
}