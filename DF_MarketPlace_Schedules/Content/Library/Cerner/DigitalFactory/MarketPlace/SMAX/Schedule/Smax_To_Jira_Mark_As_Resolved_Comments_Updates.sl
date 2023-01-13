namespace: Cerner.DigitalFactory.MarketPlace.SMAX.Schedule
flow:
  name: Smax_To_Jira_Mark_As_Resolved_Comments_Updates
  inputs:
    - jiraticketID
  workflow:
    - commentMarkAsSolvedSMAXtoJIRA:
        do:
          Cerner.DigitalFactory.MarketPlace.SMAX.Operation.commentMarkAsSolvedSMAXtoJIRA:
            - mark_as_solved_comment: "${get_sp('Cerner.DigitalFactory.MarketPlace.mark_as_solved_comment')}"
            - jiraticketID: '${jiraticketID}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - result
    - message
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      commentMarkAsSolvedSMAXtoJIRA:
        x: 455
        'y': 193
        navigate:
          3c3b98cd-91a5-d5b2-0983-e1acc1fc8510:
            targetId: 43bd3677-7de4-49d3-0bb4-48a8f267615f
            port: SUCCESS
    results:
      SUCCESS:
        43bd3677-7de4-49d3-0bb4-48a8f267615f:
          x: 777
          'y': 165
