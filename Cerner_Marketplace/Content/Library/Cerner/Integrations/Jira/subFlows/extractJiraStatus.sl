namespace: Cerner.Integrations.Jira.subFlows
flow:
  name: extractJiraStatus
  inputs:
    - inputJSON: '{"entity_type":"Request","properties":{"JiraIssueId_c":"4353715","LastUpdateTime":1625786506733,"Id":"16859"},"related_properties":{}}'
  workflow:
    - getJiraIssueId:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${inputJSON}'
            - json_path: $.properties.JiraIssueId_c
        publish:
          - jiraIssueId: "${return_result.strip('\"')}"
          - return_code
          - exception
        navigate:
          - SUCCESS: http_client_get
          - FAILURE: FAILURE
    - extract_Status:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${jiraStatusJSON}'
            - json_path: $.fields.status.name
        publish:
          - jiraIssueStatus: "${return_result.strip('\"')}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${get_sp('MarketPlace.jiraIssueURL')+'rest/api/2/issue/'+jiraIssueId}"
            - username: "${get_sp('MarketPlace.jiraUser')}"
            - password:
                value: "${get_sp('MarketPlace.jiraPassword')}"
                sensitive: true
            - query_params: fields=status
            - content_type: application/json
        publish:
          - jiraStatusJSON: '${return_result}'
        navigate:
          - SUCCESS: extract_Status
          - FAILURE: FAILURE
  outputs:
    - jiraIssueStatus: '${jiraIssueStatus}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      getJiraIssueId:
        x: 216
        'y': 136
        navigate:
          5d54b0c8-414d-3988-41c6-eeae8176b6a0:
            targetId: 134d949a-58c3-5cb4-02e2-60945f8ecb38
            port: FAILURE
      extract_Status:
        x: 643
        'y': 103
        navigate:
          22265778-75a5-d23b-b53b-a820b8337a26:
            targetId: c57cf0b1-a49b-88da-8117-01d088c41d82
            port: SUCCESS
          6dc49e94-f729-15bc-7493-653639f716af:
            targetId: 134d949a-58c3-5cb4-02e2-60945f8ecb38
            port: FAILURE
      http_client_get:
        x: 382
        'y': 105
        navigate:
          2a73109b-a389-276b-0436-439fbeca49dc:
            targetId: 134d949a-58c3-5cb4-02e2-60945f8ecb38
            port: FAILURE
    results:
      SUCCESS:
        c57cf0b1-a49b-88da-8117-01d088c41d82:
          x: 865
          'y': 99
      FAILURE:
        134d949a-58c3-5cb4-02e2-60945f8ecb38:
          x: 520
          'y': 327
