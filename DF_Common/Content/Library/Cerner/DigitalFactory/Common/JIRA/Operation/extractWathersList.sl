namespace: Cerner.DigitalFactory.Common.JIRA.Operation
operation:
  name: extractWathersList
  inputs:
    - watchers:
        required: false
    - reporter
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for converting html tage to wiki tag\r\n#   Author: Rajesh Singh Micro Focus (rajesh.singh5@microsoft.com)\r\n#   Inputs:\r\n#       - watchers\r\n#       - reporter\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - errorType\r\n#       - errorSeverity\r\n#       - errorProvider\r\n#       - errorMessage\r\n#   Created On: 22 Sep 2021\r\n#  -------------------------------------------------------------\r\n#   Modified On\t: 06 Oct 2021\r\n#   Modified By\t: Ashwini Shalke\r\n#   Modification: added 4 outputs for error handling\r\n        \r\n###############################################################\r\n\r\ndef execute(watchers, reporter):\r\n    followers = ''\r\n    errorType = ''\r\n    errorMessage = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n    \r\n    try:\r\n        if len(watchers.strip()) > 0:\r\n            if watchers.find(\",\") == -1:\r\n                followers = '{\"name\":\"'+watchers[0:watchers.find('@')].strip()+'\"},{\"name\":\"'+reporter[0:reporter.find('@')].strip()+'\"}'\r\n            else:\r\n                watchers = watchers[1:-1]\r\n                watchersList = watchers.split(',')\r\n                for watcher in watchersList:\r\n                    followers += '{\"name\":\"'+watcher[0:watcher.find('@')].strip()+'\"},'\r\n                followers = followers+'{\"name\":\"'+reporter[0:reporter.find('@')].strip()+'\"}'\r\n        else:\r\n            followers = '{\"name\":\"'+reporter[0:reporter.find('@')].strip()+'\"}'\r\n           \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        \r\n        errorType = \"e30000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n        \r\n    result = \"True\"\r\n    message = followers\r\n    \r\n    return{\"result\": result, \"message\": message,\"errorType\": errorType,\"errorSeverity\": errorSeverity,\"errorProvider\":errorProvider,\"errorMessage\":errorMessage}"
  outputs:
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
