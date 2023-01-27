namespace: Cerner.Integrations.SMAX.subFlows.Archive
flow:
  name: getAttachmentsForRequest
  inputs:
    - smaxRequestId
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
          - FAILURE: on_failure
          - SUCCESS: query_entities
    - get_attachment:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: 'https://factory-dev.cerner.com/rest/336419949/ces/attachment/cf3244fa-a35a-49f3-a4a1-a5577035e77e'
            - username: "${get_sp('MarketPlace.smaxIntgUser')}"
            - password:
                value: "${get_sp('MarketPlace.smaxIntgUserPass')}"
                sensitive: true
            - headers: "${'Cookie: SMAX_AUTH_TOKEN='+sso_token+';TENANTID='+get_sp('MarketPlace.tenantID')}"
            - content_type: application/json
        publish:
          - outFileBinary: '${return_result}'
          - error_message
          - return_code
          - status_code
        navigate:
          - SUCCESS: write_to_file
          - FAILURE: on_failure
    - query_entities:
        do:
          io.cloudslang.microfocus.service_management_automation_x.commons.query_entities:
            - saw_url: "${get_sp('MarketPlace.smaxURL')}"
            - sso_token: '${sso_token}'
            - tenant_id: "${get_sp('MarketPlace.tenantID')}"
            - entity_type: Request
            - query: "${\"Id='\"+smaxRequestId+\"'\"}"
            - fields: 'DisplayLabel,RequestAttachments'
        publish:
          - entityJsonArray: "${cs_replace(cs_replace(cs_replace(cs_json_query(entity_json,'$..properties.RequestAttachments'),'[\"','',1),'\"]','',1),'\\\\','')}"
          - return_result
          - error_json
          - jiraRequestResultCount: '${result_count}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_attachment
          - NO_RESULTS: SUCCESS
    - write_to_file:
        do:
          io.cloudslang.base.filesystem.write_to_file:
            - file_path: /tmp/itsma-vltid__itom-oo-336419949-5fb99d89d9-bbk8w.zip
            - text: '${outFileBinary}'
            - encode_type: UTF-8
        navigate:
          - SUCCESS: uploadFile
          - FAILURE: on_failure
    - uploadFile:
        do:
          Cerner.Integrations.SMAX.subFlows.uploadFile: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - entityJsonArray: '${entityJsonArray}'
    - jiraReqResultCount: '${jiraRequestResultCount}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      get_sso_token:
        x: 79
        'y': 143
      get_attachment:
        x: 282
        'y': 147
      query_entities:
        x: 80
        'y': 354
        navigate:
          bda183ed-3b69-fbc2-5674-6ccd90d600e5:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: NO_RESULTS
      write_to_file:
        x: 473
        'y': 109
      uploadFile:
        x: 642
        'y': 94
        navigate:
          742a8bc6-f4f3-6d24-0f42-a7ac6c9a9a7a:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: SUCCESS
    results:
      SUCCESS:
        be7401b9-e6fd-9843-1f78-821bc7fe1e1e:
          x: 645
          'y': 355
