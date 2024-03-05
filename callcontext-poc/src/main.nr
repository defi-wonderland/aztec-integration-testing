// https://github.com/AztecProtocol/aztec-packages/blob/245d801240998d945e6d5d3371f32eb2b31b66e5/noir-projects/aztec-nr/aztec/src/context/inputs/private_context_inputs.nr#L9

// early poc: prank and other calling context manipulation should basically be a wrapper around Private and Public context inputs,
// which are anyway passed from the fn with a test macro to their tested target fn
contract CallContextManipulation {

    use dep::std::test::OracleMock;

    use dep::aztec::{
        oracle::context::get_portal_address,
        protocol_types::{
            address::{AztecAddress, EthAddress},
            abis::{
                call_context::CallContext,
                function_selector::FunctionSelector
            },
            header::Header,
            contrakt::deployment_data::ContractDeploymentData,
            grumpkin_point::GrumpkinPoint,
            contract_class::ContractClassId
        },
        context::{
            inputs::PrivateContextInputs,
            globals::private_global_variables::PrivateGlobalVariables
        }
    };

    #[aztec(private)]
    fn constructor() {}

    #[aztec(private)]
    fn caller_is_1234() -> bool {
        context.msg_sender() == AztecAddress::from_field(1234)
    }

    #[test]
    fn test_mocking_caller() {
        let good_address = AztecAddress::from_field(1234);

        let call_context = CallContext {
            msg_sender : good_address,
            storage_contract_address : AztecAddress::from_field(0),
            portal_contract_address : EthAddress::from_field(0),

            function_selector : FunctionSelector::from_signature("caller_is_1234()"),

            is_delegate_call : false,
            is_static_call : false,
            is_contract_deployment : false,

            start_side_effect_counter : 0,
        };

        let contract_deployment_data = ContractDeploymentData {
            public_key : GrumpkinPoint { x: 0, y: 0 },
            initialization_hash : 0,
            contract_class_id : ContractClassId { inner: 0 },
            contract_address_salt : 0,
            portal_contract_address : EthAddress::from_field(0),
        };

        let private_global_variables = PrivateGlobalVariables {
            chain_id: 0,
            version: 0,
        };

        let hacked_context = PrivateContextInputs {
            call_context,
            historical_header: Header::empty(),
            contract_deployment_data,
            private_global_variables
        };

        let priv_circ_pub_input = caller_is_1234(hacked_context); 

        assert_eq(priv_circ_pub_input.return_values[0], 1);
    }

    #[test(should_fail)]
    fn test_mocking_wrong_caller() {
        let bad_address = AztecAddress::from_field(4567);

        let call_context = CallContext {
            msg_sender : bad_address,
            storage_contract_address : AztecAddress::from_field(0),
            portal_contract_address : EthAddress::from_field(0),

            function_selector : FunctionSelector::from_signature("caller_is_1234()"),

            is_delegate_call : false,
            is_static_call : false,
            is_contract_deployment : false,

            start_side_effect_counter : 0,
        };

        let contract_deployment_data = ContractDeploymentData {
            public_key : GrumpkinPoint { x: 0, y: 0 },
            initialization_hash : 0,
            contract_class_id : ContractClassId { inner: 0 },
            contract_address_salt : 0,
            portal_contract_address : EthAddress::from_field(0),
        };

        let private_global_variables = PrivateGlobalVariables {
            chain_id: 0,
            version: 0,
        };

        let hacked_context = PrivateContextInputs {
            call_context,
            historical_header: Header::empty(),
            contract_deployment_data,
            private_global_variables
        };

        let priv_circ_pub_input = caller_is_1234(hacked_context); 

        assert_eq(priv_circ_pub_input.return_values[0], 1);
    }
}


/*PrivateContextInputs {
            call_context: CallContext::empty(),
            historical_header: Header::empty(),
            contract_deployment_data: ContractDeploymentData::empty(),
            private_global_variables: PrivateGlobalVariables::empty()
        }*/