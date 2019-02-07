@RestResource(urlMapping='/agreement/*')
global class Libra_Inbound_Restful_Get_Agreement {

      @HttpPost
    global static void getAgreement()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Agreement__c> agreementList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.AgreementWrapper agreement =(Libra_Restul_Functions.AgreementWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.AgreementWrapper.class);
                
                if(String.isNotBlank(agreement.agreementId))
                {
                    String additionalClause = ' Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\')';
                    agreementList = Libra_Restul_Functions.getSObjectById(agreement.agreementId,Libra_Restful_Constants.AgreementColumns,Libra_Restful_Constants.agreementObject,additionalClause);
                    
                    if(agreementList!=null && agreementList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.Agreement(agreementList[0])));
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