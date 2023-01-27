namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: Create_Issue_in_Jira_Framework
  inputs:
    - httpClient_BodyInput
    - watcherFieldId:
        required: false
    - hide_jira_fields:
        default: ''
        required: false
    - reporter:
        required: false
    - watchers:
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
            - request_character_set: UTF-8
            - headers: null
            - body: "${cs_replace(cs_replace(httpClient_BodyInput, \"\\\\\\\\\\\\\", \"\\\\\"), \"\\\\\\\\n\", \"\\\\n\")}"
            - content_type: application/json; charset=UTF-8
        publish:
          - jiraIncidentCreationResult: '${return_result}'
          - return_code
          - response_headers
          - incidentHttpStatusCode: '${status_code}'
          - jiraInstanceIdJSON: '${error_message}'
          - errorMessage: '${error_message}'
        navigate:
          - SUCCESS: get_jira_url
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
          - jira_project: ''
          - jira_issue_key: ''
        navigate:
          - SUCCESS: getUserIdsToAddPermission
          - FAILURE: CheckAvaiability_JIRA
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing:
            - message: '${jiraErrorMessage}'
        publish:
          - errorType: e30000
          - errorMessage: '${message}'
          - errorProvider: JIRA
          - errorSeverity: ERROR
          - jira_issue_key: ''
          - jira_project: ''
        navigate:
          - SUCCESS: FAILURE
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
          - errorProvider: JIRA
          - errorMessage: '${return_result}'
          - errorType: e20000
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
          - HAS_MORE: check_if_field_exists_in_http_JIRA_CreateBody
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
    - get_jira_issueid_1:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: id
        publish:
          - jiraIssueId: '${return_result}'
          - errorMessage: '${error_message}'
          - return_code
        navigate:
          - SUCCESS: check_watcher_is_null
          - FAILURE: on_failure
    - get_jira_url:
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${jiraIncidentCreationResult}'
            - json_path: key
        publish:
          - jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')+'browse/'+return_result}"
          - errorMessage: '${error_message}'
          - return_result
          - return_code
          - jira_issue_key: '${return_result}'
          - jira_project: "${return_result.split('-')[0]}"
        navigate:
          - SUCCESS: get_jira_issueid_1
          - FAILURE: on_failure
    - CheckAvaiability_JIRA:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.CheckAvaiability_JIRA: []
        publish:
          - errorType
          - errorMessage
          - errorProvider
          - errorSeverity
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: set_message
    - set_errorMessage:
        do:
          io.cloudslang.base.utils.do_nothing:
            - message: '${jiraErrorMessage}'
            - errorMessage: '${errorMessage}'
        publish:
          - errorMessage: "${message +' : ADD USER PERMISSION IN JIRA ALSO FAILED: ' +  errorMessage}"
          - errorProvider: JIRA
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: on_failure
    - check_if_field_exists_in_http_JIRA_CreateBody:
        do:
          io.cloudslang.base.strings.string_occurrence_counter:
            - string_in_which_to_search: '${httpClient_BodyInput}'
            - string_to_find: '${jira_field}'
        publish:
          - return_result
          - return_code
          - error_message
        navigate:
          - SUCCESS: list_iterator_hide_fields
          - FAILURE: set_value_to_hide_fields
    - getUserIdsToAddPermission:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.getUserIdsToAddPermission:
            - jiraErrorMessage: '${jiraErrorMessage}'
            - watcherFieIdCustomId: '${watcherFieldId}'
        publish:
          - userIds
        navigate:
          - SUCCESS: addUserPermission_to_Jira
          - FAILURE: on_failure
    - addUserPermission_to_Jira:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.addUserPermission_to_Jira:
            - idsToAddPermission: '${userIds}'
        publish:
          - message
          - errorMessage
          - errorType
          - errorProvider
          - errorSeverity
          - firsRunDone: 'Yes'
        navigate:
          - FAILURE: set_errorMessage
          - SUCCESS: http_client_post
    - addUserPermission_to_Jira_1:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.addUserPermission_to_Jira:
            - idsToAddPermission: '${userIds}'
            - add_permissions: 'No'
        publish:
          - message
          - errorMessage
          - errorType
          - errorProvider
          - errorSeverity
          - firsRunDone: 'Yes'
        navigate:
          - FAILURE: check_hide_fields
          - SUCCESS: check_hide_fields
    - check_watcher_is_null:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${watchers}'
            - second_string: ''
        navigate:
          - SUCCESS: set_reporter_as_watcher
          - FAILURE: check_NoWatcher
    - PrepareUsernJIraidList_1:
        do:
          io.cloudslang.base.utils.do_nothing:
            - reporter: '${reporter}'
            - watchers: "${cs_replace(cs_replace(cs_replace(watchers,'[',''),']',''),'NoWatchers','')}"
            - upn_domain: "${get_sp('Cerner.DigitalFactory.cerner_upn_domain')}"
            - jira_id: '${jiraIssueId}'
        publish:
          - userIds: "${cs_replace(cs_to_lower(reporter),\"@\"+upn_domain,\"\") + \",\" + jira_id +\"||\"+cs_replace(cs_replace(cs_to_lower(watchers),\",\",\",\" + jira_id+'||'),\"@\"+upn_domain,\"\") + ','+jira_id + '||'}"
        navigate:
          - SUCCESS: addUserPermission_to_Jira_1
          - FAILURE: on_failure
    - set_reporter_as_watcher:
        do:
          io.cloudslang.base.utils.do_nothing:
            - reporter: '${reporter}'
        publish:
          - watchers: '${reporter}'
        navigate:
          - SUCCESS: PrepareUsernJIraidList_1
          - FAILURE: on_failure
    - check_NoWatcher:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${watchers}'
            - second_string: NoWatcher
            - ignore_case: 'true'
        navigate:
          - SUCCESS: set_reporter_as_watcher
          - FAILURE: PrepareUsernJIraidList_1
  outputs:
    - httpClient_Body
    - jiraIncidentCreationResult: '${jiraIncidentCreationResult}'
    - jiraIssueId: '${jiraIssueId}'
    - jiraIssueURL: '${jiraIssueURL}'
    - incidentHttpStatusCode: '${incidentHttpStatusCode}'
    - errorType: '${errorType}'
    - errorMessage: '${errorMessage}'
    - errorProvider: '${errorProvider}'
    - errorSeverity: '${errorSeverity}'
    - jiraIssueKey: '${jira_issue_key}'
    - jiraProject: '${jira_project}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      addUserPermission_to_Jira_1:
        x: 320
        'y': 40
      join_hide_fields:
        x: 40
        'y': 400
      check_watcher_is_null:
        x: 560
        'y': 280
      check_NoWatcher:
        x: 440
        'y': 280
      Loop:
        x: 1120
        'y': 40
      list_iterator_hide_fields:
        x: 320
        'y': 360
      get_jira_url:
        x: 560
        'y': 560
      CheckAvaiability_JIRA:
        x: 1000
        'y': 360
        navigate:
          49698992-3f7f-717f-7ce4-c1285c0a524e:
            targetId: f8528c76-39fe-7ea9-4666-871235ed3b84
            port: FAILURE
      set_message:
        x: 1000
        'y': 200
        navigate:
          0f749d30-c556-7f54-4bd9-0bc53f2aa3a9:
            targetId: f8528c76-39fe-7ea9-4666-871235ed3b84
            port: SUCCESS
      get_jira_issueid:
        x: 320
        'y': 200
      addUserPermission_to_Jira:
        x: 680
        'y': 280
      set_reporter_as_watcher:
        x: 560
        'y': 40
      set_httpclientbody_for_hide_fields:
        x: 40
        'y': 240
      PrepareUsernJIraidList_1:
        x: 440
        'y': 40
      http_client_put_to_hide_fileds_in_JIRA:
        x: 40
        'y': 80
        navigate:
          a03fd367-d84e-6d02-ee91-4c3c48d7d9d7:
            targetId: 5ff8c01f-1dd0-ca6f-c6d4-49ecf641607f
            port: SUCCESS
      string_occurrence_counter:
        x: 1120
        'y': 520
      set_errorMessage:
        x: 800
        'y': 360
        navigate:
          880fca72-39ed-6590-9032-ddbdeda010ba:
            targetId: f8528c76-39fe-7ea9-4666-871235ed3b84
            port: SUCCESS
      set_value_to_hide_fields:
        x: 40
        'y': 560
      http_client_post:
        x: 680
        'y': 40
      getUserIdsToAddPermission:
        x: 680
        'y': 520
      get_jira_issueid_1:
        x: 560
        'y': 400
      check_if_field_exists_in_http_JIRA_CreateBody:
        x: 320
        'y': 560
      check_hide_fields:
        x: 200
        'y': 80
        navigate:
          1d0131df-64eb-8b9d-9aba-ee9614987e09:
            targetId: 5ff8c01f-1dd0-ca6f-c6d4-49ecf641607f
            port: SUCCESS
    results:
      FAILURE:
        f8528c76-39fe-7ea9-4666-871235ed3b84:
          x: 800
          'y': 200
      SUCCESS:
        5ff8c01f-1dd0-ca6f-c6d4-49ecf641607f:
          x: 200
          'y': 200
