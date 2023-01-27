namespace: Cerner.ErrorHandling.test
flow:
  name: testErrorHandler
  workflow:
    - faultyOpp01:
        do:
          Cerner.ErrorHandling.test.faultyOpp01: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.ErrorHandling.actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${message}'
                - errorSeverity: '${errorSeverity}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      faultyOpp01:
        x: 227
        'y': 106
        navigate:
          1439b8f4-790c-b765-21d4-a3b6cb976d04:
            targetId: f7f1fb3b-bc32-fd9c-69eb-63b41d0d84c1
            port: SUCCESS
    results:
      SUCCESS:
        f7f1fb3b-bc32-fd9c-69eb-63b41d0d84c1:
          x: 481
          'y': 103
