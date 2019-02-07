/**
* Author: Rudolf Niehaus - CloudSmiths
* Date:   2017-09-12
* Desc:   MockHttp class for the case update - Http callouts 
**/

@isTest
global class Payments_UpdateCase_HTTPMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        String jsonString = '{"salesforceID":"5117E000005XQYKQA4","status":"SWIFT were generated","description":"{1:F01ABSAZAJJAXXX1967564145}{2:O1961459140103POPUESMMAXXX99195802601401031600N}"}';
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonString);
        res.setStatusCode(200);
        return res;
    } 
}