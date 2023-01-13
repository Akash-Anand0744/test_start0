namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
flow:
  name: Test_Attachments
  inputs:
    - conn_timeout: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
  workflow:
    - get_SMAXToken:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.get_SMAXToken: []
        publish:
          - result
          - smax_token: '${token}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: getOOLastruntime
          - FAILURE: on_failure
    - Test_attachmentsFromJIRAtoSMAX:
        do:
          Cerner.DigitalFactory.Tests_and_Validations.Actions.Test_attachmentsFromJIRAtoSMAX:
            - lastUpdate: '${cst_date[:16]}'
            - smax_FieldID: '${jiraSmaxIDField}'
            - smax_authToken: '${smax_token}'
        publish:
          - result
          - message
          - errorType: '${errorType}'
          - errorSeverity: '${errorSeverity}'
          - errorProvider: '${errorProvider}'
          - errorMessage: '${errorMessage}'
        navigate:
          - SUCCESS: Test_attachmentsFromSMAXtoJIRA
          - FAILURE: on_failure
    - getJiraFileds_from_SMAXConfig_Json:
        do:
          Cerner.DigitalFactory.Common.SMAX.SubFlows.getJiraFileds_from_SMAXConfig_Json:
            - smax_property_config_json: '${smax_system_property_json}'
        publish:
          - jiraSmaxIDField
          - message
          - errorMessage: '${errorMessage}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: Test_attachmentsFromJIRAtoSMAX
    - getOOLastruntime:
        do:
          Cerner.DigitalFactory.Common.OO.getOOLastruntime:
            - oo_run_name: Test_Attachments
        publish:
          - last_run_time
          - result
          - message
          - errorType
          - errorMessage
          - errorProvider
        navigate:
          - SUCCESS: getUnixToCST_timestamp
          - FAILURE: on_failure
    - get_smaxSystemProperties_json_KeyValue:
        do:
          Cerner.DigitalFactory.Common.SMAX.SubFlows.get_smaxSystemProperties_json_KeyValue: []
        publish:
          - smax_system_property_json
          - errorMessage
          - message
          - errorType
          - errorProvider: SMAX
        navigate:
          - FAILURE: on_failure
          - SUCCESS: getJiraFileds_from_SMAXConfig_Json
    - getUnixToCST_timestamp:
        do:
          Cerner.DigitalFactory.Common.Utility.getUnixToCST_timestamp:
            - dt: '${last_run_time}'
        publish:
          - result
          - message
          - cst_date
          - errorType
          - errorMessage
        navigate:
          - SUCCESS: get_smaxSystemProperties_json_KeyValue
          - FAILURE: on_failure
    - Test_attachmentsFromSMAXtoJIRA:
        do:
          Cerner.DigitalFactory.Tests_and_Validations.Actions.Test_attachmentsFromSMAXtoJIRA:
            - lastUpdate: '${last_run_time}'
            - smax_FieldID: '${jiraSmaxIDField}'
            - smax_authToken: '${smax_token}'
        publish:
          - result
          - message
          - errorType
          - errorMessage
          - errorSeverity
          - errorProvider
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvder}'
                - errorSeverity: '${errorSeverity}'
  outputs:
    - result
    - message
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_SMAXToken:
        x: 160
        'y': 360
      Test_attachmentsFromJIRAtoSMAX:
        x: 760
        'y': 40
      getJiraFileds_from_SMAXConfig_Json:
        x: 600
        'y': 40
      getOOLastruntime:
        x: 160
        'y': 160
      get_smaxSystemProperties_json_KeyValue:
        x: 440
        'y': 40
      getUnixToCST_timestamp:
        x: 280
        'y': 40
      Test_attachmentsFromSMAXtoJIRA:
        x: 960
        'y': 40
        navigate:
          e32cd7c4-9d1f-0d81-5a20-cbec2b311eb8:
            targetId: 191eb07f-eab4-e1e4-21be-a502961602c7
            port: SUCCESS
    results:
      SUCCESS:
        191eb07f-eab4-e1e4-21be-a502961602c7:
          x: 960
          'y': 360
