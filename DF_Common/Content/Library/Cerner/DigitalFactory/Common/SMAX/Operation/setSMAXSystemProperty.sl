namespace: Cerner.DigitalFactory.Common.SMAX.Operation
operation:
  name: setSMAXSystemProperty
  inputs:
    - smax_auth_baseurl: "${get_sp('MarketPlace.smaxAuthURL')}"
    - smax_user: "${get_sp('MarketPlace.smaxIntgUser')}"
    - smax_password: "${get_sp('MarketPlace.smaxIntgUserPass')}"
    - smax_tenantId: "${get_sp('MarketPlace.tenantID')}"
    - smax_baseurl: "${get_sp('MarketPlace.smaxURL')}"
    - propertyId
    - propertyValue
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for sync of Jira and Smax\r\n#   Author: Rajesh Singh (rajesh.singh5@microfocus.com), MicroFocus International\r\n#   Inputs:\r\n#       -   smax_auth_baseurl\r\n#       -   smax_user\r\n#       -   smax_password\r\n#       -   smax_tenantId\r\n#       -   smax_baseurl\r\n#       -   propertyValue\r\n#       -   propertyId\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n# function do download external modules to python \"on-the-fly\" \r\ndef install(param): \r\n    message = \"\"\r\n    result = \"\"\r\n    try:\r\n        \r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message }\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\ndef execute(smax_auth_baseurl, smax_user, smax_password, smax_tenantId, smax_baseurl,propertyId,propertyValue):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    errortype = \"\"\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        smaxDataU={}\r\n        smaxDataU['entities'] = [0]\r\n        smaxDataU['operation'] = \"UPDATE\"\r\n        data = {}\r\n        data[\"entity_type\"] = \"SystemProperties_c\"\r\n        data[\"properties\"] = {}\r\n        data[\"properties\"][\"Id\"] = propertyId\r\n        data[\"properties\"][\"SysPropertyValue_c\"] = propertyValue\r\n        smaxDataU['entities'][0] = data\r\n\r\n        authResponse = getAuthCookie(smax_auth_baseurl,smax_user, smax_password)\r\n        if authResponse[\"result\"] == \"True\":\r\n            token = authResponse[\"smax_auth\"]\r\n                    \r\n        basicAuthCredentials = (smax_user, smax_password)\r\n        authHeaders = { \"TENANTID\": \"keep-alive\", \"Content-Type\": \"application/json\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\":token}\r\n        postURL = smax_baseurl+\"/rest/\"+smax_tenantId+\"/ems/bulk\"\r\n        response = requests.post(postURL, auth=basicAuthCredentials, json= smaxDataU, headers=authHeaders, cookies=cookies)\r\n        if response.status_code == 200:\r\n            configResponse = json.loads(response.content)\r\n            completionStatus = configResponse[\"entity_result_list\"][0][\"completion_status\"]\r\n            if completionStatus == \"OK\":\r\n                result = \"True\"\r\n                message = \"System Property Updated\"\r\n            else:\r\n                result = \"False\"\r\n                message = json.dumps(configResponse)\r\n        else:\r\n            result = \"False\"\r\n            message = response.text\r\n            \r\n        \r\n    except Exception as e:\r\n        message = e\r\n        errortype = 'e20000'\r\n        result = \"False\"\r\n\r\n    return {\"result\": result,\"errorType\": errortype, \"message\": message}\r\n\r\n#authenticate in SMAX\r\ndef getAuthCookie(auth_baseurl, user, password):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    try:\r\n        import requests\r\n        basicAuthCredentials = (user, password)\r\n        data={}\r\n        data['Login'] = user\r\n        data['Password']= password\r\n\r\n        response = requests.post(auth_baseurl, json=data, auth=basicAuthCredentials)\r\n        token = response.content.decode('ascii')\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_auth\": token }"
  outputs:
    - result
    - message
    - errorType
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
