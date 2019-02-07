/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mthandeni Gumede	
*@Description : Test Class for Libra_Restful_Get_All
===============================================*/
@isTest
private class Libra_Restful_Get_All_Test {
    
    static testMethod void TestPost_Postive() {
      
            
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/all';
        req.httpMethod = 'POST';
        

        
        RestContext.request = req;
        RestContext.response= res;
        
       
               
        Test.startTest();
        Libra_Restful_Get_All.getAll();
        Test.stopTest();
    }
    
     static testMethod void TestPost_Negtive() {
   
        List<Agreement__c> Agreementlist = [Select id,Agreement_Status__c from Agreement__c where Agreement_Status__c ='Amended' limit 1];
        if(Agreementlist.size()>0)
        {
            Agreementlist[0].Agreement_Status__c ='';
        }
   
        update Agreementlist;
    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/all';
        req.httpMethod = 'POST';
        

        
        RestContext.request = req;
        RestContext.response= res;
        
       
               
        Test.startTest();
        Libra_Restful_Get_All.getAll();
        Test.stopTest();
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