@RestResource(urlMapping='/jurisdiction/*')
global class Libra_Restful_Jurisdiction {

      @HttpPost
    global static void getJurisdiction()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Jurisdiction__c> jurisdictionList;
            if(String.isNotBlank(requestBody))
            {
                String additionalClause = ' Matter__c IN(Select matter_deal__c from Agreement__c where Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\'))';
                Libra_Restul_Functions.JurisdictionWrapper jurisdiction =(Libra_Restul_Functions.JurisdictionWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.JurisdictionWrapper.class);
                
                if(String.isNotBlank(jurisdiction.jurisdictionId))
                {
                    jurisdictionList = Libra_Restul_Functions.getSObjectById(jurisdiction.jurisdictionId,Libra_Restful_Constants.JurisdictionColumns,Libra_Restful_Constants.JurisdictionObject,additionalClause);
                    
                    if(jurisdictionList!=null && jurisdictionList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.Jurisdiction(jurisdictionList[0])));
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