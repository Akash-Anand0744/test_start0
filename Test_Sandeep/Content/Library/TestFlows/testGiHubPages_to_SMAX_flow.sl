namespace: TestFlows
flow:
  name: testGiHubPages_to_SMAX_flow
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
          - errorProvider
          - errorType
        navigate:
          - SUCCESS: testGithubPages_to_SmaxKM
          - FAILURE: on_failure
    - testGithubPages_to_SmaxKM:
        do:
          TestFlows.testGithubPages_to_SmaxKM:
            - smax_token: '${token}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler: []
  outputs:
    - message: '${message}'
    - errorMessage: '${errorMessage}'
    - result: '${result}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_SMAXToken:
        x: 100
        'y': 150
      testGithubPages_to_SmaxKM:
        x: 400
        'y': 150
        navigate:
          85ab8d3e-8016-e2d5-f256-ded9dd5d2f95:
            targetId: fa7c205a-945a-75c5-6225-3713950f05aa
            port: SUCCESS
    results:
      SUCCESS:
        fa7c205a-945a-75c5-6225-3713950f05aa:
          x: 700
          'y': 150
