/**
* @Author       Dino Scarcella
* @Company:     Absa Capital
* @Description: Helper for User Trigger
* @Date:        2017
* @TestClass:   ZZTEST_UserTrigger_Helper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
===============================================================*/

public without sharing class UserTrigger_Helper {
	public static void updateOpportunityAndCallReportRelationshipOwnerRole(List<User> triggerNew, Map<Id, User> triggerOld) {
        List<String> oppIds = new List<String>();
		List<String> oppRelationshipOwnerRoles = new List<String>();
        
        List<String> callreportIds = new List<String>();
		List<String> callreportRelationshipOwnerRoles = new List<String>();
        
        // Get all call reports linked to the relationship owners being updated
        List<Call_Report__c> callreportsPerUser = [Select Id, Relationship__c, Relationship__r.OwnerId, Relationship__r.Owner.UserRole.Name, RelationshipOwnerRoleName__c FROM Call_Report__c WHERE Relationship__r.OwnerId =: triggerNew];
    	// Get all opportunities linked to the relationship owners being updated
        List<Opportunity> oppsPerUser = [Select Id, AccountId, Account.OwnerId, Account.Owner.UserRole.Name, RelationshipOwnerRoleName__c FROM Opportunity WHERE Account.OwnerId =: triggerNew];
        // Go through the users being updated
        for(User usr : [Select Id, UserRole.Name FROM User WHERE Id =: triggerNew]) {
            // If the Relationship Owner Role has changed
            if (triggerOld.get(usr.Id).UserRole != usr.UserRole) {
                // Go through the opportunities for the relationship owner roles being updated
                for(Opportunity opp : oppsPerUser) {
                    if (opp.Account.OwnerId == usr.Id &&
                        opp.RelationshipOwnerRoleName__c != usr.UserRole.Name) {
                        oppIds.add(opp.Id);
                        oppRelationshipOwnerRoles.add(usr.UserRole.Name);
                    }
                }
                // Go through the call reports for the relationship owner roles being updated
                for(Call_Report__c cr : callreportsPerUser) {
                    if (cr.Relationship__r.OwnerId == usr.Id &&
                        cr.RelationshipOwnerRoleName__c != usr.UserRole.Name) {
                        callreportIds.add(cr.Id);
                        callreportRelationshipOwnerRoles.add(usr.UserRole.Name);
                    }
                }
            }
        }
        if (oppIds.size() > 0 || callreportIds.size() > 0) updateOpportunityAndCallReportRelationshipOwnerRoles(oppIds, oppRelationshipOwnerRoles, callreportIds, callreportRelationshipOwnerRoles);
    }
    
    @future
    static void updateOpportunityAndCallReportRelationshipOwnerRoles(String[] oppIds, String[] oppRelationshipOwnerRoles, String[] callreportIds, String[] callreportRelationshipOwnerRoles) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Integer i = 0; i < oppIds.size(); i++) {
            oppsToUpdate.add(new Opportunity(Id = oppIds[i], RelationshipOwnerRoleName__c = oppRelationshipOwnerRoles[i]));
        }
        if (oppsToUpdate.size() > 0) {
        	Database.SaveResult[] result = Database.Update(oppsToUpdate, false);
            for (Database.SaveResult sr : result) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('We were not able to update Opportunity:' + err.getMessage());
                    }
                }
            }
        }
    	
        List<Call_Report__c> crsToUpdate = new List<Call_Report__c>();
        for(Integer i = 0; i < callreportIds.size(); i++) {
            crsToUpdate.add(new Call_Report__c(Id = callreportIds[i], RelationshipOwnerRoleName__c = callreportRelationshipOwnerRoles[i]));
        }
        if (crsToUpdate.size() > 0) {
        	Database.SaveResult[] result = Database.Update(crsToUpdate, false);
            for (Database.SaveResult sr : result) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('We were not able to update Call Report:' + err.getMessage());
                    }
                }
            }   
        }
    }
    
     public static void UpdateProfilePicture(List<User> newUser, List<User> oldUser) {
        
       system.debug('newUser'+newUser);
         system.debug('oldUser'+oldUser);
        for (User u: newUser) {
            User us = [Select FullPhotoUrl from user where id =: u.id];
            u.Full_Photo_URL1__c = us.FullPhotoUrl ;
      
        }
       
     }
}