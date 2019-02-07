@isTest
private class BxdWebhookController_test
{
    static testMethod void TestWebhookController() 
    {
        // create test data here
        BXDtesclassdata.setupFolder();  
        test.startTest();
       	BXDtesclassdata.setupBase();
        test.stopTest();
        
        List<Legal_Quote__c> quotes = [SELECT Id, Box_Webhook__c, Quote_Recieved__c FROM Legal_Quote__c]; 
        for(Legal_Quote__c q : quotes){
            q.Box_Webhook__c = '53';
        }
        update quotes;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/webhook';  //Request URL
        req.httpMethod = 'POST';
        req.addHeader('box-delivery-id', '673a081b-bb4b-4d45-b4f1-4131a29c1d07');
        req.addHeader('box-delivery-timestamp', '2016-07-11T10:10:33-07:00');
        req.addHeader('box-signature-algorithm', 'HmacSHA256');
        req.addHeader('box-signature-primary', 'isCeDp7mLR41/MjcSEFLag9bWmpJkgmN80Je4VIESdo=');
        req.addHeader('box-signature-secondary', '1UbiiKS7/2o5vNIlyMh7e5QGCHq8lflWFgEF+YWBugI=');
        req.addHeader('box-signature-version', '1');
        req.requestBody = Blob.valueof(JsonString());
        
        RestContext.request = req;
        RestContext.response= res;
        
        String response = BxdWebhookController.doPost();
        system.debug('RESPONSE '+response);
    }
    
    public static String JsonString(){
        String json = ' {'+
'  \"type\":\"webhook_event\",'+
'   \"id\":\"eb0c4e06-751f-442c-86f8-fd5bb404dbec\",'+
'   \"created_at\":\"2016-07-11T10:10:32-07:00\",'+
'   \"trigger\":\"FILE.UPLOADED\",'+
'   \"webhook\":{'+
'      \"id\":\"53\",'+
'      \"type\":\"webhook\"'+
'   },'+
'   \"created_by\":{'+
'      \"type\":\"user\",'+
'      \"id\":\"226067247\",'+
'      \"name\":\"John Q. Developer\",'+
'      \"login\":\"johnq@dev.name\"'+
'   },'+
'   \"source\":{'+
'      \"id\":\"73835521473\",'+
'      \"type\":\"file\",'+
'      \"file_version\":{'+
'         \"type\":\"file_version\",'+
'         \"id\":\"78096737033\",'+
'         \"sha1\":\"2c61623e86bee78e6ab444af456bccc7a1164095\" '+
'      }, '+
'      \"sequence_id\":\"0\", '+
'      \"etag\":\"0\", '+
'      \"sha1\":\"2c61623e86bee78e6ab444af456bccc7a1164095\", '+
'      \"name\":\"Test-Image-3.png\", '+
'      \"description\":\"\", '+
'      \"size\":26458, '+
'      \"path_collection\":{ '+
'         \"total_count\":4, '+
'         \"entries\":[ '+
'            { '+
'               \"type\":\"folder\", '+
'               \"id\":\"0\", '+
'               \"sequence_id\":null, '+
'               \"etag\":null, '+
'               \"name\":\"All Files\" '+
'            }, '+
'            { '+
'               \"type\":\"folder\", '+
'               \"id\":\"2614853901\", '+
'               \"sequence_id\":\"4\", '+
'               \"etag\":\"4\", '+
'               \"name\":\"Testing\" '+
'            }, '+
'            { '+
'               \"type\":\"folder\", '+
'               \"id\":\"8290186265\", '+
'               \"sequence_id\":\"0\", '+
'               \"etag\":\"0\", '+
'               \"name\":\"Webhooks Base\" '+
'            },'+
'            {'+
'               \"type\":\"folder\", '+
'               \"id\":\"8290188973\", '+
'               \"sequence_id\":\"0\", '+
'               \"etag\":\"0\", '+
'               \"name\":\"Webhooks\" '+
'            } '+
'         ] '+
'      }, '+
'      \"created_at\":\"2016-07-11T10:10:32-07:00\", '+
'      \"modified_at\":\"2016-07-11T10:10:32-07:00\", '+
'      \"trashed_at\":null, '+
'      \"purged_at\":null, '+
'      \"content_created_at\":\"2016-06-08T11:14:04-07:00\", '+
'      \"content_modified_at\":\"2016-06-08T11:14:04-07:00\", '+
'      \"created_by\":{ '+
'         \"type\":\"user\", '+
'         \"id\":\"226067247\", '+
'         \"name\":\"John Q. Developer\", '+
'         \"login\":\"johnq@dev.name\" '+
'      }, '+
'      \"modified_by\":{ '+
'         \"type\":\"user\", '+
'         \"id\":\"226067247\", '+
'         \"name\":\"John Q. Developer\", '+
'         \"login\":\"johnq@dev.name\" '+
'      }, '+
'      \"owned_by\":{ '+
'         \"type\":\"user\", '+
'         \"id\":\"226067247\", '+
'         \"name\":\"John Q. Developer\", '+
'         \"login\":\"johnq@dev.name\" '+
'      }, '+
'      \"shared_link\":null, '+
'      \"parent\":{ '+
'         \"type\":\"folder\", '+
'         \"id\":\"8290188973\", '+
'         \"sequence_id\":\"0\", '+
'         \"etag\":\"0\", '+
'         \"name\":\"Webhooks\" '+
'      }, '+
'      \"item_status\":\"active\" '+
'   }, '+
'   \"additional_info\":[ '+
'   ] '+
' } ';
       Return  json;
    }
}