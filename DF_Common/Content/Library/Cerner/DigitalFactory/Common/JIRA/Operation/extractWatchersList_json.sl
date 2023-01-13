namespace: Cerner.DigitalFactory.Common.JIRA.Operation
operation:
  name: extractWatchersList_json
  inputs:
    - watchers:
        required: false
    - reporter
    - watcherFieldId
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for Generating Watchers JSON object \r\n#   Author: Rakesh Sharma Cerner (rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       - watchers\r\n#       - reporter\r\n#       - watcherFieldId\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - errorType\r\n#       - errorSeverity\r\n#       - errorProvider\r\n#       - errorMessage\r\n#   Created On:27 Dec 2021\r\n#  -------------------------------------------------------------\r\n###############################################################\r\n\r\ndef execute(watchers, reporter, watcherFieldId):\r\n    result = \"False\"\r\n    followers = ''\r\n    errorType = ''\r\n    errorMessage = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n    watchers_json = ''\r\n\r\n    try:\r\n        if watchers.strip().lower() == 'nowatcher':\r\n            watchers_json = ''\r\n            result = 'True'\r\n            message = 'No Watcher json created as input for JIRA Project for watcher is disabled.'\r\n        elif len(watchers.strip()) > 0:\r\n            if watchers.find(\",\") == -1:\r\n                followers = '{\"name\":\"' + watchers[0:watchers.find('@')].strip() + '\"},{\"name\":\"' + reporter[\r\n                                                                                                    0:reporter.find(\r\n                                                                                                        '@')].strip() + '\"}'\r\n            else:\r\n                watchers = watchers[1:-1]\r\n                watchersList = watchers.split(',')\r\n                for watcher in watchersList:\r\n                    followers += '{\"name\":\"' + watcher[0:watcher.find('@')].strip() + '\"},'\r\n                followers = followers + '{\"name\":\"' + reporter[0:reporter.find('@')].strip() + '\"}'\r\n        else:\r\n            followers = '{\"name\":\"' + reporter[0:reporter.find('@')].strip() + '\"}'\r\n\r\n        if followers:\r\n            watchers_json = '\"' + watcherFieldId + '\":[' + followers + '],'\r\n            message = 'Watchers json object created successfully'\r\n            result = 'True'\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e30000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n\r\n    return {\"result\": result, \"message\": message, \"watchers_json\": watchers_json, \"errorType\": errorType,\r\n            \"errorSeverity\": errorSeverity,\"errorProvider\":errorProvider,\"errorMessage\": errorMessage}"
  outputs:
    - result
    - message
    - watchers_json
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
