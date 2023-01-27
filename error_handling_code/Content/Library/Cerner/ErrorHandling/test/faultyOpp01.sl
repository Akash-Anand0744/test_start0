namespace: Cerner.ErrorHandling.test
operation:
  name: faultyOpp01
  python_action:
    use_jython: false
    script: "def execute():\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorType = \"\"\r\n    errorSeverity = \"INFO\"\r\n    \r\n    try:\r\n        errorType = \"e50001\"\r\n        message = \"This is a test error\"\r\n        errorSeverity = \"ERROR\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"errorType\":errorType, \"errorSeverity\":errorSeverity}"
  outputs:
    - result
    - message
    - errorType
    - errorSeverity
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
