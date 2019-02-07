/**
* Date:  2017-09
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  Outbound API call to MIDAS Tier
**/
public class Payments_Outbound_Tier {
    
     public static Payments_JSON2ApexTier jsonclass = new Payments_JSON2ApexTier();
    
     public static Payments_JSON2ApexTier postToMIDAS(String INPUTKEY) {
        
        //build JSON file
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();
   
        gen.writeStringField('INPUTKEY',INPUTKEY);
        
        gen.writeEndObject();
        
        doHttpPost(gen.getAsString());            
        
        return jsonclass;
    }
    
    private static void doHttpPost(String jsonBody) {
       
        list<Integration_Settings_General__mdt> mdt = [Select ClientID__c, ClientSecret__c, ContentType__c, EndPoint__c 
                                                       From Integration_Settings_General__mdt  
                                                       Where DeveloperName = 'SF_2_MIDAS_TIER'];
        if(mdt.size() > 0){
            try{                        
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setTimeout(120000);
                req.setEndpoint(mdt[0].EndPoint__c);
                req.setHeader('Content-Type', mdt[0].ContentType__c);
                req.setHeader('X-IBM-Client-Id', mdt[0].ClientID__c);
                req.setHeader('X-IBM-Client-Secret', mdt[0].ClientSecret__c);
                
                req.setBody(jsonBody);
                
                Http http = new Http();
                HttpResponse response =  http.send(req);
                
                //get response json back into apex classes
                jsonclass = Payments_JSON2ApexTier.parse(response.getBody());

            }catch(System.CalloutException e) {
                System.debug('CalloutException!');
                System.debug(e.getMessage());
            }
        }else{
            System.debug('There are no settings defined for the Sf to MIDAS Tier API');
        }
    }



}