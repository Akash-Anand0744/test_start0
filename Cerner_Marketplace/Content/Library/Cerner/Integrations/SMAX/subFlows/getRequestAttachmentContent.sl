namespace: Cerner.Integrations.SMAX.subFlows
flow:
  name: getRequestAttachmentContent
  inputs:
    - attachmentId
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
          - SUCCESS: get_attachment
    - get_attachment:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${get_sp('MarketPlace.smaxURL')+\"rest/\"+get_sp('MarketPlace.tenantID')+\"/ces/attachment/\"+attachmentId}"
            - username: "${get_sp('MarketPlace.smaxIntgUser')}"
            - password:
                value: "${get_sp('MarketPlace.smaxIntgUserPass')}"
                sensitive: true
            - headers: "${'Cookie: SMAX_AUTH_TOKEN='+sso_token+';TENANTID='+get_sp('MarketPlace.tenantID')}"
            - content_type: image/png
        publish: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      get_sso_token:
        x: 77
        'y': 142
      get_attachment:
        x: 282
        'y': 149
        navigate:
          04266b1e-0d74-7e92-4e48-e4d6b474fc05:
            targetId: be7401b9-e6fd-9843-1f78-821bc7fe1e1e
            port: SUCCESS
    results:
      SUCCESS:
        be7401b9-e6fd-9843-1f78-821bc7fe1e1e:
          x: 632
          'y': 274
