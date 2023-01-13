namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
flow:
  name: CheckAvaiability_JIRA_Dev
  inputs:
    - jiraServiceUser: "${get_sp('MarketPlace.jiraUser')}"
    - jiraURL: "${get_sp('MarketPlace.jiraIssueURL')}"
    - is_retry:
        required: false
    - smax_request_id_list:
        required: false
  workflow:
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: 'https://jira3dev.cerner.com/rest/api/2/user?username=svcMarketDev'
            - auth_type: Basic
            - username: "${get_sp('MarketPlace.jiraUser')}"
            - password:
                value: "${get_sp('MarketPlace.jiraPassword')}"
                sensitive: true
            - tls_version: TLSv1.2
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
            - content_type: application/json;charset=UTF-8
        publish:
          - return_code
          - error_message
          - return_result
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: set_Message
    - set_Message:
        do:
          io.cloudslang.base.utils.do_nothing:
            - errorType: e20000
            - errorMessage: '${error_message.strip()}'
            - return_code: '${return_code}'
        publish:
          - errorType
          - errorMessage: JIRA is unavailable
          - errorProvider: JIRA
          - errorSeverity: ERROR
          - return_code
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: on_failure
  outputs:
    - errorType: '${errorType}'
    - errorMessage: '${errorMessage}'
    - errorProvider: '${errorProvider}'
    - errorSeverity: '${errorSeverity}'
    - return_result: '${return_result}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      http_client_get:
        x: 320
        'y': 120
        navigate:
          aa0acc4a-6677-68d2-cc6b-d052ef014515:
            targetId: 8b03ba9c-f50e-e1b8-724a-0a7ec3497d89
            port: SUCCESS
      set_Message:
        x: 320
        'y': 280
        navigate:
          e714a7ca-2df9-11d9-c58b-13897b0fc64a:
            targetId: bd84d2bf-bc05-cf8f-d573-bc81bbdbd13d
            port: SUCCESS
    results:
      FAILURE:
        bd84d2bf-bc05-cf8f-d573-bc81bbdbd13d:
          x: 560
          'y': 280
      SUCCESS:
        8b03ba9c-f50e-e1b8-724a-0a7ec3497d89:
          x: 560
          'y': 120
