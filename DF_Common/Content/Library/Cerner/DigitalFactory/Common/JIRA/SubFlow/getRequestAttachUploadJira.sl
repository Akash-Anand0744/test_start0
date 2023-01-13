namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: getRequestAttachUploadJira
  inputs:
    - smaxRequestId
    - jiraIssueId
  workflow:
    - downloadAttachmentUploadToJira:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.downloadAttachmentUploadToJira:
            - smaxURL: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
            - smaxTenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
            - smaxAuthURL: "${get_sp('Cerner.DigitalFactory.SMAX.smaxAuthURL')}"
            - smaxUser: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUser')}"
            - smaxPass: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUserPass')}"
            - smaxReqId: '${smaxRequestId}'
            - jiraIssueId: '${jiraIssueId}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  outputs:
    - result: '${result}'
    - message: '${message}'
    - errorType: '${errorType}'
    - errorSeverity: '${errorSeverity}'
    - errorProvider: '${errorProvider}'
    - errorMessage: '${errorMessage}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      downloadAttachmentUploadToJira:
        x: 211
        'y': 121
        navigate:
          658846df-8923-7995-935e-f64366d7e559:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: SUCCESS
          250afc9d-7643-b37c-4028-44f82fd32dd9:
            targetId: d283f673-93d2-15d2-b7fc-e095e6470d88
            port: FAILURE
    results:
      SUCCESS:
        be7401b9-e6fd-9843-1f78-821bc7fe1e1e:
          x: 491
          'y': 128
      FAILURE:
        d283f673-93d2-15d2-b7fc-e095e6470d88:
          x: 204
          'y': 343
