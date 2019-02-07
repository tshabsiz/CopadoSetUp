@RestResource(urlMapping='/deal-party/*')
global class Libra_Restful_Deal_Party {

      @HttpPost
    global static void getDealParty()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Deal_Party__c> dealPartyList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.DealPartyWrapper dealParty =(Libra_Restul_Functions.DealPartyWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.DealPartyWrapper.class);
                
                if(String.isNotBlank(dealParty.dealPartyId))
                {
                String additionalClause = ' Deal__c IN(Select matter_deal__c from Agreement__c where Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\'))';
                    dealPartyList = Libra_Restul_Functions.getSObjectById(dealParty.dealPartyId,Libra_Restful_Constants.DealPartyColumns,Libra_Restful_Constants.DealPartyObject,additionalClause);
                    
                    if(dealPartyList!=null && dealPartyList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.DealParty(dealPartyList[0])));
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