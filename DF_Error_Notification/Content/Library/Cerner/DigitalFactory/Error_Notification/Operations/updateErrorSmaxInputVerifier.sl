namespace: Cerner.DigitalFactory.Error_Notification.Operations
operation:
  name: updateErrorSmaxInputVerifier
  inputs:
    - OOErrorDetails:
        required: false
        default: ''
    - OOErrorSummary:
        required: false
        default: ''
    - smaxRequestID:
        required: false
        default: ''
  python_action:
    use_jython: false
    script: "# do not remove the execute function\r\ndef execute(OOErrorDetails, OOErrorSummary, smaxRequestID):\r\n    message = \"\"\r\n    result = \"True\"\r\n    http_json_str = \"\"\r\n    \r\n    try:\r\n        import json\r\n        \r\n        \r\n        smaxRequestID = str(smaxRequestID)\r\n        \r\n        if len(OOErrorDetails) > 0:\r\n            message += \" \" + message\r\n            OOErrorDetails = json.dumps(OOErrorDetails)\r\n        else:\r\n            result = \"False\"\r\n            message += \"NO OOErrorDetails!\"\r\n        \r\n        if len(OOErrorSummary) > 0:\r\n            message += \" \" + message\r\n        else:\r\n            result = \"False\"\r\n            message += \"NO OOErrorSummary!\"\r\n        \r\n        if len(smaxRequestID) > 0:\r\n            message += \" \" + message\r\n        else:\r\n            result = \"False\"\r\n            message += \"NO smaxRequestID!\"\r\n        \r\n        if smaxRequestID == \"0\":\r\n            result = \"False\"\r\n            message += \"smaxRequestID == 0\"\r\n        \r\n        http_json_body= '{\"entity_type\": \"Request\", \"properties\": { \"Id\": \"\", \"OOErrorDetails_c\": \"\",\"OOErrorSummary_c\": \"\"}, \"related_properties\" : { }  }'\r\n        http_json = json.loads(http_json_body)\r\n        http_json[\"properties\"][\"Id\"] = smaxRequestID\r\n        http_json[\"properties\"][\"OOErrorDetails_c\"] = OOErrorDetails\r\n        http_json[\"properties\"][\"OOErrorSummary_c\"] = OOErrorSummary\r\n        http_json_str = json.dumps(http_json)\r\n\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"http_json_str\":http_json_str }"
  outputs:
    - message
    - result
    - http_json_str
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
