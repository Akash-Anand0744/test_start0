########################################################################################################################
#!!
#! @input Key_value_list: Unable to load description
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: Create_json_object_fm_key_value_pair_List
  inputs:
    - Key_value_list:
        default: ''
        required: false
  workflow:
    - key_value_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${Key_value_list}'
            - second_string: ''
            - ignore_case: 'true'
            - json_key_value: ''
        publish:
          - json_key_value
        navigate:
          - SUCCESS: set_message
          - FAILURE: list_iterator_Key_value_list
    - list_iterator_Key_value_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${Key_value_list}'
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
    - extract_key_value:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_value: '${key_value}'
        publish:
          - key: "${key_value.split(',',1)[0]}"
          - value: "${key_value.split(',',1)[1]}"
        navigate:
          - SUCCESS: Value_isnull
          - FAILURE: on_failure
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - message: Provided Key Value list is empty
        navigate:
          - SUCCESS: SUCCESS
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
    - Value_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: "${value.strip(',').strip()}"
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: extractKeyTpe
    - extractKeyTpe:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.extractKeyTpe:
            - jirafieldkey: '${key}'
            - jirafieldvalue: '${value}'
        publish:
          - key: '${key.strip()}'
          - keyType
          - message
          - result
          - errorMessage: '${message}'
          - valueType
          - value
          - errorType
        navigate:
          - SUCCESS: Is_keyType_rich
          - FAILURE: on_failure
    - Is_keyType_rich:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${valueType}'
            - second_string: rich
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: convertHTMLtoJIRAMarkup
          - FAILURE: createJirafieldType_json
    - convertHTMLtoJIRAMarkup:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.convertHTMLtoJIRAMarkup:
            - htmlString: '${value}'
        publish:
          - value: '${wikiString[1:-1]}'
          - imageLinks
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: createJirafieldType_json
          - FAILURE: on_failure
    - createJirafieldType_json:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.createJirafieldType_json:
            - jirafieldkey: '${key}'
            - jirafieldkeyValue: '${value}'
            - json_keyValue: '${json_key_value}'
            - jirafieldkeyType: '${keyType}'
        publish:
          - json_key_value
          - result
          - message
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
  outputs:
    - json_key_value_object: '${json_key_value}'
    - message: '${message}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      set_message:
        x: 533
        'y': 74
        navigate:
          a400c864-ac45-2a6d-0467-5a24d1e4342d:
            targetId: 43d7f239-8cc4-213e-8f99-a8422e98e31b
            port: SUCCESS
      extractKeyTpe:
        x: 304
        'y': 518
      convertHTMLtoJIRAMarkup:
        x: 723
        'y': 571
      extract_key_value:
        x: 91
        'y': 282
      Is_keyType_rich:
        x: 462
        'y': 519
      set_message_1:
        x: 720
        'y': 284
        navigate:
          7d550f46-43b7-ce6c-f3c9-8733b7dd1fea:
            targetId: 43d7f239-8cc4-213e-8f99-a8422e98e31b
            port: SUCCESS
      list_iterator_Key_value_list:
        x: 351
        'y': 284
      createJirafieldType_json:
        x: 728
        'y': 429
      Value_isnull:
        x: 92
        'y': 525
      key_value_isnull:
        x: 350
        'y': 66
    results:
      SUCCESS:
        43d7f239-8cc4-213e-8f99-a8422e98e31b:
          x: 720
          'y': 67
