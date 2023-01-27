namespace: Cerner.Integrations.SMAX.subFlows
flow:
  name: getJiraRequestsForStatusUpdate
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
          - exception
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: query_entities
    - query_entities:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.query_entities:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - sso_token: '${sso_token}'
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - entity_type: Request
            - query: "RequestJiraIssueStatus_c = 'Yes'"
            - fields: 'Id,JiraIssueId_c'
        publish:
          - entityJsonArray: '${entity_json}'
          - return_result
          - error_json
          - jiraRequestResultCount: '${result_count}'
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: SUCCESS
          - NO_RESULTS: SUCCESS
  outputs:
    - entityJsonArray: '${entityJsonArray}'
    - jiraReqResultCount: '${jiraRequestResultCount}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_sso_token:
        x: 154
        'y': 137
        navigate:
          14aafa74-b1fe-b6f1-e962-159f8e3ac54f:
            targetId: 6eea84b5-ecc1-7f13-4f51-bedb5d568f21
            port: FAILURE
      query_entities:
        x: 393
        'y': 135
        navigate:
          54372c5e-38bc-2328-c0aa-d4ce2a208606:
            targetId: 6eea84b5-ecc1-7f13-4f51-bedb5d568f21
            port: FAILURE
          9f90d772-515c-347b-c2fb-2aae9b96c4fb:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: SUCCESS
          b52dde86-6954-48ca-fac1-fc2e21b888f7:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: NO_RESULTS
    results:
      FAILURE:
        6eea84b5-ecc1-7f13-4f51-bedb5d568f21:
          x: 402
          'y': 307
      SUCCESS:
        be7401b9-e6fd-9843-1f78-821bc7fe1e1e:
          x: 615
          'y': 247
