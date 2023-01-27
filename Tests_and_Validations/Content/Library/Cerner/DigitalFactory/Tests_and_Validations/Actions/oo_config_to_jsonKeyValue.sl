namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
operation:
  name: oo_config_to_jsonKeyValue
  inputs:
    - input_json
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      def execute(input_json):
          import json

          try:
              key_value_json = ''
              tt_json = {}
              message = ''

              tt_json = json.loads(input_json)
              for entity in tt_json["entities"]:
                  key = entity["properties"]["DisplayLabel"]
                  value = entity["properties"]["SysPropertyValue_c"]
                  key_value_json += '"' + key + '":"' + value + '",'

              key_value_json = key_value_json[:-1]
              key_value_json = '{' +  key_value_json + '}'
              result = "True"
              message = 'Successfully converted to json key value object'

          except Exception as e:
              message = e
              result = "False"
          return {"result": result, "message": message,"key_value_json": key_value_json }
  outputs:
    - key_value_json
    - message
  results:
    - SUCCESS
