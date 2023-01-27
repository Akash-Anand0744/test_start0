namespace: Cerner.DFMP.Schedules.SMAX.Operations
operation:
  name: attachmentsFromSMAXtoJIRA
  inputs:
    - MarketPlace_jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')}"
    - MarketPlace_jiraUser: "${get_sp('MarketPlace.jiraUser')}"
    - MarketPlace_jiraPassword: "${get_sp('MarketPlace.jiraPassword')}"
    - smax_auth_baseurl: "${get_sp('MarketPlace.smaxAuthURL')}"
    - smax_user: "${get_sp('MarketPlace.smaxIntgUser')}"
    - smax_password:
        sensitive: true
        default: "${get_sp('MarketPlace.smaxIntgUserPass')}"
    - smax_tenantId: "${get_sp('MarketPlace.tenantID')}"
    - smax_baseurl: "${get_sp('MarketPlace.smaxURL')}"
    - projectNames: "${get_sp('MarketPlace.jiraProjects')}"
    - creator: "${get_sp('MarketPlace.jiraIssueCreator')}"
    - lastUpdate:
        required: false
    - smax_FieldID
    - smax_authToken
    - conn_timeout: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
    - smax_jirasmaxid_list:
        required: false
    - smax_request_id_list:
        required: false
    - http_fail_status_codes: "${get_sp('Cerner.DigitalFactory.http_fail_status_codes')}"
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for sync of Jira and Smax\r\n#   Operation: attachmentsFromSMAXtoJIRA\r\n#   Author: Ashwini Shalke (ashwini.shalke@cerner.com), MicroFocus International\r\n#   Inputs:\r\n#       - MarketPlace_jiraIssueURL\r\n#       - MarketPlace_jiraUser\r\n#       - MarketPlace_jiraPassword\r\n#       - jiraticketID\r\n#       - smax_authToken\r\n#       - smax_tenantId\r\n#       - smax_baseurl\r\n#       - smax_FieldID\r\n#       - smax_jirasmaxid_list\r\n#       - smax_request_id_list\r\n#       - projectNames\r\n#       - creator\r\n#       - lastUpdate\r\n#       - conn_timeout\r\n#       - http_fail_status_codes\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - errorType\r\n#       - errorMessage\r\n#       - errorProvider\r\n#       - errorSeverity\r\n#       - errorLogs\r\n# this operation will fetch all the attachments from SMAX to JIRA\r\n# Modified on 21 Jn 2022 by Ashwini Shalke to re-built the logic for attachments\r\n# Modified on 18 July 2022 by Ashwini Shalke for error logs\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\nimport time\r\nimport datetime\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    try:\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# main function\r\ndef execute(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword, smax_authToken, smax_tenantId,\r\n            smax_baseurl,smax_FieldID,smax_jirasmaxid_list,smax_request_id_list,projectNames, creator, lastUpdate, conn_timeout,http_fail_status_codes):\r\n    message = \"\"\r\n    result = \"False\"\r\n    tresult = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    provider_issue = \"\"\r\n    errorLogs = \"\"\r\n    reqUrl =\"\"\r\n    #lastUpdate = \"1657621020899\"\r\n\r\n    try:\r\n        # requirement external modules\r\n        install(\"requests\")\r\n\r\n        import requests\r\n        import json\r\n\r\n\r\n        if len(smax_jirasmaxid_list.split(\"♪\")) > 0:\r\n            for issues in smax_jirasmaxid_list.split(\"♪\"):\r\n                if issues:\r\n                    status_codes = json.loads(http_fail_status_codes)\r\n                    jiraticketID = str(issues.split(\"♫\")[0])\r\n                    smaxticketID = str(issues.split(\"♫\")[1])\r\n                    attachmentDetailsFromSMAX = \"\"\r\n                    attachmentDetailsFromJira = []\r\n                    filesListFromSMAX =[]\r\n                    filesArrayForJira = []\r\n\r\n################calling getAttachmentFromJIRA to fetch all attachments from SMAX based on smaxTicketID##########\r\n                    attachmentsFromSMAX = getAttachmentsFROMSMAX(smax_baseurl, smax_tenantId, smax_authToken,smaxticketID,jiraticketID,lastUpdate,smax_request_id_list,status_codes)\r\n\r\n                    tresult = attachmentsFromSMAX[\"result\"]\r\n                    message = attachmentsFromSMAX[\"message\"]\r\n                    errorType = attachmentsFromSMAX[\"errorType\"]\r\n                    provider_issue = attachmentsFromSMAX[\"provider_issue\"]\r\n                    attachmentDetailsFromSMAX = attachmentsFromSMAX[\"fileDetailsFromSMAX\"]\r\n                    errorLogs += attachmentsFromSMAX[\"errorLogs\"]\r\n                    if tresult == \"False\" and provider_issue == \"True\":\r\n                        raise Exception(message)\r\n                    elif tresult == \"False\" and provider_issue != \"True\":\r\n                        continue\r\n\r\n################calling fetchAttachmentsFromSMAX to fetch all attachments from JIRA based on jiraticketID###############\r\n                    if attachmentDetailsFromSMAX:\r\n                        attachmentsFromJira = getAttachmentsFromJIRA(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword, jiraticketID,smaxticketID,\r\n                           creator,smax_FieldID,status_codes)\r\n\r\n                        tresult = attachmentsFromJira[\"result\"]\r\n                        message = attachmentsFromJira[\"message\"]\r\n                        errorType = attachmentsFromJira[\"errorType\"]\r\n                        errorProvider = attachmentsFromJira[\"errorProvider\"]\r\n                        provider_issue = attachmentsFromJira[\"provider_issue\"]\r\n                        attachmentDetailsFromJira = attachmentsFromJira[\"attachmentDetailsArray\"]\r\n                        errorLogs += attachmentsFromJira[\"errorLogs\"]\r\n\r\n                        if tresult == \"False\" and provider_issue == \"True\":\r\n                            raise Exception(message)\r\n                        elif tresult == \"False\" and provider_issue != \"True\":\r\n                            continue\r\n\r\n####################calling compareFiles to get the list of new attachments for SMAX##################################\r\n                        filesFromSMAX = compareFiles(attachmentDetailsFromSMAX, attachmentDetailsFromJira)\r\n\r\n                        result = filesFromSMAX[\"result\"]\r\n                        message = filesFromSMAX[\"message\"]\r\n                        errorType = filesFromSMAX[\"errorType\"]\r\n                        errorLogs += filesFromSMAX[\"errorMessage\"]\r\n                        filesListFromSMAX = filesFromSMAX['attachmentDetailArrayFromSMAX']\r\n\r\n####################calling compareFiles to get the list of new attachments for SMAX##################################\r\n                        if filesListFromSMAX:\r\n                            downloadFileForJira = downloadFileInDrive(smax_baseurl,smax_tenantId,filesListFromSMAX,smax_authToken,status_codes,smaxticketID,jiraticketID)\r\n\r\n                            tresult = downloadFileForJira[\"result\"]\r\n                            message = downloadFileForJira[\"message\"]\r\n                            errorType = downloadFileForJira[\"errorType\"]\r\n                            errorProvider = downloadFileForJira[\"errorProvider\"]\r\n                            provider_issue = downloadFileForJira[\"provider_issue\"]\r\n                            filesArrayForJira = downloadFileForJira['FilesArray']\r\n                            errorLogs += downloadFileForJira[\"errorLogs\"]\r\n\r\n                            if tresult == \"False\" and provider_issue == \"True\":\r\n                                raise Exception(message)\r\n                            elif tresult == \"False\" and provider_issue != \"True\":\r\n                                continue\r\n################calling uploadFileToJira to upload all attachments to Jira based on jiraTicketID##########\r\n                        if filesArrayForJira != []:\r\n                            uploadFilesJIRA = uploadFileToJira(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword, jiraticketID,smaxticketID,filesArrayForJira,status_codes)\r\n\r\n                            tresult = uploadFilesJIRA[\"result\"]\r\n                            message = uploadFilesJIRA[\"message\"]\r\n                            errorType = uploadFilesJIRA[\"errorType\"]\r\n                            errorProvider = uploadFilesJIRA[\"errorProvider\"]\r\n                            provider_issue = uploadFilesJIRA[\"provider_issue\"]\r\n                            errorLogs += uploadFilesJIRA[\"errorLogs\"]\r\n                            if tresult == \"False\" and provider_issue == \"True\":\r\n                                raise Exception(message)\r\n                            elif tresult == \"False\" and provider_issue != \"True\":\r\n                                continue\r\n                    else:\r\n                        result = \"True\"\r\n                        message = \"No attachment in SMAX, SMAXID :- \" +str(smaxticketID)\r\n\r\n            result = True\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        if not errorType:\r\n            errorType = \"e30000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        if not errorProvider:\r\n            errorProvider = \"SMAX\"\r\n        if not errorLogs:\r\n            errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + reqUrl + \"||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + message + \"|||\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage, \"errorLogs\": errorLogs, \"provider_issue\": provider_issue}\r\n\r\n# get the list of attachments from SMAX based on SMAX ticket ID\r\ndef getAttachmentsFROMSMAX(smax_baseurl, smax_tenantId, smax_authToken,smaxticketID,jiraticketID,lastUpdate,smax_request_id_list,status_codes):\r\n    message = \"\"\r\n    result = \"\"\r\n    requestAttachURL = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    provider_issue = \"\"\r\n    errorLogs = \"\"\r\n    response = \"\"\r\n    failCodes = \"\"\r\n    responseCode = \"\"\r\n\r\n    try:\r\n        import json\r\n        import requests\r\n        import platform\r\n        import mimetypes\r\n\r\n        attachmentLinkResponse = {}\r\n        attachmentList = []\r\n        responseMeta = {}\r\n        attachmentCount = 0\r\n        fileDetailsFromSMAX = \"\"\r\n\r\n########create smax URL to get attachments for a Request\r\n        reqUrl = smax_baseurl + \"/rest/\" + smax_tenantId + \"/ems/Request/\" + smaxticketID + \"?layout=RequestAttachments,CreateTime\"\r\n\r\n########basicAuthCredentials = (smax_user, smax_password)\r\n        authHeaders = {\"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\": smax_authToken}\r\n\r\n########request to pull the attachment links\r\n        response = requests.get(reqUrl, headers=authHeaders, cookies=cookies)\r\n        responseCode = str(response.status_code)\r\n        \r\n        if response.status_code == 200:\r\n            responseMeta = json.loads(response.text)\r\n            attachmentCount = len(responseMeta[\"entities\"])\r\n            if responseMeta[\"meta\"][\"completion_status\"] == \"OK\":\r\n                if attachmentCount > 0:\r\n                    attachmentLinkResponse = json.loads(response.content)\r\n\r\n                    #extract list of attached file attributes\r\n                    if \"RequestAttachments\" in attachmentLinkResponse[\"entities\"][0][\"properties\"]:\r\n                        attachmentJSONString = attachmentLinkResponse[\"entities\"][0][\"properties\"][\r\n                            \"RequestAttachments\"]\r\n                        attachmentJSONString = attachmentJSONString.replace('True','true').replace('TRUE','true').replace('False','false').replace('FALSE','false')\r\n                        attachmentJSONList = json.loads(attachmentJSONString)\r\n                        attachmentList = attachmentJSONList[\"complexTypeProperties\"]\r\n                        attachmentLastUpdateTime = attachmentLinkResponse[\"entities\"][0][\"properties\"][\r\n                                    \"LastUpdateTime\"]\r\n                        attachmentCreateTime = attachmentLinkResponse[\"entities\"][0][\"properties\"][\r\n                                    \"CreateTime\"]\r\n                        \r\n\r\n                        # loop over json array containing properties of file\r\n                        if not lastUpdate:\r\n                            lastUpdate = int(attachmentCreateTime)\r\n                        if attachmentLastUpdateTime > int(lastUpdate):\r\n                            fileProperties = {}\r\n                            attachmentCount = 0\r\n                            if len(attachmentList) > 0:\r\n                                for fileProperties in attachmentList:\r\n                                    if \"file_name\" in fileProperties[\"properties\"]:\r\n                                        smaxFileId = fileProperties[\"properties\"][\"id\"]\r\n                                        smaxFileName = fileProperties[\"properties\"][\"file_name\"]\r\n                                        smaxFileLastUpdate = fileProperties[\"properties\"].get(\"LastUpdateTime\")\r\n\r\n                                        if smaxFileLastUpdate:\r\n                                            if (int(smaxFileLastUpdate) >= int(lastUpdate)):\r\n                                                fileDetailsFromSMAX += smaxFileName + \"♫\" + smaxFileId + \"♪\"\r\n                                                result = \"True\"\r\n                                                message = \"Attachments from SMAX\"\r\n                                            else:\r\n                                                result = \"True\"\r\n                                                message = \"No recent attachment to upload\"\r\n                        else:\r\n                            message = \"No latest attachment found in SMAX, SMAXID :- \" + str(smaxticketID)\r\n                            result = \"True\"\r\n                    else:\r\n                        result = \"True\"\r\n                        message = \"No attachment found in SMAX, SMAXID :- \" + str(smaxticketID)\r\n            else:\r\n                msg = \"GetAttachmentsFROMSMAX :- Failure in attachment http response: \" + str(responseMeta[\"meta\"][\"errorDetailsList\"]) + \" SMAXID :- \" + str(smaxticketID)\r\n                raise Exception(msg)\r\n        else:\r\n            failCodes = status_codes['smax']\r\n            if responseCode in failCodes:\r\n                provider_issue = \"True\"\r\n                msg = \"GetAttachmentsFROMSMAX:- Unsupported response from provider: \" + str(response.text) + \" :Response Code: \" + str(response.status_code)\r\n                raise Exception(msg)\r\n            else:\r\n                result = \"False\"\r\n                errorLogs += \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + reqUrl + \"||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + str(\r\n                    response.content) + \" :Response Code: \" + str(response.status_code) + \"|||\"\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n        if not responseCode:\r\n            provider_issue = \"True\"\r\n        errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + reqUrl + \"||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + message + \"|||\"\r\n\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorMessage\": errorMessage,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider,\"errorLogs\": errorLogs, \"provider_issue\": provider_issue,\"fileDetailsFromSMAX\":fileDetailsFromSMAX}\r\n\r\n\r\ndef getAttachmentsFromJIRA(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword, jiraticketID,smaxticketID,\r\n                           creator,smax_FieldID,status_codes):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = ''\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    response = \"\"\r\n    provider_issue = \"\"\r\n    errorLogs = \"\"\r\n    failCodes = \"\"\r\n    data = {}\r\n    arr = []\r\n    attachmentDetailsArray = []\r\n    responseCode = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        reqUrl = '{0}rest/api/2/search'.format(MarketPlace_jiraIssueURL)\r\n        data = {}\r\n        data[\"jql\"] = \"issue={0}\".format(jiraticketID)\r\n        data[\"startAt\"] = \"0\"\r\n        data[\"maxResults\"] = \"500\"\r\n        data[\"fields\"] = [\"attachment\", smax_FieldID]\r\n        inputString = json.dumps(data)\r\n\r\n        basicAuthCredentials = requests.auth.HTTPBasicAuth(MarketPlace_jiraUser, MarketPlace_jiraPassword)\r\n        headers = {'X-Atlassian-Token': 'no-check', 'Content-Type': 'application/json'}\r\n        response = requests.post(reqUrl, auth=basicAuthCredentials, headers=headers, data=inputString)\r\n        responseCode = str(response.status_code)\r\n\r\n        if response.status_code == 200:\r\n            responseData = {}\r\n            responseData = response.json()\r\n            arr = responseData[\"issues\"][0][\"fields\"][\"attachment\"]\r\n\r\n            if arr != []:\r\n                for i in arr:\r\n                    # attachments details\r\n                    fileName = i[\"filename\"]\r\n                    fileID = i[\"id\"]\r\n                    attachmentDetails = {}\r\n\r\n                    if fileName:\r\n                        attachmentDetails.update({\"fileName\": fileName})\r\n                    if fileID:\r\n                        attachmentDetails.update({\"fileID\": fileID})\r\n\r\n                    if attachmentDetails:\r\n                        attachmentDetailsArray.append(attachmentDetails)\r\n                        result = \"True\"\r\n                        message = \"Attachments present in JIRA ,\" + \" JIRAID :- \" + str(jiraticketID)\r\n            else:\r\n                result = \"True\"\r\n                message = \"No attachments in JIRA, \" + \"JIRAID :- \" + str(jiraticketID)\r\n        else:\r\n            failCodes = status_codes['jira']\r\n            if responseCode in failCodes:\r\n                provider_issue = \"True\"\r\n                msg = \"GetAttachmentsFromJIRA :- Unsupported response from the Provider  \" + str(response.text) + \" :Response Code: \" + str(\r\n                    response.status_code)\r\n                raise Exception(msg)\r\n            else:\r\n                errorLogs += \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + reqUrl + \"||ErrorProvider,JIRA||ProviderUrlBody,||ErrorMessage,\" + str(\r\n                    response.text) + \" :Response Code: \" + str(response.status_code) + \"|||\"\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"JIRA\"\r\n        if not responseCode:\r\n            provider_issue = \"True\"\r\n        errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + reqUrl + \"||ErrorProvider,JIRA||ProviderUrlBody,||ErrorMessage,\" + message + \"|||\"\r\n\r\n    return {\"result\": result, \"message\": message,\"errorType\": errorType,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage,\r\n            \"errorLogs\": errorLogs,\"provider_issue\": provider_issue,\"attachmentDetailsArray\": attachmentDetailsArray}\r\n\r\n\r\n#comparing the files in SMAX and JIRA and preparing the attachment list for JIRA\r\ndef compareFiles(attachmentDetailsFromSMAX, attachmentDetailsFromJira):\r\n    result = \"\"\r\n    message = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorType = \"\"\r\n    attachmentDetailArrayFromSMAX = []\r\n\r\n    try:\r\n        for file in attachmentDetailsFromSMAX.split(\"♪\"):\r\n            if file != '':\r\n                smaxFileName = str(file.split(\"♫\")[0])\r\n                smaxFileId = str(file.split(\"♫\")[1])\r\n                attachmentDetailFromSMAX = {}\r\n\r\n                if attachmentDetailsFromJira:\r\n                    for attach in attachmentDetailsFromJira:\r\n                        attachId = attach.get(\"fileID\")\r\n                        attachName = attach.get(\"fileName\")\r\n                        flag = \"\"\r\n\r\n                        smaxNewFileName = smaxFileId[:8] + \"_\" +smaxFileName\r\n                        smaxNewFileId = smaxFileId[:8]\r\n\r\n                        if attachId in smaxNewFileName[:len(attachId)] or attachId in smaxFileName[:len(attachId)]:\r\n                            result = \"True\"\r\n                            message = \"Parent of attachment is JIRA\"\r\n                            break\r\n                        elif smaxNewFileId in attachName[:len(smaxNewFileId)]:\r\n                            result = \"True\"\r\n                            message = \"SMAX Attachment exists in JIRA\"\r\n                            break\r\n                        else:\r\n                            flag = \"attachment doesn't exists\"\r\n                else:\r\n                    flag = \"attachment doesn't exists\"\r\n\r\n                if flag == \"attachment doesn't exists\":\r\n                    attachmentDetailFromSMAX.update({\"fileName\": smaxFileName})\r\n                    attachmentDetailFromSMAX.update({\"fileID\": smaxFileId})\r\n\r\n                if attachmentDetailFromSMAX:\r\n                    attachmentDetailArrayFromSMAX.append(attachmentDetailFromSMAX)\r\n                    result = \"True\"\r\n                    message = \"New Attachment to be added in JIRA\"\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorType = \"e20000\"\r\n\r\n    return {\"attachmentDetailArrayFromSMAX\":attachmentDetailArrayFromSMAX,\"result\":result,\"message\":message,\"errorMessage\": errorMessage,\"errorType\": errorType,\r\n            \"errorSeverity\": errorSeverity}\r\n\r\n\r\ndef uploadFileToJira(MarketPlace_jiraIssueURL, MarketPlace_jiraUser, MarketPlace_jiraPassword, jiraticketID,smaxticketID,filesArrayForJira,status_codes):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    errorLogs = \"\"\r\n    provider_issue = \"\"\r\n    failCodes = \"\"\r\n    response =\"\"\r\n    responseCode = \"\"\r\n\r\n    try:\r\n        import requests\r\n\r\n        basicAuthCredentials = requests.auth.HTTPBasicAuth(MarketPlace_jiraUser, MarketPlace_jiraPassword)\r\n        payload = {}\r\n        headers = {'X-Atlassian-Token': 'no-check'}\r\n        reqUrl = \"{0}rest/api/2/issue/{1}/attachments\".format(MarketPlace_jiraIssueURL, jiraticketID)\r\n\r\n        response = requests.post(reqUrl, data=payload, files=filesArrayForJira, headers=headers,\r\n                                     auth=basicAuthCredentials)\r\n        message = response.text\r\n        responseCode = str(response.status_code)\r\n\r\n        if response.status_code == 200:\r\n            result = \"True\"\r\n            message = \"File(s) Attached Successfully in JIRA, SMAXID :- \" +str(smaxticketID) +\" JIRAID :- \" + str(jiraticketID)\r\n        else:\r\n            failCodes = status_codes[\"jira\"]\r\n            if responseCode in failCodes:\r\n                provider_issue = \"True\"\r\n                msg = \"UploadFileToJira:- Unsupported response from provider: \" + str(response.text) + \" :Response Code: \" + str(\r\n                    response.status_code)\r\n                raise Exception(msg)\r\n            else:\r\n                errorLogs += \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + reqUrl + \"||ErrorProvider,JIRA||ProviderUrlBody,||ErrorMessage,\" + str(response.content) + \" :Response Code: \" + str(response.status_code) + \"|||\"\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        if not errorType:\r\n            errorType = \"e30000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"JIRA\"\r\n        if not responseCode:\r\n            provider_issue = \"True\"\r\n        errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + reqUrl + \"||ErrorProvider,JIRA||ProviderUrlBody,||ErrorMessage,\" + message + \"|||\"\r\n\r\n    return {\"result\": result, \"message\": str(message), \"errorType\": errorType, \"errorMessage\": errorMessage,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider,\"errorLogs\": errorLogs,\r\n            \"provider_issue\": provider_issue}\r\n\r\ndef downloadFileInDrive(smax_baseurl,smax_tenantId,filesListFromSMAX,smax_authToken,status_codes,smaxticketID,jiraticketID):\r\n    import os\r\n    import platform\r\n    import mimetypes\r\n\r\n    result = \"\"\r\n    message = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    provider_issue = \"\"\r\n    errorLogs = \"\"\r\n    failCodes = \"\"\r\n    fileDeletionPathList = []\r\n    FilesArray= []\r\n    my_os = platform.system()\r\n    response = \"\"\r\n    responseCode = \"\"\r\n\r\n    try:\r\n        import requests\r\n        for file in filesListFromSMAX:\r\n            fileId = file.get(\"fileID\")\r\n            fileName = file.get(\"fileName\")\r\n\r\n            FILES = \"\"\r\n            smaxTag = fileId[:8]\r\n            newFileName = smaxTag + \"_\" + fileName\r\n\r\n            authHeaders = {\"TENANTID\": \"keep-alive\"}\r\n            cookies = {\"SMAX_AUTH_TOKEN\": smax_authToken}\r\n\r\n            # create URL of attached file to download\r\n            reqUrl = smax_baseurl + \"/rest/\" + smax_tenantId + \"/ces/attachment/\" + fileId\r\n            # download attached file\r\n            response = requests.get(reqUrl, headers=authHeaders,cookies=cookies)\r\n            responseCode = str(response.status_code)\r\n\r\n        # if response is successful\r\n            if response.status_code == 200:\r\n                data = response.content\r\n\r\n                if (my_os == \"Windows\"):\r\n                    downloadFilePath = 'c:\\\\temp\\\\' + newFileName\r\n                    fileDeletionPathList.append(downloadFilePath)\r\n                    open(downloadFilePath, 'wb').write(data)\r\n\r\n                    fileType = mimetypes.guess_type(downloadFilePath)[\r\n                           0] or 'application/octet-stream'\r\n                    FILES = ('file', (\r\n                        newFileName, open(downloadFilePath, 'rb'), fileType))\r\n                else:\r\n                    downloadFilePath = '\\\\tmp\\\\' + newFileName\r\n                    fileDeletionPathList.append(downloadFilePath)\r\n                    open(downloadFilePath, 'wb').write(data)\r\n\r\n                    fileType = mimetypes.guess_type(downloadFilePath)[\r\n                       0] or 'application/octet-stream'\r\n                    FILES = ('file', (\r\n                        newFileName, open(downloadFilePath, 'rb'), fileType))\r\n\r\n                if FILES:\r\n                    FilesArray.append(FILES)\r\n                    message = \"Downloaded file for JIRA\"\r\n                    result = \"True\"\r\n            else:\r\n                failCodes = status_codes[\"smax\"]\r\n                if responseCode in failCodes:\r\n                    provider_issue = \"True\"\r\n                    msg = \"DownloadFileInDrive :- Unsupported response from provider: \" + str(response.text) + \" :Response Code: \" + str(\r\n                        response.status_code)\r\n                    raise Exception(msg)\r\n                else:\r\n                    errorLogs += \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + reqUrl + \"||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + str(\r\n                        response.content) + \" :Response Code: \" + str(response.status_code) + \"|||\"\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n        if not responseCode:\r\n            provider_issue = \"True\"\r\n        errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + reqUrl + \"||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + message + \"|||\"\r\n        \r\n\r\n    return {\"result\": result, \"message\": str(message), \"errorType\": errorType, \"errorMessage\": errorMessage,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider,\"errorLogs\": errorLogs, \"provider_issue\": provider_issue,\"FilesArray\": FilesArray}"
  outputs:
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - errorLogs
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
