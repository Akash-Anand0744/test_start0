namespace: Cerner.Integrations.Jira.subFlows
flow:
  name: updateSMAXRequest
  inputs:
    - jiraIssueURL:
        required: true
    - jiraIssueId:
        required: true
    - smaxRequestID
  workflow:
    - akash_flow1:
        do:
          akash_flows_project.akash_flow1: []
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: akash_flow2
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing:
            - errorMessage: "${get('errorMessage', return_result)}"
        publish:
          - errorMessage
          - errorSeverity: ERROR
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: on_failure
    - akash_flow2:
        do:
          akash_flows_project.Operation.akash_flow2: []
        navigate:
          - FAILURE: set_message
          - SUCCESS: SUCCESS
  outputs:
    - errorMessage: '${errorMessage}'
    - return_result: '${return_result}'
    - errorSeverity: '${errorSeverity}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      set_message:
        x: 440
        'y': 320
        navigate:
          17bec3a4-cfcf-c8e5-baab-26d09e0326e6:
            targetId: aa27e946-3123-f5a6-0822-7574205c9f86
            port: SUCCESS
      akash_flow1:
        x: 200
        'y': 80
        navigate:
          7345cbb8-5c16-07a3-697f-cdcac8421fd6:
            targetId: aa27e946-3123-f5a6-0822-7574205c9f86
            port: FAILURE
      akash_flow2:
        x: 480
        'y': 80
        navigate:
          b7371390-ccf7-420a-d92f-68f52f7aaa99:
            targetId: 602e300e-9d6a-9429-10c2-e3eaf7d940d8
            port: SUCCESS
    results:
      FAILURE:
        aa27e946-3123-f5a6-0822-7574205c9f86:
          x: 200
          'y': 320
      SUCCESS:
        602e300e-9d6a-9429-10c2-e3eaf7d940d8:
          x: 680
          'y': 80
