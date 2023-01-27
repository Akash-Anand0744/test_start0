namespace: Cerner.Integrations.Jira.subFlows
operation:
  name: extractWathersList
  inputs:
    - watchers:
        required: false
    - reporter
  python_action:
    use_jython: false
    script: "def execute(watchers, reporter):\r\n    followers = ''\r\n    errorMessage=''\r\n    errorCode = ''\r\n    try:\r\n        if len(watchers.strip()) > 0:\r\n            if watchers.find(\",\") == -1:\r\n                followers = '{\"name\":\"'+watchers[0:watchers.find('@')].strip()+'\"},{\"name\":\"'+reporter[0:reporter.find('@')].strip()+'\"}'\r\n            else:\r\n                watchers = watchers[1:-1]\r\n                watchersList = watchers.split(',')\r\n                for watcher in watchersList:\r\n                    followers += '{\"name\":\"'+watcher[0:watcher.find('@')].strip()+'\"},'\r\n                followers = followers+'{\"name\":\"'+reporter[0:reporter.find('@')].strip()+'\"}'\r\n        else:\r\n            followers = '{\"name\":\"'+reporter[0:reporter.find('@')].strip()+'\"}'\r\n         \r\n            \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorCode = 'e30000'\r\n        errorMessage = 'StepName-extractWatchersList: '+str(e)\r\n        \r\n    result = \"True\"\r\n    message = followers\r\n    \r\n    return{\"result\": result, \"message\": message,\"errorCode\": errorCode,\"errorMessage\":errorMessage }"
  outputs:
    - result
    - message
    - errorCode
    - errorMessage
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
