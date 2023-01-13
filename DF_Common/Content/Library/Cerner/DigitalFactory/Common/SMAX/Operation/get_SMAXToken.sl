########################################################################################################################
#!!
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.SMAX.Operation
operation:
  name: get_SMAXToken
  inputs:
    - smax_url: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
    - smax_user: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUser')}"
    - smax_password: "${get_sp('Cerner.DigitalFactory.SMAX.smaxIntgUserPass')}"
    - smax_tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation to get the SMAX SMAX_AUTH_TOKEN\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   operation: get_SMAXToken\r\n#   Inputs:\r\n#       -   smax_url\r\n#       -   smax_user\r\n#       -   smax_password\r\n#       -   smax_tenantId\r\n#      \r\n#\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   errortype\r\n#       -   errorLogs\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\ndef execute(smax_url, smax_user, smax_password, smax_tenantId):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    errortype = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    errorLogs = \"\"\r\n\r\n    try:\r\n        smax_auth_baseurl = smax_url + '/auth/authentication-endpoint/authenticate/token?TENANTID=' + smax_tenantId\r\n        ## https://factorymarketdev.cerner.com/auth/authentication-endpoint/authenticate/token?TENANTID=336419949x\r\n        authResponse = getAuthCookie(smax_auth_baseurl, smax_user, smax_password)\r\n        if authResponse[\"result\"] == \"True\":\r\n            token = authResponse[\"smax_auth\"]\r\n            result = \"True\"\r\n        else:\r\n            emsg = authResponse[\"message\"]\r\n            msg = 'Cannot Open Connection to SMAX, Wrong URL or Wrong User password or SMAX not Available : ' + str(emsg)\r\n            errorType = 'e20000'\r\n            raise Exception(msg)\r\n    except Exception as e:\r\n        message = str(e)\r\n        errorMessage = message\r\n        errortype = 'e20000'\r\n        result = \"False\"\r\n        errorProvider = 'SMAX'\r\n        errorSeverity = \"ERROR\"\r\n        errorLogs = \"ProviderUrl,\" + smax_auth_baseurl + \"||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + str(message) + \"|||\"\r\n\r\n    return {\"result\": result, \"token\":token, \"message\": message, \"errorType\": errortype, \"errorMessage\": errorMessage, \"errorSeverity\": errorSeverity,\"errorProvider\":errorProvider,\"errorLogs\":errorLogs}\r\n\r\n# authenticate in SMAX\r\ndef getAuthCookie(auth_baseurl, user, password):\r\n    message = \"\"\r\n    result = \"\",\r\n    token = \"\"\r\n    try:\r\n        import requests\r\n        basicAuthCredentials = (user, password)\r\n        data = {}\r\n        data['Login'] = user\r\n        data['Password'] = password\r\n\r\n        response = requests.post(auth_baseurl, json=data, auth=basicAuthCredentials)\r\n        token = response.content.decode('ascii')\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"smax_auth\": token}"
  outputs:
    - result
    - token
    - message
    - errorMessage
    - errorSeverity
    - errorProvider
    - errorType
    - errorLogs
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
