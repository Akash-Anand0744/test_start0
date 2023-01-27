########################################################################################################################
#!!
#! @description: This Python operation creates the SMAX Payload body for executing SMAX DELETE REST API
#!
#! @input SMAX_studio_app: SMAX entity where records should be added/ updated/ deleted
#! @input ext_id: External ID of the article
#! @input smax_ext_id_list: External IDs list retrieved from SMAX Articles filter by Source System - CernerGitHUB
#! @input extid_smaxid_articlehash: Content containing external ID of the retrieved article/ page, SMAX Article ID and the article hash.
#! @input SourceSystem: Source system from where the data was retrieved for processing - CernerGitHUB
#!
#! @output smaxDataDelete: SMAX REST API Delete json body
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: build_SMAX_KM_Article_Delete_payload
  inputs:
    - SMAX_studio_app
    - ext_id
    - smax_ext_id_list
    - extid_smaxid_articlehash
    - SourceSystem
  python_action:
    use_jython: false
    script: "# do not remove the execute function\ndef execute(SMAX_studio_app,ext_id,smax_ext_id_list,extid_smaxid_articlehash,SourceSystem):\n    # code goes here\n    message = \"\"\n    result = \"False\"\n    errorType = \"\"\n    errorSeverity = \"\"\n    errorProvider = \"\"\n    errorMessage = \"\"\n    errorLogs = \"\"\n    smaxDataDelete = \"\"\n    try:\n        import requests\n        import json\n\n        smax_ext_id_list = smax_ext_id_list.strip().split(\",\")\n\n        # Create data for insert in SMAX\n        smaxDataD = {}\n        smaxDataD['entities'] = []\n        smaxDataD['operation'] = \"DELETE\"\n        \n        smaxDataD['entities'] = [0]\n\n        extid_smaxid_articlehash = json.loads(extid_smaxid_articlehash)\n        smax_id_articlehash = extid_smaxid_articlehash[ext_id]\n        smax_id = smax_id_articlehash.split(\"||\")[0]\n        smaxDataD['entities'][0] = {}\n        smaxDataD['entities'][0][\"entity_type\"] = SMAX_studio_app\n        smaxDataD['entities'][0][\"properties\"] = {}\n        smaxDataD['entities'][0][\"properties\"][\"Id\"] = smax_id\n        \n        smaxDataD = removenull_fm_dict(smaxDataD)[\"output\"]\n        if len(smaxDataD['entities']) <1:\n            smaxDataD = None\n        else:\n            smaxDataDelete = json.dumps(smaxDataD)\n        \n        message = 'Data Prepared for Delete in SMAX'\n        result = \"True\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n        errorMessage = message\n        errorType = 'e30000'\n        if not errorProvider:\n            errorProvider = 'SMAX'\n        errorSeverity = \"ERROR\"\n        errorLogs = \"ProviderUrl,||ErrorProvider,SMAX||ProviderUrlBody,||ErrorMessage,\" + str(message) + \"|||\"\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\"errorProvider\": errorProvider,\"errorMessage\":errorMessage,\"errorLogs\":errorLogs, \"smaxDataDelete\": smaxDataDelete}\n        \n# you can add additional helper methods below.\ndef removenull_fm_dict(input):\n    result = \"False\"\n    message = \"\"\n    output = \"\"\n    try:\n        ii = len(input['entities'])\n        i = 0\n        a = 0\n        while i < ii:\n            if input['entities'][a] == 0:\n                del input['entities'][a]\n                a -= 1\n            i += 1\n            a += 1\n        output = input\n        result = \"True\"\n        message = \"Input processed and null values removed\"\n\n    except Exception as e:\n        result = \"False\"\n        message = \"Failed to clean NULL Values: \" + str(e)\n\n    return {\"result\":result,\"message\":message,\"output\":output}"
  outputs:
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - smaxDataDelete
    - errorLogs
  results:
    - FAILURE: '${result=="False"}'
    - SUCCESS
