@Istest
public class BxdLegalQuoteRequestService_test {
	
    Public Static testmethod void BxdLegalQuoteServiceM(){
        
       // test.StartTest();
            BXDtesclassdata.setupFolder();
        	BXDtesclassdata.setupBase();
        	Legal_Quote_Request__c 	LegalQuoteRequest;
            LegalQuoteRequest = [Select id from Legal_Quote_Request__c limit 1];
            LegalQuoteRequest_handler.createBoxFolder(LegalQuoteRequest.Id);
       // test.StopTest();
        
    }
}