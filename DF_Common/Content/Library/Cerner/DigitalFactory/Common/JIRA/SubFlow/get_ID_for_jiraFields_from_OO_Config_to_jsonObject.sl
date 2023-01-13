########################################################################################################################
#!!
#! @input get_id_value_fm_oo_config: Key Value Pair List separated by Coma(,) and field delimitter  is "||"  like  (Key1, test first key value||Key2,  second Key Value||Key3, Third Key Value||)
#! @input smax_system_property_json: SMAX System Properties Config json object
#! @input oo_jira_customField_json_object: OO Config JIRA custom field json object
#! @input keysuffix: Suffix for OO Config Property for Jira fields ID Values
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: get_ID_for_jiraFields_from_OO_Config_to_jsonObject
  inputs:
    - get_id_value_fm_oo_config: ''
    - smax_system_property_json: ''
    - oo_jira_customField_json_object: ''
    - keysuffix: JSON
  workflow:
    - key_value_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${get_id_value_fm_oo_config}'
            - second_string: ''
            - ignore_case: 'true'
            - json_key_value: ''
        publish:
          - json_key_value
          - key_value_list: '${first_string}'
        navigate:
          - SUCCESS: set_message
          - FAILURE: getOOConfigProperties
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - message: Provided Key Value list is empty
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - list_iterator_Key_value_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${key_value_list}'
            - separator: '||'
        publish:
          - result_string
          - return_result
          - return_code
          - key_value: '${result_string}'
        navigate:
          - HAS_MORE: extract_key_value
          - NO_MORE: set_message_1
          - FAILURE: on_failure
    - set_message_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - json_key_value: '${json_key_value}'
        publish:
          - message: Provided Key Value list is converted into Json Key Value Pair successfully
          - json_key_value
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - extract_key_value:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_value: '${key_value}'
        publish:
          - key: "${key_value.split(',',1)[0].strip()}"
          - value: "${key_value.split(',',1)[1].strip()}"
        navigate:
          - SUCCESS: ValueofKey_isnull
          - FAILURE: on_failure
    - append_key_value_for_json:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key: "${get('newKey', key)}"
            - value: '${newValue}'
            - json_key_value: '${json_key_value}'
        publish:
          - json_key_value: "${json_key_value + '\"' + key + '\":{\"id\":\"' + value + '\"},'}"
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
    - get_ValueID_from_OOConfig:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${json_input_object}'
            - json_path: '${value.strip()}'
        publish:
          - newValue: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_newKey_from_jiraCustimField
          - FAILURE: set_message_2
    - ValueofKey_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${value}'
            - second_string: ''
            - ignore_case: 'true'
            - key_config: "${'MarketPlace.'+ key + '_' + keysuffix}"
        publish:
          - key_config
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: get_OO_config_json_for_ID_Val
    - set_message_2:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key: '${key}'
            - value: '${value}'
            - json_input: '${json_input_object}'
            - keysuffix: '${keysuffix}'
        publish:
          - errorMessage: "${'Failed:  Key (' + value + ') not found in the provided json object: ' + key + '_' + keysuffix + ': ' + json_input}"
          - errorProvider: OOExec
          - errorSeverity: ERROR
          - errorType: e10000
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: FAILURE
    - set_message_2_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key: '${key}'
            - keysuffix: '${keysuffix}'
        publish:
          - errorMessage: "${'Failed: OO Configuration  Key not foind for ' + key + '_' + keysuffix + '.  Ensure the Config Property Exists'}"
          - errorProvider: OOExec
          - errorSeverity: ERROR
          - errorType: e10000
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: FAILURE
    - get_newKey_from_jiraCustimField:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${oo_jira_customField_json_object}'
            - json_path: '${key.strip()}'
        publish:
          - newKey: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: append_key_value_for_json
          - FAILURE: get_newKey_from_smax_config_properties
    - get_newKey_from_smax_config_properties:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${smax_system_property_json}'
            - json_path: '${key.strip()}'
        publish:
          - newKey: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: append_key_value_for_json
          - FAILURE: set_message_2_2
    - set_message_2_2:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key: '${key}'
        publish:
          - errorMessage: "${'Warning: New Key not found for ' + key + 'Ensure that this Key exists in SMAX or OO Config Properties But still Progressing without Failure'}"
          - errorProvider: OOExec
          - errorSeverity: WARN
          - errorType: e10000
          - newKey: '${key}'
        navigate:
          - SUCCESS: append_key_value_for_json
          - FAILURE: on_failure
    - getOOConfigProperties:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.getOOConfigProperties:
            - smax_auth_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxAuthURL')}"
            - smax_user: "${get_sp('io.cloudslang.microfocus.oo.oo_username')}"
            - smax_password: "${get_sp('io.cloudslang.microfocus.oo.oo_password')}"
            - smax_tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
            - smax_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - keysuffix: JSON
        publish:
          - oo_config_json_list: '${config_json}'
          - message
          - errorType
          - result
          - errorMessage: '${errormessage}'
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
    - get_OO_config_json_for_ID_Val:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${oo_config_json_list}'
            - json_path: "${key + '_' + keysuffix}"
        publish:
          - json_input_object: '${return_result}'
          - errorMessage: '${error_message}'
          - return_code
        navigate:
          - SUCCESS: get_ValueID_from_OOConfig
          - FAILURE: set_message_2_1
  outputs:
    - json_object_key_value_pair_with_ID: '${json_key_value}'
    - message: '${message}'
    - errorProvider: '${errorProvider}'
    - errorSeverity: '${errorSeverity}'
    - errorType: '${errorType}'
    - errorMessage: '${errorMessage}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_newKey_from_smax_config_properties:
        x: 901
        'y': 254
      get_OO_config_json_for_ID_Val:
        x: 486
        'y': 467
      set_message:
        x: 489
        'y': 32
        navigate:
          2444db65-076e-dfd2-2596-5db2f133b941:
            targetId: 87cee391-7d23-232d-0a5b-211fe2c389e8
            port: SUCCESS
      getOOConfigProperties:
        x: 19
        'y': 154
      set_message_2_1:
        x: 486
        'y': 635
        navigate:
          3c39d289-03f0-9f24-55e9-0f62db7b7c86:
            targetId: 19db2882-8d2e-ad53-e472-98b77feb42f5
            port: SUCCESS
          cb103df0-053e-785a-7c63-5d7ef2477c8f:
            targetId: 19db2882-8d2e-ad53-e472-98b77feb42f5
            port: FAILURE
      set_message_2_2:
        x: 904
        'y': 76
      append_key_value_for_json:
        x: 484
        'y': 313
      extract_key_value:
        x: 147
        'y': 439
      get_newKey_from_jiraCustimField:
        x: 900
        'y': 423
      ValueofKey_isnull:
        x: 317
        'y': 447
      get_ValueID_from_OOConfig:
        x: 698
        'y': 460
      set_message_1:
        x: 487
        'y': 179
        navigate:
          52629812-b698-6a63-0e15-ebf9715a49d1:
            targetId: 87cee391-7d23-232d-0a5b-211fe2c389e8
            port: SUCCESS
      list_iterator_Key_value_list:
        x: 149
        'y': 252
      set_message_2:
        x: 903
        'y': 629
        navigate:
          bb8fa6fb-7617-54da-760a-79d83eee60c5:
            targetId: 19db2882-8d2e-ad53-e472-98b77feb42f5
            port: FAILURE
          176a3224-7082-ea4c-26b6-b5883f7fbdab:
            targetId: 19db2882-8d2e-ad53-e472-98b77feb42f5
            port: SUCCESS
      key_value_isnull:
        x: 152
        'y': 40
    results:
      FAILURE:
        19db2882-8d2e-ad53-e472-98b77feb42f5:
          x: 703
          'y': 634
      SUCCESS:
        87cee391-7d23-232d-0a5b-211fe2c389e8:
          x: 656
          'y': 38
