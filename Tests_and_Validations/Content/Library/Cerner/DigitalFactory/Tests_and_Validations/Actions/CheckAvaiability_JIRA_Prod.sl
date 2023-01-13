namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
flow:
  name: CheckAvaiability_JIRA_Prod
  inputs:
    - jiraServiceUser: "${get_sp('MarketPlace.jiraUser')}"
    - jiraURL: "${get_sp('MarketPlace.jiraIssueURL')}"
  workflow:
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: 'https://jira3.cerner.com/rest/api/2/user?username=svcMarketProd'
            - auth_type: Basic
            - username: svcMarketProd
            - password:
                value: dDd3NzhDTdnupXJd
                sensitive: true
            - tls_version: TLSv1.2
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
            - trust_keystore: ''
            - trust_password:
                sensitive: true
            - keystore: ''
            - content_type: application/json;charset=UTF-8
        publish:
          - return_code
          - error_message
          - return_result
          - url
          - username
          - password
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: availabilityCheck_Jira
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
    - availabilityCheck_Jira:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.availabilityCheck_Jira:
            - MarketPlace_jiraIssueURL: 'https://jira3.cerner.com/'
            - MarketPlace_jiraUser: svcMarketProd
            - MarketPlace_jiraPassword: dDd3NzhDTdnupXJd
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: set_Message
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
        x: 288
        'y': 33
        navigate:
          974bb58b-e946-d9fc-a1c8-cf584b5f5f47:
            targetId: 01a3706e-4d11-9ef8-56e3-c32209cc0a89
            port: SUCCESS
      set_Message:
        x: 290
        'y': 375
        navigate:
          e714a7ca-2df9-11d9-c58b-13897b0fc64a:
            targetId: bd84d2bf-bc05-cf8f-d573-bc81bbdbd13d
            port: SUCCESS
      availabilityCheck_Jira:
        x: 286
        'y': 198
        navigate:
          0f7cd669-f847-052a-0176-d36577eec54c:
            targetId: 01a3706e-4d11-9ef8-56e3-c32209cc0a89
            port: SUCCESS
    results:
      FAILURE:
        bd84d2bf-bc05-cf8f-d573-bc81bbdbd13d:
          x: 581
          'y': 367
      SUCCESS:
        01a3706e-4d11-9ef8-56e3-c32209cc0a89:
          x: 568
          'y': 32
