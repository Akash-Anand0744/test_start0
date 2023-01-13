########################################################################################################################
#!!
#! @input get_list_for_jirafields: a comma separated list as input 
#! @input smax_system_property_json: SMAX System Properties Config json object
#! @input oo_jira_customField_json_object: OO Config JIRA custom field json object
#!
#! @output jirafields_list: coma separated list of jira fields with custom field names
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: get_jiraFields_fm_oo_config_to_list
  inputs:
    - get_list_for_jirafields:
        default: ''
        required: false
    - smax_system_property_json: ''
    - oo_jira_customField_json_object: ''
  workflow:
    - key_value_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${get_list_for_jirafields}'
            - second_string: ''
            - ignore_case: 'true'
            - json_key_value: ''
        publish:
          - json_key_value
          - key_value_list: '${first_string}'
        navigate:
          - SUCCESS: set_message
          - FAILURE: list_iterator_Key_value_list
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - message: Provided  jira fields list is empty
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - list_iterator_Key_value_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${key_value_list}'
            - separator: ','
        publish:
          - result_string
          - return_result
          - return_code
          - key: '${result_string}'
        navigate:
          - HAS_MORE: get_newKey_from_jiraCustimField
          - NO_MORE: set_message_1
          - FAILURE: on_failure
    - set_message_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - json_key_value: '${json_key_value}'
        publish:
          - message: Provided  list is converted into jiraFieds list  successfully
          - json_key_value
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - append_key_value_for_json:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key: "${get('newKey', key)}"
            - json_key_value: '${json_key_value}'
        publish:
          - json_key_value: "${json_key_value + key + ','}"
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
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
          - errorMessage: "${'Warning: JIRA custom field name  for -' + key + ' not found, still continuing further'}"
          - errorProvider: OOExec
          - errorSeverity: WARN
          - errorType: e10000
          - newKey: '${key}'
        navigate:
          - SUCCESS: append_key_value_for_json
          - FAILURE: on_failure
  outputs:
    - jirafields_list: '${json_key_value}'
    - message: '${message}'
    - errorProvider: '${errorProvider}'
    - errorSeverity: '${errorSeverity}'
    - errorType: '${errorType}'
    - errorMessage: '${errorMessage}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      key_value_isnull:
        x: 152
        'y': 40
      set_message:
        x: 486
        'y': 36
        navigate:
          2444db65-076e-dfd2-2596-5db2f133b941:
            targetId: 87cee391-7d23-232d-0a5b-211fe2c389e8
            port: SUCCESS
      list_iterator_Key_value_list:
        x: 151
        'y': 254
      set_message_1:
        x: 486
        'y': 177
        navigate:
          52629812-b698-6a63-0e15-ebf9715a49d1:
            targetId: 87cee391-7d23-232d-0a5b-211fe2c389e8
            port: SUCCESS
      append_key_value_for_json:
        x: 481
        'y': 310
      get_newKey_from_jiraCustimField:
        x: 151
        'y': 511
      get_newKey_from_smax_config_properties:
        x: 491
        'y': 511
      set_message_2_2:
        x: 756
        'y': 399
    results:
      SUCCESS:
        87cee391-7d23-232d-0a5b-211fe2c389e8:
          x: 749
          'y': 101
