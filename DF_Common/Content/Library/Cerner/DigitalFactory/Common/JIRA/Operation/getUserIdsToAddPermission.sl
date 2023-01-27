namespace: Cerner.DigitalFactory.Common.JIRA.Operation
operation:
  name: getUserIdsToAddPermission
  inputs:
    - jiraErrorMessage:
        required: false
    - watcherFieIdCustomId:
        required: false
  python_action:
    use_jython: false
    script: "# main function\r\ndef execute(watcherFieIdCustomId,jiraErrorMessage):\r\n    import json\r\n    errorMessageJson={}\r\n    userPermissionError=\"\"\r\n    userIds=\"\"\r\n    result=\"True\"\r\n    \r\n    errorMessageJson = json.loads(jiraErrorMessage)\r\n    userPermissionError = str(errorMessageJson[\"errors\"][watcherFieIdCustomId]).split(\": \")\r\n    #userIds = userPermissionError[1].replace(\", \",\",\")\r\n    userIds = userPermissionError[1].replace(\", \",\",||\")\r\n    if \",||\" not in userIds:\r\n        userIds += \",||\"\r\n    \r\n    return {\"userIds\": userIds,\"result\":result}"
  outputs:
    - userIds
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
