/**
* Date:  2017-09
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  Outbound API call to MIDAS Statements
**/
public class Payments_Outbound_Statements {

    public static Payments_JSON2ApexStat jsonclass = new Payments_JSON2ApexStat();
    
    public static Payments_JSON2ApexStat postToMIDAS(String CUST,String CURR,String ACOD,String ACSQ,String FDATE,String TDATE,String STYPE,String SPAGE,String SLINE) {
        
        //build JSON file
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();
        
        gen.writeStringField('CUST',CUST);
        gen.writeStringField('CURR',CURR);
        gen.writeStringField('ACOD',ACOD);
        gen.writeStringField('ACSQ',ACSQ);
        gen.writeStringField('FDATE',FDATE);
        gen.writeStringField('TDATE',TDATE);
        gen.writeStringField('STYPE',STYPE);
        gen.writeStringField('SPAGE',SPAGE);
        gen.writeStringField('SLINE',SLINE);
        
        gen.writeEndObject();
        
        doHttpPost(gen.getAsString()); 
        
        return jsonclass;
    }
    
    //@future (callout=true)
    private static void doHttpPost(String jsonBody) {
       
        list<Integration_Settings_General__mdt> mdt = [Select ClientID__c, ClientSecret__c, ContentType__c, EndPoint__c 
                                                       From Integration_Settings_General__mdt  
                                                       Where DeveloperName = 'SF_2_MIDAS_STAT'];
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
                jsonclass = Payments_JSON2ApexStat.parse(response.getBody());

            }catch(System.CalloutException e) {
                System.debug('CalloutException!');
                System.debug(e.getMessage());
            }
        }else{
            System.debug('There are no settings defined for the Sf to MIDAS Statement API');
        }
    }
 
}