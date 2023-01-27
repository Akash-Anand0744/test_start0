namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: prepareSMAXData
  inputs:
    - SMAX_studio_app
    - service_article_list
    - new_external_id_list
    - smax_ext_id_list:
        required: false
    - extid_smaxid_articlehash:
        required: false
    - SourceSystem
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      #def execute():
          # code goes here
      # you can add additional helper methods below.

      def execute(SMAX_studio_app,service_article_list,new_external_id_list,smax_ext_id_list,extid_smaxid_articlehash,SourceSystem):
          message = ""
          result = "False"
          errorType = ""
          errorSeverity = ""
          errorProvider = ""
          errorMessage = ""
          smaxDataInsert = ""
          smaxDataUpdate = ""
          smaxDataDelete = ""
          description = "Content from Cerner GITHUB"

          try:
              import requests
              import json

              new_external_id_list = new_external_id_list.split(",")
              smax_ext_id_list = smax_ext_id_list.strip().split(",")

              # Create data for insert in SMAX
              smaxDataI = {}
              smaxDataI['entities'] = []
              smaxDataI['operation'] = "CREATE"
              # Create data for Update in SMAX
              smaxDataU = {}
              smaxDataU['entities'] = []
              smaxDataU['operation'] = "UPDATE"
              # Create data for Update in SMAX
              smaxDataD = {}
              smaxDataD['entities'] = []
              smaxDataD['operation'] = "DELETE"
              if extid_smaxid_articlehash:
                  extid_smaxid_articlehash = json.loads(extid_smaxid_articlehash)

              ## Prepare data for insert
              if service_article_list:
                  articles = service_article_list.split("♪♪")
                  smaxDataI['entities'] = [0] * len(articles)
                  smaxDataU['entities'] = [0] * len(articles)
                  ii = 0
                  i = 0
                  for article in articles:
                      data = article.split("♪")
                      service = data[0]
                      new_ext_id = data[1]
                      title = data[2]
                      article_hash = data[3]
                      article_body = data[4]
                      if new_ext_id not in smax_ext_id_list:
                          smaxDataI['entities'][ii] = {}
                          smaxDataI['entities'][ii]["entity_type"] = SMAX_studio_app
                          smaxDataI['entities'][ii]["properties"] = {}
                          smaxDataI['entities'][ii]["properties"]["Service"] = service
                          smaxDataI['entities'][ii]["properties"]["ExternalId"] = new_ext_id
                          smaxDataI['entities'][ii]["properties"]["Title"] = title
                          smaxDataI['entities'][ii]["properties"]["Content"] = article_body
                          smaxDataI['entities'][ii]["properties"]["Description"] = description
                          smaxDataI['entities'][ii]["properties"]["ArticleContent"] = description
                          smaxDataI['entities'][ii]["properties"]["ArticleHash_c"] = article_hash
                          smaxDataI['entities'][ii]["properties"]["Subtype"] = "Article"
                          smaxDataI['entities'][ii]["properties"]["SourceSystem_c"] = SourceSystem
                          smaxDataI['entities'][ii]["properties"]["PhaseId"] = "External"
                          smaxDataI['entities'][ii]["related_properties"] = {}
                          ii += 1
                      elif new_ext_id in smax_ext_id_list:
                          smax_id_articlehash = extid_smaxid_articlehash[new_ext_id]
                          smax_id = smax_id_articlehash.split("||")[0]
                          smax_articlehash = smax_id_articlehash.split("||")[1]
                          if smax_articlehash != article_hash:
                              smaxDataU['entities'][i] = {}
                              smaxDataU['entities'][i]["entity_type"] = SMAX_studio_app
                              smaxDataU['entities'][i]["properties"] = {}
                              smaxDataU['entities'][i]["properties"]["Id"] = smax_id
                              smaxDataU['entities'][i]["properties"]["Service"] = service
                              smaxDataU['entities'][i]["properties"]["ExternalId"] = new_ext_id
                              smaxDataU['entities'][i]["properties"]["Title"] = title
                              smaxDataU['entities'][i]["properties"]["Content"] = article_body
                              smaxDataU['entities'][i]["properties"]["Description"] = description
                              smaxDataU['entities'][i]["properties"]["ArticleContent"] = description
                              smaxDataU['entities'][i]["properties"]["ArticleHash_c"] = article_hash
                              smaxDataU['entities'][i]["properties"]["Subtype"] = "Article"
                              smaxDataU['entities'][i]["properties"]["SourceSystem_c"] = SourceSystem
                              smaxDataU['entities'][i]["properties"]["PhaseId"] = "External"
                              smaxDataU['entities'][i]["related_properties"] = {}
                              i += 1

              # Prepare data for  delete  Article records
             # smax_article_hashs = smax_article_hash_list.split(",")
              smaxDataD['entities'] = [0] * len(smax_ext_id_list)

              i = 0
              if smax_ext_id_list:
                  for ext_id in smax_ext_id_list:
                      if ext_id:
                          if ext_id not in new_external_id_list:
                              smax_id_articlehash = extid_smaxid_articlehash[ext_id]
                              smax_id = smax_id_articlehash.split("||")[0]
                              smaxDataD['entities'][i] = {}
                              smaxDataD['entities'][i]["entity_type"] = SMAX_studio_app
                              smaxDataD['entities'][i]["properties"] = {}
                              smaxDataD['entities'][i]["properties"]["Id"] = smax_id
                              i += 1

              # remove null items
              smaxDataI = removenull_fm_dict(smaxDataI)["output"]
              smaxDataU = removenull_fm_dict(smaxDataU)["output"]
              smaxDataD = removenull_fm_dict(smaxDataD)["output"]

              if len(smaxDataI['entities']) <1:
                  smaxDataI = None
              else:
                  smaxDataInsert = json.dumps(smaxDataI)

              if len(smaxDataU['entities']) <1:
                  smaxDataU = None
              else:
                  smaxDataUpdate = json.dumps(smaxDataU)

              if len(smaxDataD['entities']) <1:
                  smaxDataD = None
              else:
                  smaxDataDelete = json.dumps(smaxDataD)

              message = 'Data Prepared for Insert Update and Delete in SMAX'
              result = "True"
          except Exception as e:
              message = e
              result = "False"
              errorMessage = message
              errorType = 'e30000'
              if not errorProvider:
                  errorProvider = 'OO'
              errorSeverity = "ERROR"
          return {"result": result, "message": message, "errorType": errorType, "errorSeverity": errorSeverity,"errorProvider": errorProvider,"errorMessage":errorMessage, "smaxDataInsert": smaxDataInsert,  "smaxDataUpdate": smaxDataUpdate,"smaxDataDelete": smaxDataDelete}

      def removenull_fm_dict(input):
          result = "False"
          message = ""
          output = ""
          try:
              ii = len(input['entities'])
              i = 0
              a = 0
              while i < ii:
                  if input['entities'][a] == 0:
                      del input['entities'][a]
                      a -= 1
                  i += 1
                  a += 1
              output = input
              result = "True"
              message = "Input processed and null values removed"

          except Exception as e:
              result = "False"
              message = "Failed to clean NULL Values: " + str(e)

          return {"result":result,"message":message,"output":output}
  outputs:
    - smaxDataInsert
    - smaxDataUpdate
    - smaxDataDelete
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
  results:
    - FAILURE: '${result=="False"}'
    - SUCCESS
