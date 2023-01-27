########################################################################################################################
#!!
#! @description: Operation to extract the Property Value for one Property Key form json Object
#!
#! @input json_object: json object having propetry Values
#! @input property_key: Property Key Name for which Value to bee xtracted
#!!#
########################################################################################################################
namespace: Integrations.Cerner.DigitalFactory.SMAX_Update
operation:
  name: get_key_value_from_json_object
  inputs:
    - json_object
    - property_key
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for Getting Value for Key Property from Jason Object\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       - json_object\r\n#       - property_key\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - propery_value\r\n#   Created On: 24 Sep 2021\r\n#\r\n#  -------------------------------------------------------------\r\n#   Modified On\t:\r\n#   Modified By\t:\r\n#   Modification:\r\n#################################################################\r\n\r\n\r\n# do not remove the execute function\r\ndef execute(json_object, property_key):\r\n\r\n    message = \"\"\r\n    result = \"True\"\r\n    property_value = \"\"\r\n\r\n    try:\r\n        s1 = json_object\r\n        k1 = '\"' + property_key + '\":'\r\n        property_value = s1.split(k1)[1].split(\",\")[0].strip().strip('}').strip('\"')\r\n        message = 'Property Value extracted'\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n\r\n    return {\"result\": result, \"message\": message, \"property_value\": property_value}\r\n\r\n# you can add additional helper methods below."
  outputs:
    - result
    - message
    - property_value
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
