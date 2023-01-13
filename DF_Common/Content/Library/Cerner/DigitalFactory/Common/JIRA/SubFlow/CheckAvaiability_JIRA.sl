namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: CheckAvaiability_JIRA
  inputs:
    - jiraServiceUser: "${get_sp('MarketPlace.jiraUser')}"
    - jiraURL: "${get_sp('MarketPlace.jiraIssueURL')}"
  workflow:
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${''.join([get_sp('MarketPlace.jiraIssueURL'),'rest/api/2/user?username=',get_sp('MarketPlace.jiraUser')])}"
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
          - url
          - username
          - password
          - response_headers
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: string_equals_response_headers_is_null
    - set_Message:
        do:
          io.cloudslang.base.utils.do_nothing:
            - errorType: e20000
            - errorMessage: '${error_message.strip()}'
            - return_code: '${return_code}'
            - response_headers: '${response_headers}'
            - return_result: '${return_result}'
        publish:
          - errorType
          - errorMessage: "${'JIRA is unavailable: ' + response_headers + return_result}"
          - errorProvider: JIRA
          - errorSeverity: ERROR
          - return_code
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: on_failure
    - string_equals_response_headers_is_null:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${response_headers}'
            - ignore_case: 'true'
        navigate:
          - SUCCESS: set_response_headers
          - FAILURE: set_Message
    - set_response_headers:
        do:
          io.cloudslang.base.utils.do_nothing:
            - response_headers: '-NULL Headers-'
        publish:
          - response_headers
        navigate:
          - SUCCESS: set_Message
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
        x: 302
        'y': 38
        navigate:
          974bb58b-e946-d9fc-a1c8-cf584b5f5f47:
            targetId: 01a3706e-4d11-9ef8-56e3-c32209cc0a89
            port: SUCCESS
      set_Message:
        x: 300
        'y': 344
        navigate:
          e714a7ca-2df9-11d9-c58b-13897b0fc64a:
            targetId: bd84d2bf-bc05-cf8f-d573-bc81bbdbd13d
            port: SUCCESS
      string_equals_response_headers_is_null:
        x: 63
        'y': 164
      set_response_headers:
        x: 305
        'y': 167
    results:
      FAILURE:
        bd84d2bf-bc05-cf8f-d573-bc81bbdbd13d:
          x: 580
          'y': 351
      SUCCESS:
        01a3706e-4d11-9ef8-56e3-c32209cc0a89:
          x: 572
          'y': 43
