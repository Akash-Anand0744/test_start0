namespace: Cerner.DigitalFactory.Common.Remedy.Operations
operation:
  name: get_RapidToken
  inputs:
    - rapid_url: "${get_sp('Cerner.DigitalFactory.Remedy.rapidURL')}"
    - consumer_key: "${get_sp('Cerner.DigitalFactory.Remedy.consumerKey')}"
    - consumer_secret: "${get_sp('Cerner.DigitalFactory.Remedy.consumerSecret')}"
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation to get the Rapid API Token for Remedy Operations\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   operation: get_RapidToken\r\n#   Inputs:\r\n#       -   rapid_url\r\n#       -   consumer_key\r\n#       -   consumer_secret\r\n\r\n#\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   token\r\n#       -   errortype\r\n#       -   errorMessage\r\n#       -   errorSeverity\r\n#       -   errorProvider\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\ndef execute(rapid_url, consumer_key, consumer_secret):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    errortype = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n\r\n    try:\r\n        authResponse = getAuthCookie(rapid_url, consumer_key, consumer_secret)\r\n        if authResponse[\"result\"] == \"True\":\r\n            token = authResponse[\"auth_token\"]\r\n            result = \"True\"\r\n        else:\r\n            emsg = authResponse[\"message\"]\r\n            msg = 'Cannot Open Connection to Rapid, Wrong URL or Wrong User password or Rapid not Available : ' + str(\r\n                emsg)\r\n            raise Exception(msg)\r\n    except Exception as e:\r\n        message = str(e)\r\n        errorMessage = message\r\n        errortype = 'e20000'\r\n        result = \"False\"\r\n        errorProvider = 'RAPID'\r\n        errorSeverity = \"ERROR\"\r\n\r\n    return {\"result\": result, \"token\": token, \"message\": message, \"errorType\": errortype, \"errorMessage\": errorMessage,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider}\r\n\r\n\r\n# authenticate in SMAX\r\ndef getAuthCookie(auth_baseurl, user, password):\r\n    message = \"\"\r\n    result = \"\"\r\n    access_token = \"\"\r\n    try:\r\n        import requests\r\n        import json\r\n        basicAuthCredentials = (user, password)\r\n\r\n        url = auth_baseurl + '/token?grant_type=client_credentials'\r\n\r\n        response = requests.post(url,  auth=basicAuthCredentials)\r\n        if response.status_code == 200:\r\n            tresponse = json.loads(response.content)\r\n            access_token = tresponse[\"access_token\"]\r\n            result = \"True\"\r\n        else:\r\n            message = str(response.text) + ': Response code: ' + str(response.status_code)\r\n            raise Exception(message)\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"auth_token\": access_token}"
  outputs:
    - result
    - message
    - token
    - errorMessage
    - errorType
    - errorSeverity
    - errorProvider
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
