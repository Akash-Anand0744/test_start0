namespace: Cerner.ErrorHandling
properties:
  - config: "{\"errorConfName\":\"phase1\",\"errorHandlers\":[{\"handler\":{\"id\":\"1\",\"name\":\"logger\",\"config\":{\"values\":[{\"value\":{\"name\":\"path\",\"data\":\"\\\\tmp\\\\aa.txt\"}},{\"value\":{\"name\":\"path2\",\"data\":\"aa.txt\"}}]}}},{\"handler\":{\"id\":\"2\",\"name\":\"email\",\"config\":{\"values\":[{\"value\":{\"name\":\"emailFrom\",\"data\":\"error@cerner.com\"}},{\"value\":{\"name\":\"emailTo\",\"data\":\"error1@cerner.com\"}}]}}}],\"errorActionMapping\":{\"defalt\":{\"actions\":[{\"action\":{\"id\":\"1\",\"config\":{\"values\":[{\"value\":{\"name\":\"path\",\"data\":\"\\\\tmp\\\\aa1.txt\"}}]}}},{\"action\":{\"id\":\"2\"}}]},\"failSafe\":{\"actions\":[{\"action\":{\"id\":\"2\",\"config\":{\"values\":[{\"value\":{\"name\":\"path\",\"data\":\"\\\\tmp\\\\aa2.txt\"}}]}}},{\"action\":{\"id\":\"2\"}}]},\"errorTypes\":[{\"error\":{\"regex\":\"e2*\",\"actions\":[{\"action\":{\"id\":\"1\",\"config\":{\"values\":[{\"value\":{\"name\":\"path\",\"data\":\"\\\\tmp\\\\aa3.txt\"}}]}}}]}},{\"error\":{\"regex\":\"e1*\",\"actions\":[{\"action\":{\"id\":\"1\",\"config\":{\"values\":[{\"value\":{\"name\":\"path\",\"data\":\"\\\\tmp\\\\aa4.txt\"}}]}}}]}},{\"error\":{\"regex\":\"e1*\",\"actions\":[{\"action\":{\"id\":\"1\",\"config\":{\"values\":[{\"value\":{\"name\":\"path\",\"data\":\"\\\\tmp\\\\aa5.txt\"}}]}}}]}}]}}"
  - loggerName: logger
  - emailerName: email
  - incidentCreatorName: incident
  - monitoringTriggerName: monitoring
  - parameterMapping: 'name,path;path;path;path'
