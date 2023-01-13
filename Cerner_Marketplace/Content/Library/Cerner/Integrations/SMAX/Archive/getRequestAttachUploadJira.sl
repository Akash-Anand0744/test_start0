namespace: Cerner.Integrations.SMAX.Archive
flow:
  name: getRequestAttachUploadJira
  inputs:
    - smaxRequestId
    - jiraIssueId
  workflow:
    - downloadAttachmentUploadToJira:
        do:
          Cerner.Integrations.SMAX.subFlows.downloadAttachmentUploadToJira:
            - smaxReqId: '${smaxRequestId}'
            - jiraIssueId: '${jiraIssueId}'
        publish:
          - result
          - message
          - errorCode
          - errorMessage
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - result: '${result}'
    - message: '${message}'
    - errorCode: '${errorCode}'
    - errorMessage: '${errorMessage}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      downloadAttachmentUploadToJira:
        x: 215
        'y': 222
        navigate:
          2e6515b3-8d64-64a7-c5c0-c802bde68cf8:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: SUCCESS
    results:
      SUCCESS:
        be7401b9-e6fd-9843-1f78-821bc7fe1e1e:
          x: 506
          'y': 218
