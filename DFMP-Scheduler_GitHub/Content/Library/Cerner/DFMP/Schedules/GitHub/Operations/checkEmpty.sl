########################################################################################################################
#!!
#! @description: This Python operation is used to check if input variable is empty.
#!
#! @input inputCheck: Input variable to check if empty
#!
#! @output result: If input variable is not empty, it returns "Input Not Empty". Otherwise, "Input Empty"
#!!#
########################################################################################################################
namespace: Cerner.DFMP.Schedules.GitHub.Operations
operation:
  name: checkEmpty
  inputs:
    - inputCheck:
        required: false
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      def execute(inputCheck):
          # code goes here
          if inputCheck and inputCheck != "null":
              result = "Input Not Empty"
          else:
              result = "Input Empty"
          return {"result": result}
      # you can add additional helper methods below.
  outputs:
    - result
  results:
    - IS_EMPTY: '${result=="Input Empty"}'
      CUSTOM_0: "${result=='Input Empty'}"
    - NOT_EMPTY
