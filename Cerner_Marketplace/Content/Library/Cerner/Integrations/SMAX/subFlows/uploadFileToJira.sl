namespace: Cerner.Integrations.SMAX.subFlows
operation:
  name: uploadFileToJira
  inputs:
    - url: "${get_sp('MarketPlace.jiraIssueURL')}"
    - user: "${get_sp('MarketPlace.jiraUser')}"
    - password: "${get_sp('MarketPlace.jiraPassword')}"
    - filepath
    - jiraIssueId
  python_action:
    use_jython: false
    script: "import sys, os\nimport subprocess\n\n# do not remove the execute function \ndef install(param): \n    message = \"\"\n    result = \"\"\n    try:\n        \n        pathname = os.path.dirname(sys.argv[0])\n        message = os.path.abspath(pathname)\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\n        result = \"True\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n    return {\"result\": result, \"message\": message }\n    # code goes here\n# you can add additional helper methods below.\n\ninstall(\"requests\")\n\n# do not remove the execute function \ndef execute(url, user, password, filepath,jiraIssueId): \n    message = \"\"\n    result = \"False\"\n    token = \"\"\n    try:\n        import requests\n        import base64\n     \n        basicAuthCredentials = requests.auth.HTTPBasicAuth(user,password)\n        attachment = filepath.split(\"/\")[-1]\n        #image_64_decode = base64.decodestring(filepath)\n        #image_result = open('/tmp/Cerner-logo-1.png', 'wb')\n        #image_result.write(image_64_decode)\n        files = [('file',(attachment,open(filepath,'rb'),'application/zip'))]\n        headers = { 'X-Atlassian-Token': 'no-check'}\n        url = url +\"rest/api/2/issue/\"+jiraIssueId+\"/attachments\"\n        response = requests.post(url, files=files, headers=headers, auth=basicAuthCredentials)\n        message = response.text\n        if response.status_code == 200:\n            result = \"True\"\n        \n        \n    except Exception as e:\n        message = e\n        result = \"False\"\n        \n    return {\"result\": result, \"message\": message }\n# you can add additional helper methods below."
  outputs:
    - result
    - message
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
