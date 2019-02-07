/**
* Author: Rudolf Niehaus - CloudSmiths
* Date:   2017-09-12
* Desc:   MockHttp class for the Create CASE - Http callouts 
**/

@isTest
global class Payments_CreateCase_HTTPMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        JSONGenerator gen = JSON.createGenerator(true);
       //String bicCode, String description, String relatedRef,String countryCode, String originPack, String messageType, String transactionRef
        gen.writeStartObject();
        gen.writeStringField('bicCode','RUDIX7777777;739998367.0');
        gen.writeStringField('description','{1:F01ABSAZAJJAXXX1967564145}{2:O1961459140103POPUESMMAXXX99195802601401031600N}');
        gen.writeStringField('relatedRef','XYUoookjhg1');
        gen.writeStringField('countryCode','DZ;ABooZAJ0AXIX');
        gen.writeStringField('originPack','Test Routing TEST 2');
        gen.writeStringField('messageType','MT196');
        gen.writeStringField('transactionRef','TYYXpppl43');
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