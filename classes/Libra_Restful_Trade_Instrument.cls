@RestResource(urlMapping='/trade-instrument/*')
global class Libra_Restful_Trade_Instrument {

      @HttpPOST
    global static void getTradeInstrument()
    {
          String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Trade_Instrument__c> tradeInstrumentList;
            List<LibraRestfulModel.TradeInstrument> tradeIntrumentCollection = new List<LibraRestfulModel.TradeInstrument>();
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.tradeInstrumentWrapper tradeInstrument =(Libra_Restul_Functions.tradeInstrumentWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.tradeInstrumentWrapper.class);
                
                if(String.isNotBlank(tradeInstrument.tradeInstrumentId))
                {
                    tradeInstrumentList = Libra_Restul_Functions.getSObjectById(tradeInstrument.tradeInstrumentId,Libra_Restful_Constants.tradeInstrumentColumns,Libra_Restful_Constants.tradeInstrumentObject);
                    
                    if(tradeInstrumentList!=null && tradeInstrumentList.size()>0)
                    {
                        tradeIntrumentCollection.add(new LibraRestfulModel.TradeInstrument(tradeInstrumentList[0]));
                    }
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(tradeIntrumentCollection));
                }
                else
                {
                    for(Trade_Instrument__c varTradeIntrument :(List<Trade_Instrument__c>)Libra_Restul_Functions.getSObject(Libra_Restful_Constants.tradeInstrumentColumns,Libra_Restful_Constants.tradeInstrumentObject))
                    {
                        tradeIntrumentCollection.add(new LibraRestfulModel.TradeInstrument(varTradeIntrument));
                    }
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(tradeIntrumentCollection));
                }
            }
        }
        catch(StringException eex)
        {
            RestContext.response.responseBody = Blob.valueOf(Libra_Restful_Constants.NotFound);
            RestContext.response.statusCode =Libra_Restful_Constants.statusCodeNotFound;
        }catch(QueryException qe)
        {
            RestContext.response.responseBody = Blob.valueOf(qe.getMessage());
            RestContext.response.statusCode =400;
        }
    }
}