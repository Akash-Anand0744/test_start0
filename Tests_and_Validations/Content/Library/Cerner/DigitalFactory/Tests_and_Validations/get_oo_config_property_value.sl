namespace: Cerner.DigitalFactory.Tests_and_Validations
operation:
  name: get_oo_config_property_value
  inputs:
    - key_config
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      def execute(key_config):
          import json

          try:
              key_value_json = ''
              oo_config_value = ''
              message = ''

              oo_config_value = get_sp(key_config)

              result = "True"
              message = 'Successfully retrieved OO Configuration Value'

          except Exception as e:
              message = e
              errormessage = message
              result = "False"
          return {"result": result, "message": message, "errormessage": errormessage,"oo_config_value": oo_config_value }
  outputs:
    - oo_config_value
    - message
    - errormessage
    - result
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
