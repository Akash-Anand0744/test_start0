########################################################################################################################
#!!
#! @description: This Python operation extracts the service, new_ext_id, article_hash and article_body from string containing these values delimited by ♪.
#!
#! @input article: Input string containg service, new_ext_id, article_hash and article_body delimited by ♪
#!
#! @output service: SMAX Service Definition ID
#! @output new_ext_id: New External Article ID
#! @output title: Article Title
#! @output article_hash: Article Hash value
#! @output article_body: Article Body
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: extract_data_fields_SMAX_KMArticle
  inputs:
    - article
  python_action:
    use_jython: false
    script: "# do not remove the execute function\ndef execute(article):\n    # code goes here\n    message = \"\"\n    result = \"False\"\n    errorType = \"\"\n    errorSeverity = \"\"\n    errorProvider = \"\"\n    errorMessage = \"\"\n    errorLogs = \"\"\n    try:\n        data = article.split(\"♪\")\n        service = data[0]\n        new_ext_id = data[1]\n        title = data[2]\n        article_hash = data[3]\n        article_body = data[4]\n        result = \"True\"\n        message = \"Successfull extracted Article data\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n        errorMessage = message\n        errorType = 'e30000'\n        if not errorProvider:\n            errorProvider = 'OO'\n        errorSeverity = \"ERROR\"\n        errorLogs = \"ProviderUrl,||ErrorProvider,OO||ProviderUrlBody,||ErrorMessage,\" + str(message) + \"|||\"\n    \n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\"errorProvider\": errorProvider,\"errorMessage\":errorMessage,\"errorLogs\":errorLogs, \"service\": service, \"new_ext_id\": new_ext_id, \"title\": title, \"article_hash\": article_hash, \"article_body\": article_body}\n# you can add additional helper methods below."
  outputs:
    - service
    - new_ext_id
    - title
    - article_hash
    - article_body
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - errorLogs
  results:
    - FAILURE: '${result=="False"}'
      CUSTOM_0: '${result=="False"}'
    - SUCCESS
