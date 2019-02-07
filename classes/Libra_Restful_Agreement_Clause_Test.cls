/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mthandeni Gumede	
*@Description : Test Class for Libra_Restful_Agreement_Clause
===============================================*/
@isTest
public class Libra_Restful_Agreement_Clause_Test {

    
    static testmethod void myUnitTestPositive()
    {
        
        Libra_TestDataClass data =  new Libra_TestDataClass(); 
        
      
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/agreement-clause/';       
        
        String agreementClauseId = [select Matter_Deal__c from Agreement__c  limit 1].Matter_Deal__c;
        
        Libra_Restul_Functions.AgreementClauseWrapper agreementClause = new Libra_Restul_Functions.AgreementClauseWrapper();
        agreementClause.agreementClauseId = agreementClauseId;
        req.requestBody = Blob.valueof(JSON.serialize(agreementClause));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Agreement_Clause.getAgreementClause();
        test.stopTest();
    }
    
    static testmethod void myUnitTestNegative()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/agreement-clause/';       
        
        
        Libra_Restul_Functions.AgreementClauseWrapper agreementClause = new Libra_Restul_Functions.AgreementClauseWrapper();
        agreementClause.agreementClauseId = 'Invalid ID';
        req.requestBody = Blob.valueof(JSON.serialize(agreementClause));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Agreement_Clause.getAgreementClause();
        test.stopTest();
    }
    
}