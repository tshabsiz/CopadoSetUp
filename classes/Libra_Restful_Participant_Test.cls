/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mthandeni Gumede	
*@Description : Test Class for Libra_Restful_Participant 
===============================================*/
@isTest
public class Libra_Restful_Participant_Test {
    
    static testMethod void Test_Postive() {
       
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/participant/';
        req.addHeader('httpMethod', 'POST');
        
        
        String participantId = [select Matter_Deal__c from Agreement__c where Agreement_Status__c= 'Amended' limit 1].Matter_Deal__c;
        
        Libra_Restul_Functions.ParticipantWrapper participant = new Libra_Restul_Functions.ParticipantWrapper();
        participant.participantId = participantId;
        req.requestBody = Blob.valueof(JSON.serialize(participant));
        RestContext.request = req; 
        RestContext.response= res;
        

        
        Test.startTest();
        Libra_Restful_Participant.getParticipant();
        Test.stopTest();
    }
    
        
    static testmethod void myUnitTestNegative()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/participant/';       
        
        
        Libra_Restul_Functions.ParticipantWrapper participant = new Libra_Restul_Functions.ParticipantWrapper();
        participant.participantId = 'Invalid ID';
        req.requestBody = Blob.valueof(JSON.serialize(participant));
        RestContext.request = req; 
        RestContext.response= res;
        
        test.startTest();
        Libra_Restful_Participant.getParticipant();
        test.stopTest();
    }
    
   @TestSetup static void setupData()
    {
        Libra_TestDataClass data =  new Libra_TestDataClass();
        
        List<Agreement__c> Agreementlist = [Select id,Agreement_Status__c from Agreement__c limit 1];
        if(Agreementlist.size()>0)
        {
            Agreementlist[0].Agreement_Status__c ='Amended';
        }
        
        update Agreementlist;
    }

}