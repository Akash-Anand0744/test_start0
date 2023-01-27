########################################################################################################################
#!!
#! @input idsToAddPermission: format "userId,jiraIssueid||UserId,jiraIssueid||" The userId Associate id
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: addUserPermission_to_Jira
  inputs:
    - idsToAddPermission
    - add_permissions: 'Yes'
    - previous_errorLogs:
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
          - errorType
          - errorProvider
          - errorLogs
        navigate:
          - SUCCESS: getUserIdsGroupsToAddPermission
          - FAILURE: on_failure
    - getUserIdsGroupsToAddPermission:
        do:
          Cerner.DigitalFactory.Common.SMAX.Operation.getUserIdsGroupsToAddPermission:
            - userIds: '${idsToAddPermission}'
            - smax_token: '${smax_token}'
            - previous_errorLogs: '${previous_errorLogs}'
        publish:
          - user_group_list: '${user_group}'
          - result
          - message
          - errorType
          - errorProvider
          - errorMessage
          - errorSeverity
          - errorLogs
        navigate:
          - SUCCESS: addUserPermissions_Jira
          - FAILURE: on_failure
    - addUserPermissions_Jira:
        do:
          Cerner.DigitalFactory.Common.JIRA.Operation.addUserPermissions_Jira:
            - user_group_list: '${user_group_list}'
            - add_permissions: '${add_permissions}'
        publish:
          - result
          - message
          - errorSeverity
          - errorType
          - errorProvider
          - errorMessage
          - firstRunDone: 'Yes'
          - errorLogs
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - message: '${message}'
    - errorMessage: '${errorMessage}'
    - errorType: '${errorType}'
    - errorProvider: '${errorProvider}'
    - errorSeverity: '${errorSeverity}'
    - errorLogs: '${errorLogs}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_SMAXToken:
        x: 200
        'y': 120
      getUserIdsGroupsToAddPermission:
        x: 360
        'y': 320
      addUserPermissions_Jira:
        x: 520
        'y': 120
        navigate:
          9160cadf-505d-fade-36f7-f6390afe889c:
            targetId: 676a314f-38e0-368d-d2be-688175acb39e
            port: SUCCESS
    results:
      SUCCESS:
        676a314f-38e0-368d-d2be-688175acb39e:
          x: 720
          'y': 160
