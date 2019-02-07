/**
* Author: Rudolf Niehaus - CloudSmiths
* Date:   2017-10-16
* Desc:   MockHttp class for MIDAS outbound statements request 
**/

@isTest
global class Payments_Outbound_Statements_Mock implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {
        
        JSONGenerator gen = JSON.createGenerator(true);
       
        gen.writeStartObject();
        gen.writeStringField('CUST','028738');
        gen.writeStringField('CURR','ZAR');
        gen.writeStringField('ACOD','0000006712');
        gen.writeStringField('ACSQ','01');
        gen.writeStringField('FDATE','20170701');
        gen.writeStringField('TDATE','20170801');
        gen.writeStringField('STYPE','B');
        gen.writeStringField('SPAGE','1');
        gen.writeStringField('SLINE','999');
        gen.writeEndObject();
        
        String postBody = gen.getAsString();
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(postBody);
        res.setStatusCode(200);
        return res;
    }
   

}