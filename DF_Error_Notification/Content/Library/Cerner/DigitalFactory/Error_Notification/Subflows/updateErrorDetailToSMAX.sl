namespace: Cerner.DigitalFactory.Error_Notification.Subflows
flow:
  name: updateErrorDetailToSMAX
  inputs:
    - OOErrorDetails:
        default: ''
        required: false
    - OOErrorSummary:
        default: ''
        required: false
    - smaxRequestID:
        default: ''
        required: false
  workflow:
    - updateErrorSmaxInputVerifier:
        do:
          Cerner.DigitalFactory.Error_Notification.Operations.updateErrorSmaxInputVerifier:
            - OOErrorDetails: '${OOErrorDetails}'
            - OOErrorSummary: '${OOErrorSummary}'
            - smaxRequestID: '${smaxRequestID}'
        publish:
          - http_json_str
          - message
          - result
        navigate:
          - SUCCESS: get_sso_token
          - FAILURE: SUCCESS
    - get_sso_token:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.get_sso_token:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - username: "${get_sp('MarketPlace.smaxIntgUser')}"
            - password:
                value: "${get_sp('MarketPlace.smaxIntgUserPass')}"
                sensitive: true
        publish:
          - sso_token
          - status_code
          - exception
        navigate:
          - FAILURE: SOFT_FAILURE
          - SUCCESS: update_entities
    - update_entities:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.update_entities:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - sso_token: '${sso_token}'
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - json_body: '${http_json_str}'
            - OOErrorDeatils: '${OOErrorDetails}'
            - OOErrorSummary: '${OOErrorSummary}'
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: SUCCESS
  results:
    - SUCCESS
    - SOFT_FAILURE
    - FAILURE
extensions:
  graph:
    steps:
      updateErrorSmaxInputVerifier:
        x: 43
        'y': 90
        navigate:
          6050f45c-ec85-34df-f7f6-acb0e8df721c:
            targetId: 602e300e-9d6a-9429-10c2-e3eaf7d940d8
            port: FAILURE
      get_sso_token:
        x: 200
        'y': 84
        navigate:
          5934d4f5-81f2-30d8-24c4-65c98e223c03:
            targetId: 9201bfc8-5e92-b60c-2552-1783c53b68ae
            port: FAILURE
      update_entities:
        x: 463
        'y': 90
        navigate:
          7d6a03c5-fdd2-0634-d9ae-c3c6ee40fa2c:
            targetId: 602e300e-9d6a-9429-10c2-e3eaf7d940d8
            port: SUCCESS
          45facbd7-30e9-518e-9c40-9e1a932c052f:
            targetId: 68a1acd1-acbe-c3af-e88a-abf7e086fb23
            port: FAILURE
    results:
      SUCCESS:
        602e300e-9d6a-9429-10c2-e3eaf7d940d8:
          x: 448
          'y': 301
      SOFT_FAILURE:
        9201bfc8-5e92-b60c-2552-1783c53b68ae:
          x: 322
          'y': 1
      FAILURE:
        68a1acd1-acbe-c3af-e88a-abf7e086fb23:
          x: 622
          'y': 87
