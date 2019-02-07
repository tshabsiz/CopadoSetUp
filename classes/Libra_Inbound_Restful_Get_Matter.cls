/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mabhedle Tonga 
*@Description : Rest function that gets matter with agreement status of Confirmed/Completed or Amended
===============================================*/
@RestResource(urlMapping='/matter/*')
global class Libra_Inbound_Restful_Get_Matter {
    
    @HttpPost
    global static void getMatter()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<advpm__Matter__c> matterList;
            List<LibraRestfulModel.Matter> JSONmatterList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.MatterWrapper mt =(Libra_Restul_Functions.MatterWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.MatterWrapper.class);

                if(mt.matterId!=null)
                {
                    String additionalClause = ' ID IN (Select matter_deal__c from Agreement__c where Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\'))';
                    matterList = Libra_Restul_Functions.getSObjectById(mt.matterId,Libra_Restful_Constants.MatterColumns,Libra_Restful_Constants.MatterObject,additionalClause);
                    
                    if(matterList!=null && matterList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.Matter(matterList[0])));
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