namespace: Cerner.DigitalFactory.Error_Notification.Test
flow:
  name: testErrorHandler
  workflow:
    - faultyOpp:
        do:
          Cerner.ErrorHandling.test.faultyOpp: []
        publish:
          - errorType
          - errorSeverity
          - message
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${message}'
                - errorSeverity: '${errorSeverity}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      faultyOpp:
        x: 185
        'y': 98.96875
        navigate:
          c5eda698-6231-5438-adbe-2488d9f561e8:
            targetId: f7f1fb3b-bc32-fd9c-69eb-63b41d0d84c1
            port: SUCCESS
    results:
      SUCCESS:
        f7f1fb3b-bc32-fd9c-69eb-63b41d0d84c1:
          x: 481
          'y': 103
