/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Service external collaboration folder creation after an approval process was granted
* @Date:        2018
*/
public class BxdExternalCollaborationService {
    //init BxdFolderHandler
    private static FolderHandler folderHandler = new FolderHandler();
    private static Map<String, Request_Member__c> memberMap;
    
    /**
    * createExternalCollaboration - create external collaboration after an approval process
    **/
    @Future(callout = true)
    public static void createApprovedExternalCollaborations(Set<String> externalCollabRequests) {
        System.debug('****SET '+externalCollabRequests);
        if(externalCollabRequests != null){
            //fetch request members.
            List<External_Collaboration_Request__c> collaborationRequests = [SELECT Id, Deal__c, Deal__r.External_Collaboration_Id__c,
                                                                             Folder_Id__c, Folder_Name__c, Access_Level__c, Parent_Request__c,
                                                                             Access_Valid_Until__c, Processed__c, Deal__r.Name, Deal__r.RecordTypeId,
                                                                             (
                                                                                 SELECT
                                                                                 Id,
                                                                                 Member_Email__c,
                                                                                 Collaboration_Id__c,
                                                                                 External_Collaboration_Request__c
                                                                                 FROM Request_Members__r 
                                                                             )
                                                                             FROM External_Collaboration_Request__c
                                                                             WHERE Id in: externalCollabRequests ];
            
            //initialized members list for those with success collaboration creation
            List<Request_Member__c> updatedMembers;
            
            //get the request from the list          
            for(External_Collaboration_Request__c request : collaborationRequests){    
                String folderId;
                String parentFolderId;
                Box_Folder_Structure__c folderStructure;
                advpm__Matter__c matter;
                
                //get folder structure for Deals
                if(request.Deal__c != null)
                    folderStructure = folderHandler.getFolderStructure(advpm__Matter__c.SObjectType, request.Deal__r.RecordTypeId, true, true);
                
                //set the External Collaboration parent folder from the Matter
                parentFolderId = request.Deal__r.External_Collaboration_Id__c;
                if(String.isBlank(parentFolderId)){
                    //get matter folder
                    String matterFolderId = folderHandler.getBoxFolderIdByRecordId(request.Deal__c);
                    
                    //create parent external collaboration of them all
                    if(!String.isBlank(matterFolderId) && folderStructure != null){
                        matter = [SELECT Id, Name, Matter_ID__c, RecordTypeId, Owner.Id  FROM advpm__Matter__c WHERE Id=:request.Deal__c];
                        //set helper
                        BxdExternalCollaborationHelper parentExternalHelper = new BxdExternalCollaborationHelper(null, folderStructure.Folder_Name__c + ' - ' + matter.Name, matterFolderId, folderStructure.External_Collaboration_Id__c, null, null);
                        
                        //create parent external collaboration folder
                        parentExternalHelper = folderHandler.createExternalBoxFolder(parentExternalHelper);
                        parentFolderId = parentExternalHelper.folderId;
                        
                        //set folder on matter
                        matter.External_Collaboration_Id__c = parentFolderId;
                    }
                }
                
                //process request
                if(!String.isBlank(parentFolderId) && !String.isBlank(request.Access_Level__c ) && folderStructure != null){                    
                    //init helper list and map
                    memberMap = new Map<String, Request_Member__c>();
                    List<BxdExternalCollaborationHelper.Collaborator> collaborators = new List<BxdExternalCollaborationHelper.Collaborator>();
                    
                    //add members to collaborators list
                    for(Request_Member__c member : request.Request_Members__r){
                        collaborators.add(new BxdExternalCollaborationHelper.Collaborator(member.Member_Email__c, null));
                        
                        //keep the reference in a map
                        memberMap.put(member.Member_Email__c, member);
                    }
                    
                    //create new folder if folder is blank
                    if(String.isBlank(request.Folder_Id__c) && !collaborators.isEmpty()) {
                        //set external collaboration details on helper
                        BxdExternalCollaborationHelper externalHelper = new BxdExternalCollaborationHelper(null, request.Folder_Name__c + ' - [' + request.Deal__r.Name + ']', parentFolderId, folderStructure.External_Collaboration_Id__c, collaborators, folderHandler.parseToolkitRole(request.Access_Level__c));
                        
                        //create external collaboration folder
                        externalHelper = folderHandler.createExternalBoxFolder(externalHelper);
                        
                        //set external collaboration folder on request
                        request.Folder_Id__c = externalHelper.folderId;
                        
                        //set collaboration IDs on Member objects
                        updatedMembers = addCollaborationIdOnMember(externalHelper.collaborators);
                    } else if(!String.isBlank(request.Folder_Id__c)) {
                        //old request, amend external collaboration
                        BxdExternalCollaborationHelper externalHelper = amendExternalCollaboration(request, folderStructure);
                        
                        if(externalHelper != null){
                            //set collaboration IDs on Member objects
                            updatedMembers = addCollaborationIdOnMember(externalHelper.collaborators);
                        }
                    }
                    
                    //commit box changes
                    folderHandler.commitBoxChanges();
                    
                    //update members
                    if(updatedMembers != null && !updatedMembers.isEmpty())
                        update updatedMembers;
                    
                    //update request
                    if(request != null)
                        update request;
                    
                    //update matter
                    if(matter != null){
                        update matter;
                    }
                }           
            }
        }
    }
    
    /**
    * amendExternalCollaboration - remove external collaboration after an approval process
    **/
    private static BxdExternalCollaborationHelper amendExternalCollaboration(External_Collaboration_Request__c newRequest, Box_Folder_Structure__c folderStructure) {
        //init helper and all lists to process
        BxdExternalCollaborationHelper externalHelper = null;
        List<BxdExternalCollaborationHelper.Collaborator> addedCollaborators = new List<BxdExternalCollaborationHelper.Collaborator>();
        List<BxdExternalCollaborationHelper.Collaborator> updatedCollaborators = new List<BxdExternalCollaborationHelper.Collaborator>();
        List<BxdExternalCollaborationHelper.Collaborator> removedCollaborators = new List<BxdExternalCollaborationHelper.Collaborator>();
        
        //init helper map for reference
        Map<String, Request_Member__c> oldMemberMap = new Map<String, Request_Member__c>();
        
        //query old linked request
        External_Collaboration_Request__c oldRequest = [SELECT Id, Deal__c, Deal__r.External_Collaboration_Id__c, 
                                                        Folder_Id__c, Folder_Name__c, Access_Level__c,
                                                        (
                                                            SELECT
                                                            Id,
                                                            Member_Email__c,
                                                            Collaboration_Id__c,
                                                            External_Collaboration_Request__c
                                                            FROM Request_Members__r 
                                                        )
                                                        FROM External_Collaboration_Request__c
                                                        WHERE Id =: newRequest.Parent_Request__c ];
        
        if(oldRequest != null){
            //build old members map
            for(Request_Member__c oldMember : oldRequest.Request_Members__r){
                oldMemberMap.put(oldMember.Member_Email__c, oldMember);
            }
            
            //get new members and old members that need an update of permission level
            for(Request_Member__c newMember : newRequest.Request_Members__r){
                //if found remove
                Request_Member__c oldMember = oldMemberMap.remove(newMember.Member_Email__c);
                
                //if null it means we never add this member before
                if(oldMember == null){
                    //add to added list
                    addedCollaborators.add(new BxdExternalCollaborationHelper.Collaborator(newMember.Member_Email__c, null));
                    
                    //add to map for reference once processed
                    memberMap.put(newMember.Member_Email__c, newMember);
                } else if(oldMember != null && oldRequest.Access_Level__c != newRequest.Access_Level__c){
                    updatedCollaborators.add(new BxdExternalCollaborationHelper.Collaborator(oldMember.Member_Email__c, oldMember.Collaboration_Id__c));
                }
            }
            
            //if the old Map still contains data, it means some members were removed in new request, we must remove them on box as well
            if(!oldMemberMap.isEmpty()){
                for(Request_Member__c oldMember : oldMemberMap.values()){
                    removedCollaborators.add(new BxdExternalCollaborationHelper.Collaborator(oldMember.Member_Email__c, oldMember.Collaboration_Id__c));
                }
            }
            
            System.debug('### NEWLIST ' + addedCollaborators);
            System.debug('### UPDLIST ' + updatedCollaborators);
            System.debug('### DELLIST ' + removedCollaborators);
            
            //add new collaborators
            if(!addedCollaborators.isEmpty()){
                externalHelper = addCollaborators(newRequest.Folder_Id__c, addedCollaborators, newRequest.Access_Level__c);
            }
            
            //update collaborators
            if(!updatedCollaborators.isEmpty()){
                updateCollaborators(updatedCollaborators, newRequest.Access_Level__c);
            }
            
            //remove collaborators
            if(!removedCollaborators.isEmpty()){
                removeCollaborators(newRequest.Folder_Id__c, removedCollaborators);
            }
        }
        
        return externalHelper;
    }
    
    /**
    * addCollaborators - add collaborators to an existing folder
    **/
    private static BxdExternalCollaborationHelper addCollaborators(String folderId, List<BxdExternalCollaborationHelper.Collaborator> collaborators, String permission) {
        
        folderHandler.addCollaboratorsToFolder(folderId, collaborators, folderHandler.parseToolkitRole(permission));
        
        //set collaborators on helper as we will need it to update members
        return new BxdExternalCollaborationHelper(null, null, null, null, collaborators, null);
    }
    
    /**
    * updateCollaborators - update collaboration role to existing collaborators
    **/
    private static void updateCollaborators(List<BxdExternalCollaborationHelper.Collaborator> collaborators, String permission) {
        //loop through collaboration and update role
        for(BxdExternalCollaborationHelper.Collaborator collaborator : collaborators){
            folderHandler.updateCollaboration(collaborator.collaborationId, folderHandler.parseRole(permission));
        }
    }
    
    /**
    * removeExternalCollaboration - remove external collaboration once valid at date expires
    **/
    public static void removeExternalCollaboration(List<External_Collaboration_Request__c> collaborationRequests) {
        if(!collaborationRequests.isEmpty()){
            //init vars
            List<External_Collaboration_Request__c> processed = new List<External_Collaboration_Request__c>();
            List<BxdExternalCollaborationHelper.Collaborator> collaborators = new List<BxdExternalCollaborationHelper.Collaborator>();
            
            //Loop through each request and remove members.
            for(External_Collaboration_Request__c request : collaborationRequests){
                //add members to collaborators list
                for(Request_Member__c member : request.Request_Members__r){
                    if(!String.isBlank(member.Collaboration_Id__c)){
                        collaborators.add(new BxdExternalCollaborationHelper.Collaborator(member.Member_Email__c, member.Collaboration_Id__c));
                    }
                }
                
                //call remove collaborator api
                Boolean removed = removeCollaborators(request.Folder_Id__c, collaborators);
                if(removed){
                    request.Processed__c = true;
                    processed.add(request);
                }
            }   
            
            //update processed record
            Database.Update(processed, false);
        }
    }
    
    /**
    * removeCollaborators - remove external collaboration on folder
    **/
    private static Boolean removeCollaborators(String folderId, List<BxdExternalCollaborationHelper.Collaborator> collaborators) {
        if(!collaborators.isEmpty()){
            try{
                //remove collaboration for members
                for(BxdExternalCollaborationHelper.Collaborator collaborator : collaborators){
                    folderHandler.removeCollaboration(collaborator.collaborationId);
                }
                
                //will return true if there is no issue
                return true;
            } catch (Exception e){
                System.debug('***BxdExternal Collaboration -- removeCollaborators -- '  + e);
            }
            
        } 
        //otherwise, nothing was process
        return false;
    }
    
    private static List<Request_Member__c> addCollaborationIdOnMember(List<BxdExternalCollaborationHelper.Collaborator> collaborators) {
        List<Request_Member__c> updatedMembers = new List<Request_Member__c>();
        System.debug('***Add Collaborators: '+collaborators);
        
        //set collaboration IDs on members by getting members from map reference
        for(BxdExternalCollaborationHelper.Collaborator collaborator : collaborators){
            Request_Member__c member = memberMap.get(collaborator.email);
            if(member != null){
                member.Collaboration_Id__c = collaborator.collaborationId;
                updatedMembers.add(member);
            } 
        }
        
        return updatedMembers;
    }
      
    /**
    * FolderHandler - wrapper class for BxdFolderHandler
    **/
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            //the specific constructor in parent will be initialized
            super(true);
        }
    }
}