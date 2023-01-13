namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: Create_Issue_in_Jira
  inputs:
    - httpClient_BodyInput
    - watcherFieldId:
        required: false
    - hide_jira_fields:
        default: ''
        required: false
  workflow:
    - http_client_post:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: "${get_sp('MarketPlace.jiraIssueURL')+'rest/api/2/issue'}"
            - auth_type: Basic
            - username: "${get_sp('MarketPlace.jiraUser')}"
            - password:
                value: "${get_sp('MarketPlace.jiraPassword')}"
                sensitive: true
            - tls_version: TLSv1.2
            - body: '${httpClient_BodyInput}'
            - content_type: application/json
        publish:
          - jiraIncidentCreationResult: '${return_result}'
          - return_code
          - response_headers
          - incidentHttpStatusCode: '${status_code}'
          - jiraInstanceIdJSON: '${error_message}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: check_hide_fields
          - FAILURE: Loop
    - Loop:
        do_external:
          1f0d93cd-2692-4339-81d7-9b3c6de46029:
            - count: '1'
            - to: '1'
        navigate:
          - has more: string_occurrence_counter
          - no more: set_message
          - failure: set_message
    - string_occurrence_counter:
        do:
          io.cloudslang.base.strings.string_occurrence_counter:
            - string_in_which_to_search: '${jiraIncidentCreationResult}'
            - string_to_find: 'Users do not have permission to view this issue:'
        publish:
          - jiraErrorMessage: '${string_in_which_to_search}'
        navigate:
          - SUCCESS: addUserPermissions_Jira
          - FAILURE: set_message
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing:
            - message: '${jiraErrorMessage}'
        publish:
          - errorType: e30000
          - errorMessage: '${message}'
          - errorProvider: JIRA
          - errorSeverity: ERROR
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: on_failure
    - addUserPermissions_Jira:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.addUserPermissions_Jira:
            - jiraFailureHTTPcode: '${incidentHttpStatusCode}'
            - jiraFailureMessage: '${jiraErrorMessage}'
            - watcherFileId: '${watcherFieldId}'
        publish:
          - result
          - message
          - errorSeverity
          - errorType
          - errorProvider
          - errorMessage
        navigate:
          - SUCCESS: http_client_post
          - FAILURE: on_failure
    - http_client_put_to_hide_fileds_in_JIRA:
        do:
          io.cloudslang.base.http.http_client_put:
            - url: "${get_sp('MarketPlace.jiraIssueURL')+'rest/api/2/issue/'+jiraIssueId}"
            - auth_type: Basic
            - username: "${get_sp('MarketPlace.jiraUser')}"
            - password:
                value: "${get_sp('MarketPlace.jiraPassword')}"
                sensitive: true
            - tls_version: TLSv1.2
            - body: "${'{\"fields\": {'+httpclientbody_hide_fields + '} }'}"
            - content_type: application/json
        publish:
          - jira_field_key_list: '${return_result}'
          - error_message
          - return_code
          - status_code
          - response_headers
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - check_hide_fields:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${hide_jira_fields}'
            - second_string: ''
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: get_jira_issueid
    - get_jira_issueid:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: id
        publish:
          - jiraIssueId: '${return_result}'
          - errorMessage: '${error_message}'
          - httpclientbody_hide_fields: ' '
        navigate:
          - SUCCESS: list_iterator_hide_fields
          - FAILURE: on_failure
    - set_value_to_hide_fields:
        do:
          io.cloudslang.base.utils.do_nothing:
            - jira_field: '${jira_field}'
        publish:
          - jira_hide_field_key_value: "${'\"' + jira_field + '\":' + 'null'}"
        navigate:
          - SUCCESS: join_hide_fields
          - FAILURE: on_failure
    - list_iterator_hide_fields:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${hide_jira_fields}'
        publish:
          - result_string
          - return_result
          - return_code
          - jira_field: '${result_string}'
        navigate:
          - HAS_MORE: set_value_to_hide_fields
          - NO_MORE: set_httpclientbody_for_hide_fields
          - FAILURE: on_failure
    - set_httpclientbody_for_hide_fields:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpclientbody_hide_fields: '${httpclientbody_hide_fields}'
        publish:
          - httpclientbody_hide_fields: '${httpclientbody_hide_fields[:-1]}'
        navigate:
          - SUCCESS: http_client_put_to_hide_fileds_in_JIRA
          - FAILURE: on_failure
    - join_hide_fields:
        do:
          io.cloudslang.base.strings.append:
            - origin_string: '${httpclientbody_hide_fields}'
            - text: '${jira_hide_field_key_value + ","}'
        publish:
          - httpclientbody_hide_fields: '${new_string}'
        navigate:
          - SUCCESS: list_iterator_hide_fields
  outputs:
    - httpClient_Body
    - errorType: '${errorType}'
    - errorMessage: '${errorMessage}'
    - errorProvider: '${errorProvider}'
    - errorSeverity: '${errorSeverity}'
    - jiraIncidentCreationResult: '${jiraIncidentCreationResult}'
    - incidentHttpStatusCode: '${incidentHttpStatusCode}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      join_hide_fields:
        x: 84
        'y': 366
      Loop:
        x: 1098
        'y': 25
      list_iterator_hide_fields:
        x: 454
        'y': 374
      set_message:
        x: 864
        'y': 94
        navigate:
          0f749d30-c556-7f54-4bd9-0bc53f2aa3a9:
            targetId: f8528c76-39fe-7ea9-4666-871235ed3b84
            port: SUCCESS
      get_jira_issueid:
        x: 439
        'y': 197
      set_httpclientbody_for_hide_fields:
        x: 65
        'y': 227
      addUserPermissions_Jira:
        x: 609
        'y': 329
      http_client_put_to_hide_fileds_in_JIRA:
        x: 61
        'y': 53
        navigate:
          a03fd367-d84e-6d02-ee91-4c3c48d7d9d7:
            targetId: 5ff8c01f-1dd0-ca6f-c6d4-49ecf641607f
            port: SUCCESS
      string_occurrence_counter:
        x: 1098
        'y': 332
      set_value_to_hide_fields:
        x: 277
        'y': 461
      http_client_post:
        x: 610
        'y': 28
      check_hide_fields:
        x: 424
        'y': 27
        navigate:
          1d0131df-64eb-8b9d-9aba-ee9614987e09:
            targetId: 5ff8c01f-1dd0-ca6f-c6d4-49ecf641607f
            port: SUCCESS
    results:
      FAILURE:
        f8528c76-39fe-7ea9-4666-871235ed3b84:
          x: 675
          'y': 136
      SUCCESS:
        5ff8c01f-1dd0-ca6f-c6d4-49ecf641607f:
          x: 255
          'y': 59
