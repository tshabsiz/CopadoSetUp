/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mthandeni Gumede	
*@Description : Test Class for Libra_Restful_Agreement_Trade_Istru
===============================================*/
@isTest
public class Libra_Agreement_Trade_Instru_Test {
    
    
    static testmethod void myUnitTestPositive()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/agreement-trade-instrument/';       
        
        String agreementTradeInstrumentId = [select Matter_Deal__c from Agreement__c where Agreement_Status__c= 'Amended' limit 1].Matter_Deal__c;
        
        Libra_Restul_Functions.AgreementTradeInstrumentWrapper agreementTradeInstrument = new Libra_Restul_Functions.AgreementTradeInstrumentWrapper();
        agreementTradeInstrument.agreementTradeInstrumentId = agreementTradeInstrumentId;
        req.requestBody = Blob.valueof(JSON.serialize(agreementTradeInstrument));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Agreement_Trade_Instru.getAgreementTradeInstrument();
        test.stopTest();
    }
    
    static testmethod void myUnitTestNegative()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/agreement-trade-instrument/';       
        
        
        Libra_Restul_Functions.AgreementTradeInstrumentWrapper agreementTradeInstrument = new Libra_Restul_Functions.AgreementTradeInstrumentWrapper();
        agreementTradeInstrument.agreementTradeInstrumentId = 'Invalid ID';
        req.requestBody = Blob.valueof(JSON.serialize(agreementTradeInstrument));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Agreement_Trade_Instru.getAgreementTradeInstrument();
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