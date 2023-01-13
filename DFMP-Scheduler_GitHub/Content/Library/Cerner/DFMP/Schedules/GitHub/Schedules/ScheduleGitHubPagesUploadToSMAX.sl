namespace: Cerner.DFMP.Schedules.GitHub.Schedules
flow:
  name: ScheduleGitHubPagesUploadToSMAX
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
          - SUCCESS: GetGitHubPagesUploadToSMAX
          - FAILURE: on_failure
    - GetGitHubPagesUploadToSMAX:
        do:
          Cerner.DFMP.Schedules.GitHub.Operations.GetGitHubPagesUploadToSMAX:
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
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_SMAXToken:
        x: 100
        'y': 150
      GetGitHubPagesUploadToSMAX:
        x: 400
        'y': 150
        navigate:
          c600c408-a7c6-bee4-57e1-9f975d3d6e4f:
            targetId: 6c9118e1-e30b-010f-7408-9c6396510bdd
            port: SUCCESS
    results:
      SUCCESS:
        6c9118e1-e30b-010f-7408-9c6396510bdd:
          x: 700
          'y': 150
