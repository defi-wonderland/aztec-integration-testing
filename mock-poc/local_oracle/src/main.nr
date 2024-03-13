
// https://github.com/AztecProtocol/aztec-packages/blob/827afd10edfca8b2c8273742717f039981543194/noir-projects/aztec-nr/aztec/src/oracle/context.nr
use dep::aztec::protocol_types::{address::AztecAddress, abis::function_selector::FunctionSelector, constants::RETURN_VALUES_LENGTH};

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
        let deployment_address = deploy_contract();

        assert(deployment_address != AztecAddress::zero());
    }

    #[test]
    fn test_interact() {
        let deployment_address = deploy_contract();

        // add oracle call for the public/private call

        // assert result
    }

    #[oracle(deployContract)]
    unconstrained fn deploy() -> pub AztecAddress { }

    unconstrained fn deploy_contract() -> pub AztecAddress {
        deploy()
    }
}