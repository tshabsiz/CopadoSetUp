@RestResource(urlMapping='/ammendment/*')
global class Libra_Restful_Amendment {

	@HttpPost
    global static void getAmendment()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Amendment__c> amendmentList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.AmendmentWrapper amendment =(Libra_Restul_Functions.AmendmentWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.AmendmentWrapper.class);
                
                if(String.isNotBlank(amendment.amendmentId))
                {
                    
                    if(amendment.amendmentType.equalsIgnoreCase('matter'))
                    {
                        String additionalClause = ' Matter__c IN(Select matter_deal__c from Agreement__c where Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\'))';
                        amendmentList = Libra_Restul_Functions.getSObjectById(amendment.amendmentId,Libra_Restful_Constants.AmendmentColumns,Libra_Restful_Constants.AmendmentObject,additionalClause);

                    }
                    if(amendment.amendmentType.equalsIgnoreCase('agreement'))
                    {
                        String additionalClause = ' Agreement__r.Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\')';
                        amendmentList = Libra_Restul_Functions.getSObjectById(amendment.amendmentId,Libra_Restful_Constants.AmendmentColumns,Libra_Restful_Constants.AmendmentObject,additionalClause);

                    }
                    if(amendment.amendmentType.equalsIgnoreCase('supportingAgreement'))
                    {
                        String additionalClause = ' Supporting_Agreement__r.Agreement__r.Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\')';
                        amendmentList = Libra_Restul_Functions.getSObjectById(amendment.amendmentId,Libra_Restful_Constants.AmendmentColumns,Libra_Restful_Constants.AmendmentObject,additionalClause);

                    }
                    	
                    
                    if(amendmentList!=null && amendmentList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.Ammendment(amendmentList[0])));
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