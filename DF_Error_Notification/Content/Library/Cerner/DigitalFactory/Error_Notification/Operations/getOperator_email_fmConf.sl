namespace: Cerner.DigitalFactory.Error_Notification.Operations
operation:
  name: getOperator_email_fmConf
  inputs:
    - confString: "${get_sp('Cerner.DigitalFactory.Error_Notification.config')}"
  python_action:
    use_jython: false
    script: "###############################################################\r\n# Operation: getOperator_email_fmConf\r\n#  \r\n#   Author: Rakesh Sharma Cerner (rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       - confString\r\n#  \r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - operator_email\r\n#       - errorType\r\n#       - errorMessage\r\n#   Created On:12 Jan 2022\r\n#  -------------------------------------------------------------\r\n###############################################################\r\n\r\ndef execute(confString):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorMessage = ''\r\n    errorType = ''\r\n    operator_email = \"\"\r\n\r\n    try:\r\n        import json\r\n        conf = json.loads(confString)\r\n        handlers = conf[\"errorHandlers\"]\r\n        for handler in handlers:\r\n            if handler[\"handler\"][\"name\"] == \"email\":\r\n                values = handler[\"handler\"][\"config\"][\"values\"]\r\n                for value in values:\r\n                    if value[\"value\"][\"name\"] == \"operator_email\":\r\n                        operator_email = value[\"value\"][\"data\"]\r\n                        break\r\n\r\n        if len(operator_email) > 5:\r\n            result = \"True\"\r\n            message = \"Operator email retrieved succesfully from conf\"\r\n        else:\r\n            message = \"Failed to retrieve from conf, check the configuration again\"\r\n            result = \"False\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = 'e10000'\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message, \"operator_email\": operator_email, \"errorType\": errorType,\r\n            \"errorMessage\": errorMessage}"
  outputs:
    - operator_email
    - result
    - message
    - errorType
    - errorMessage
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
