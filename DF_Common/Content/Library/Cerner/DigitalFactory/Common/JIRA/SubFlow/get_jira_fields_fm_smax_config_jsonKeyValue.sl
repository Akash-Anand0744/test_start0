namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: get_jira_fields_fm_smax_config_jsonKeyValue
  inputs:
    - get_jira_fields_fm_smax_config
    - smax_config_json
  workflow:
    - key_value_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${get_jira_fields_fm_smax_config}'
            - second_string: ''
            - ignore_case: 'true'
            - json_key_value: ''
        publish:
          - json_key_value
          - key_value_list: '${first_string}'
        navigate:
          - SUCCESS: set_message
          - FAILURE: list_iterator_Key_value_list
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
          - json_key_value: '${json_key_value[:-1]}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - message: Provided Key Value list is empty
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - extract_key_value:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_value: '${key_value}'
        publish:
          - key: "${key_value.split(',',1)[0]}"
          - value: "${key_value.split(',',1)[1]}"
        navigate:
          - SUCCESS: get_newKey_from_OOConfig
          - FAILURE: on_failure
    - get_newKey_from_OOConfig:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${smax_config_json_object}'
            - json_path: '${key}'
        publish:
          - newKey: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: append_key_value_for_json
          - FAILURE: on_failure
    - append_key_value_for_json:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key: '${newKey}'
            - value: '${value}'
            - json_key_value: '${json_key_value}'
        publish:
          - json_key_value: "${json_key_value + '\"' + key + '\":\"' + value + '\",'}"
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
  outputs:
    - get_jira_fields_fm_smax_config_jsonKeyValue: '${json_key_value}'
    - message: '${message}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      key_value_isnull:
        x: 265
        'y': 53
      list_iterator_Key_value_list:
        x: 276
        'y': 294
      set_message_1:
        x: 566
        'y': 216
        navigate:
          79d2b7e0-a23a-2be8-483c-9cccd34d48ae:
            targetId: 377003fd-a828-722d-cbb9-20e5cd5e7fc4
            port: SUCCESS
      set_message:
        x: 543
        'y': 49
        navigate:
          b271c6d9-956e-b3db-72d6-2f3272e0073f:
            targetId: 377003fd-a828-722d-cbb9-20e5cd5e7fc4
            port: SUCCESS
      extract_key_value:
        x: 274
        'y': 505
      get_newKey_from_OOConfig:
        x: 495
        'y': 505
      append_key_value_for_json:
        x: 788
        'y': 497
    results:
      SUCCESS:
        377003fd-a828-722d-cbb9-20e5cd5e7fc4:
          x: 866
          'y': 45
