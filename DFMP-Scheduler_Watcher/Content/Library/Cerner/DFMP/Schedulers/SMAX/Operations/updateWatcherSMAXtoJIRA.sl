namespace: Cerner.DFMP.Schedulers.SMAX.Operations
operation:
  name: updateWatcherSMAXtoJIRA
  inputs:
    - MarketPlace_jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')}"
    - MarketPlace_jiraUser: "${get_sp('MarketPlace.jiraUser')}"
    - MarketPlace_jiraPassword: "${get_sp('MarketPlace.jiraPassword')}"
    - jiraticketID:
        required: true
    - watchersList:
        required: true
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for sync of Jira and Smax\r\n#   Author: Ashwini Shalke (ashwini.shalke@cerner.com), MicroFocus International\r\n#   Inputs:\r\n#       -  MarketPlace_jiraIssueURL\r\n#       -  MarketPlace_jiraUser\r\n#       -  MarketPlace_jiraPassword\r\n#       -  watchersList\r\n#       -  jiraticketID\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - errorType\r\n#       - errorMessage\r\n#       - errorProvider\r\n#       - errorSeverity\r\n###############################################################\r\n\r\ndef execute(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword, jiraticketID,\r\n                       watchersList):\r\n    \r\n    watchersErrorMessage = \"\"\r\n    watcherErrorType = \"\"\r\n    watcherErrorProvider = \"\"\r\n    watchersErrorSeverity = \"\"\r\n    watchersErrorResult = \"\"\r\n                           \r\n    wList = watchersList.strip('[').strip(']').split(\",\")\r\n\r\n    for watcher in wList:\r\n        watchersResult = updateWatcherinJIRA(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword,jiraticketID,\r\n                                         watcher)\r\n                                         \r\n        if watchersResult[\"errorMessage\"]:\r\n            watcherErrorType =  watchersResult[\"errorType\"] + \" \"\r\n            watchersErrorMessage += watchersResult[\"errorMessage\"] + \" \"\r\n            watcherErrorProvider = watchersResult[\"errorProvider\"] + \" \"\r\n            watchersErrorSeverity = watchersResult[\"errorSeverity\"] + \" \"\r\n            watchersErrorResult = watchersResult[\"result\"]\r\n        \r\n    return {\"result\": watchersResult[\"result\"], \"message\": watchersResult[\"message\"],\"errorType\": watcherErrorType,\"errorSeverity\": watchersErrorSeverity, \"errorProvider\": watcherErrorProvider, \"errorMessage\": watchersErrorMessage}\r\n\r\n\r\n\r\ndef updateWatcherinJIRA(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword,jiraticketID,watcher):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    errorType = ''\r\n    errorMessage = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        data = watcher[0:watcher.find('@')].strip()\r\n        watcherData = json.dumps(data)\r\n\r\n        reqUrl = '{0}rest/api/2/issue/{1}/watchers'.format(MarketPlace_jiraIssueURL, jiraticketID)\r\n        basicAuthCredentials = requests.auth.HTTPBasicAuth(MarketPlace_jiraUser, MarketPlace_jiraPassword)\r\n        headers = {'X-Atlassian-Token': 'no-check', 'Content-Type': 'application/json'}\r\n        response = requests.post(reqUrl, auth=basicAuthCredentials, headers=headers, data=watcherData)\r\n        message = response.status_code\r\n        print(response.status_code)\r\n\r\n        if response.status_code == 204:\r\n            message = \"Watchers added - \" +watcherData\r\n            result = \"True\"\r\n\r\n        else:\r\n            message = \"Watchers not updated in JIRA - \" +watcherData\r\n            result = \"False\"\r\n            errorType = \"e20000\"\r\n            errorMessage = message\r\n            errorSeverity = \"ERROR\"\r\n            errorProvider = \"JIRA\"\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"JIRA\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType,\r\n        \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage}"
  outputs:
    - result
    - message
    - errorMessage
    - errorType
    - errorSeverity
    - errorProvider
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
