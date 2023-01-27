namespace: Cerner.DigitalFactory.Error_Notification.Operations
operation:
  name: checkInput
  inputs:
    - errorType:
        required: false
        default: ''
    - errorMessage:
        required: false
        default: ''
    - errorSeverity:
        required: false
        default: ''
    - conf
  python_action:
    use_jython: false
    script: "def execute(errorType, errorMessage, errorSeverity, conf):\r\n    message = \"\"\r\n    result = \"False\"\r\n    \r\n    try:\r\n        if len(errorType) > 0:\r\n            result = \"True\"\r\n        else:\r\n            result = \"True\"\r\n            errorType = \"e9999\"\r\n        \r\n        if len(errorMessage) > 0:\r\n            errorMessage = errorMessage\r\n        else:\r\n            errorMessage = errorType + \": !NO MESSAGE CHECK CODE!\"\r\n        \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"errorMessageOut\":errorMessage, \"errorTypeOut\":errorType}"
  outputs:
    - result
    - message
    - errorMessageOut
    - errorTypeOut
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
