/**
* Author: Rudolf Niehaus - CloudSmiths
* Date:   2017-10-16
* Desc:   MockHttp class for MIDAS outbound deal request 
**/

@isTest
global class Payments_Outbound_Deal_Mock implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest req) {
        
        JSONGenerator gen = JSON.createGenerator(true);
       
        gen.writeStartObject();
        gen.writeStringField('INPUTKEY','P170704AAAAIN00');
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