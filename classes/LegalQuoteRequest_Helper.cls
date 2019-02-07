public class LegalQuoteRequest_Helper {
    
    /**
    * VARIABLES
    **/
    public static List<UserRole> userRoles = new List<UserRole>();
    public static List<User> users = new List<User>();
    
    
    public static User determineApprovalUser(Id inputUserId)
    {
        System.debug('### LegalQuoteRequest_Helper : determineApprover');
        System.debug('### LegalQuoteRequest_Helper : determineApprover : userId : '+inputUserId);
         
        //Get all roles in the hierachy.
        userRoles = [
            SELECT
                Id,
                Name,
                ParentRoleId
            FROM UserRole
        ];
        
        System.debug('### LegalQuoteRequest_Helper : determineApprover : userRoles : '+userRoles);
        
        //Get all user records.
        users = [
            SELECT
                Id,
                Username,
                UserRoleId,
                UserRole.Name,
                Can_Approve_Legal_Quotes__c
            FROM User
            WHERE isActive = true
        ];
        
        System.debug('### LegalQuoteRequest_Helper : determineApprover : users : '+users);
        
        //Make sure we got roles and users backs.
        if(!userRoles.isEmpty() && !users.isEmpty())
        {
            //Convert lists to a maps.
            Map<Id, User> usersMap = new Map<Id, User>(users);
            Map<Id, UserRole> userRolesMap = new Map<Id, UserRole>(userRoles);
            
            //Starting role.
            Id currentRoleId = usersMap.get(inputUserId).UserRoleId;
            System.debug('### LegalQuoteRequest_Helper : determineApprover : currentRoleId : '+currentRoleId);
            
            while(currentRoleId != null)
            {
                System.debug('### LegalQuoteRequest_Helper : determineApprover : WHILE : START');
                System.debug('### LegalQuoteRequest_Helper : determineApprover : WHILE : START : currentRoleId : '+currentRoleId);
                
                //Approval user
                User approvalUser = approverInRole(currentRoleId);
                
                //No user found.
                if(approvalUser == null)
                {
                    //Call function again.
                    currentRoleId =  userRolesMap.get(currentRoleId).ParentRoleId;
                }
                
                //User found.
                if(approvalUser != null)
                {
                    System.debug('### LegalQuoteRequest_Helper : determineApprover : approvalUser.Id : '+approvalUser.Id);
                    
                    //Return approval user record.
                    return approvalUser; 
                }
                System.debug('### LegalQuoteRequest_Helper : determineApprover : WHILE : END'); 
            }
        }
        
        //Default Return.
        return null;
    }
    
    /**
    * Determines if a role has an approver in the role.
    **/
    public static User approverInRole(Id inputRoleId)
    {
        //Loop through all users
        for(User user : users)
        {
            if(user.UserRoleId == inputRoleId && user.Can_Approve_Legal_Quotes__c == true)
            {
                return user;
            }
        }
        
        //Default return.
        return null;
    }
    
    /**
    * getFullRecords - Returns full record details.
    **/
    public static List<Legal_Quote_Request__c> getFullRecords(Set<Id> inputIds)
    {
        List<Legal_Quote_Request__c> legalQuoteRequests = new List<Legal_Quote_Request__c>();
        
        legalQuoteRequests = [
            SELECT 
                Id,
                Name,
                RecordTypeId,
                Quote_Approver__c
            FROM Legal_Quote_Request__c 
            WHERE Id IN :inputIds
        ];
        
        return legalQuoteRequests;
    }
    
    /**
    * getRecordTypeMap - Returns a map of record type id to name.
    **/
    public static Map<Id, String> getRecordTypeMap()
    {
        Map<Id, String> recordTypeMap = new Map<Id, String>();
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Legal_Quote_Request__c').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        
        for(Schema.RecordTypeInfo info : recordTypeInfo)
        {
            recordTypeMap.put(info.getRecordTypeId(), info.getName()); 
        }
        
        //Default return.
        return recordTypeMap;
    }

    public static Integer calculateRiskScore(String value, String difficulty)
    {
        System.debug('### LegalQuoteRequest_Helper : calculateRiskScore');
        
        Integer score = 0;
        
        if(difficulty == 'Low')
        {
            if(value == 'Very Low')
            {
                score = 1;
            }
            if(value == 'Low')
            {
                score = 1;
            }
            if(value == 'Medium')
            {
                score = 2;
            }
            if(value == 'High')
            {
                score = 3;
            }
            if(value == 'Very High')
            {
                 score = 3;
            }
        }
        
        if(difficulty == 'Medium')
        {
            if(value == 'Very Low')
            {
                score = 1;
            }
            if(value == 'Low')
            {
                score = 2;
            }
            if(value == 'Medium')
            {
                score = 3;
            }
            if(value == 'High')
            {
                score = 4;
            }
            if(value == 'Very High')
            {
                score = 5;
            }
        }
        
        if(difficulty == 'High')
        {
            if(value == 'Very Low')
            {
                score = 2;
            }
            if(value == 'Low')
            {
                score = 3;
            }
            if(value == 'Medium')
            {
                score = 4;
            }
            if(value == 'High')
            {
                score = 5;
            }
            if(value == 'Very High')
            {
                score = 6;
            }
        }
        
        return score;
    }

    public static void detemineLegalQuoteRequestStatus(List<Legal_Quote__c> inputNewList, Map<Id,Legal_Quote__c> inputOldMap)
    {
        //Blank list.
        Set<Id> legalQuoteRequestIds = new Set<Id>(); 
        List<Legal_Quote_Request__c> legalQuoteRequests = new List<Legal_Quote_Request__c>();

        //Loop new records.
        for(Legal_Quote__c legalQuote : inputNewList)
        {
            //Requested services.
            if(legalQuote.Request_for_Service__c == true && inputOldMap.get(legalQuote.Id).Request_for_Service__c == false)
            {   
                //Add to affected requests list.
                legalQuoteRequestIds.add(legalQuote.Legal_Quote_Request__c);
            }
        } 

        //Anything to process. 
        if(!legalQuoteRequestIds.isEmpty())
        {
            //Fetch legal quote request records.
            legalQuoteRequests = [
                SELECT
                    Id,
                    Status__c
                FROM
                    Legal_Quote_Request__c
                WHERE
                    Id IN :legalQuoteRequestIds
            ];

            //Set status.
            for(Legal_Quote_Request__c legalQuoteRequest : legalQuoteRequests)
            {
                legalQuoteRequest.Status__c = 'Closed';
            }   

            //Update
            update legalQuoteRequests;
        }      
    }
}