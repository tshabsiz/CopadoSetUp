/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mthandeni Gumede	
*@Description : Test Class for Libra_Restful_Trade_Instrument
===============================================*/
@isTest
public class Libra_Restful_Trade_Instrument_Test {
    
    
    static testmethod void myUnitTestPositive()
    {
        Libra_TestDataClass data =  new Libra_TestDataClass();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/trade-instrument/';       
        
        String tradeInstrumentId = [select Matter_Deal__c from Agreement__c  limit 1].Matter_Deal__c;
        
        Libra_Restul_Functions.TradeInstrumentWrapper tradeInstrument = new Libra_Restul_Functions.TradeInstrumentWrapper();
        tradeInstrument.tradeInstrumentId = tradeInstrumentId;
        req.requestBody = Blob.valueof(JSON.serialize(tradeInstrument));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Trade_Instrument.getTradeInstrument();
        test.stopTest();
    }
    
    static testmethod void myUnitTestNegative()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/trade-instrument/';       
        
        
        Libra_Restul_Functions.TradeInstrumentWrapper tradeInstrument = new Libra_Restul_Functions.TradeInstrumentWrapper();
        tradeInstrument.tradeInstrumentId = 'Invalid ID';
        req.requestBody = Blob.valueof(JSON.serialize(tradeInstrument));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Trade_Instrument.getTradeInstrument();
        test.stopTest();
    }

}