namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: fields_append_toDescription
  inputs:
    - description: ''
    - fields_append_toDescription:
        default: ''
        required: false
  workflow:
    - check_fields_toDescription_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${fields_append_toDescription}'
            - second_string: ''
            - ignore_case: 'true'
            - description: '${description}'
        publish:
          - newDescription: '${description}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: list_iterator
    - list_iterator:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${fields_append_toDescription}'
            - separator: '||'
        publish:
          - result_string
          - return_result
          - return_code
          - key_value: '${result_string}'
        navigate:
          - HAS_MORE: extract_key_value
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - extract_key_value:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_value: '${key_value}'
        publish:
          - key: "${key_value.split(',',1)[0].strip()}"
          - value: "${key_value.split(',',1)[1].strip()}"
        navigate:
          - SUCCESS: Value_isnull
          - FAILURE: on_failure
    - append_key_value_toDescription:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key: '${key}'
            - value: '${value}'
            - newDescription: '${newDescription}'
        publish:
          - newDescription: "${newDescription + '\\n<strong>' + key + '</strong> : ' + value}"
        navigate:
          - SUCCESS: list_iterator
          - FAILURE: on_failure
    - Value_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${value}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: list_iterator
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
          - errorProvider
        navigate:
          - SUCCESS: append_key_value_toDescription
          - FAILURE: on_failure
  outputs:
    - newDescription: '${newDescription}'
    - errorType: '${errorType}'
    - errorMessage: '${errorMessage}'
    - errorProvider: '${errorProvider}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      check_fields_toDescription_isnull:
        x: 398
        'y': 98
        navigate:
          b4206209-360e-d00d-88c3-fa523ec29db4:
            targetId: 2e5892a0-d1de-cee5-a1c0-809941c8f551
            port: SUCCESS
      list_iterator:
        x: 398
        'y': 334
        navigate:
          8dcaefc8-0acc-3336-9144-583ce3b5fbc9:
            targetId: 2e5892a0-d1de-cee5-a1c0-809941c8f551
            port: NO_MORE
      extract_key_value:
        x: 396
        'y': 507
      append_key_value_toDescription:
        x: 716
        'y': 339
      Value_isnull:
        x: 721
        'y': 524
      extractKeyTpe:
        x: 892.933349609375
        'y': 458.0833435058594
    results:
      SUCCESS:
        2e5892a0-d1de-cee5-a1c0-809941c8f551:
          x: 704
          'y': 99
