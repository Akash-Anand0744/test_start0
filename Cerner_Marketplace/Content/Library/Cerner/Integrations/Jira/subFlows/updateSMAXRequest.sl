namespace: Cerner.Integrations.Jira.subFlows
flow:
  name: updateSMAXRequest
  inputs:
    - jiraIssueURL:
        required: true
    - jiraIssueId:
        required: true
    - smaxRequestID
  workflow:
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
          - errorMessage: '${exception}'
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: update_entities
    - update_entities:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.update_entities:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - sso_token: '${sso_token}'
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - json_body: "${'{\"entity_type\": \"Request\", \"properties\": { \"Id\": \"'+smaxRequestID+'\", \"JiraIncidentURL_c\": \"'+jiraIssueURL+'\", \"JiraIssueStatus_c\": \"Open\",\"RequestJiraIssueStatus_c\": \"Yes\", \"JiraIssueId_c\": \"'+jiraIssueId+'\"}, \"related_properties\" : { }  }'}"
        publish:
          - errorMessage: '${error_json}'
          - return_result
          - op_status
        navigate:
          - FAILURE: set_message
          - SUCCESS: SUCCESS
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing:
            - errorMessage: "${get('errorMessage', return_result)}"
        publish:
          - errorMessage
          - errorSeverity: ERROR
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: on_failure
  outputs:
    - errorMessage: '${errorMessage}'
    - return_result: '${return_result}'
    - errorSeverity: '${errorSeverity}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_sso_token:
        x: 202
        'y': 84
        navigate:
          c8030ed1-516c-1102-7c5c-5524609b3941:
            targetId: aa27e946-3123-f5a6-0822-7574205c9f86
            port: FAILURE
      update_entities:
        x: 440
        'y': 80
        navigate:
          7d6a03c5-fdd2-0634-d9ae-c3c6ee40fa2c:
            targetId: 602e300e-9d6a-9429-10c2-e3eaf7d940d8
            port: SUCCESS
      set_message:
        x: 440
        'y': 320
        navigate:
          17bec3a4-cfcf-c8e5-baab-26d09e0326e6:
            targetId: aa27e946-3123-f5a6-0822-7574205c9f86
            port: SUCCESS
    results:
      FAILURE:
        aa27e946-3123-f5a6-0822-7574205c9f86:
          x: 200
          'y': 320
      SUCCESS:
        602e300e-9d6a-9429-10c2-e3eaf7d940d8:
          x: 680
          'y': 80
