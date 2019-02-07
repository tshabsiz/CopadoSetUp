/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mthandeni Gumede	
*@Description : Test Class for Libra_Restful_Amedments 
===============================================*/
@isTest
public class Libra_Restful_Amendment_Test {
    
    	static testmethod void myUnitTestPositiveForMatters()
    {
        

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ammendment/';       
        
        String amendmentId = [select Matter_Deal__c from Agreement__c where Agreement_Status__c= 'Amended' limit 1].Matter_Deal__c;
        
        Libra_Restul_Functions.AmendmentWrapper amendment = new Libra_Restul_Functions.AmendmentWrapper();
        amendment.amendmentId = amendmentId;
        amendment.amendmentType = 'matter';
        req.requestBody = Blob.valueof(JSON.serialize(amendment));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Amendment.getAmendment();
        test.stopTest();
    }
    	static testmethod void myUnitTestPositiveForAgreement()
    {
        

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ammendment/';       
        
        String amendmentId = [select Matter_Deal__c from Agreement__c where Agreement_Status__c= 'Amended' limit 1].Matter_Deal__c;
        
        Libra_Restul_Functions.AmendmentWrapper amendment = new Libra_Restul_Functions.AmendmentWrapper();
        amendment.amendmentId = amendmentId;
        amendment.amendmentType = 'agreement';
        req.requestBody = Blob.valueof(JSON.serialize(amendment));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Amendment.getAmendment();
        test.stopTest();
    }
     	static testmethod void myUnitTestPositiveForSupportAgreement()
    {
        

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ammendment/';       
        
        String amendmentId = [select Matter_Deal__c from Agreement__c where Agreement_Status__c= 'Amended' limit 1].Matter_Deal__c;
        
        Libra_Restul_Functions.AmendmentWrapper amendment = new Libra_Restul_Functions.AmendmentWrapper();
        amendment.amendmentId = amendmentId;
        amendment.amendmentType = 'supportingAgreement';
        req.requestBody = Blob.valueof(JSON.serialize(amendment));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Amendment.getAmendment();
        test.stopTest();
    }
    
    
    
    static testmethod void myUnitTestNegative()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ammendment/';       
        
        
        Libra_Restul_Functions.AmendmentWrapper ammendment = new Libra_Restul_Functions.AmendmentWrapper();
        req.requestBody = Blob.valueof(JSON.serialize(ammendment));
        RestContext.request = req; 
        RestContext.response= res;
  
        test.startTest();
           Libra_Restful_Amendment.getAmendment();
        test.stopTest();
    }
    
    @TestSetup static void setupData()
    {
        Libra_TestDataClass data =  new Libra_TestDataClass();
        
        List<Agreement__c> Agreementlist = [Select id,Agreement_Status__c from Agreement__c limit 1];
        if(Agreementlist.size()>0)
        {
            Agreementlist[0].Agreement_Status__c ='Amended';
          
        }
        
        update Agreementlist;
        
    }
    
}