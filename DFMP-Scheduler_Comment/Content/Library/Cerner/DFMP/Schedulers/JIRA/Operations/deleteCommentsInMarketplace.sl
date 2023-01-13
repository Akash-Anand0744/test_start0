namespace: Cerner.DFMP.Schedules.JIRA.Operations
operation:
  name: deleteCommentsInMarketplace
  inputs:
    - MP_jiraIssueURL: "${get_sp('MarketPlace.jiraIssueURL')}"
    - MP_jiraUser: "${get_sp('MarketPlace.jiraUser')}"
    - MP_jiraPassword: "${get_sp('MarketPlace.jiraPassword')}"
    - smax_user: "${get_sp('MarketPlace.smaxIntgUser')}"
    - smax_tenantId: "${get_sp('MarketPlace.tenantID')}"
    - smax_Url: "${get_sp('MarketPlace.smaxURL')}"
    - lastUpdate:
        required: false
    - smax_FieldID
    - smax_Bridge_ID
    - conn_timeout: "${get_sp('Cerner.DigitalFactory.connection_timeout')}"
    - smax_Token
    - domainName
    - jira_smaxjiraid_list
    - http_fail_status_codes: "${get_sp('Cerner.DigitalFactory.http_fail_status_codes')}"
    - previous_errorLogs:
        required: false
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for sync of comments From JIRA TO SMAX\r\n#   Operation: deleteCommentsInMarketplace\r\n#   Author: Sirisha Krishna Yalam(SY091463@cerner.net)\r\n#   Inputs:\r\n#       -  MP_jiraIssueURL\r\n#       -  MP_jiraUser\r\n#       -  MP_jiraPassword\r\n#       -  jira_smaxjiraid_list\r\n#       -  lastUpdate\r\n#       -  smax_Token\r\n#       -  smax_user\r\n#       -  smax_tenantId\r\n#       -  smax_Url\r\n#       -  smax_FieldID\r\n#       -  smax_Bridge_ID\r\n#       -  conn_timeout\r\n#       -  domainName\r\n#       -  http_fail_status_codes\r\n#       -  previous_errorLogs\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - errorType\r\n#       - errorMessage\r\n#       - errorSeverity\r\n#       - errorProvider\r\n#       - errorLogs\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\nimport datetime\r\nfrom datetime import datetime\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    try:\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\ninstall(\"time\")\r\ninstall(\"pytz\")\r\ninstall(\"markdown\")\r\n\r\n\r\n# main function\r\ndef execute(MP_jiraIssueURL, MP_jiraUser, MP_jiraPassword, jira_smaxjiraid_list,\r\n            lastUpdate, smax_Token, smax_user, smax_tenantId, smax_Url,\r\n            smax_FieldID, smax_Bridge_ID, conn_timeout, domainName, http_fail_status_codes, previous_errorLogs):\r\n    message = \"\"\r\n    result = \"\"\r\n    jiraticketID = \"\"\r\n    smaxticketID = \"\"\r\n    errorType = ''\r\n    errorMessage = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n    response = \"\"\r\n    provider_failure = \"\"\r\n    errorLogs = \"\"\r\n    reqUrl = \"\"\r\n    responseBody = \"\"\r\n    responseCode = \"\"\r\n    ProviderUrlBody = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        status_codes = json.loads(http_fail_status_codes)\r\n\r\n        if len(jira_smaxjiraid_list.split(\"♪\")) > 0:\r\n            for issues in jira_smaxjiraid_list.split(\"♪\"):\r\n\r\n                jiraticketID = str(issues.split(\"♫\")[0])\r\n                smaxticketID = str(issues.split(\"♫\")[1])\r\n\r\n                fetchCommentsFromJira = getDeletedJiraCommentData(MP_jiraIssueURL, MP_jiraUser, MP_jiraPassword,\r\n                                                                  jiraticketID, smaxticketID, smax_FieldID, lastUpdate,\r\n                                                                  conn_timeout, status_codes)\r\n\r\n                tresult = fetchCommentsFromJira[\"result\"]\r\n                message = fetchCommentsFromJira[\"message\"]\r\n                errorType = fetchCommentsFromJira[\"errorType\"]\r\n                errorLogs += fetchCommentsFromJira[\"errorLogs\"]\r\n                provider_failure = fetchCommentsFromJira[\"provider_failure\"]\r\n                deleted_comments_list = fetchCommentsFromJira[\"deleted_comments_list\"]\r\n                if tresult == \"False\" and provider_failure == \"True\":\r\n                    raise Exception(message)\r\n                elif tresult == \"False\" and provider_failure != \"True\":\r\n                    continue\r\n                if deleted_comments_list:\r\n                    # *******get the smax comment ID***************\r\n                    fetchSmaxCommentID = getSmaxCommentID(deleted_comments_list, smaxticketID, jiraticketID)\r\n                    tresult = fetchSmaxCommentID[\"result\"]\r\n                    message = fetchSmaxCommentID[\"message\"]\r\n                    errorType = fetchSmaxCommentID[\"errorType\"]\r\n                    errorLogs += fetchSmaxCommentID[\"errorLogs\"]\r\n                    smaxCommentIDS = fetchSmaxCommentID[\"smaxCommentIDS\"]\r\n\r\n                    for getSmaxCommID in smaxCommentIDS.split(\"♫♫\"):\r\n                        if getSmaxCommID:\r\n                            smaxCommentID = \"\"\r\n                            smaxExistingCommentID = \"\"\r\n                            commentUpdateUserId = \"\"\r\n                            jiraticketID = str(getSmaxCommID.split(\"♪\")[0])\r\n                            smaxticketID = str(getSmaxCommID.split(\"♪\")[1])\r\n                            comAssociateID = str(getSmaxCommID.split(\"♪\")[2])\r\n                            jiraCommentsHash = str(getSmaxCommID.split(\"♪\")[3])\r\n                            smaxCommentID = str(getSmaxCommID.split(\"♪\")[4])\r\n                            if not smaxCommentID:\r\n                                existingCommentID = getSmaxCommentIDOfExistingComment(smax_Url, smax_tenantId,\r\n                                                                                      smax_Token, jiraCommentsHash,\r\n                                                                                      smaxticketID, jiraticketID,\r\n                                                                                      conn_timeout, status_codes)\r\n                                smaxExistingCommentID = existingCommentID[\"existingCommentId\"]\r\n                                tresult = existingCommentID[\"result\"]\r\n                                message = existingCommentID[\"message\"]\r\n                                errorType = existingCommentID[\"errorType\"]\r\n                                errorProvider = existingCommentID[\"errorProvider\"]\r\n                                errorLogs += existingCommentID[\"errorLogs\"]\r\n                                provider_failure = existingCommentID[\"provider_failure\"]\r\n                                if tresult == \"False\" and provider_failure == \"True\":\r\n                                    raise Exception(message)\r\n                                elif tresult == \"False\" and provider_failure != \"True\":\r\n                                    errorLogs += existingCommentID[\"errorLogs\"]\r\n                                    continue\r\n                            if (smaxExistingCommentID != '' or smaxCommentID != ''):\r\n                                # ***************** FETCH USERID From SMAX *************\r\n                                fetchUserIdFromSmax = getUserID(smax_Token, smax_Url, smax_tenantId, smax_Bridge_ID,\r\n                                                                smax_user, comAssociateID, domainName, smaxticketID,\r\n                                                                jiraticketID,conn_timeout)\r\n                                commentUpdateUserId = fetchUserIdFromSmax[\"commentUpdateUserId\"]\r\n                                # *************frame input body to API********************\r\n                                fetchPostData = getPostData(commentUpdateUserId, smaxCommentID, smaxExistingCommentID)\r\n                                data = fetchPostData[\"data\"]\r\n                                smaxCommID = fetchPostData[\"smaxCommID\"]\r\n                                # ***********update the smax comment with jira delete comment*************\r\n                                updateSmaxComment = updateSmaxExistingComment(smax_Url, smax_tenantId, smax_Token,\r\n                                                                              smaxticketID, jiraticketID, data,\r\n                                                                              smaxCommID, status_codes,conn_timeout)\r\n\r\n                                tresult = updateSmaxComment[\"result\"]\r\n                                message = updateSmaxComment[\"message\"]\r\n                                errorType = updateSmaxComment[\"errorType\"]\r\n                                errorProvider = updateSmaxComment[\"errorProvider\"]\r\n                                provider_failure = updateSmaxComment[\"provider_failure\"]\r\n                                errorLogs += updateSmaxComment[\"errorLogs\"]\r\n                                if tresult == \"False\" and provider_failure == \"True\":\r\n                                    raise Exception(message)\r\n                                elif tresult == \"False\" and provider_failure != \"True\":\r\n                                    continue\r\n                else:\r\n                    result = \"True\"\r\n                    message = \"No recent deleted comments for Jira TicketID \" + jiraticketID + \" and smax RequestID \" + smaxticketID\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        if not errorType:\r\n            errorType = \"e30000\"\r\n        errorSeverity = \"ERROR\"\r\n        if not errorProvider:\r\n            errorProvider = \"JIRA\"\r\n        errorMessage = message\r\n        errorLogs += \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + str(reqUrl) + \"||ErrorProvider,JIRA||ProviderUrlBody,\" + ProviderUrlBody + \"||ErrorMessage,\" + str(\r\n            message) + \": Response Code: \" + responseCode + \"|||\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\r\n            \"errorProvider\": errorProvider, \"errorMessage\": errorMessage, \"errorLogs\": errorLogs + previous_errorLogs,\r\n            \"provider_failure\": provider_failure}\r\n\r\n\r\ndef getDeletedJiraCommentData(MP_jiraIssueURL, MP_jiraUser, MP_jiraPassword, jiraticketID, smaxticketID, smax_FieldID,\r\n                              lastUpdate, conn_timeout, status_codes):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    attachmentData = \"\"\r\n    deleted_comments_list = \"\"\r\n    provider_failure = \"\"\r\n    errorLogs = \"\"\r\n    responseCode = \"\"\r\n    responseBody = \"\"\r\n    ProviderUrlBody = \"\"\r\n    reqUrl = \"\"\r\n    failCodes = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        reqUrl = '{0}rest/api/2/issue/{1}?expand=changelog&fields=changelog'.format(MP_jiraIssueURL, jiraticketID)\r\n        basicAuthCredentials = requests.auth.HTTPBasicAuth(MP_jiraUser, MP_jiraPassword)\r\n        headers = {'X-Atlassian-Token': 'no-check', 'Content-Type': 'application/json'}\r\n        response = requests.get(reqUrl, auth=basicAuthCredentials, headers=headers, timeout=int(conn_timeout))\r\n        responseCode = str(response.status_code)\r\n        responseBody = str(response.json())\r\n        if response.status_code == 200:\r\n            responseData = {}\r\n            responseData = response.json()\r\n            arr = responseData[\"changelog\"]\r\n            if ((arr[\"total\"] == 0) or (len(arr[\"histories\"]) == 0)):\r\n                message = \"No recent deleted comments in JIRA\"\r\n                result = \"True\"\r\n            else:\r\n                for i in arr[\"histories\"]:\r\n                    DeletedTime = timeConversion(i[\"created\"])\r\n\r\n                    if lastUpdate:\r\n                        # ***********format last updated time***************\r\n                        lastUpdateDateTime = datetime.fromisoformat(lastUpdate)\r\n                        # *****************fetch recent deleted comments **********************************\r\n                        if ((DeletedTime >= lastUpdateDateTime) and (i[\"items\"][0][\"field\"] == \"Comment\")):\r\n                            deleted_comments_list += jiraticketID + \"♪\" + smaxticketID + \"♪\" + i[\"author\"][\r\n                                \"name\"] + \"♪\" + \\\r\n                                                     i[\"items\"][0][\"from\"] + \"♫♫\"\r\n                    else:\r\n                        if (i[\"items\"][0][\"field\"] == \"Comment\"):\r\n                            deleted_comments_list += jiraticketID + \"♪\" + smaxticketID + \"♪\" + i[\"author\"][\r\n                                \"name\"] + \"♪\" + \\\r\n                                                     i[\"items\"][0][\"from\"] + \"♫♫\"\r\n        else:\r\n            failCodes = status_codes['jira']\r\n            if responseCode in failCodes:\r\n                provider_failure = \"True\"\r\n                msg = \"Unsupported response from provider: \" + responseBody + \", Response Code: \" + responseCode\r\n                raise Exception(msg)\r\n            else:\r\n                errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + str(reqUrl) + \"||ErrorProvider,JIRA||ProviderUrlBody,\" + ProviderUrlBody + \"||ErrorMessage,\" + responseBody + \": Response Code: \" + responseCode + \"|||\"\r\n\r\n        if deleted_comments_list:\r\n            result = \"True\"\r\n            message = \"Pulled all the deleted comments\"\r\n        else:\r\n            result = \"True\"\r\n            message = \"No recent deleted comments in jiraIssueID \" + jiraticketID\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + str(reqUrl) + \"||ErrorProvider,JIRA||ProviderUrlBody,\" + ProviderUrlBody + \"||ErrorMessage,\" + str(e) + \": Response Code: \" + responseCode + \"|||\"\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"JIRA\"\r\n        if not responseCode:\r\n            provider_failure = \"True\"\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\r\n            \"errorProvider\": errorProvider, \"errorMessage\": errorMessage,\r\n            \"deleted_comments_list\": deleted_comments_list,\r\n            \"errorLogs\": errorLogs, \"provider_failure\": provider_failure}\r\n\r\n\r\ndef getSmaxCommentID(deleted_comments_list, smaxticketID, jiraticketID):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    smaxCommentIDS = \"\"\r\n    provider_failure = \"\"\r\n    errorLogs = \"\"\r\n    responseCode = \"\"\r\n    responseBody = \"\"\r\n    ProviderUrlBody = \"\"\r\n    reqUrl = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        import markdown\r\n        for issues in deleted_comments_list.split(\"♫♫\"):\r\n            if issues:\r\n                deletedComment = \"\"\r\n                jiraTikID = \"\"\r\n                smaxTikID = \"\"\r\n                comAssociateID = \"\"\r\n                smaxCommentID = \"\"\r\n                fetchsmaxID = \"\"\r\n                jira_comments_hash = \"\"\r\n                jiraTikID = str(issues.split(\"♪\")[0])\r\n                smaxTikID = str(issues.split(\"♪\")[1])\r\n                comAssociateID = str(issues.split(\"♪\")[2])\r\n                deletedComment = str(issues.split(\"♪\")[3])\r\n                html = markdown.markdown(deletedComment).replace('\\xa0', '').replace('\\xc2', '')\r\n                ## html string having smax comment id check\r\n                if len(html) > 109:\r\n                    tthtml = html[len(html) - 110:]\r\n                else:\r\n                    tthtml = html\r\n                if '--smaxCommentID:' in tthtml and 'Comment_From_Marketplace' in tthtml:\r\n                    fetchsmaxIDfromJiracomment = tthtml.split(\"--smaxCommentID:\")[1]\r\n                    fetchsmaxID = fetchsmaxIDfromJiracomment.split(\"@\")[0]\r\n                if fetchsmaxID:\r\n                    smaxCommentID = fetchsmaxID\r\n                    removeHTMLSmaxTag = html.split(\"{color:white}Do not edit this\")[0]\r\n                    removeHTMLSmaxTag = removeHTMLSmaxTag.replace(' ', '')\r\n                    jira_comments_hash = str(hash(removeHTMLSmaxTag))\r\n                else:\r\n                    html = html.replace(' ', '')\r\n                    jira_comments_hash = str(hash(str(html)))\r\n                smaxCommentIDS += jiraTikID + \"♪\" + smaxTikID + \"♪\" + comAssociateID + \"♪\" + jira_comments_hash + \"♪\" + smaxCommentID + \"♫♫\"\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n        \r\n        errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + str(reqUrl) + \"||ErrorProvider,SMAX||ProviderUrlBody,\" + ProviderUrlBody + \"||ErrorMessage,\" + str(message) + \": Response Code: \" + responseCode + \"|||\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\r\n            \"errorProvider\": errorProvider, \"errorMessage\": errorMessage, \"smaxCommentIDS\": smaxCommentIDS,\r\n            \"errorLogs\": errorLogs}\r\n\r\n\r\ndef getUserID(smax_Token, smax_Url, smax_tenantId, smax_Bridge_ID, smax_user, comAssociateID, domainName, smaxticketID,\r\n              jiraticketID,conn_timeout):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    commentUpdateUserName = \"\"\r\n    commentUpdateUserId = \"\"\r\n    reqUrl = \"\"\r\n    ProviderUrlBody = \"\"\r\n    responseCode = \"\"\r\n    responseBody = \"\"\r\n    errorLogs = \"\"\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        if comAssociateID != \"\":\r\n            commentUpdateUserName = comAssociateID + \"@\" + domainName + \"'\"\r\n        else:\r\n            commentUpdateUserName = smax_user\r\n\r\n        authHeaders = {\"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\": smax_Token}\r\n        reqUrl = smax_Url + \"/rest/\" + smax_tenantId + \"/ems/Person?layout=Id,Upn,Email,EmployeeStatus&filter=Upn='\" + commentUpdateUserName + \"'\"\r\n        response = requests.get(reqUrl, headers=authHeaders, cookies=cookies, timeout=int(conn_timeout))\r\n        responseCode = str(response.status_code)\r\n        responseBody = str(response.content)\r\n        if response.status_code == 200:\r\n            entityJsonArray = json.loads(response.content)\r\n            if 'properties' in str(entityJsonArray):\r\n                commentUpdateUserId = entityJsonArray[\"entities\"][0][\"properties\"][\"Id\"]\r\n            else:\r\n                commentUpdateUserId = smax_Bridge_ID\r\n        else:\r\n            commentUpdateUserId = smax_Bridge_ID\r\n\r\n    except Exception as e:\r\n        message = str(reqUrl) + str(e)\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n        if not responseCode:\r\n            provider_failure = \"True\"\r\n        errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + str(reqUrl) + \"||ErrorProvider,SMAX||ProviderUrlBody,\" + ProviderUrlBody + \"||ErrorMessage,\" + str(message) + \": Response Code: \" + responseCode + \"|||\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\r\n            \"errorProvider\": errorProvider, \"errorMessage\": errorMessage, \"commentUpdateUserId\": commentUpdateUserId,\r\n            \"errorLogs\": errorLogs}\r\n\r\n\r\ndef timeConversion(commentUpdateTime):\r\n    from datetime import datetime\r\n    # **************Format updated time******************\r\n    TimeValue = ((commentUpdateTime.split('T'))[1].split(\".\"))[0]\r\n    size = len(TimeValue)\r\n    TimeValueHM = TimeValue[:size - 3]\r\n    DateValue = ((commentUpdateTime.split('T'))[0])\r\n    date_string = str(DateValue) + \" \" + str(TimeValueHM)\r\n    convertedTime = datetime.fromisoformat(date_string)\r\n\r\n    return convertedTime\r\n\r\n\r\ndef getSmaxCommentIDOfExistingComment(smax_Url, smax_tenantId, smax_Token, jiraCommentsHash, smaxticketID, jiraticketID,\r\n                                      conn_timeout, status_codes):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = ''\r\n    errorMessage = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n    existingCommentId = ''\r\n    responseBody = \"\"\r\n    responseCode = \"\"\r\n    errorLogs = \"\"\r\n    provider_failure = \"\"\r\n    reqUrl = \"\"\r\n    ProviderUrlBody = \"\"\r\n    failCodes = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        authHeaders = {\"TENANTID\": \"keep-alive\"}\r\n        cookies = {\"SMAX_AUTH_TOKEN\": smax_Token}\r\n        reqUrl = smax_Url + \"/rest/\" + smax_tenantId + \"/collaboration/comments/Request/\" + smaxticketID\r\n        response = requests.get(reqUrl, headers=authHeaders, cookies=cookies, timeout=int(conn_timeout))\r\n        responseBody = str(response.content)\r\n        responseCode = str(response.status_code)\r\n        if response.status_code == 200:\r\n            responseData = json.loads(response.content)\r\n            if responseData != []:\r\n                for i in responseData:\r\n                    commentsData = i['Body'].replace('\\xa0', '').replace('\\xc2', '').replace('\\3ucc', '')\r\n                    commentID = i[\"Id\"]\r\n\r\n                    if commentsData.find(\"jira_comments_id:\") != -1:\r\n                        split_string = commentsData.split('<p><span style=\"color:#ffffff\">jira_comments_id:', 1)\r\n                        substring = split_string[0].replace(' ', '')\r\n                        tts = len(substring)\r\n                        smax_comments_hash = str(hash(str(substring)))\r\n                    else:\r\n                        commentsData = commentsData.replace(' ', '')\r\n                        smax_comments_hash = str(hash(commentsData))\r\n                    if (smax_comments_hash == jiraCommentsHash):\r\n                        existingCommentId = commentID\r\n                        break\r\n                    else:\r\n                        result = True\r\n                        message = \"No comment found for jiraticketID \" + jiraticketID\r\n            message = \"Comments Hash conversion processed\"\r\n            result = \"True\"\r\n        else:\r\n            failCodes = status_codes['smax']\r\n            if responseCode in failCodes:\r\n                provider_failure = \"True\"\r\n                msg = \"Unsupported response from provider: \" + responseBody + \", Response Code: \" + responseCode\r\n                raise Exception(msg)\r\n            else:\r\n                errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + str(reqUrl) + \"||ErrorProvider,SMAX||ProviderUrlBody,\" + ProviderUrlBody + \"||ErrorMessage,\" + responseBody + \": Response Code: \" + responseCode + \"|||\"\r\n\r\n    except Exception as e:\r\n        message = str(reqUrl) + str(e)\r\n        result = \"False\"\r\n        if not errorType:\r\n            errorType = \"e30000\"\r\n        errorMessage = \"Failure in fetching the existing Smax Comment ID\" + str(message)\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n        if not responseCode:\r\n            provider_failure = \"True\"\r\n        errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + str(reqUrl) + \"||ErrorProvider,SMAX||ProviderUrlBody,\" + ProviderUrlBody + \"||ErrorMessage,\" + str(message) + \": Response Code: \" + responseCode + \"|||\"\r\n\r\n    return {\"result\": result, \"existingCommentId\": existingCommentId, \"message\": message, \"errorType\": errorType,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage,\r\n            \"errorLogs\": errorLogs, \"provider_failure\": provider_failure}\r\n\r\n\r\ndef updateSmaxExistingComment(smax_Url, smax_tenantId, smax_Token, smaxticketID, jiraticketID, data, smaxCommID,\r\n                              status_codes,conn_timeout):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    errorLogs = \"\"\r\n    reqUrl = \"\"\r\n    responseBody = \"\"\r\n    responseCode = \"\"\r\n    provider_failure = \"\"\r\n    ProviderUrlBody = \"\"\r\n    failCodes = \"\"\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        authHeaders = {\"TENANTID\": \"keep-alive\", 'Content-Type': 'application/json'}\r\n        cookies = {\"SMAX_AUTH_TOKEN\": smax_Token}\r\n        reqUrl = '{0}/rest/{1}/collaboration/comments/Request/{2}/{3}'.format(smax_Url, smax_tenantId, smaxticketID,\r\n                                                                              smaxCommID)\r\n        response = requests.put(reqUrl, headers=authHeaders, cookies=cookies, json=data, timeout=int(conn_timeout))\r\n        responseBody = str(response.text)\r\n        responseCode = str(response.status_code)\r\n        if response.status_code == 200:\r\n            message = \"Records Updated with delete comment\"\r\n            result = \"True\"\r\n        else:\r\n            failCodes = status_codes['smax']\r\n            if responseCode in failCodes:\r\n                provider_failure = \"True\"\r\n                msg = \"Unsupported response from provider: \" + responseBody + \", Response Code: \" + responseCode\r\n                raise Exception(msg)\r\n            else:\r\n                errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + str(reqUrl) + \"||ErrorProvider,SMAX||ProviderUrlBody,\" + ProviderUrlBody + \"||ErrorMessage,\" + responseBody + \": Response Code: \" + responseCode + \"|||\"\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        if not errorType:\r\n            errorType = \"e30000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n        if not responseCode:\r\n            provider_failure = \"True\"\r\n        errorLogs = \"SMAXRequestId,\" + smaxticketID + \"||JiraIssueId,\" + jiraticketID + \"||ProviderUrl,\" + str(reqUrl) + \"||ErrorProvider,SMAX||ProviderUrlBody,\" + ProviderUrlBody + \"||ErrorMessage,\" + str(message) + \": Response Code: \" + responseCode + \"|||\"\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\r\n            \"errorProvider\": errorProvider, \"errorMessage\": errorMessage, \"errorLogs\": errorLogs,\r\n            \"provider_failure\": provider_failure}\r\n\r\n\r\ndef getPostData(commentUpdateUserId, smaxCommentID, smaxExistingCommentID):\r\n    smaxCommID = \"\"\r\n    data = {}\r\n    data[\"IsSystem\"] = \"false\"\r\n    commentStringData = \"This comment has been deleted in JIRA\"\r\n    data[\"Body\"] = commentStringData\r\n    data[\"CommentFrom\"] = \"ExternalServiceDesk\"\r\n    data[\"Submitter\"] = {}\r\n    data[\"Submitter\"][\"UserId\"] = commentUpdateUserId\r\n    if smaxCommentID:\r\n        data[\"Id\"] = smaxCommentID\r\n        smaxCommID = smaxCommentID\r\n    else:\r\n        data[\"Id\"] = smaxExistingCommentID\r\n        smaxCommID = smaxExistingCommentID\r\n\r\n    return {\"data\": data, \"smaxCommID\": smaxCommID}"
  outputs:
    - result
    - message
    - errorSeverity
    - errorType
    - errorProvider
    - errorMessage
    - errorLogs
    - provider_failure
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
