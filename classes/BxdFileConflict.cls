public class BxdFileConflict {
    public Conflicts conflicts {get;set;} 

		public BxdFileConflict(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'conflicts') {
							conflicts = new Conflicts(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'BxdFileConflict consuming unrecognized property: '+text);
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
	
	public class Conflicts {
		public String type_Z {get;set;} // in json: type
		public String id {get;set;} 
		public String name {get;set;} 

		public Conflicts(JSONParser parser) {
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
							System.debug(LoggingLevel.WARN, 'Conflicts consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static BxdFileConflict parse(String json) {
		return new BxdFileConflict(System.JSON.createParser(json));
	}
}