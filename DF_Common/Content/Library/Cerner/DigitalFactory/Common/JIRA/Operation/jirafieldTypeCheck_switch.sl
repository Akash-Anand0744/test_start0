namespace: Cerner.DigitalFactory.Common.JIRA.Operation
operation:
  name: jirafieldTypeCheck_switch
  inputs:
    - jirafieldkeyType
  python_action:
    use_jython: false
    script: "def execute(jirafieldkeyType):\r\n    message = \"\"\r\n    result = \"False\"\r\n    key = \"\"\r\n    \r\n    try:\r\n       \r\n        if jirafieldkeyType == 'array':\r\n            result = \"array\"\r\n           \r\n        if jirafieldkeyType == 'name':\r\n            result = \"name\"\r\n           \r\n        if jirafieldkeyType == 'default':\r\n            result = \"default\"\r\n          \r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}"
  outputs:
    - result
    - message
  results:
    - ARRAY_TYPE: '${result == "array"}'
      CUSTOM_0: '${result == "array"}'
    - NAME_TYPE: '${result == "name"}'
      CUSTOM_0: '${result == "name"}'
    - DEFAULT: '${result == "default"}'
    - FAILURE
