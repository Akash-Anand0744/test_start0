namespace: Cerner.DigitalFactory.MarketPlace.DynamicDropDown.Schedule
operation:
  name: ExtractIdsFromSQLOutput
  inputs:
    - output_json
  python_action:
    use_jython: false
    script: "###############################################################\r\nimport sys, os\r\nimport subprocess\r\nimport requests\r\n\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    try:\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n    \r\n\r\ndef execute(output_json):\r\n    install(\"requests\")\r\n    \r\n    result = \"False\"\r\n    message= \"\"\r\n    errorProvider = \"\"\r\n    errorMessage = \"\"\r\n    id_list = \"\"\r\n    \r\n   \r\n    try:\r\n        import json\r\n        output_json = json.loads(output_json)\r\n        for item in output_json:\r\n            id_gp = item[\"id\"]\r\n            id_list += str(id_gp) + ','\r\n        id_list = id_list[:-1]\r\n        if id_list:\r\n            result = \"True\"\r\n        else:\r\n            message = \"id_list is empty\"\r\n    except Exception as e:\r\n        \r\n        message = str(e)\r\n        result = \"False\"\r\n        errorProvider = \"DB\"\r\n        errorMessage = message\r\n    \r\n    \r\n    return {\"id_list\" : id_list,\"result\": result, \"message\": message, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage}"
  outputs:
    - id_list
    - result
    - message
    - errorProvider
    - errorMessage
  results:
    - SUCCESS: "${result == 'True'}"
    - FAILURE
