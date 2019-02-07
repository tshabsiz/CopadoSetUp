public class BxdPolicy {
    public String type_Z {get;set;} // in json: type
    public String id {get;set;} 
    public String policy_name {get;set;} 
    public String policy_type {get;set;} 
    public Integer retention_length {get;set;} 
    public String disposition_action {get;set;} 
    public String status {get;set;} 
    public String description {get;set;} 
    public String filter_started_at {get;set;} 
    public String filter_ended_at {get;set;} 
    public Boolean is_ongoing {get;set;} 
    
    public BxdPolicy() {
    }
    
    public BxdPolicy(JSONParser parser) {
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
                    } else if (text == 'policy_type') {
                        policy_type = parser.getText();
                    } else if (text == 'retention_length') {
                        retention_length = parser.getIntegerValue();
                    } else if (text == 'disposition_action') {
                        disposition_action = parser.getText();
                    } else if (text == 'status') {
                        status = parser.getText();
                    } else if (text == 'description') {
                        description = parser.getText();
                    } else if (text == 'filter_started_at') {
                        filter_started_at = parser.getText();
                    } else if (text == 'filter_ended_at') {
                        filter_ended_at = parser.getText();
                    } else if (text == 'is_ongoing') {
                        is_ongoing = parser.getBooleanValue();
                    } else {
                        System.debug(LoggingLevel.WARN, 'BxdLegalHoldPolicy consuming unrecognized property: '+text);
                        consumeObject(parser);
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
    
    public static BxdPolicy parse(String json) {
        return new BxdPolicy(System.JSON.createParser(json));
    }
    
    public static String getJsonString(BxdPolicy policy) {
        String policyString = JSON.serialize(policy, true);
        return policyString;
    }
}