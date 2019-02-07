// Json as per from https://developer.box.com/v2.0/reference#the-notification-payload

public class BxdWebhookJsonObject {
    public String type_Z {get;set;} // in json: type
    public String id {get;set;} 
    public String created_at {get;set;} 
    public String trigger_Z {get;set;} // in json: trigger
    public Webhook webhook {get;set;} 
    public Created_by created_by {get;set;} 
    public Source source {get;set;} 
    public List<Additional_info> additional_info {get;set;} 
    
    public BxdWebhookJsonObject(){
        
    }
    
    /**
    * BxdWebhookJsonObject constructor - used to instantiate BxdWebhookJsonObject object, helps parse the json object
    **/
    public BxdWebhookJsonObject(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'type') {
                        type_Z = parser.getText();
                    } else if (text == 'id') {
                        id = parser.getText();
                    } else if (text == 'created_at') {
                        created_at = parser.getText();
                    } else if (text == 'trigger') {
                        trigger_Z = parser.getText();
                    } else if (text == 'webhook') {
                        webhook = new Webhook(parser);
                    } else if (text == 'created_by') {
                        created_by = new Created_by(parser);
                    } else if (text == 'source') {
                        source = new Source(parser);
                    } else if (text == 'additional_info') {
                        additional_info = new List<Additional_info>();
                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                            additional_info.add(new Additional_info(parser));
                        }
                    } else {
                        System.debug(LoggingLevel.WARN, 'BxdWebhookJsonObject consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    /**
    * BxdWebhookJsonObject - this method is used to instantiate a new BxdWebhookJsonObject using the passed string
    **/
    public static BxdWebhookJsonObject parse(String json) {
        return new BxdWebhookJsonObject(System.JSON.createParser(json));
    }
    
    /**
    * consumeObject - this method is used to consume and parse the json object
    **/
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
    
    /**
    * Additional_info - this is an inner class used as a field object in BxdWebhookJsonObject
    **/
    public class Additional_info {
        
        /**
        * Additional_info constructor - used to instantiate Additional_info object, helps parse the json object
        **/
        public Additional_info(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        {
                            System.debug(LoggingLevel.WARN, 'Additional_info consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    /**
    * File_version - this is an inner class 
    **/
    public class File_version {
        public String type_Z {get;set;} // in json: type
        public String id {get;set;} 
        public String sha1 {get;set;} 
        
        public File_version(){
        }
        
        /**
        * File_version constructor - used to instantiate File_version object, helps parse the json object
        **/
        public File_version(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'sha1') {
                            sha1 = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'File_version consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    /**
    * Parent - this is an inner class
	**/
    public class Parent {
        public String type_Z {get;set;} // in json: type
        public String id {get;set;} 
        public String name {get;set;} 
        
        public Parent(){
        }
        
        /**
        * Parent constructor - used to instantiate Parent object, helps parse the json object
        **/
        public Parent(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Parent consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    /**
    * Webhook - this is an inner class used as a field object in BxdWebhookJsonObject
    **/
    public class Webhook {
        public String id {get;set;} 
        public String type_Z {get;set;} // in json: type
        
        /**
        * Webhook constructor - used to instantiate Webhook object, helps parse the json object
        **/
        public Webhook(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'type') {
                            type_Z = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Webhook consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    /**
    * Created_by - this is an inner class used as a field object in BxdWebhookJsonObject
    **/
    public class Created_by {
        public String id {get;set;} 
        public String name {get;set;} 
        
        /**
        * Created_by constructor - used to instantiate Created_by object, helps parse the json object
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
    * Source - this is an inner class used as a field object in BxdWebhookJsonObject
    **/
    public class Source {
        public String id {get;set;} 
        public String type_Z {get;set;} // in json: type
        public File_version file_version {get;set;} 
        public String shared_link {get;set;} 
        public Parent parent {get;set;} 
        public String item_status {get;set;} 
        
        /**
        * Source constructor - used to instantiate Source object, helps parse the json object
        **/
        public Source(JSONParser parser) {
            parent = new Parent();
            file_version = new File_version();
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'file_version') {
                            file_version = new File_version(parser);
                        } else if (text == 'shared_link') {
                            shared_link = parser.getText();
                        } else if (text == 'parent') {
                            parent = new Parent(parser);
                        } else if (text == 'item_status') {
                            item_status = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Source consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
}