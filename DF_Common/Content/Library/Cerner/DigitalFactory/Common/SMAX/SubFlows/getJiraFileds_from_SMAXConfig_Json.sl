namespace: Cerner.DigitalFactory.Common.SMAX.SubFlows
flow:
  name: getJiraFileds_from_SMAXConfig_Json
  inputs:
    - smax_property_config_json
  workflow:
    - key_value_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_property_config_json}'
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: set_message
          - FAILURE: get_watcherFieldId
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - message: 'SMAX Property Config Json IS NULL, check again the Configurations and mapping'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - get_watcherFieldId:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${smax_property_config_json}'
            - json_path: watcherFieldId
        publish:
          - watcherFieldId: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_jiraSmaxIdFieldId
          - FAILURE: set_message_1
    - set_message_1:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - message: Cannot  extarct Watcher or SmaxID JIRA Field. Check teh COnfiguration Again
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: on_failure
    - get_jiraSmaxIdFieldId:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${smax_property_config_json}'
            - json_path: jiraSmaxIDField
        publish:
          - jiraSmaxIDField: '${return_result}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: set_message_1
  outputs:
    - jiraSmaxIDField: '${jiraSmaxIDField}'
    - watcherFieldId: '${watcherFieldId}'
    - message: '${message}'
    - errorMessage: '${errorMessage}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      key_value_isnull:
        x: 176
        'y': 93
      set_message:
        x: 390
        'y': 98
        navigate:
          7cead8c4-401b-7090-77d8-74f9b774f6a9:
            targetId: ed7e33b6-1d1c-0592-b4e6-d2452f750923
            port: SUCCESS
      get_watcherFieldId:
        x: 176
        'y': 420
      set_message_1:
        x: 395
        'y': 267
        navigate:
          01fbf1f5-9f39-d604-49fe-514b40a09aaf:
            targetId: b96f4810-f887-5566-9e4a-6a074f6c217c
            port: SUCCESS
      get_jiraSmaxIdFieldId:
        x: 388
        'y': 428
        navigate:
          a772529e-ab63-cf52-8d74-79376ea13b8a:
            targetId: ed7e33b6-1d1c-0592-b4e6-d2452f750923
            port: SUCCESS
    results:
      FAILURE:
        b96f4810-f887-5566-9e4a-6a074f6c217c:
          x: 622
          'y': 270
      SUCCESS:
        ed7e33b6-1d1c-0592-b4e6-d2452f750923:
          x: 796
          'y': 290
