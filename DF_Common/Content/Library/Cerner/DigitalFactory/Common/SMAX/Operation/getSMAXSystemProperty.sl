namespace: Cerner.DigitalFactory.Common.SMAX.Operation
operation:
  name: getSMAXSystemProperty
  inputs:
    - smax_auth_baseurl: "${get_sp('MarketPlace.smaxAuthURL')}"
    - smax_user: "${get_sp('MarketPlace.smaxIntgUser')}"
    - smax_password: "${get_sp('MarketPlace.smaxIntgUserPass')}"
    - smax_tenantId: "${get_sp('MarketPlace.tenantID')}"
    - smax_baseurl: "${get_sp('MarketPlace.smaxURL')}"
    - propertyKey: jiraIssueLastUpdateTime
  python_action:
    use_jython: false
    script: "###############################################################\n#   OO operation for sync of Jira and Smax\n#   Author: Rajesh Singh (rajesh.singh5@microfocus.com), MicroFocus International\n#   Inputs:\n#       -   smax_auth_baseurl\n#       -   smax_user\n#       -   smax_password\n#       -   smax_tenantId\n#       -   smax_baseurl\n#       -   propertyKey\n#   Outputs:\n#       -   result\n#       -   message\n#       -   propertyValue\n###############################################################\nimport sys, os\nimport subprocess\n\n# function do download external modules to python \"on-the-fly\" \ndef install(param): \n    message = \"\"\n    result = \"\"\n    errorType = \"\"\n    try:\n        \n        pathname = os.path.dirname(sys.argv[0])\n        message = os.path.abspath(pathname)\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\n        result = \"True\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n    return {\"result\": result, \"message\": message }\n\n# requirement external modules\ninstall(\"requests\")\ndef execute(smax_auth_baseurl, smax_user, smax_password, smax_tenantId, smax_baseurl,propertyKey):\n    message = \"\"\n    result = \"\"\n    token = \"\"\n    propertyId = \"\"\n    lastUpdate = \"\"\n    errortype = \"\"\n\n    try:\n        import requests\n        import json\n        authResponse = getAuthCookie(smax_auth_baseurl,smax_user, smax_password)\n        if authResponse[\"result\"] == \"True\":\n            token = authResponse[\"smax_auth\"]\n                    \n        basicAuthCredentials = (smax_user, smax_password)\n        authHeaders = { \"TENANTID\": \"keep-alive\", \"Content-Type\": \"application/json\"}\n        cookies = {\"SMAX_AUTH_TOKEN\":token}\n        getURL = smax_baseurl+\"/rest/\"+smax_tenantId+\"/ems/SystemProperties_c?filter=DisplayLabel='\"+propertyKey+\"'&layout=Id,SysPropertyValue_c\"\n        response = requests.get(getURL, auth=basicAuthCredentials, headers=authHeaders, cookies=cookies)\n        if response.status_code == 200:\n            configResponse = json.loads(response.content)\n            lastUpdate = configResponse[\"entities\"][0][\"properties\"][\"SysPropertyValue_c\"]\n            propertyId = configResponse[\"entities\"][0][\"properties\"][\"Id\"]\n            result = \"True\"\n            message = \"last update time retrieved\"\n        else:\n            msg = 'Cannot Open Connection to SMAX, Wrong URL or Wrong User password or SMAX not Available'\n            errorType = 'e20000'\n            raise Exception(msg)\n    except Exception as e:\n        message = e\n        errortype = 'e20000'\n        result = \"False\"\n\n    return {\"result\": result, \"errorType\": errortype,\"message\": message, \"SystemPropValue\": lastUpdate, \"propertyId\": propertyId}\n\n#authenticate in SMAX\ndef getAuthCookie(auth_baseurl, user, password):\n    message = \"\"\n    result = \"\"\n    token = \"\"\n    try:\n        import requests\n        basicAuthCredentials = (user, password)\n        data={}\n        data['Login'] = user\n        data['Password']= password\n\n        response = requests.post(auth_baseurl, json=data, auth=basicAuthCredentials)\n        token = response.content.decode('ascii')\n        result = \"True\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n    return {\"result\": result, \"message\": message, \"smax_auth\": token }"
  outputs:
    - result
    - message
    - SystemPropValue
    - propertyId
    - errorType
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
