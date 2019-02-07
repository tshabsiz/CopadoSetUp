public class BxdLegalHoldAssignment {
    public String policy_id {get;set;} 
    public String type {get;set;}
    public String id {get;set;} 
    public Legal_hold_policy legal_hold_policy {get;set;}
    public Assign_to assign_to {get;set;}
    public Assigned_to assigned_to {get;set;} 
    public Assigned_by assigned_by {get;set;} 
    public String assigned_at {get;set;} 
    public String deleted_at {get;set;} 
    
    public BxdLegalHoldAssignment() {
        assign_to = new Assign_to();
    }
    
    public BxdLegalHoldAssignment(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'policy_id') {
                        policy_id = parser.getText();
                    } else if (text == 'type') {
                        type = parser.getText();
                    } else if (text == 'id') {
                        id = parser.getText();
                    } else if (text == 'legal_hold_policy') {
                        legal_hold_policy = new Legal_hold_policy(parser);
                    } else if (text == 'assign_to') {
                        assign_to = new Assign_to(parser);
                    }else if (text == 'assigned_to') {
                        assigned_to = new Assigned_to(parser);
                    } else if (text == 'assigned_by') {
                        assigned_by = new Assigned_by(parser);
                    } else if (text == 'assigned_at') {
                        assigned_at = parser.getText();
                    } else if (text == 'deleted_at') {
                        deleted_at = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'BxdLegalHoldAssignment consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Assign_to {
        public String type {get;set;} // in json: type
        public String id {get;set;}
        
        public Assign_to(){          
        }
        
        public Assign_to(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Assign_to consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Assigned_to {
        public String type {get;set;} // in json: type
        public String id {get;set;}
        
        public Assigned_to(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Assigned_to consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Assigned_by {
        public String type {get;set;} // in json: type
        public String id {get;set;} 
        public String name {get;set;} 
        public String login {get;set;} 
        
        public Assigned_by(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'login') {
                            login = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Assigned_by consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Legal_hold_policy {
        public String type_Z {get;set;} // in json: type
        public String id {get;set;} 
        public String policy_name {get;set;} 
        
        public Legal_hold_policy(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'policy_name') {
                            policy_name = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Legal_hold_policy consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }   
    
    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || 
                curr == JSONToken.START_ARRAY) {
                    depth++;
                } else if (curr == JSONToken.END_OBJECT ||
                           curr == JSONToken.END_ARRAY) {
                               depth--;
                           }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
    public static BxdLegalHoldAssignment parse(String json) {
        return new BxdLegalHoldAssignment(System.JSON.createParser(json));
    }
    
    public static String getJsonString(BxdLegalHoldAssignment assignment) {
        String assignmentString = JSON.serialize(assignment, true);
        return assignmentString;
    }   
}