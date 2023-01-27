namespace: Cerner.Integrations.SMAX
flow:
  name: UpdateSMAXRequestJiraIssueStatus
  workflow:
    - getJiraRequestsForStatusUpdate:
        do:
          Cerner.Integrations.SMAX.subFlows.getJiraRequestsForStatusUpdate: []
        publish:
          - entityJsonArray
          - jiraReqResultCount
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: string_equals
    - Array_Iterator:
        do_external:
          50efc8cb-f1e7-4123-984c-979039f22f2c:
            - array: '${entityJsonArray}'
        publish:
          - entityJSON: '${returnResult}'
        navigate:
          - has more: extractJiraStatus
          - no more: SUCCESS
          - failure: FAILURE
    - extractJiraStatus:
        do:
          Cerner.Integrations.Jira.subFlows.extractJiraStatus:
            - inputJSON: '${entityJSON}'
        publish:
          - jiraIssueStatus
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: updateSMAXRequestStatus
    - updateSMAXRequestStatus:
        do:
          Cerner.Integrations.SMAX.subFlows.updateSMAXRequestStatus:
            - jiraIssueStatus: '${jiraIssueStatus}'
            - inputJSON: '${entityJSON}'
        publish: []
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: Array_Iterator
    - string_equals:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${jiraReqResultCount}'
            - second_string: '0'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: Array_Iterator
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      getJiraRequestsForStatusUpdate:
        x: 120
        'y': 73
        navigate:
          12a8a614-8980-c30e-7095-5bc208672e37:
            targetId: 44cc71e0-1f9f-780d-42c1-c882584be35e
            port: FAILURE
      Array_Iterator:
        x: 345
        'y': 188
        navigate:
          99b8ac75-b3cf-e4df-e84d-767bf30f917b:
            targetId: 44cc71e0-1f9f-780d-42c1-c882584be35e
            port: failure
          de96b241-fc1f-81a3-3a8d-36e278d8200c:
            targetId: 47759877-1776-1a88-1d8b-f170213c7ae9
            port: no more
      extractJiraStatus:
        x: 342
        'y': 327
        navigate:
          eca21acf-6dea-c9dd-20fd-f59161af19ac:
            targetId: 44cc71e0-1f9f-780d-42c1-c882584be35e
            port: FAILURE
      updateSMAXRequestStatus:
        x: 566
        'y': 401
        navigate:
          5677d473-e904-b41b-20b4-a4898dc5bb07:
            targetId: 44cc71e0-1f9f-780d-42c1-c882584be35e
            port: FAILURE
      string_equals:
        x: 320
        'y': 22
        navigate:
          dbf7100d-e038-b21f-bbbe-e37d9d5eed1d:
            targetId: 47759877-1776-1a88-1d8b-f170213c7ae9
            port: SUCCESS
    results:
      FAILURE:
        44cc71e0-1f9f-780d-42c1-c882584be35e:
          x: 119
          'y': 415
      SUCCESS:
        47759877-1776-1a88-1d8b-f170213c7ae9:
          x: 577
          'y': 62
