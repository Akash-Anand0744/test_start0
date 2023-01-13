namespace: Integrations.Cerner.DigitalFactory.DummyFlows
flow:
  name: Test_DND_API_Calls
  workflow:
    - Get_User_Identifier:
        do_external:
          f1c8b14a-694f-4a03-a84a-c7504fe0a29b: []
        publish:
          - userIdentifier
          - document
        navigate:
          - success: Get_DND_API_URI_and_Creds
          - failure: on_failure
    - Get_DND_API_URI_and_Creds:
        do_external:
          faaab960-0309-4178-85d1-606f04d18db4: []
        publish:
          - password
          - username
          - tenant
          - url
        navigate:
          - success: http_client_get
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${'https://factory-dev.cerner.com/336419949/dnd/api/service/instance/e4c089a67e34d359017e93489f206e73/topology/e4c089a67e34d359017e937ac6c04ac5/propertyTree?userIdentifier=' + userIdentifier}"
            - auth_type: basic
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        publish:
          - return_result
          - error_message
          - response_headers
          - status_code
          - return_code
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Get_User_Identifier:
        x: 177
        'y': 42
      http_client_get:
        x: 529
        'y': 283
        navigate:
          8e679b13-77c1-0d23-4ae0-95cee5d15118:
            targetId: be78263a-ea3d-af80-a4ed-b20408d8a0e4
            port: SUCCESS
      Get_DND_API_URI_and_Creds:
        x: 177
        'y': 284
    results:
      SUCCESS:
        be78263a-ea3d-af80-a4ed-b20408d8a0e4:
          x: 777
          'y': 280
