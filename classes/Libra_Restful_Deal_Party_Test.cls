@IsTest
public class Libra_Restful_Deal_Party_Test {
    
     static testmethod void myUnitTestPositive()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/deal-party/';       
        
        String dealPartyId = [select Matter_Deal__c from Agreement__c where Agreement_Status__c= 'Amended' limit 1].Matter_Deal__c;
        
        Libra_Restul_Functions.DealPartyWrapper dealParty = new Libra_Restul_Functions.DealPartyWrapper();
        dealParty.dealPartyId = dealPartyId;
        req.requestBody = Blob.valueof(JSON.serialize(dealParty));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Deal_Party.getDealParty();
        test.stopTest();
    }
    
    static testmethod void myUnitTestNegative()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/master/';       
        
        
        Libra_Restul_Functions.DealPartyWrapper dealParty = new Libra_Restul_Functions.DealPartyWrapper();
        dealParty.dealPartyId = 'Invalid ID';
        req.requestBody = Blob.valueof(JSON.serialize(dealParty));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Deal_Party.getDealParty();
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