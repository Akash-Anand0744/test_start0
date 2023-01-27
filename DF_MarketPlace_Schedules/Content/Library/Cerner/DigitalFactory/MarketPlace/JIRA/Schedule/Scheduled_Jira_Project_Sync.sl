namespace: Cerner.DigitalFactory.MarketPlace.JIRA.Schedule
flow:
  name: Scheduled_Jira_Project_Sync
  workflow:
    - JiraProjectSync:
        do:
          Cerner.DigitalFactory.MarketPlace.JIRA.Operation.JiraProjectSync: []
        publish:
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
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      JiraProjectSync:
        x: 321
        'y': 297
        navigate:
          db6d182b-446a-838f-9daf-27fca97cce34:
            targetId: d65c8b83-206c-81f5-20a8-4bce357a25c1
            port: SUCCESS
    results:
      SUCCESS:
        d65c8b83-206c-81f5-20a8-4bce357a25c1:
          x: 587
          'y': 299
