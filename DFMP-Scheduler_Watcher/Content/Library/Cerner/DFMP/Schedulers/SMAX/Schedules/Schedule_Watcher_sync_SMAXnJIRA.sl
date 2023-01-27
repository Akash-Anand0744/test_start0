########################################################################################################################
#!!
#! @description: This scheduler will add watchers from SMAX to JIRA and viceversa.
#!                
#!               Inputs :- 
#!               conn_timeout
#!               smax_request_id_list
#!               error_log_id
#!               is_retry
#!                
#!               Output :-
#!               result
#!               message
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedulers.SMAX.Schedules
flow:
  name: Schedule_Watcher_sync_SMAXnJIRA
  inputs:
    - conn_timeout: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
    - smax_request_id_list:
        required: false
    - is_retry:
        required: false
    - error_log_id:
        required: false
  workflow:
    - get_SMAXToken:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.get_SMAXToken: []
        publish:
          - result
          - smax_token: '${token}'
          - message
          - errorMessage
          - errorSeverity
          - errorProvider
          - errorType
          - errorLogs
        navigate:
          - SUCCESS: check_smax_request_id_list
          - FAILURE: on_failure
    - msSqlQuery:
        do:
          Cerner.DigitalFactory.Common.DB.Operation.msSqlQuery:
            - sqlQuery: '${sqlCommand}'
            - previous_errorLogs: '${errorLogs}'
        publish:
          - result
          - message
          - output_json
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - errorLogs
        navigate:
          - SUCCESS: checkIfAnyUpdatedJira
          - FAILURE: on_failure
    - checkIfAnyUpdateIssue:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smaxAndJiraIDs}'
        publish:
          - firstRunDone: ''
        navigate:
          - SUCCESS: frameSqlCommandForWatchers
          - FAILURE: postWatchersFromSmaxToJira
    - checkIfAnyUpdateWatcherIds:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${watcherPersonIdList}'
        navigate:
          - SUCCESS: checkAny_Error_logs
          - FAILURE: postWatchersFromJiraToSmax
    - checkIfAnyUpdatedJira:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${output_json}'
        navigate:
          - SUCCESS: checkAny_Error_logs
          - FAILURE: getPersonIdOfWatchersForSmaxRequests
    - checkIfAnyIdsRequirePermission:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${idsToAddPermission}'
            - second_string: ''
        publish: []
        navigate:
          - SUCCESS: frameSqlCommandForWatchers
          - FAILURE: AllowOneRun
    - AllowOneRun:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${firstRunDone}'
            - idsToAddPermission: '${idsToAddPermission}'
        publish:
          - errorMessage: "${'Add User Permission in JIRA failed for the ' + idsToAddPermission}"
          - errorType: '1000'
          - errorProvider: JIRA
          - idsToAddPermission
        navigate:
          - SUCCESS: addUserPermission_to_Jira
          - FAILURE: frameSqlCommandForWatchers
    - addUserPermission_to_Jira:
        do:
          Cerner.DigitalFactory.Common.JIRA.SubFlow.addUserPermission_to_Jira:
            - idsToAddPermission: '${idsToAddPermission}'
            - previous_errorLogs: ''
        publish:
          - message
          - errorMessage
          - errorType
          - errorProvider
          - errorSeverity
          - firstRunDone: 'Yes'
          - errorLogs
        navigate:
          - FAILURE: postWatchersFromSmaxToJira
          - SUCCESS: postWatchersFromSmaxToJira
    - getUpdatedWatchersRequestIds:
        do:
          Cerner.DFMP.Schedulers.SMAX.Operations.getUpdatedWatchersRequestIds:
            - lastUpdate: '${last_run_time}'
            - smax_authToken: '${smax_token}'
            - smax_request_id_list: '${smax_request_id_list}'
        publish:
          - result
          - message
          - smaxAndJiraIDs
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - newUpdateTime
          - errorLogs
        navigate:
          - SUCCESS: checkIfAnyUpdateIssue
          - FAILURE: on_failure
    - postWatchersFromSmaxToJira:
        do:
          Cerner.DFMP.Schedulers.SMAX.Operations.postWatchersFromSmaxToJira:
            - smaxAndJiraIDs: '${smaxAndJiraIDs}'
            - previous_errorLogs: '${errorLogs}'
            - smax_authToken: '${smax_token}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - newWatcherAndJiraIDs
          - jiraWatchersList
          - existingWatcherAndJiraIDs
          - idsDoesnotExistInJira
          - idsToAddPermission
          - idsAddedToJiraList
          - errorLogs
        navigate:
          - SUCCESS: checkIfAnyIdsRequirePermission
          - FAILURE: on_failure
    - getPersonIdOfWatchersForSmaxRequests:
        do:
          Cerner.DFMP.Schedulers.SMAX.Operations.getPersonIdOfWatchersForSmaxRequests:
            - sqlOutputArray: '${output_json}'
            - previous_errorLogs: '${errorLogs}'
            - smax_authToken: '${smax_token}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - existingWatcherList
          - watcherPersonIdList
          - errorLogs
          - newWatcherIdList
          - watcherMissingInSmax
        navigate:
          - SUCCESS: checkIfAnyUpdateWatcherIds
          - FAILURE: on_failure
    - postWatchersFromJiraToSmax:
        do:
          Cerner.DFMP.Schedulers.JIRA.Operations.postWatchersFromJiraToSmax:
            - watcherPersonIdList: '${watcherPersonIdList}'
            - previous_errorLogs: '${errorLogs}'
            - smax_authToken: '${smax_token}'
        publish:
          - result
          - message
          - errorType
          - errorSeverity
          - errorProvider
          - errorMessage
          - errorLogs
        navigate:
          - SUCCESS: checkAny_Error_logs
          - FAILURE: on_failure
    - getOOLastruntime:
        do:
          Cerner.DigitalFactory.Common.OO.getOOLastruntime:
            - oo_run_name: Schedule_Watcher_sync_SMAXnJIRA
        publish:
          - last_run_time
          - result
          - message
          - errorType
          - errorMessage
          - errorProvider
          - errorLogs
        navigate:
          - SUCCESS: getUpdatedWatchersRequestIds
          - FAILURE: on_failure
    - LogErrors_to_ErrorLogTracker:
        do:
          Cerner.DFMP.Error_Framework.SubFlows.LogErrors_to_ErrorLogTracker:
            - error_logs: '${errorLogs}'
            - smax_auth_token: '${smax_token}'
            - is_retry: '${is_retry}'
            - error_log_id: '${error_log_id}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - checkAny_Error_logs:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${errorLogs}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: LogErrors_to_ErrorLogTracker
    - check_smax_request_id_list:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${smax_request_id_list}'
        publish:
          - cst_date: ''
          - last_run_time: ''
        navigate:
          - SUCCESS: getOOLastruntime
          - FAILURE: getUpdatedWatchersRequestIds
    - frameSqlCommandForWatchers:
        do:
          Cerner.DFMP.Schedulers.JIRA.Operations.frameSqlCommandForWatchers:
            - lastUpdate: '${last_run_time}'
            - smax_request_id_list: '${smax_request_id_list}'
        publish:
          - sqlCommand
          - result
          - errorType
          - errorSeverity
          - errorMessage
        navigate:
          - SUCCESS: msSqlQuery
          - FAILURE: on_failure
    - on_failure:
        - MainErrorHandler:
            do:
              Cerner.DigitalFactory.Error_Notification.Actions.MainErrorHandler:
                - errorType: '${errorType}'
                - errorMessage: '${errorMessage}'
                - errorProvider: '${errorProvider}'
                - errorSeverity: '${errorSeverity}'
                - errorLogs: '${errorLogs}'
                - isRetry: '${is_retry}'
  outputs:
    - result
    - message
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      msSqlQuery:
        x: 760
        'y': 40
      checkAny_Error_logs:
        x: 920
        'y': 240
        navigate:
          b7b6bebf-320c-e721-7975-0af573a4edb2:
            targetId: 43bd3677-7de4-49d3-0bb4-48a8f267615f
            port: SUCCESS
      checkIfAnyUpdatedJira:
        x: 920
        'y': 40
      checkIfAnyIdsRequirePermission:
        x: 520
        'y': 240
      getUpdatedWatchersRequestIds:
        x: 240
        'y': 40
      LogErrors_to_ErrorLogTracker:
        x: 880
        'y': 440
        navigate:
          16af828b-a8dc-5946-d203-f398fb7852da:
            targetId: 43bd3677-7de4-49d3-0bb4-48a8f267615f
            port: SUCCESS
      checkIfAnyUpdateIssue:
        x: 400
        'y': 40
      getPersonIdOfWatchersForSmaxRequests:
        x: 1080
        'y': 40
      checkIfAnyUpdateWatcherIds:
        x: 1280
        'y': 40
      getOOLastruntime:
        x: 240
        'y': 320
      addUserPermission_to_Jira:
        x: 400
        'y': 440
      AllowOneRun:
        x: 640
        'y': 440
      frameSqlCommandForWatchers:
        x: 640
        'y': 40
      postWatchersFromJiraToSmax:
        x: 1200
        'y': 240
      check_smax_request_id_list:
        x: 80
        'y': 320
      postWatchersFromSmaxToJira:
        x: 400
        'y': 240
      get_SMAXToken:
        x: 80
        'y': 120
    results:
      SUCCESS:
        43bd3677-7de4-49d3-0bb4-48a8f267615f:
          x: 760
          'y': 240
