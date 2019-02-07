public class BxdTokenExchange {
    public String access_token {get;set;} 
    public Integer expires_in {get;set;} 
    public String token_type {get;set;} 
    
    public BxdTokenExchange(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'access_token') {
                        access_token = parser.getText();
                    } else if (text == 'expires_in') {
                        expires_in = parser.getIntegerValue();
                    } else if (text == 'token_type') {
                        token_type = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'BxdTokenExchange consuming unrecognized property: '+text);
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
    
    public static BxdTokenExchange parse(String json) {
        return new BxdTokenExchange(System.JSON.createParser(json));
    }
    
    public static String getJsonString(BxdTokenExchange tokenExchange) {
        String tokenExchangeString = JSON.serialize(tokenExchange, true);
        return tokenExchangeString;
    }
}