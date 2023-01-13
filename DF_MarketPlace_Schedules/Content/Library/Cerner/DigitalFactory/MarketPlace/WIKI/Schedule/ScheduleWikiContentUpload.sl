namespace: Cerner.DigitalFactory.MarketPlace.WIKI.Schedule
flow:
  name: ScheduleWikiContentUpload
  workflow:
    - ExtractWikiContentXLoadSMAX:
        do:
          Cerner.DigitalFactory.MarketPlace.WIKI.Operation.ExtractWikiContentXLoadSMAX: []
        publish:
          - message
          - errorType
          - errorSeverity
          - result
          - jresult
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${message}'
                - errorProvider: OO
                - errorSeverity: '${errorSeverity}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      ExtractWikiContentXLoadSMAX:
        x: 202.03700256347656
        'y': 152.05091857910156
        navigate:
          04793d24-63db-c901-8b70-9a7e7d42094e:
            targetId: 2f6bae06-d0a7-42e2-4ea6-f07af3c67b9f
            port: SUCCESS
    results:
      SUCCESS:
        2f6bae06-d0a7-42e2-4ea6-f07af3c67b9f:
          x: 489
          'y': 32
