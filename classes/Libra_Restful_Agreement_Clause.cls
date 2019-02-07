@RestResource(urlMapping='/agreement-clause/*')
global class Libra_Restful_Agreement_Clause {

	@HttpPost
    global static void getAgreementClause()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Agreement_Clause__c> agreementClauseList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.AgreementClauseWrapper agreementClause =(Libra_Restul_Functions.AgreementClauseWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.AgreementClauseWrapper.class);
                
                if(String.isNotBlank(agreementClause.agreementClauseId))
                {
                    agreementClauseList = Libra_Restul_Functions.getSObjectById(agreementClause.agreementClauseId,Libra_Restful_Constants.AgreementClauseColumns,Libra_Restful_Constants.AgreementClauseObject);
                    
                    if(agreementClauseList!=null && agreementClauseList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.AgreementClause(agreementClauseList[0])));
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