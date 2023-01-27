########################################################################################################################
#!!
#! @description: This operation creates the SMAX Payload body for executing SMAX CREATE or UPDATE REST API
#!
#! @input SMAX_studio_app: SMAX entity where records should be added/ updated/ deleted
#! @input service: SMAX Service Definition ID
#! @input new_ext_id: New external ID of the retrieved article/ page
#! @input new_external_id_list: List of new external ID of the retrieved article/ page
#! @input smax_ext_id_list: External IDs list retrieved from SMAX Articles filter by Source System - CernerGitHUB
#! @input extid_smaxid_articlehash: Content containing external ID of the retrieved article/ page, SMAX Article ID and the article hash.
#! @input title: Title of the article
#! @input article_body: Body of the article
#! @input article_hash: Hash value of the article
#! @input SourceSystem: Source system from where the data was retrieved for processing
#! @input SMAX_Operation: Operation to perform in SMAX - CREATE or UPDATE
#!
#! @output smaxDataPayload: SMAX REST API Create/ Update json body
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: build_SMAX_KM_Article_CreateOrUpdate_payload
  inputs:
    - SMAX_studio_app
    - service
    - new_ext_id
    - new_external_id_list
    - smax_ext_id_list
    - extid_smaxid_articlehash
    - title
    - article_body
    - article_hash
    - SourceSystem
    - SMAX_Operation
  python_action:
    use_jython: false
    script: "# do not remove the execute function\n#This function creates the SMAX Payload body for executing SMAX CREATE or UPDATE REST API\ndef execute(SMAX_studio_app,service,new_ext_id,new_external_id_list,smax_ext_id_list,extid_smaxid_articlehash,title,article_body,article_hash,SourceSystem,SMAX_Operation):\n    # code goes here\n    message = \"\"\n    result = \"False\"\n    errorType = \"\"\n    errorSeverity = \"\"\n    errorProvider = \"\"\n    errorMessage = \"\"\n    errorLogs = \"\"\n    smaxDataPayload = \"\"\n    description = \"Content from Cerner GITHUB\"\n\n    try:\n        import requests\n        import json\n\n        if SMAX_Operation == \"CREATE\":\n            # Create data for insert in SMAX\n            smaxDataI = {}\n            smaxDataI['entities'] = []\n            smaxDataI['operation'] = \"CREATE\"\n        \n            #Do list iteration for the below line and then pass articles to this function\n            #articles = service_article_list.split(\"♪♪\")\n            #Python operation created for data extraction - extract_data_fields_SMAX_KMArticle\n            smaxDataI['entities'] = [0]\n        \n            #Actual SMAX Article CREATE Payload\n            smaxDataI['entities'][0] = {}\n            smaxDataI['entities'][0][\"entity_type\"] = SMAX_studio_app\n            smaxDataI['entities'][0][\"properties\"] = {}\n            smaxDataI['entities'][0][\"properties\"][\"Service\"] = service\n            smaxDataI['entities'][0][\"properties\"][\"ExternalId\"] = new_ext_id\n            smaxDataI['entities'][0][\"properties\"][\"Title\"] = title\n            smaxDataI['entities'][0][\"properties\"][\"Content\"] = article_body\n            smaxDataI['entities'][0][\"properties\"][\"Description\"] = description\n            smaxDataI['entities'][0][\"properties\"][\"ArticleContent\"] = description\n            smaxDataI['entities'][0][\"properties\"][\"ArticleHash_c\"] = article_hash\n            smaxDataI['entities'][0][\"properties\"][\"Subtype\"] = \"Article\"\n            smaxDataI['entities'][0][\"properties\"][\"SourceSystem_c\"] = SourceSystem\n            smaxDataI['entities'][0][\"properties\"][\"PhaseId\"] = \"External\"\n            smaxDataI['entities'][0][\"related_properties\"] = {}\n        \n            smaxDataI = removenull_fm_dict(smaxDataI)[\"output\"]\n            if len(smaxDataI['entities']) <1:\n                smaxDataI = None\n            else:\n                smaxDataPayload = json.dumps(smaxDataI)\n        \n            message = 'Data Prepared for Insert into SMAX'\n            result = \"True\"\n        elif SMAX_Operation == \"UPDATE\":\n            new_external_id_list = new_external_id_list.split(\",\")\n            smax_ext_id_list = smax_ext_id_list.strip().split(\",\")\n            # Create data for Update in SMAX\n            smaxDataU = {}\n            smaxDataU['entities'] = []\n            smaxDataU['operation'] = \"UPDATE\"\n            \n            smaxDataU['entities'] = [0]\n            \n            #Actual SMAX Article UPDATE Payload\n            if extid_smaxid_articlehash:\n                extid_smaxid_articlehash = json.loads(extid_smaxid_articlehash)\n                smax_id_articlehash = extid_smaxid_articlehash[new_ext_id]\n                smax_id = smax_id_articlehash.split(\"||\")[0]\n                smax_articlehash = smax_id_articlehash.split(\"||\")[1]\n                if smax_articlehash != article_hash:\n                    smaxDataU['entities'][0] = {}\n                    smaxDataU['entities'][0][\"entity_type\"] = SMAX_studio_app\n                    smaxDataU['entities'][0][\"properties\"] = {}\n                    smaxDataU['entities'][0][\"properties\"][\"Id\"] = smax_id\n                    smaxDataU['entities'][0][\"properties\"][\"Service\"] = service\n                    smaxDataU['entities'][0][\"properties\"][\"ExternalId\"] = new_ext_id\n                    smaxDataU['entities'][0][\"properties\"][\"Title\"] = title\n                    smaxDataU['entities'][0][\"properties\"][\"Content\"] = article_body\n                    smaxDataU['entities'][0][\"properties\"][\"Description\"] = description\n                    smaxDataU['entities'][0][\"properties\"][\"ArticleContent\"] = description\n                    smaxDataU['entities'][0][\"properties\"][\"ArticleHash_c\"] = article_hash\n                    smaxDataU['entities'][0][\"properties\"][\"Subtype\"] = \"Article\"\n                    smaxDataU['entities'][0][\"properties\"][\"SourceSystem_c\"] = SourceSystem\n                    smaxDataU['entities'][0][\"properties\"][\"PhaseId\"] = \"External\"\n                    smaxDataU['entities'][0][\"related_properties\"] = {}\n                \n                    smaxDataU = removenull_fm_dict(smaxDataU)[\"output\"]\n                    if len(smaxDataU['entities']) <1:\n                     smaxDataU = None\n                    else:\n                        smaxDataPayload = json.dumps(smaxDataU)\n                    message = 'Data Prepared for Update into SMAX'\n                    result = \"True\"\n                else:\n                    message = 'No Data to Insert or Update into SMAX'\n                    result = \"Bypass\"\n            \n    except Exception as e:\n        message = e\n        result = \"False\"\n        errorMessage = message\n        errorType = 'e30000'\n        if not errorProvider:\n            errorProvider = 'SMAX'\n        errorSeverity = \"ERROR\"\n        errorLogs = \"ProviderUrl,||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + str(message) + \"|||\"\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\"errorProvider\": errorProvider,\"errorMessage\":errorMessage,\"errorLogs\":errorLogs, \"smaxDataPayload\": smaxDataPayload}\n        \n# you can add additional helper methods below.\ndef removenull_fm_dict(input):\n    result = \"False\"\n    message = \"\"\n    output = \"\"\n    try:\n        ii = len(input['entities'])\n        i = 0\n        a = 0\n        while i < ii:\n            if input['entities'][a] == 0:\n                del input['entities'][a]\n                a -= 1\n            i += 1\n            a += 1\n        output = input\n        result = \"True\"\n        message = \"Input processed and null values removed\"\n\n    except Exception as e:\n        result = \"False\"\n        message = \"Failed to clean NULL Values: \" + str(e)\n\n    return {\"result\":result,\"message\":message,\"output\":output}"
  outputs:
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - smaxDataPayload
    - errorLogs
  results:
    - FAILURE: '${result=="False"}'
    - SUCCESS
