########################################################################################################################
#!!
#! @input oo_flow_status_ToGetLastRunTime: default is COMPLETED, provide the exact Flow Status to retrieve the last run time
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.OO
operation:
  name: getOOLastruntime
  inputs:
    - central_url: "${get_sp('io.cloudslang.microfocus.oo.central_url')}"
    - oo_username: "${get_sp('io.cloudslang.microfocus.oo.oo_username')}"
    - oo_password: "${get_sp('io.cloudslang.microfocus.oo.oo_password')}"
    - oo_run_name: ''
    - oo_flow_status_ToGetLastRunTime: COMPLETED
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   Opertion Name: getOOLastruntime\r\n#   OO operation for getting the last successful run time based on Flow Run Name\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       -   central_url\r\n#       -   oo_username\r\n#       -   oo_password\r\n#       -   oo_run_name\r\n#       -   oo_flow_status_ToGetLastRunTime\r\n#\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   errortype\r\n#       -   errorMessage\r\n#       -   errorProvider\r\n#       -   last_run_time\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e10000\"\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorMessage\": errorMessage}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n\r\ndef execute(central_url, oo_username, oo_password, oo_run_name, oo_flow_status_ToGetLastRunTime):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorProvider = \"\"\r\n    last_run_time = \"\"\r\n    errorSeverity = \"\"\r\n    errorLogs = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        basicAuthCredentials = (oo_username, oo_password)\r\n        authHeaders = {\"TENANTID\": \"keep-alive\", \"Content-Type\": \"application/json\"}\r\n\r\n        i = 0\r\n        while i < 4:\r\n            pgno = 10\r\n            if i == 1:\r\n                pgno = 50\r\n            if i == 2:\r\n                pgno = 100\r\n            if i == 3:\r\n                pgno = 400\r\n            getURL = central_url + \"/rest/v2/executions?runName=\" + oo_run_name + \"&pageSize=\" + str(pgno) + \"&status=\" + oo_flow_status_ToGetLastRunTime\r\n\r\n            response = requests.get(getURL, auth=basicAuthCredentials, headers=authHeaders)\r\n            if response.status_code == 200:\r\n                executions = json.loads(response.content)\r\n                if executions:\r\n                    for execution in executions:\r\n                        ttlast_run_time = execution[\"startTime\"]\r\n                        resultStatusType = execution[\"resultStatusType\"]\r\n                        if resultStatusType == 'RESOLVED':\r\n                            if not last_run_time:\r\n                                last_run_time = ttlast_run_time\r\n                            elif ttlast_run_time > last_run_time:\r\n                                last_run_time = ttlast_run_time\r\n                    if last_run_time:                        \r\n                        result = \"True\"\r\n                        message = \"OO Flow Last run end time successfully retrieved \"\r\n                        break\r\n            else:\r\n                msg = \"Run Name :\" + oo_run_name + \" : Not FOUND \"+ str(response.content)\r\n                raise Exception(msg)\r\n            i += 1\r\n        else:\r\n            msg = 'Cannot Open Connection to OO Central, Wrong URL or Wrong User password '+ str(response.content)\r\n            raise Exception(msg)\r\n\r\n    except Exception as e:\r\n        result = \"False\"\r\n        message = str(e)\r\n        errorMessage = message\r\n        errorType = 'e20000'\r\n        errorProvider = 'OOExec'\r\n        errorSeverity = 'ERROR'\r\n        errorLogs = \"ProviderUrl,\" + getURL + \"||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + message + \"|||\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorMessage\": errorMessage,\"errorSeverity\":errorSeverity,\r\n        \"errorProvider\": errorProvider,\r\n        \"last_run_time\": last_run_time,\"errorLogs\":errorLogs}"
  outputs:
    - last_run_time
    - result
    - message
    - errorType
    - errorMessage
    - errorProvider
    - errorSeverity
    - errorLogs
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
