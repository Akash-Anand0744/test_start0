namespace: Cerner.DigitalFactory.Common.JIRA.SubFlow
flow:
  name: setJiraOutputProperty_OnFailure
  workflow:
    - set_message:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish: []
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: FAILURE
  outputs:
    - incidentHttpStatusCode: '-1'
    - jiraIncidentCreationResult: Failed
    - jiraIssueURL: ''
    - jiraIssueId: ''
  results:
    - FAILURE
extensions:
  graph:
    steps:
      set_message:
        x: 235
        'y': 141
        navigate:
          e7ae5c1b-4de8-b9f0-7c18-b1572904bc6e:
            targetId: 0c28bba0-4a86-831c-57b2-4967c3dfd37a
            port: FAILURE
          951d73ff-3ca2-66a8-c8e7-8f719844f3f3:
            targetId: 0c28bba0-4a86-831c-57b2-4967c3dfd37a
            port: SUCCESS
    results:
      FAILURE:
        0c28bba0-4a86-831c-57b2-4967c3dfd37a:
          x: 499
          'y': 154
