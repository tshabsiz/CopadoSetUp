@RestResource(urlMapping='/clause/*')
global class Libra_Restful_Clause {

	@HttpPOST
    global static void getClause()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<Clause__c> clauseList;
            List<LibraRestfulModel.Clause> clauseCollection = new List<LibraRestfulModel.Clause>();
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.ClauseWrapper clause =(Libra_Restul_Functions.ClauseWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.ClauseWrapper.class);
                
                if(String.isNotBlank(clause.clauseId))
                {
                    clauseList = Libra_Restul_Functions.getSObjectById(clause.clauseId,Libra_Restful_Constants.ClauseColumns,Libra_Restful_Constants.ClauseObject);
                    
                    if(clauseList!=null && clauseList.size()>0)
                    {
                        clauseCollection.add(new LibraRestfulModel.Clause(clauseList[0]));
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(clauseCollection));
                    }
                    
                }
                else
                {
                    
                    
                    for(Clause__c varClause :(List<Clause__c>)Libra_Restul_Functions.getSObject(Libra_Restful_Constants.ClauseColumns,Libra_Restful_Constants.ClauseObject))
                    {
                        clauseCollection.add(new LibraRestfulModel.Clause(varClause));
                    }
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(clauseCollection));
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