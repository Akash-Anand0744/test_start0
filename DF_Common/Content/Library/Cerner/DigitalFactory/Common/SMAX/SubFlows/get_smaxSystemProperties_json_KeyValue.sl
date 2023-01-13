namespace: Cerner.DigitalFactory.Common.SMAX.SubFlows
flow:
  name: get_smaxSystemProperties_json_KeyValue
  inputs:
    - smax_token:
        required: false
  workflow:
    - getAllSMAXSystemProperties:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.getAllSMAXSystemProperties:
            - smax_auth_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxAuthURL')}"
            - smax_user: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUser')}"
            - smax_password: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUserPass')}"
            - smax_tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
            - smax_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - smax_token: '${smax_token}'
        publish:
          - result
          - message
          - errorType
          - errorMessage: '${errormessage}'
          - key_value_json: ' '
          - errorProvider
          - config_json
          - errorLogs
        navigate:
          - SUCCESS: convert_smax_config_prop_to_jsonKeyValue
          - FAILURE: on_failure
    - convert_smax_config_prop_to_jsonKeyValue:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.convert_smax_config_prop_to_jsonKeyValue:
            - input_json: '${config_json}'
        publish:
          - key_value_json
          - message
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - smax_system_property_json: '${key_value_json}'
    - errorMessage: '${errorMessage}'
    - message: '${message}'
    - errorType: '${errorType}'
    - errorProvider: '${errorProvider}'
    - errorSeverity: Error
    - errorLogs: '${errorLogs}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      getAllSMAXSystemProperties:
        x: 263
        'y': 164
      convert_smax_config_prop_to_jsonKeyValue:
        x: 529
        'y': 163
        navigate:
          9907cf79-db52-d4e8-8bac-77a323bfdec1:
            targetId: 9a09cfa6-58cc-e052-e352-1ff41e59c61e
            port: SUCCESS
    results:
      SUCCESS:
        9a09cfa6-58cc-e052-e352-1ff41e59c61e:
          x: 710
          'y': 170
