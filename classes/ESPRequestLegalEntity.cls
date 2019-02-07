/*==============================================
 * @CreatedBy   : Mabhedle Tonga 
 * @CreatedDate : 2017-05-25
 * @Description : 
 * =============================================
*/
@RestResource(urlMapping='/requestLegalEntityCIFUpdate/*')
global class ESPRequestLegalEntity {
    
    
    private static string CLIENT_TYPE='Client';
    
    @HttpPost
    global static void requestLegalEntityCIFUpdate(String SFGUID,String CIFNumber	)
    {	
        ESPUtility.Response response  = new ESPUtility.Response();
        try
        {
            Account currentRelationship;
            List<ID> relationshipIDs = new List<ID>();
            //Tonga MM : Search salesforce guid and that will find the record and update it using the CIF provided
            List<Account> relationshipList = [Select id,Name,SDS__c,CIF__c,RecordTypeId,Type from Account where ID=:SFGUID];
            
            if(relationshipList.size()>0)
            {
                currentRelationship = relationshipList[0];
                currentRelationship.CIF__c = CIFNumber;
                currentRelationship.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
                currentRelationship.Type = CLIENT_TYPE;	
                
                update currentRelationship;
                
                
                response.message  ='Successful Update';
           }
            else
            {
                response.message  ='Salesforce Account Id received does not exist in the database';
            }
            if(!Test.isRunningTest())
            {
                RestContext.response.responseBody = Blob.valueOf(System.JSON.serialize(response));
            }
            
        }
        catch(Exception exc)
        {
            response.message  =exc.getMessage();
            response.stackTrace  =exc.getStackTraceString();
            RestContext.response.responseBody = Blob.valueOf(System.JSON.serialize(response));
        }
    }

}