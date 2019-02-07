@RestResource(urlMapping='/netting-group/*')
global class Libra_Restful_Netting_Group {

	@HttpPost
    global static void getNettingGrouping()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Netting_Group__c> nettingGroupList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.NettingGroupWrapper nettingGroup =(Libra_Restul_Functions.NettingGroupWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.NettingGroupWrapper.class);
                
                if(String.isNotBlank(nettingGroup.nettingGroupId))
                {
                String additionalClause = ' Matter_Deal__c IN(Select matter_deal__c from Agreement__c where Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\'))';
                    nettingGroupList = Libra_Restul_Functions.getSObjectById(nettingGroup.nettingGroupId,Libra_Restful_Constants.nettingGroupColumns,Libra_Restful_Constants.nettingGroupObject,additionalClause);
                    
                    if(nettingGroupList!=null && nettingGroupList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.NettingGroup(nettingGroupList[0])));
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