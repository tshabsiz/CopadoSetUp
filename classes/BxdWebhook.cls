// As per https://developer.box.com/v2.0/reference#get-webhook
public class BxdWebhook {
    public String id {get;set;} 
    public String type {get;set;}
    public String address {get;set;}
    public Target target {get;set;} 
    public Created_by created_by {get;set;}  
    public List<String> triggers {get;set;} 
    
    /**
    * BxdWebhook constructor - used to instantiate a new Target
    **/
    public BxdWebhook() {
        this.target = new Target();
    }
    
    /**
    * BxdWebhook constructor - used to instatiate a new BxdWebhook object, helps to parse the json object
    **/
    public BxdWebhook(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'id') {
                        id = parser.getText();
                    } else if (text == 'type') {
                        type = parser.getText();
                    } else if (text == 'target') {
                        target = new Target(parser);
                    } else if (text == 'created_by') {
                        created_by = new Created_by(parser);
                    } else if (text == 'address') {
                        address = parser.getText();
                    } else if (text == 'triggers') {
                        triggers = new List<String>();
                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                            triggers.add(parser.getText());
                        }
                    } else {
                        System.debug(LoggingLevel.WARN, 'BoxWebhook consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    /**
    * parse - used to create a BxdWebhook object from passed string 
    **/
    public static BxdWebhook parse(String json) {
        return new BxdWebhook(System.JSON.createParser(json));
    }
    
    /**
    * getJsonString - used to serialize a BxdWebhook object to a string
    **/
    public static String getJsonString(BxdWebhook webhook) {
        String webhookString = JSON.serialize(webhook, true);
        return webhookString;
    }
    
    /**
    * Target - is an inner class used as a object field for BxdWebhook object
    **/
    public class Target {
        public String id {get;set;} 
        public String type {get;set;} // in json: type
        
        public Target() {
        }
        
        /**
    	* Target constructor - used to instatiate a new Target object, helps to parse the json object
    	**/
        public Target(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'type') {
                            type = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Target consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    /**
    * Created_by - is an inner class used as a object field for BxdWebhook object
    **/
    public class Created_by {
        public String id {get;set;} 
        public String name {get;set;} 
        
        /**
    	* Created_by constructor - used to instatiate a new Created_by object, helps to parse the json object
    	**/
        public Created_by(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Created_by consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }    
    
    /**
    * consumeObject - this method helps to parse the json object
    **/
    private static void consumeObject(JSONParser parser) {
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
}