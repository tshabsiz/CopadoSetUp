@RestResource(urlMapping='/agreement-trade-instrument/*')
global class Libra_Restful_Agreement_Trade_Instru {

      @HttpPost
    global static void getAgreementTradeInstrument()
    {
          String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Agreement_Trade_Instrument__c> AgreementTradeInstrumentList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.AgreementTradeInstrumentWrapper agreementTradeInstrument =(Libra_Restul_Functions.AgreementTradeInstrumentWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.AgreementTradeInstrumentWrapper.class);
                
                if(String.isNotBlank(agreementTradeInstrument.agreementTradeInstrumentId))
                {
                    AgreementTradeInstrumentList = Libra_Restul_Functions.getSObjectById(agreementTradeInstrument.agreementTradeInstrumentId,Libra_Restful_Constants.AgreementTradeInstrumentColumns,Libra_Restful_Constants.AgreementTradeInstrumentObject);
                    
                    if(AgreementTradeInstrumentList!=null && AgreementTradeInstrumentList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.AgreementTradeInstrument(AgreementTradeInstrumentList[0])));
                    }
                    else
                    {
                        RestContext.response.responseBody = Blob.valueOf(Libra_Restful_Constants.NotFound);
                        RestContext.response.statusCode =Libra_Restful_Constants.statusCodeNotFound;
                    }
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