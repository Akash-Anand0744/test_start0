########################################################################################################################
#!!
#! @input jira_subtask_issuetype: its ID of jira subtask IssueType and default is '5'
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: Create_jiraIssue_subTasks
  inputs:
    - jira_project
    - jira_issue_key
    - jira_issue_subtasks
    - jira_subtask_issuetype: '5'
  workflow:
    - jira_substaks_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${jira_issue_subtasks}'
            - second_string: ''
            - ignore_case: 'true'
        publish:
          - httpClient_BodyInput: ''
        navigate:
          - SUCCESS: set_message_1
          - FAILURE: list_iterator_Key_value_list
    - http_client_post:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: "${get_sp('MarketPlace.jiraIssueURL')+'rest/api/2/issue/bulk'}"
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
          - errorProvider: JIRA
          - errorType: e20000
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - list_iterator_Key_value_list:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${jira_issue_subtasks}'
            - separator: '||'
        publish:
          - result_string
          - return_result
          - return_code
          - key_value: '${result_string}'
        navigate:
          - HAS_MORE: extract_key_value
          - NO_MORE: finalise_subtask_http_body
          - FAILURE: on_failure
    - set_message_1:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - message: Provided jira issue subtasks list is empty
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - extract_key_value:
        do:
          io.cloudslang.base.utils.do_nothing:
            - key_value: '${key_value}'
        publish:
          - subtask: "${key_value.split(',',1)[0].strip()}"
          - subtask_description: "${key_value.split(',',1)[1].strip()}"
        navigate:
          - SUCCESS: subtask_isnull
          - FAILURE: on_failure
    - subtask_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: "${subtask.strip(',').strip()}"
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: subtask_descri_isnull
    - subtask_descri_isnull:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: "${subtask_description.strip(',').strip()}"
            - second_string: ''
            - ignore_case: 'true'
        publish: []
        navigate:
          - SUCCESS: set_sub_task_description
          - FAILURE: create_subtask_http_body
    - create_subtask_http_body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_BodyInput: '${httpClient_BodyInput}'
            - new_body: "${'{\"fields\": { \"project\": { \"key\": \"'+ jira_project + '\" }, \"parent\": { \"key\": \"' + jira_issue_key + '\" }, \"summary\": \"' + subtask + '\", \"description\": \"' + subtask_description + '\", \"issuetype\": { \"id\": \"'+ jira_subtask_issuetype + '\" } } },'}"
        publish:
          - httpClient_BodyInput: '${httpClient_BodyInput + new_body}'
        navigate:
          - SUCCESS: list_iterator_Key_value_list
          - FAILURE: on_failure
    - finalise_subtask_http_body:
        do:
          io.cloudslang.base.utils.do_nothing:
            - httpClient_BodyInput: "${'{\"issueUpdates\": [' + httpClient_BodyInput[:-1] + ']}'}"
        publish:
          - httpClient_BodyInput
        navigate:
          - SUCCESS: http_client_post
          - FAILURE: on_failure
    - set_sub_task_description:
        do:
          io.cloudslang.base.utils.do_nothing:
            - subtask_description: '${subtask}'
        publish:
          - subtask_description
        navigate:
          - SUCCESS: create_subtask_http_body
          - FAILURE: on_failure
  outputs:
    - jiraIncidentCreationResult: '${jiraIncidentCreationResult}'
    - incidentHttpStatusCode: '${incidentHttpStatusCode}'
    - errorType: '${errorType}'
    - errorMessage: '${errorMessage}'
    - errorProvider: '${errorProvider}'
    - errorSeverity: '${errorSeverity}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      finalise_subtask_http_body:
        x: 360
        'y': 280
      subtask_isnull:
        x: 200
        'y': 520
      subtask_descri_isnull:
        x: 320
        'y': 520
      extract_key_value:
        x: 40
        'y': 520
      jira_substaks_isnull:
        x: 160
        'y': 80
      set_message_1:
        x: 520
        'y': 120
        navigate:
          c82fbb1a-eb98-4bbe-04d8-d066e6e40efd:
            targetId: b90b3009-9fe7-3b73-ff8a-97d818cfaeee
            port: SUCCESS
      create_subtask_http_body:
        x: 520
        'y': 440
      list_iterator_Key_value_list:
        x: 160
        'y': 280
      http_client_post:
        x: 520
        'y': 280
        navigate:
          a88ef57c-0219-b27a-fb00-8a44d83be7b1:
            targetId: b90b3009-9fe7-3b73-ff8a-97d818cfaeee
            port: SUCCESS
      set_sub_task_description:
        x: 520
        'y': 600
    results:
      SUCCESS:
        b90b3009-9fe7-3b73-ff8a-97d818cfaeee:
          x: 800
          'y': 160
