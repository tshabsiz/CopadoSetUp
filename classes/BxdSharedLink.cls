public class BxdSharedLink {
    public String id {get;set;}
    public String type {get;set;}
    public Shared_link shared_link;
    
    public BxdSharedLink() {
        this.shared_link = new Shared_link();
    } 
    
   public BxdSharedLink(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'shared_link') {
							shared_link = new Shared_link(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'BxdSharedLink consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
    
    public static String getJsonString(BxdSharedLink sharedLink) {
        String sharedString = JSON.serialize(sharedLink, true);
        return sharedString;
    }
    
    public static BxdSharedLink parse(String json) {
		return new BxdSharedLink(System.JSON.createParser(json));
	}
    
    public class Shared_link {
        public String url {get;set;} 
		public String download_url {get;set;} 
		public String access {get;set;} 
		public Permissions permissions {get;set;} 
        
        public Shared_link() {
            this.permissions = new Permissions();
        }
        
        public Shared_link(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'url') {
							url = parser.getText();
						} else if (text == 'download_url') {
							download_url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Shared_link consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
    }
    
    public class Permissions {
        public Boolean can_download;
        public Boolean can_preview;
        
        public Permissions() {
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
}