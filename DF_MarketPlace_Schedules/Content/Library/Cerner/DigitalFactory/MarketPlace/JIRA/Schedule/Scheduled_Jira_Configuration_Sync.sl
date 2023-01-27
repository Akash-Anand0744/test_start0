namespace: Cerner.DigitalFactory.MarketPlace.JIRA.Schedule
flow:
  name: Scheduled_Jira_Configuration_Sync
  workflow:
    - JiraConfAppSync:
        do:
          Cerner.DigitalFactory.MarketPlace.JIRA.Operation.JiraConfAppSync: []
        publish:
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
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      JiraConfAppSync:
        x: 350
        'y': 300
        navigate:
          cd4b2355-614d-8c76-6579-7ba3e4a4bda7:
            targetId: d65c8b83-206c-81f5-20a8-4bce357a25c1
            port: SUCCESS
    results:
      SUCCESS:
        d65c8b83-206c-81f5-20a8-4bce357a25c1:
          x: 587
          'y': 299
