/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mthandeni Gumede	
*@Description : Test Class for Libra_Restful_Judisdication
===============================================*/
@isTest
public class Libra_Restful_Jurisdiction_Test {
    
     static testmethod void myUnitTestPositive()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/jurisdiction/';       
        
        String jurisdictionId = [select Matter_Deal__c from Agreement__c where Agreement_Status__c= 'Amended' limit 1].Matter_Deal__c;
        
        Libra_Restul_Functions.jurisdictionWrapper jurisdiction = new Libra_Restul_Functions.jurisdictionWrapper();
        jurisdiction.jurisdictionId = jurisdictionId;
        req.requestBody = Blob.valueof(JSON.serialize(jurisdiction));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Jurisdiction.getJurisdiction();
        test.stopTest();
    }
    
    static testmethod void myUnitTestNegative()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/jurisdiction/';       
        
        
        Libra_Restul_Functions.jurisdictionWrapper jurisdiction = new Libra_Restul_Functions.jurisdictionWrapper();
        jurisdiction.jurisdictionId = 'Invalid ID';
        req.requestBody = Blob.valueof(JSON.serialize(jurisdiction));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Jurisdiction.getJurisdiction();
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