namespace: Cerner.ErrorHandling.operations
operation:
  name: checkInput
  inputs:
    - errorType
    - errorMessage
    - errorSeverity
    - conf
  python_action:
    use_jython: false
    script: "def execute(errorType, errorMessage, errorSeverity, conf):\r\n    message = \"\"\r\n    result = \"False\"\r\n    \r\n    try:\r\n        if len(errorType) > 0:\r\n            result = \"True\"\r\n        else:\r\n            result = \"False\"\r\n        if len(errorMessage) > 0:\r\n            errorMessage = errorType + \": !NO MESSAGE CHECK CODE!\"\r\n        \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"errorMessageOut\":errorMessage}"
  outputs:
    - result
    - message
    - errorMessageOut
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
