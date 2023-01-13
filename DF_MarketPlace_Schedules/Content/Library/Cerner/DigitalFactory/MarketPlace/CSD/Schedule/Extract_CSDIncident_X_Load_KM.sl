namespace: Cerner.DigitalFactory.MarketPlace.CSD.Schedule
flow:
  name: Extract_CSDIncident_X_Load_KM
  workflow:
    - Get_CSD_Incidents_Upload_to_KM:
        do:
          Cerner.DigitalFactory.MarketPlace.CSD.Operation.Get_CSD_Incidents_Upload_to_KM:
            - csd_authtoken: "${get_sp('Cerner.DigitalFactory.MarketPlace.CSDAuthToken')}"
            - csd_host: "${get_sp('Cerner.DigitalFactory.MarketPlace.CSDHost')}"
            - csd_port: "${get_sp('Cerner.DigitalFactory.MarketPlace.CSDPort')}"
            - smax_auth_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxAuthURL')}"
            - smax_user: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUser')}"
            - smax_password: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUserPass')}"
            - smax_tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
            - smax_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - csd_severity: "${get_sp('Cerner.DigitalFactory.MarketPlace.CSDSeverity')}"
        publish:
          - message
          - result
          - jresult
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
    - result: '${result}'
    - message: '${message}'
    - jresult: '${jresult}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Get_CSD_Incidents_Upload_to_KM:
        x: 235
        'y': 153
        navigate:
          5373289a-6f64-4b78-9f64-6fcf70bf2bc3:
            targetId: 8d73c523-806f-58aa-423a-8864b7fd60dc
            port: SUCCESS
    results:
      SUCCESS:
        8d73c523-806f-58aa-423a-8864b7fd60dc:
          x: 508
          'y': 91
