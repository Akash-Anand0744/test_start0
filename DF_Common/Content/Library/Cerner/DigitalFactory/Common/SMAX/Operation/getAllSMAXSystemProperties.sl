namespace: Cerner.DigitalFactory.Common.SMAX.Operation
operation:
  name: getAllSMAXSystemProperties
  inputs:
    - smax_auth_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxAuthURL')}"
    - smax_user: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUser')}"
    - smax_password: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUserPass')}"
    - smax_tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
    - smax_baseurl: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
    - smax_token:
        required: false
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation to get all System Properties from Configuration Item App\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       -   smax_auth_baseurl\r\n#       -   smax_user\r\n#       -   smax_password\r\n#       -   smax_tenantId\r\n#       -   smax_baseurl\r\n#   \r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   errortype\r\n#       -   config_json\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n# function do download external modules to python \"on-the-fly\" \r\ndef install(param): \r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n        \r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message }\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\ndef execute(smax_auth_baseurl, smax_user, smax_password, smax_tenantId, smax_baseurl, smax_token):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    errortype = \"\"\r\n    errormessage = \"\"\r\n    config_json = \"\"\r\n    errorProvider = \"\"\r\n    errorLogs = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        if not smax_token:\r\n            authResponse = getAuthCookie(smax_auth_baseurl,smax_user, smax_password)\r\n            if authResponse[\"result\"] == \"True\":\r\n                token = authResponse[\"smax_auth\"]\r\n        else:\r\n            token = smax_token\r\n                    \r\n        basicAuthCredentials = (smax_user, smax_password)\r\n        authHeaders = { \"TENANTID\": \"keep-alive\", \"Content-Type\": \"application/json\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\":token}\r\n        getURL = smax_baseurl+\"/rest/\"+smax_tenantId+\"/ems/SystemProperties_c?layout=Id,SysPropertyValue_c,DisplayLabel\"\r\n        response = requests.get(getURL, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\r\n        if response.status_code == 200:\r\n            #config_json = json.loads(response.content)\r\n            config_json = str(response.content).lstrip(\"b'\").rstrip(\"'\")\r\n            result = \"True\"\r\n            message = \"System Properties retrieved from SMAX Property Configurations\"\r\n        else:\r\n            msg = \"Unsupported Response from the Provider: \" + str(response.content) +\" Response Status Code: \"+ str(response.status_code)\r\n            errorType = 'e20000'\r\n            raise Exception(msg)\r\n    except Exception as e:\r\n        message = str(e)\r\n        errormessage = message\r\n        errortype = 'e20000'\r\n        errorProvider =\"SMAX\"\r\n        result = \"False\"\r\n        errorLogs = \"ProviderUrl,\" + getURL + \"||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + message + \"|||\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errortype,  \"errormessage\": errormessage,\"config_json\": config_json,\"errorProvider\":errorProvider,\"errorLogs\":errorLogs}\r\n\r\n#authenticate in SMAX\r\ndef getAuthCookie(auth_baseurl, user, password):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    try:\r\n        import requests\r\n        basicAuthCredentials = (user, password)\r\n        data={}\r\n        data['Login'] = user\r\n        data['Password']= password\r\n\r\n        response = requests.post(auth_baseurl, json=data, auth=basicAuthCredentials)\r\n        token = response.content.decode('ascii')\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_auth\": token }"
  outputs:
    - result
    - message
    - errorType
    - errormessage
    - config_json
    - errorProvider
    - errorLogs
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
