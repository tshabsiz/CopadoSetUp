@RestResource(urlMapping='/participant/*')
global class Libra_Restful_Participant {

      @HttpPost
    global static void getParticipant()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            List<advpm__Participant__c> participantList;
            if(String.isNotBlank(requestBody))
            {
                Libra_Restul_Functions.ParticipantWrapper participant =(Libra_Restul_Functions.ParticipantWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.ParticipantWrapper.class);
                
                if(String.isNotBlank(participant.participantId))
                {
                String additionalClause = ' advpm__Matter__c IN(Select matter_deal__c from Agreement__c where Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\'))';
                    participantList = Libra_Restul_Functions.getSObjectById(participant.participantId,Libra_Restful_Constants.ParticipantColumns,Libra_Restful_Constants.ParticipantObject,additionalClause);
                    
                    if(participantList!=null && participantList.size()>0)
                    {
                        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new LibraRestfulModel.Participant(participantList[0])));
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