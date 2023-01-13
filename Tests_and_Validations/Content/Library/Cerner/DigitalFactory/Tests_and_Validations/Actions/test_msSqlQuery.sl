namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
flow:
  name: test_msSqlQuery
  workflow:
    - msSqlQuery:
        do:
          Cerner.DigitalFactory.Common.DB.Operation.msSqlQuery:
            - database: RTMaster
            - sqlQuery: 'SELECT ip_asset_id as id, ip_solution as title, ip_solution as description, update_dt_tm as update_date FROM MAP_IP_SOLUTION'
        publish:
          - result
          - output_json
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - message
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      msSqlQuery:
        x: 260
        'y': 60
        navigate:
          e5a921a3-81f7-987f-c7be-ec992270a185:
            targetId: 48a216e1-607a-a166-bf27-09135f67ce07
            port: SUCCESS
    results:
      SUCCESS:
        48a216e1-607a-a166-bf27-09135f67ce07:
          x: 520
          'y': 320
