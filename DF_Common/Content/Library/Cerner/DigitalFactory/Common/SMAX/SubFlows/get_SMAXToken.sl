namespace: Cerner.DigitalFactory.Common.SMAX.SubFlows
flow:
  name: get_SMAXToken
  workflow:
    - get_SMAXToken:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.get_SMAXToken: []
        publish:
          - result
          - token
          - message
          - errorMessage
          - errorSeverity
          - errorProvder
          - errorType
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_SMAXToken:
        x: 376.9333190917969
        'y': 180.1999969482422
        navigate:
          b196f627-7ed5-ed01-c4a6-5c5632e792ac:
            targetId: acc39314-b9bf-4603-3464-8c005821fcbc
            port: SUCCESS
    results:
      SUCCESS:
        acc39314-b9bf-4603-3464-8c005821fcbc:
          x: 606.066650390625
          'y': 156.4666748046875
