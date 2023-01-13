namespace: Cerner.Integrations.SMAX.subFlows.debug
flow:
  name: execCommand
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
          - SUCCESS: download_file
    - download_file:
        worker_group: RAS_file_download
        do:
          io.cloudslang.base.cmd.run_command:
            - command: "${\"curl --location --request GET 'https://factory-dev.cerner.com/rest/336419949/ces/attachment/600e0b90-4ad4-4416-af7c-18386746b017' \\\n--header 'Cookie: SMAX_AUTH_TOKEN=\"+sso_token+\";TENANTID=336419949' \\\n--header 'Authorization: Basic b28tYnJpZGdlOk9PX0JyaWRnZV8x' \\\n--data-raw '' \\\n--output '/tmp/cernerlogo2.png' \"}"
        publish:
          - envOut: '${return_result}'
        navigate:
          - SUCCESS: validate_download
          - FAILURE: on_failure
    - validate_download:
        worker_group: RAS_file_download
        do:
          io.cloudslang.base.cmd.run_command:
            - command: ls -l /tmp
        publish:
          - localOut: '${return_result}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_sso_token:
        x: 84
        'y': 174
      download_file:
        x: 217
        'y': 103
      validate_download:
        x: 401
        'y': 165
        navigate:
          4d110625-0435-1402-f893-691e824d9d16:
            targetId: 9b09ee02-16b6-3995-8fce-2d9932c91881
            port: SUCCESS
    results:
      SUCCESS:
        9b09ee02-16b6-3995-8fce-2d9932c91881:
          x: 589
          'y': 133
