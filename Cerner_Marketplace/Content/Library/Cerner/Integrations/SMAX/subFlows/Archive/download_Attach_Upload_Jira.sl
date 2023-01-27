namespace: Cerner.Integrations.SMAX.subFlows.Archive
flow:
  name: download_Attach_Upload_Jira
  inputs:
    - smaxURL: "${get_sp('MarketPlace.smaxURL')}"
    - smaxTenantId: "${get_sp('MarketPlace.tenantID')}"
    - smaxAuthURL: "${get_sp('MarketPlace.smaxAuthURL')}"
    - smaxUser: "${get_sp('MarketPlace.smaxIntgUser')}"
    - smaxPass: "${get_sp('MarketPlace.smaxIntgUserPass')}"
    - idFileName
    - jiraIssueId
  workflow:
    - get_filename_attachid:
        do:
          io.cloudslang.base.utils.do_nothing:
            - input_0: '${idFileName}'
        publish:
          - attachId: "${input_0.split('||')[0]}"
          - fileName: "${input_0.split('||')[1]}"
        navigate:
          - SUCCESS: get_sso_token
          - FAILURE: on_failure
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
            - command: "${\"curl --location --request GET '\"+smaxURL+\"rest/\"+smaxTenantId+\"/ces/attachment/\"+attachId+\"' \\\n--header 'Cookie: SMAX_AUTH_TOKEN=\"+sso_token+\";TENANTID=\"+smaxTenantId+\"' \\\n--data-raw '' \\\n--output '/tmp/\"+fileName+\"' \"}"
        publish:
          - attachId: '${return_result}'
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
          - SUCCESS: uploadFileToJira
          - FAILURE: on_failure
    - uploadFileToJira:
        worker_group: RAS_file_download
        do:
          Cerner.Integrations.SMAX.subFlows.uploadFileToJira:
            - filepath: "${'/tmp/'+fileName}"
            - jiraIssueId: '${jiraIssueId}'
        navigate:
          - SUCCESS: run_command
          - FAILURE: on_failure
    - run_command:
        worker_group: RAS_file_download
        do:
          io.cloudslang.base.cmd.run_command:
            - command: "${'rm /tmp/'+fileName}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_filename_attachid:
        x: 57
        'y': 388
      get_sso_token:
        x: 53
        'y': 107
      download_file:
        x: 223
        'y': 107
      validate_download:
        x: 404
        'y': 105
      uploadFileToJira:
        x: 414
        'y': 367
      run_command:
        x: 590
        'y': 357
        navigate:
          6ab38f8c-8357-ba9d-628c-6341d2fe704d:
            targetId: 9b09ee02-16b6-3995-8fce-2d9932c91881
            port: SUCCESS
    results:
      SUCCESS:
        9b09ee02-16b6-3995-8fce-2d9932c91881:
          x: 589
          'y': 133
