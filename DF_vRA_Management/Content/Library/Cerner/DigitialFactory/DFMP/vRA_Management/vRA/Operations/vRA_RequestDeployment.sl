namespace: Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations
operation:
  name: vRA_RequestDeployment
  inputs:
    - vRA_host: "${get_sp('Cerner.DigitalFactory.DFMP.vRA_host')}"
    - vRA_protocol: "${get_sp('Cerner.DigitalFactory.DFMP.vRA_protocol')}"
    - vRA_bearer_token
    - catalog_id
    - body
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for to Decode the DIrect Values into the Parameters\r\n#   Operation: vRA_RequestDeployment\r\n#   Author: Rakesh Sharma (Rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       -   vRA_host\r\n#       -   vRA_user\r\n#       -   vRA_password\r\n#       -   vRA_protocol\r\n#       -   catalog_id\r\n#       -   body\r\n#\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   deploymentId\r\n#       -   errorType\r\n#       -   errorMessage\r\n#       -   errorSeverity\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\ndef execute(vRA_host, vRA_protocol, vRA_bearer_token, catalog_id, body):\r\n    message = \"\"\r\n    result = \"False\"\r\n    key = \"\"\r\n    value = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorProvider = \"\"\r\n    deploymentId = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        url = \"{0}://{1}/catalog/api/items/{2}/request\".format(vRA_protocol, vRA_host, catalog_id)\r\n        headers = {\r\n            \"Content-Type\": \"application/json\",\r\n            \"Authorization\": \"Bearer {}\".format(vRA_bearer_token)\r\n        }\r\n        payload = body\r\n        #data = json.dumps(payload)\r\n        response = requests.request(\"POST\", url, data=payload, headers=headers, verify=False)\r\n\r\n        if response.status_code == 200:\r\n            vRA_response = json.loads(response.content[1:-1])\r\n            deploymentId = vRA_response[\"deploymentId\"]\r\n            result = \"True\"\r\n            message = 'vRA Deployment initiated successfully'\r\n        else:\r\n            result = \"False\"\r\n            message = str(response.text)\r\n            raise Exception(message)\r\n\r\n    except Exception as e:\r\n        errorType = 'e20000'\r\n        message = str(e)\r\n        #errorMessage = message\r\n        errorMessage = message\r\n        result = \"False\"\r\n        errorProvider = \"vRA\"\r\n\r\n    return {\"result\": result, \"message\": message, \"deploymentId\": deploymentId, \"errorProvider\": errorProvider,\r\n            \"errorMessage\": errorMessage, \"errorType\": errorType}"
  outputs:
    - result
    - message
    - deploymentId
    - errorMessage
    - errorProvider
    - errorType
  results:
    - SUCCESS: "${result == 'True'}"
    - FAILURE
