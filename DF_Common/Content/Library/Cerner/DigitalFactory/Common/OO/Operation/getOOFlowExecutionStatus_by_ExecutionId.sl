########################################################################################################################
#!!
#! @input execution_id: It is the run ID or Execution ID of the OO Flow executed
#! @input timeout: timeout period to check the status
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.OO.Operation
operation:
  name: getOOFlowExecutionStatus_by_ExecutionId
  inputs:
    - central_url: "${get_sp('io.cloudslang.microfocus.oo.central_url')}"
    - oo_username: "${get_sp('io.cloudslang.microfocus.oo.oo_username')}"
    - oo_password: "${get_sp('io.cloudslang.microfocus.oo.oo_password')}"
    - execution_id: ''
    - timeout: '1200'
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   Opertion Name: getOOFlowExecutionStatus_by_ExecutionId\r\n#   OO operation for getting the execution status of OO Flow by Execution ID\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   Created on: 19 Jul 2022\r\n#   Inputs:\r\n#       -   central_url\r\n#       -   oo_username\r\n#       -   oo_password\r\n#       -   execution_id\r\n#\r\n#\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   errortype\r\n#       -   errorMessage\r\n#       -   errorProvider\r\n#       -   last_run_time\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e10000\"\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorMessage\": errorMessage}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n\r\ndef execute(central_url, oo_username, oo_password, execution_id,timeout):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorProvider = \"\"\r\n    flow_execution_status = \"\"\r\n    errorSeverity = \"\"\r\n    if timeout:\r\n        timeout = int(timeout)\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        import time\r\n\r\n        basicAuthCredentials = (oo_username, oo_password)\r\n        authHeaders = {\"TENANTID\": \"keep-alive\", \"Content-Type\": \"application/json\"}\r\n\r\n        i = 0\r\n        runtime = 0\r\n        while i == 0:\r\n\r\n            getURL = central_url + \"/rest/v2/executions/{0}/summary\".format(execution_id)\r\n\r\n            response = requests.get(getURL, auth=basicAuthCredentials, headers=authHeaders)\r\n            if response.status_code == 200:\r\n                executions = json.loads(response.content)\r\n                if executions:\r\n                    status = executions[0][\"status\"]\r\n                    if status == 'COMPLETED':\r\n                        i = 11\r\n                        flow_execution_status = executions[0][\"resultStatusName\"]\r\n                        message = 'Successfully retrieved the status of the Flow Execution for execution id:' + execution_id\r\n                        result = 'True'\r\n                        break\r\n                    else:\r\n                        runtime += 15\r\n                        time.sleep(15)\r\n                    if runtime > timeout:\r\n                        msg = 'Process timedout to check the status of flow execution:' + execution_id\r\n                        raise Exception(msg)\r\n                        \r\n            else:\r\n                msg = \"No Response from the OO Central:\" + str(response.text)\r\n                raise Exception(msg)\r\n        else:\r\n            msg = \"Execution Id:\" + execution_id + \" Not FOUND\"\r\n            raise Exception(msg)\r\n\r\n    except Exception as e:\r\n        result = \"False\"\r\n        message = e\r\n        errorMessage = message\r\n        errorType = 'e20000'\r\n        errorProvider = 'OOExec'\r\n        errorSeverity = 'ERROR'\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorMessage\": errorMessage,\r\n            \"errorSeverity\": errorSeverity,\r\n            \"errorProvider\": errorProvider, \"flow_execution_status\": flow_execution_status}"
  outputs:
    - flow_execution_status
    - result
    - message
    - errorType
    - errorMessage
    - errorProvider
    - errorSeverity
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
