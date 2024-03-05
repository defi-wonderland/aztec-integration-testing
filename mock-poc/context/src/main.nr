
// https://github.com/AztecProtocol/aztec-packages/blob/827afd10edfca8b2c8273742717f039981543194/noir-projects/aztec-nr/aztec/src/oracle/context.nr

contract MockContextPoc {

    use dep::std::test::OracleMock;

    use dep::aztec::{
        oracle::context::get_portal_address,
        protocol_types::address::{AztecAddress, EthAddress},
    };

    #[aztec(private)]
    fn constructor() {}

    #[aztec(private)]
    fn portal_is_1234(aztec_side: AztecAddress) -> bool {
        get_portal_address(aztec_side) == EthAddress::from_field(1234)
    }

    #[test]
    fn test_mocking_caller() {
        let mocked_aztec_portal = AztecAddress::from_field(1234);
        let mocked_eth_portal = EthAddress::from_field(1234);
        let _mock = OracleMock::mock("getPortalContractAddress").with_params(mocked_aztec_portal).returns(mocked_eth_portal);
        
        // zeroing PrivateContextInputs? Is it the right thing to do tho? no Empty trait for PrivateContextInputs
        let priv_circ_pub_input = portal_is_1234(dep::std::unsafe::zeroed(), mocked_aztec_portal); 

        assert_eq(priv_circ_pub_input.return_values[0], 1);
    }

    #[test(should_fail)]
    fn test_mocking_wrong_caller() {
        let mocked_aztec_portal = AztecAddress::from_field(4567);
        let mocked_eth_portal = EthAddress::from_field(4567);
        let _mock = OracleMock::mock("getPortalContractAddress").with_params(mocked_aztec_portal).returns(mocked_eth_portal);

        let priv_circ_pub_input = portal_is_1234(dep::std::unsafe::zeroed(), mocked_aztec_portal);

        assert_eq(priv_circ_pub_input.return_values[0], 1);
    }
}


/*PrivateContextInputs::new({
            call_context: CallContext::empty(),
            historical_header: Header::empty(),
            contract_deployment_data: ContractDeploymentData::empty(),
            private_global_variables: PrivateGlobalVariables::empty()
        })*/