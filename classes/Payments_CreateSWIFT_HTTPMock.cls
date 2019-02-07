/**
* Author: Rudolf Niehaus - CloudSmiths
* Date:   2017-09-12
* Desc:   MockHttp class for the Create SWIFT - Http callouts 
**/

@isTest
global class Payments_CreateSWIFT_HTTPMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        JSONGenerator gen = JSON.createGenerator(true);
       
        gen.writeStartObject();
        gen.writeStringField('answers','THE MESSAGE');
        gen.writeStringField('destinationAddress','BBRUBEBBXXXX');
        gen.writeNumberField('messageType',199);
        gen.writeStringField('narrative','narritave');
        gen.writeStringField('queries','queries');
        gen.writeStringField('relatedReference','SF0111AA199PT-P');
        gen.writeStringField('salesforceId','5117E000005XQYKQA4');
        gen.writeStringField('senderAddress','ABSAZAJ0AXXX');
        gen.writeNumberField('swiftId',2091035);
        gen.writeStringField('transactionReference','SF0111B103E2');
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