@RestResource(urlMapping='/supporting-agreement/*')
global class Libra_Inbound_Restful_S_Agreement {

      @HttpPost
    global static void getSupportingAgreement()
    {
          String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Supporting_Agreement__c> supportingAgreementList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.AgreementWrapper supportingAgreement =(Libra_Restul_Functions.AgreementWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.AgreementWrapper.class);
                
                if(String.isNotBlank(supportingAgreement.agreementId))
                {
                    String additionalClause = ' Agreement__r.Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\')';
                    supportingAgreementList = Libra_Restul_Functions.getSObjectById(supportingAgreement.agreementId,Libra_Restful_Constants.SupportingAgreementColumns,Libra_Restful_Constants.SupportingAgreementObject,additionalClause);
                    
                    if(supportingAgreementList!=null && supportingAgreementList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.SupportingAgreement(supportingAgreementList[0])));
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