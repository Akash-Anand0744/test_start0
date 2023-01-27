namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: Updated_getRequestAttachUploadJira
  inputs:
    - smaxRequestId
    - jiraIssueId
    - smax_FieldID
  workflow:
    - Updated_downloadAttachmentUploadToJira:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.Updated_downloadAttachmentUploadToJira:
            - smaxReqId: '${smaxRequestId}'
            - jiraIssueId: '${jiraIssueId}'
            - smax_FieldID: '${smax_FieldID}'
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
      Updated_downloadAttachmentUploadToJira:
        x: 240
        'y': 120
        navigate:
          bb950b99-dbe7-e2df-0f2e-02b9197419a4:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: SUCCESS
          4b9e8599-cdea-1787-1c35-c59ace39b191:
            targetId: d283f673-93d2-15d2-b7fc-e095e6470d88
            port: FAILURE
    results:
      SUCCESS:
        be7401b9-e6fd-9843-1f78-821bc7fe1e1e:
          x: 491
          'y': 128
      FAILURE:
        d283f673-93d2-15d2-b7fc-e095e6470d88:
          x: 240
          'y': 360
