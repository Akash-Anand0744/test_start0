########################################################################################################################
#!!
#! @input key_value_pair_list: Key Value Pair List separated by Coma(,) and field delimitter  is "||"  like  (Key1, test first key value||Key2,  second Key Value||Key3, Third Key Value||)
#! @input json_input_object: Unable to load description
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: get_NewKeyValue_json_object_fm_json_input
  inputs:
    - key_value_pair_list:
        default: ''
        required: false
    - json_input_object:
        default: ''
        required: false
    - smax_system_property_json:
        default: ''
        required: false
  workflow:
    - key_value_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${key_value_pair_list}'
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
    - get_newKey_from_OOConfig:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${json_input_object}'
            - json_path: '${key}'
        publish:
          - newKey: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: Is_keyType_rich
          - FAILURE: get_newKey_from_SMAXCOnfig
    - ValueofKey_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: "${value.strip(',').strip()}"
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: extractKeyTpe
    - set_message_2:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key: '${key}'
        publish:
          - errorMessage: "${'Failed:  Key (' + key + ') not found in the provided json object. Verify the Input json Object with correct objects'}"
          - errorProvider: OOExec
          - errorSeverity: ERROR
          - errorType: e10000
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: FAILURE
    - get_newKey_from_SMAXCOnfig:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${smax_system_property_json}'
            - json_path: '${key}'
        publish:
          - newKey: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: Is_keyType_rich
          - FAILURE: set_message_2
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
          - errorProvider
        navigate:
          - SUCCESS: get_newKey_from_OOConfig
          - FAILURE: on_failure
    - createJirafieldType_json:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.createJirafieldType_json:
            - jirafieldkey: '${newKey}'
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
  outputs:
    - json_object_key_value_pair: '${json_key_value}'
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
      get_newKey_from_OOConfig:
        x: 486
        'y': 529
      set_message:
        x: 510
        'y': 52
        navigate:
          2444db65-076e-dfd2-2596-5db2f133b941:
            targetId: 87cee391-7d23-232d-0a5b-211fe2c389e8
            port: SUCCESS
      extractKeyTpe:
        x: 262
        'y': 534
      convertHTMLtoJIRAMarkup:
        x: 720
        'y': 240
      get_newKey_from_SMAXCOnfig:
        x: 665
        'y': 528
      extract_key_value:
        x: 66
        'y': 326
      Is_keyType_rich:
        x: 740
        'y': 408
      ValueofKey_isnull:
        x: 69
        'y': 523
      set_message_1:
        x: 509
        'y': 190
        navigate:
          52629812-b698-6a63-0e15-ebf9715a49d1:
            targetId: 87cee391-7d23-232d-0a5b-211fe2c389e8
            port: SUCCESS
      list_iterator_Key_value_list:
        x: 267
        'y': 329
      createJirafieldType_json:
        x: 501
        'y': 305
      set_message_2:
        x: 977
        'y': 520
        navigate:
          bb8fa6fb-7617-54da-760a-79d83eee60c5:
            targetId: 19db2882-8d2e-ad53-e472-98b77feb42f5
            port: FAILURE
          176a3224-7082-ea4c-26b6-b5883f7fbdab:
            targetId: 19db2882-8d2e-ad53-e472-98b77feb42f5
            port: SUCCESS
      key_value_isnull:
        x: 280
        'y': 40
    results:
      FAILURE:
        19db2882-8d2e-ad53-e472-98b77feb42f5:
          x: 979
          'y': 102
      SUCCESS:
        87cee391-7d23-232d-0a5b-211fe2c389e8:
          x: 800
          'y': 120
