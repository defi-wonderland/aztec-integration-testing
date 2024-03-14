contract LocalOracle {

    use dep::std::test::OracleMock;

    use dep::aztec::{
        oracle::context::get_portal_address,
        protocol_types::{
            abis::function_selector::FunctionSelector,
            address::AztecAddress,
            constants::RETURN_VALUES_LENGTH}
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

        let function_selector = FunctionSelector::from_signature("get_meaning_of_life()");

        // add oracle call for the public/private call
        let result = view(deployment_address, function_selector, [0,0,0,0]);

        // assert result
        assert(result == 42);
    }

    #[oracle(deployContract)]
    unconstrained fn deploy() -> pub AztecAddress { }

    unconstrained fn deploy_contract() -> pub AztecAddress {
        deploy()
    }

    // for now, 4 args -> same as callstack limit?
    #[oracle(view)]
    unconstrained fn view_oracle(contract_address: AztecAddress, method_name: FunctionSelector, args: [Field; 4]) -> pub Field {}

    unconstrained fn view(contract_address: AztecAddress, method_name: FunctionSelector, args: [Field; 4]) -> pub Field {
        view_oracle(contract_address, method_name, args)
    }
}