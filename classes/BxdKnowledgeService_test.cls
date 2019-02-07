@isTest
public class BxdKnowledgeService_test {
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();   
    
    public static testmethod void testgetBoxFolderFiles(){      
        BXDtesclassdata.setupBoxFolder();
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        //BOX DOCUMENT
        test.startTest();
        BxdKnowledgeService.getBoxFolderFiles(testDataClass.TestMatter.Id);
        BxdKnowledgeService.getBoxFolderFiles(testDataClass.TestMatter.Id, 2);
        Test.stopTest();       
    }
    
    public static testmethod void testCreateBoxCaseFolder(){      
        BXDtesclassdata.setupBoxFolder();
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        Test.startTest();
        Case MatterCase = new Case();
        MatterCase.Matter__c = testDataClass.TestMatter.Id;  
        MatterCase.Division__c = 'CIB'; 
        MatterCase.Business_Area__c = 'Banking';
        MatterCase.Subject = 'Test';
        RecordType rt = [Select id From RecordType where Name= 'Knowledge Request' limit 1];
        MatterCase.RecordTypeid = rt.id;
        Insert MatterCase;
        Test.stopTest();  
        
        List<BxdKnowledgeItem> fileList = new List<BxdKnowledgeItem>();
        BxdKnowledgeItem item = new BxdKnowledgeItem('12345', 'lead.pdf', '', 'https://box.com', '0', null);
        fileList.Add(item);
        
        //BOX DOCUMENT
        Attachment attach = new Attachment(); 
        attach.Name='KM Attachment'; 
        Blob bodyBlob=Blob.valueOf('KM Attachment Test Attachment Body');
        attach.body=bodyBlob; 
        attach.parentId= MatterCase.Id; 
        attach.ContentType = 'application/msword';
        attach.IsPrivate = false; 
        attach.Description = 'Test';
        insert attach; 
        
        BxdKnowledgeService.createBoxCaseFolder(MatterCase.Id, fileList, attach.Body, attach.Name);  
    }
    
    public static testmethod void testGetContent(){      
        BXDtesclassdata.setupBoxFolder();
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        test.startTest();
        BxdKnowledgeService.getBoxFolderContents(testDataClass.TestMatter.Id);
        Test.stopTest();       
    }
    
    public static testmethod void testCopyFiles() {
        String mockResponseBody = '{"type":"file","id":"5000948880","sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","description":"apictureoftigers","size":629644,"path_collection":{"total_count":2,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"AllFiles"},{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"}]},"created_at":"2012-12-12T10:55:30-08:00","modified_at":"2012-12-12T11:04:26-08:00","created_by":{"type":"user","id":"17738362","name":"seanrose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"seanrose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"seanrose","login":"sean@box.com"},"shared_link":{"url":"https://www.box.com/s/rh935iit6ewrmw0unyul","download_url":"https://www.box.com/shared/static/rh935iit6ewrmw0unyul.jpeg","vanity_url":null,"is_password_enabled":false,"unshared_at":null,"download_count":0,"preview_count":0,"access":"open","permissions":{"can_download":true,"can_preview":true}},"parent":{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"},"item_status":"active"}';
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'Created', 201));

        BoxApiConnection api = new BoxApiConnection('accesstoken');
        BoxFolder destination = new BoxFolder(api, '11446498');
        
        List<BxdKnowledgeItem> fileList = new List<BxdKnowledgeItem>();
        BxdKnowledgeItem item = new BxdKnowledgeItem('5000948880', 'lead.pdf', '', 'https://box.com', '11446498', null);
        fileList.Add(item);

        Test.startTest();
        BxdKnowledgeService.copyFiles(api, destination, fileList);
        Test.stopTest();
    } 
    
    public static testmethod void testCopyCaseFolderToMatter(){      
        BXDtesclassdata.setupBoxFolder();
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        Test.startTest();
        Case MatterCase = new Case();
        MatterCase.Matter__c = testDataClass.TestMatter.Id;  
        MatterCase.Division__c = 'CIB'; 
        MatterCase.Business_Area__c = 'Banking';
        MatterCase.Subject = 'Test';
        RecordType rt = [Select id From RecordType where Name= 'Knowledge Request' limit 1];
        MatterCase.RecordTypeid = rt.id;
        Insert MatterCase;
        Test.stopTest();  
      
        BxdKnowledgeService.copyCaseFolderToMatter(MatterCase.Id, testDataClass.TestMatter.Id);  
    }
}