@Istest
public class BxdLegalQuoteService_test {   
    
    Public Static testmethod void BxdLegalQuoteServiceM(){
        
      //  test.StartTest();
        	BXDtesclassdata.setupFolder();
            BXDTestclassData2.Cloudsmiths_TestDataClass();
       // 	BXDtesclassdata.setupBase(); 
        	
            Condition__c Con = [Select id,RecordTypeId from Condition__c where name= 'TestCon' limit 1];
        
        	 PageReference pageRef = Page.Condition_Override_view;
             pageRef .getParameters().put('id',Con.id);
             
             Test.setCurrentPageReference(pageRef);
        
        	 ApexPages.StandardController sc = new ApexPages.standardController(Con);
             Condition_Override Condition = new Condition_Override(sc);
        	 Condition.createBoxFolder();
        	 Condition.createBoxPermission();

             List<Condition_Occurrence__c> testData = new List<Condition_Occurrence__c>();

             testData = [
                SELECT
                    Id,
                    Name
                FROM Condition_Occurrence__c
             ];

             System.debug('BxdLegalQuoteService_test : '+testData);
        	
        
            Condition_Occurrence__c Occ=[Select id,RecordTypeId  from Condition_Occurrence__c where name= 'KYC' limit 1]; 
        	ApexPages.StandardController scOCC = new ApexPages.standardController(Occ);
        
            Condition_Occurrence_Override Occurrence  = new Condition_Occurrence_Override(scOCC);
        	Occurrence.createBoxPermission();
                
        
        
        
     //   test.StopTest();
        
    }
    
}