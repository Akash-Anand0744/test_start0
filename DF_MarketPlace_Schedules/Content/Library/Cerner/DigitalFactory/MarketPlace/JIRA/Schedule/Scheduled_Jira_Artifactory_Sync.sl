namespace: Cerner.DigitalFactory.MarketPlace.JIRA.Schedule
flow:
  name: Scheduled_Jira_Artifactory_Sync
  workflow:
    - JiraArtifactorySync:
        do:
          Cerner.DigitalFactory.MarketPlace.JIRA.Operation.JiraArtifactorySync: []
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
      JiraArtifactorySync:
        x: 291
        'y': 312
        navigate:
          af467004-1d5d-f8bf-b9ad-24825816092b:
            targetId: d65c8b83-206c-81f5-20a8-4bce357a25c1
            port: SUCCESS
    results:
      SUCCESS:
        d65c8b83-206c-81f5-20a8-4bce357a25c1:
          x: 587
          'y': 299
