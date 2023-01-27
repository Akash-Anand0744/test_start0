########################################################################################################################
#!!
#! @input flow_uuid: OO Flow UUID for the flow which is to be executed
#! @input flow_inputs: Input parameters and values like key  Value pairs separated by comma and double pipes like key1,Value1||key2,Value2||
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.OO.Operation
operation:
  name: execute_OOFlow_by_FlowUUID
  inputs:
    - central_url: "${get_sp('io.cloudslang.microfocus.oo.central_url')}"
    - oo_username: "${get_sp('io.cloudslang.microfocus.oo.oo_username')}"
    - oo_password: "${get_sp('io.cloudslang.microfocus.oo.oo_password')}"
    - flow_uuid: ''
    - flow_inputs:
        required: false
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   Opertion Name: execute_OOFlow_by_ExecutionId\r\n#   OO operation for getting the execution status of OO Flow by Execution ID\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   Created on: 19 Jul 2022\r\n#   Inputs:\r\n#       -   central_url\r\n#       -   oo_username\r\n#       -   oo_password\r\n#       -   flow_uuid\r\n#       -   flow_inputs\r\n#\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   errortype\r\n#       -   errorMessage\r\n#       -   errorProvider\r\n#       -   flow_execution_id\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e10000\"\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorMessage\": errorMessage}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n\r\ndef execute(central_url, oo_username, oo_password, flow_uuid, flow_inputs):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorProvider = \"\"\r\n    flow_execution_id = \"\"\r\n    errorSeverity = \"\"\r\n    inputs = ''\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        basicAuthCredentials = (oo_username, oo_password)\r\n        authHeaders = {\"TENANTID\": \"keep-alive\", \"Content-Type\": \"application/json\"}\r\n\r\n        if flow_inputs:\r\n            for i in flow_inputs.split('||'):\r\n                if i:\r\n                    key = i.split(',')[0]\r\n                    value = i.split(',')[1]\r\n                    inputs += '\"' + key + '\":\"' + value + '\",'\r\n        if inputs:\r\n            inputs = '{' + inputs[:-1] + '}'\r\n            inputs = json.loads(inputs)\r\n            payload = {\r\n                \"flowUuid\": flow_uuid,\r\n                \"logLevel\": \"STANDARD\",\r\n                \"inputs\": inputs\r\n            }\r\n        else:\r\n            payload = {\r\n                \"flowUuid\": flow_uuid,\r\n                \"logLevel\": \"STANDARD\"\r\n            }\r\n\r\n        payload = json.dumps(payload)\r\n\r\n        postURL = central_url + \"/rest/v2/executions\"\r\n\r\n        response = requests.post(postURL, auth=basicAuthCredentials, headers=authHeaders, data=payload)\r\n\r\n        if response.status_code == 201:\r\n            flow_execution_id = json.loads(response.content)\r\n            message = 'Successfully Executed the OO Flow: ' + flow_uuid\r\n            result = 'True'\r\n\r\n        else:\r\n            msg = \"Invalid Response from the Provider:\" + str(response.text)\r\n            raise Exception(msg)\r\n\r\n    except Exception as e:\r\n        result = \"False\"\r\n        message = e\r\n        errorMessage = message\r\n        errorType = 'e20000'\r\n        errorProvider = 'OOExec'\r\n        errorSeverity = 'ERROR'\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorMessage\": errorMessage,\r\n        \"errorSeverity\": errorSeverity,\r\n        \"errorProvider\": errorProvider, \"flow_execution_id\": flow_execution_id}"
  outputs:
    - flow_execution_id
    - result
    - message
    - errorType
    - errorMessage
    - errorProvider
    - errorSeverity
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
