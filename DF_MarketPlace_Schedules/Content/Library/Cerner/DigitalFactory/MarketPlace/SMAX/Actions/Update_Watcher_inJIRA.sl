namespace: Cerner.DigitalFactory.MarketPlace.SMAX.Actions
flow:
  name: Update_Watcher_inJIRA
  inputs:
    - jiraticketID:
        required: true
    - watchersList:
        required: true
  workflow:
    - updateWatcherSMAXtoJIRA:
        do:
          Cerner.DigitalFactory.MarketPlace.SMAX.Operation.updateWatcherSMAXtoJIRA:
            - jiraticketID: '${jiraticketID}'
            - watchersList: '${watchersList}'
        publish:
          - result
          - message
          - errorMessage
          - errorType
          - errorSeverity
          - errorProvider
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
            publish: []
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      updateWatcherSMAXtoJIRA:
        x: 540
        'y': 118
        navigate:
          a7cfeee7-19a9-a29e-6c55-eaeac1170b06:
            targetId: e8041a93-d8bf-110a-6147-534d46ffe138
            port: SUCCESS
    results:
      SUCCESS:
        e8041a93-d8bf-110a-6147-534d46ffe138:
          x: 279
          'y': 160
