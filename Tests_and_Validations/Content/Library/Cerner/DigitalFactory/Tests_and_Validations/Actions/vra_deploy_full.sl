namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
operation:
  name: vra_deploy_full
  inputs:
    - project_id
    - catalog_id
    - os_image
    - passwd
    - size
    - version
    - vrafqdn
    - user
    - password:
        sensitive: true
    - deploymentname
  python_action:
    use_jython: false
    script: "# do not remove the execute function\r\ndef execute(project_id,catalog_id,os_image,passwd,size,version,vrafqdn,user,password,deploymentname):\r\n    import requests\r\n    import json\r\n    import time\r\n    requests.packages.urllib3.disable_warnings()\r\n\r\n    apiurl = \"https://{}/csp/gateway/am/api/login?access_token\".format(vrafqdn)\r\n    payload = '{{\"username\":\"{}\",\"password\":\"{}\"}}'.format(user, password)\r\n    headers = {\r\n    'content-type': \"application/json\"\r\n    }\r\n    response = requests.request(\"POST\", apiurl, data=payload, headers=headers, verify=False)\r\n    j = response.json()['refresh_token']\r\n    auth = j\r\n\r\n    tokenurl = \"https://{}/iaas/api/login\".format(vrafqdn)\r\n    tokenpayload = '{{\"refreshToken\":\"{}\"}}'.format(auth)\r\n    headers = {\r\n    'content-type': \"application/json\"\r\n    }\r\n    response = requests.request(\"POST\", tokenurl, data=tokenpayload, headers=headers, verify=False)\r\n    k = response.json()['token']\r\n    token = k\r\n\r\n    catalogurl = \"https://{}/catalog/api/items/{}/request\".format(vrafqdn,catalog_id)\r\n    catalogheaders = {\r\n    'content-type': \"application/json\",\r\n    \"Authorization\": \"Bearer {}\".format(token)\r\n    }\r\n\r\n    catalogpayload = {\r\n        'deploymentName': deploymentname,\r\n        'projectId': project_id,\r\n        'bulkRequestCount': 1,\r\n        'inputs': {\r\n            'os-image': os_image,\r\n            'hardware-config': size,\r\n            'environment': \"Environment:Development\",\r\n            'windowspassword': passwd\r\n        },\r\n        'version': version\r\n    }\r\n    catalogresponse = requests.request(\"POST\", catalogurl, data=json.dumps(catalogpayload), headers=catalogheaders, verify=False).json()\r\n    print (catalogresponse)\r\n    url = \"https://{}/iaas/api/deployments\".format(vrafqdn)\r\n    headers = {\r\n        'content-type': \"application/json\",\r\n        'authorization': \"Bearer {}\".format(token)\r\n    }\r\n    api_output = requests.get(url, headers=headers, verify=False).json()['content']\r\n    for i in api_output:\r\n        if i['name'] == deploymentname:\r\n            deploymentid=(i['id'])\r\n    print (deploymentid)\r\n\r\n    url = \"https://{}/deployment/api/deployments/{}?expandResources=true\".format(vrafqdn,deploymentid)\r\n    headers = {\r\n        'content-type': \"application/json\",\r\n        'authorization': \"Bearer {}\".format(token)\r\n    }\r\n    deployment_info = requests.get(url, headers=headers, verify=False)\r\n    deployment_status = deployment_info.json()['status']\r\n    print (deployment_status)\r\n\r\n    dp_status = False\r\n    while dp_status != \"CREATE_SUCCESSFUL\":\r\n      deployment_info = requests.get(url, headers=headers, verify=False)\r\n      dp_status = deployment_info.json()['status']\r\n      print(dp_status)\r\n      time.sleep(20)\r\n\r\n    url = \"https://{}/deployment/api/deployments/{}/resources\".format(vrafqdn,deploymentid)\r\n    headers = {\r\n        'content-type': \"application/json\",\r\n        'authorization': \"Bearer {}\".format(token)\r\n    }\r\n    deployment_info = requests.get(url, headers=headers, verify=False)\r\n    json_parse=deployment_info.json()\r\n    hostname = (json_parse['content'][0]['properties']['resourceName'])\r\n    vm_ipaddress = (json_parse['content'][0]['properties']['address'])\r\n    vm_state = (json_parse['content'][0]['properties']['powerState'])\r\n    return{\"hostname\": hostname, \"vm_ipaddress\": vm_ipaddress, \"vm_state\": vm_state, \"deployment_id\": deploymentid}"
  outputs:
    - hostname
    - vm_ipaddress
    - vm_state
    - deployment_id
  results:
    - SUCCESS