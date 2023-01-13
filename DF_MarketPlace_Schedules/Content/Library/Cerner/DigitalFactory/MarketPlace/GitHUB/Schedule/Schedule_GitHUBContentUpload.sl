namespace: Cerner.DigitalFactory.MarketPlace.GitHUB.Schedule
flow:
  name: Schedule_GitHUBContentUpload
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
          - SUCCESS: ExtractGitHUBContentXLoadSMAX
          - FAILURE: on_failure
    - ExtractGitHUBContentXLoadSMAX:
        do:
          Cerner.DigitalFactory.MarketPlace.GitHUB.Operation.ExtractGitHUBContentXLoadSMAX:
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
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: "${get('errorMessage', message)}"
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
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
        x: 320
        'y': 80
      ExtractGitHUBContentXLoadSMAX:
        x: 640
        'y': 80
        navigate:
          4e6a082e-3dbe-b1a6-2125-473497e325b4:
            targetId: f167e603-bd47-bfff-1a6a-74e3ca464a53
            port: SUCCESS
    results:
      SUCCESS:
        f167e603-bd47-bfff-1a6a-74e3ca464a53:
          x: 920
          'y': 80
