namespace: Cerner.DigitialFactory.DFMP.vRA_Management.vRA.SubFlows
flow:
  name: get_values_fm_OOSysProps
  inputs:
    - get_values_fm_OOSysProps
  workflow:
    - key_value_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${get_values_fm_OOSysProps}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: set_message
          - FAILURE: list_iterator_Key_value_list
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - message: 'get_values_fm_OOSysProps IS NULL, check again Property for correct Values'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - list_iterator_Key_value_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${get_values_fm_OOSysProps}'
            - separator: '||'
        publish:
          - key_value: '${result_string}'
          - return_result
          - return_code
          - key: '${result_string}'
        navigate:
          - HAS_MORE: extract_key_value
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - extract_key_value:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_value: '${key_value}'
        publish:
          - key: "${key_value.split(',',1)[0]}"
          - value: "${key_value.split(',',1)[1]}"
        navigate:
          - SUCCESS: If_Key_Project
          - FAILURE: on_failure
    - If_Key_Project:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: "${key.strip('_c')}"
            - second_string: Project
            - ignore_case: 'true'
            - Projects_json: "${get_sp('Cerner.DigitalFactory.DFMP.Projects')}"
        publish:
          - Projects_json
        navigate:
          - SUCCESS: get_id_forProjects
          - FAILURE: If_Key_CatalogItemID_OSType
    - get_id_forProjects:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${Projects_json}'
            - json_path: '${value}'
        publish:
          - projectid: '${return_result}'
          - errorMessage: '${error_message}'
          - return_result
          - return_code
          - error_message
          - project: '${json_path}'
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
    - If_Key_CatalogItemID_OSType:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: "${key.strip('_c')}"
            - second_string: OSType
            - ignore_case: 'true'
            - vRACatalog_json: "${get_sp('Cerner.DigitalFactory.DFMP.CatalogItems')}"
        publish:
          - vRACatalog_json
        navigate:
          - SUCCESS: get_catalogitemid
          - FAILURE: If_Key_Instance_Size
    - get_catalogitemid:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${vRACatalog_json}'
            - json_path: '${value}'
        publish:
          - vRACatalogItemId: '${return_result}'
          - errorMessage: '${error_message}'
          - vra_catalog: '${json_path}'
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
    - If_Key_Instance_Size:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: "${key.strip('_c')}"
            - second_string: InstanceSize
            - ignore_case: 'true'
            - InstanceSize_json: "${get_sp('Cerner.DigitalFactory.DFMP.InstanceSize')}"
        publish:
          - InstanceSize_json
        navigate:
          - SUCCESS: get_InstanceSize
          - FAILURE: on_failure
    - get_InstanceSize:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${InstanceSize_json}'
            - json_path: '${value}'
        publish:
          - flavor: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
  outputs:
    - projectid: '${projectid}'
    - vRACatalogItemId: '${vRACatalogItemId}'
    - flavor: '${flavor}'
    - message: '${message}'
    - project: '${project}'
    - vra_catalog: '${vra_catalog}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      get_id_forProjects:
        x: 405
        'y': 455
      If_Key_Instance_Size:
        x: 834.933349609375
        'y': 610.0833129882812
      set_message:
        x: 456
        'y': 104
        navigate:
          1ebcd3b2-3e84-7dd0-f7c0-367be3e896da:
            targetId: 938080c8-2cda-adb8-c188-3831485d0045
            port: SUCCESS
      extract_key_value:
        x: 282
        'y': 602
      If_Key_Project:
        x: 454
        'y': 617
      If_Key_CatalogItemID_OSType:
        x: 621
        'y': 616
      list_iterator_Key_value_list:
        x: 285
        'y': 293
        navigate:
          3c00081a-b721-0e12-c22e-2a0fd254e7c6:
            targetId: 938080c8-2cda-adb8-c188-3831485d0045
            port: NO_MORE
      get_catalogitemid:
        x: 623
        'y': 457
      get_InstanceSize:
        x: 849.933349609375
        'y': 436.0833435058594
      key_value_isnull:
        x: 281
        'y': 102
    results:
      SUCCESS:
        938080c8-2cda-adb8-c188-3831485d0045:
          x: 648
          'y': 178
