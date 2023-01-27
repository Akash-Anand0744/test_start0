namespace: Cerner.DigitalFactory.MarketPlace.CSD.Schedule
flow:
  name: Extract_CSDEvents_X_Load_KM
  workflow:
    - Get_CSD_Events_Upload_to_KM:
        do:
          Cerner.DigitalFactory.MarketPlace.CSD.Operation.Get_CSD_Events_Upload_to_KM:
            - csd_authtoken: "${get_sp('Cerner.DigitalFactory.MarketPlace.CSDAuthToken')}"
            - csd_host: "${get_sp('Cerner.DigitalFactory.MarketPlace.CSDHost')}"
            - csd_port: "${get_sp('Cerner.DigitalFactory.MarketPlace.CSDPort')}"
            - smax_auth_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxAuthURL')}"
            - smax_user: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUser')}"
            - smax_password: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUserPass')}"
            - smax_tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
            - smax_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - past_days: '120'
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
  outputs:
    - result
    - message
    - jresult
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Get_CSD_Events_Upload_to_KM:
        x: 270
        'y': 131
        navigate:
          a0d5fc0c-208b-13ea-404a-7e9a44029461:
            targetId: 8d73c523-806f-58aa-423a-8864b7fd60dc
            port: SUCCESS
    results:
      SUCCESS:
        8d73c523-806f-58aa-423a-8864b7fd60dc:
          x: 508
          'y': 91
