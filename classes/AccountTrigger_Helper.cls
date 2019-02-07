/**
* @Author       Dino Scarcella
* @Company:     Absa Capital
* @Description: Helper for Account Trigger
* @Date:        2017
* @TestClass:   ZZTEST_AccountTrigger_Helper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
===============================================================
*@Modified BY : Mabhedle Tonga 
*@Modification Description : Implemented dynamic manual share for account to opp based on parent change and ownership change
*@Modification Date : 2017-06-22
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

public without sharing class AccountTrigger_Helper {
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-547 - Update Segment on Related Opportunities on account in order for sharing rules to work
* @param            List<Account> triggerNew, Map<Id, Account> triggerOld
* @Returns:         void
* History
* <Date>      <Authors Name>    <Brief Description of Change> 
*------------------------------------------------------------*/
    private static Set<ID> callReportIDSet {get;set;}
    public static void updateOpportunitySegmentAndIndustry(List<Account> triggerNew, Map<Id, Account> triggerOld) {
        Boolean RunTrigger = false;
        for(Account acc : triggerNew) {
            // Only run if the segment/industry has changed
            if (triggerOld.get(acc.Id).Segment__c != acc.Segment__c || triggerOld.get(acc.Id).Industry != acc.Industry)
            {
                RunTrigger = true;
            }
        }
        if (!RunTrigger) return;
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        // Get all opportunities linked to the accounts being updated
        List<Opportunity> oppsPerAccount = [Select Id, AccountId FROM Opportunity WHERE AccountId =: triggerNew];
        // Go through the accounts being updated
        for(Account acc : [Select Id, Segment__c, Industry, OwnerId FROM Account WHERE Id =: triggerNew]) {
            // If the segment/industry has changed
            if (triggerOld.get(acc.Id).Segment__c != acc.Segment__c || triggerOld.get(acc.Id).Industry != acc.Industry) {
                // Go through the opportunities for the account being updated
                for(Opportunity opp : oppsPerAccount) {
                    if (opp.AccountId != null && opp.AccountId == acc.Id) {
                        if (triggerOld.get(acc.Id).Segment__c != acc.Segment__c) opp.Segment__c = 'FireOpportunityUpdate';
                        if (triggerOld.get(acc.Id).Industry != acc.Industry) opp.Industry__c = 'FireOpportunityUpdate';
                        oppsToUpdate.add(opp);
                    }
                }
            }
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
    }
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-547 - Update Segment on Account should the Owner Change
* @param            List<Account> triggerNew, Map<Id, Account> triggerOld
* @Returns:         void
* History
* <Date>      <Authors Name>    <Brief Description of Change>
*------------------------------------------------------------*/
    
    public static void updateAccountSegment(List<Account> triggerNew, Map<Id, Account> triggerOld) {
        Boolean RunTrigger = false;
        for(Account acc : triggerNew) {
            // Only check new account/updated account fields if owner is changed
            if (triggerOld == null || triggerOld.get(acc.Id).OwnerId != acc.OwnerId)
            {
                RunTrigger = true;
            }
        }
        if (!RunTrigger) return;
        
        Set<Id> ownerids = new Set<Id>();
        Map<Id, Id> accownermap = new Map<Id, Id>();
        for(Account acc : triggerNew) {
            ownerids.add(acc.OwnerId);
        }
        Map<Id, User> owneraccdetail = new  Map<Id, User>([Select Id, UserRoleId, UserRole.Name FROM User WHERE Id =: ownerids]);
        for(Account acc : triggerNew) {
            // Only check new account/updated account fields if owner is changed
            if (
                triggerOld == null || 
                triggerOld.get(acc.Id).OwnerId != acc.OwnerId
            )
            {	
                if (owneraccdetail.get(acc.OwnerId).UserRoleId != null && owneraccdetail.get(acc.OwnerId).UserRole.Name.Contains('Coverage - PS')) acc.Segment__c = 'Public Sector';
                else if (owneraccdetail.get(acc.OwnerId).UserRoleId != null && owneraccdetail.get(acc.OwnerId).UserRole.Name.Contains('Global Corporates')) acc.Segment__c = 'Global Corporate';
            }
        }	
    }
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-678 - Toggle sharing client plan with relationship owner (remove old owner, give access to new owner)
* @param            List<Account> triggerNew, Map<Id, Account> triggerOld
* @Returns:         void
* History
* <Date>      <Authors Name>    <Brief Description of Change>
*------------------------------------------------------------*/
    public static void updateClientPlanSharing(List<Account> triggerNew, Map<Id, Account> triggerOld) {
        //getting client plans
        List<Client_Plan__c> plans = [
            SELECT Id, Relationship__c
            FROM Client_Plan__c
            WHERE Relationship__c =: triggerNew
        ];
        //if no client plans no need to go further
        if (plans.size() == 0) return;
        //getting client plan shares done through trigger
        List<Client_Plan__Share> planshares = [
            SELECT Id, ParentId, UserOrGroupId
            FROM Client_Plan__Share
            WHERE ParentId =: plans
            AND RowCause =: Schema.Client_Plan__Share.RowCause.Client_Plan_Manager__c
            AND IsDeleted = false
        ];
        List<Client_Plan__Share> shareRecsToDelete = new List<Client_Plan__Share>();
        List<Client_Plan__Share> shareRecsToAdd = new List<Client_Plan__Share>();
        //loop through all the accounts updated
        for(Account acc : triggerNew) {
            // we only want to do anything if the owner changed
            if (triggerOld.get(acc.Id).OwnerId != acc.OwnerId) {
                //loop through all client plans
                for(Client_Plan__c plan : plans) {
                    Boolean SharedWithNewAccountOwner = false;
                    //if the plans relationship id is the same as the relationship updated
                    if (plan.Relationship__c == acc.id) {
                        //check if the share exists for the previous relationship owner on this specific client plan
                        for(Client_Plan__Share planshare : planshares) {
                            //if we find a share record linked to previous owner delete it
                            if (planshare.ParentId == plan.Id && planshare.UserOrGroupId == triggerOld.get(acc.Id).OwnerId)
                                shareRecsToDelete.add(planshare);
                            //if we find a share record linked to new owner set flag to true
                            if (planshare.ParentId == plan.Id && planshare.UserOrGroupId == acc.OwnerId)
                                SharedWithNewAccountOwner = true;
                        }
                    }
                    //if we never found a share for this plan on the new owner add a share record
                    if (!SharedWithNewAccountOwner) shareRecsToAdd.add(ClientPlanUtils.createSharingInstance(plan.Id, acc.OwnerId));
                }
            }
        }
        if (shareRecsToDelete.size() > 0) Database.delete(shareRecsToDelete, false);
        if (shareRecsToAdd.size() > 0) Database.insert(shareRecsToAdd, false);
    }
    public static void checkOpportunityCallReportShareParentChange(Map<ID,Account> newAccountMap,Map<ID,Account> oldAccountMap)
    {
        Map<id,Account> newBuiltAccountMap = new Map<ID,Account>();
        Map<id,Account> OldBuiltAccountMap = new Map<ID,Account>();
        
        Map<ID,Account> accountToDelete = new Map<Id,Account>();
        
        //Tonga : Determine if manual sharing should be removed completely or updated depending on the user change
        for(Account acc :newAccountMap.values())
        {
            
            if(acc.recordTypeID==Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group').getRecordTypeId())
            {
                if(acc.ParentId!=oldAccountMap.get(acc.ID).ParentID)
                {
                    if(String.isBlank(acc.ParentId))
                    {
                        accountToDelete.put(acc.ID,oldAccountMap.get(acc.ID));
                    }
                    else
                    {
                        newBuiltAccountMap.put(acc.ID, acc);
                        OldBuiltAccountMap.put(acc.ID,oldAccountMap.get(acc.ID)); 
                    }
                       
                }               
            }
            
            if(accountToDelete.size()>0)
            {
                removeOpportunityShare(accountToDelete);
            }
        }
        
        if(newBuiltAccountMap.size()>0)
        {
            updateOppShare(newBuiltAccountMap,oldBuiltAccountMap);
        }
	}
    //Tonga MM : If a user removes a  parent account completely, this should also remove the implemented manual share for the parent Owner
    public static void removeOpportunityShare(Map<ID,Account> accountToDelete)
    {
        Set<ID> accountIDSet = new Set<ID>();
        for(Account acc : accountToDelete.values())
        {
            accountIDSet.add(acc.ParentID);
        }
        List<Opportunity> oppList = [Select ID from Opportunity where AccountID In: accountToDelete.keySet()];
        
        List<Opportunityshare> oppshare = [Select ID from OpportunityShare where OpportunityID IN:oppList AND rowCause='Manual'];
        
        if(oppshare.size()>0)
        {
            delete oppShare;
        }
        
    }
    public static void updateOppShare(Map<ID,Account> newAccountMap,Map<ID,Account> oldAccountMap)
    {
        Set<ID> OwnerIDSet = new Set<ID>();
        Set<ID> OppIDSet = new Set<ID>();
        callReportIDSet = new Set<ID>();
        
        List<OpportunityShare> oldShareToDelete = new List<OpportunityShare>();
        List<OpportunityShare> newShareToInsert = new List<OpportunityShare>();
        Map<ID,Account> accountList;

            accountList = new Map<ID,Account>([select ID,Account.OwnerId,ParentID,Parent.OwnerID,(Select ID,OwnerID 
                                                                                                  from Opportunities
                                                                                                 where RecordTypeID !=:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Private opportunity').getRecordTypeId()) 
                                                           from Account where ID IN :newAccountMap.keySet()]);
        for(Account currentAccount : accountList.values())
        {
            for(Opportunity opp : currentAccount.Opportunities)
            {
                OppIDSet.add(opp.ID);
            }
        }
         for(Account currentAccount :oldAccountMap.values())
        {
            OwnerIDSet.add(accountList.get(currentAccount.ID).Parent.OwnerID);
        }
        //Tonga MM : get a map for Account to Call Report, this way you can determin each owner per parent account for each call report collection
        Map<ID,List<Call_Report__c>> AccountToCallReport = getAccountToCallReportMap(accountList);
        updateCallReportShare(OwnerIDSet,callReportIDSet,AccountToCallReport,accountList);
        
        
       
        
        //Tonga MM : Get Old oppshares delete based on ownership change
        List<OpportunityShare> oppShareList = [Select ID,Opportunity.AccountID 
                                               from OpportunityShare where OpportunityID IN: OppIDSet  
                                               AND rowCause ='Manual'];
        
        for(OpportunityShare oppShare : oppShareList)
        {
            if(oldAccountMap.containsKey(oppShare.Opportunity.AccountID))
            {
                oldShareToDelete.add(oppShare);
            }
        }
        
        //Tonga MM Insert new OpportunityShare        
        for(Account currentAccount : accountList.values())
        {            
            for(Opportunity currentOpportunity : currentAccount.Opportunities)
            {
                if(!currentOpportunity.OwnerID.equals(accountList.get(currentAccount.ID).Parent.OwnerID))
                newShareToInsert.add(addOpportunityShare(currentOpportunity,accountList.get(currentAccount.ID).Parent.OwnerID));
            }
        }
         if(oldShareToDelete.size()>0)
        {
             
            delete oldShareToDelete;
        }
        if(newShareToInsert.size()>0)
        {           
           Database.insert(newShareToInsert,false);
        }
       
    }
    
    public static void checkOpportunityCallReportShareOwnerChange(Map<ID,Account> newAccountMap,Map<ID,Account> oldAccountMap)
    {
        Map<id,Account> newBuiltAccountMap = new Map<ID,Account>();
        Map<id,Account> OldBuiltAccountMap = new Map<ID,Account>();
        
        for(Account currentAccount : newAccountMap.values())
        {
            if(currentAccount.recordTypeID==Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group').getRecordTypeId()&& currentAccount.Type=='Global Parent')
            {
                if(currentAccount.OwnerId!=oldAccountMap.get(currentAccount.ID).OwnerID)
                {                    
                    newBuiltAccountMap.put(currentAccount.ID,currentAccount);
                }
            }
            
        }
        if(newBuiltAccountMap.size()>0)
        {
            updateOpportunityShare(newBuiltAccountMap,oldAccountMap);
        }        
    }
    
    public static void updateOpportunityShare(Map<ID,Account> newAccountMap,Map<ID,Account> oldAccountMap)
    {
        Set<ID> OwnerIDSet = new Set<ID>();
        callReportIDSet = new Set<ID>();
        List<OpportunityShare> oldShareToDelete = new List<OpportunityShare>();
        List<OpportunityShare> newShareToInsert = new List<OpportunityShare>();
        Map<ID,Account> accountList;
        
            accountList = new Map<ID,Account>([select ID,Account.OwnerId,ParentID,(Select ID,OwnerID 
                                                                                   from Opportunities 
                                                                                   where RecordTypeID !=:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Private opportunity').getRecordTypeId())
                                                           from Account where ParentID IN :newAccountMap.keySet()]);
                
        //Tonga MM : get a map for Account to Call Report, this way you can determin each owner per parent account for each call report collection
        Map<ID,List<Call_Report__c>> AccountToCallReport = getAccountToCallReportMap(accountList);
       
        for(Account currentAccount :oldAccountMap.values())
        {
            OwnerIDSet.add(currentAccount.OwnerID);
        }
 		updateCallReportShare(OwnerIDSet,callReportIDSet,AccountToCallReport,newAccountMap);
        
        //Tonga MM : Get Old oppshares delete based on ownership change
        List<OpportunityShare> oppShareList = [Select ID,Opportunity.AccountID 
                                               from OpportunityShare where Opportunity.AccountID IN: accountList.keySet()  
                                               AND UserOrGroupID IN : OwnerIDSet AND rowCause ='Manual'];
        
        
        for(OpportunityShare oppShare : oppShareList)
        {
            if(accountList.containsKey(oppShare.Opportunity.AccountID))
            {
                oldShareToDelete.add(oppShare);
            }
        }
        
        //Tonga MM Insert new OpportunityShare        
        for(Account currentAccount : accountList.values())
        {            
            String ownerID = newAccountMap.get(currentAccount.ParentID).OwnerID;
            for(Opportunity currentOpportunity : currentAccount.Opportunities)
            {
                if(!ownerID.equalsIgnoreCase(currentOpportunity.OwnerID))
                {
                    newShareToInsert.add(addOpportunityShare(currentOpportunity,ownerID));
                }                
            }
        }
        
        if(newShareToInsert.size()>0)
        {
            Database.insert(newShareToInsert,false);
        }
        if(oldShareToDelete.size()>0)
        {
            delete oldShareToDelete;
        }
    }
    
    
    public static void updateCallReportShare(Set<ID> OldUserIDSet,Set<ID> CallReportID,Map<ID,List<Call_Report__c>>AccountToCallReport,Map<id,Account>newAccountMap)
    {
        List<Call_Report__Share> newCallReportShare = new List<Call_Report__Share>();

        //Tonga MM : Get Old oppshares delete based on ownership change
        List<Call_Report__Share> oppShareList = [Select ID,ParentID,UserOrGroupID 
                                               from Call_Report__Share where ParentID IN: CallReportID  
                                               AND rowCause ='Manual' AND UserOrGroupID IN:OldUserIDSet];
        
        for(ID accountID : AccountToCallReport.keySet())
        {           
            for(Call_Report__c callReport : AccountToCallReport.get(accountID))
            {                
                if(newAccountMap.containskey(callReport.Relationship__r.ParentID))
                {
                    newCallReportShare.add(addCallReportShare(callReport,newAccountMap.get(callReport.Relationship__r.ParentID).OwnerID));
                }
                else if(newAccountMap.containskey(callReport.Relationship__c))
                {
                    newCallReportShare.add(addCallReportShare(callReport,newAccountMap.get(callReport.Relationship__c).Parent.OwnerID));
                }
            }
        }
        
        if(oppShareList.size()>0)	
        {
            delete oppShareList;
        }
        if(newCallReportShare.size()>0)
        {            
            Database.insert(newCallReportShare,false);
        }        
   }    
    //Tonga MM : Build sharing record for each user per record for Call Report
    private static Call_Report__Share addCallReportShare(Call_Report__c callReport, ID newOwner)
    {
        Call_Report__Share callReportShare = new Call_Report__Share();
        callReportShare.UserOrGroupId = newOwner;
        callReportShare.ParentID = callReport.ID;
        callReportShare.AccessLevel = 'Read';
        
        return callReportShare;
    }
    
    //Tonga MM : Built sharing entry for user per record for Opportunity
    public static OpportunityShare addOpportunityShare(Opportunity opp, ID newOwner)
    {
        OpportunityShare oppShare = new OpportunityShare();
        oppShare.UserOrGroupId = newOwner;
        oppShare.OpportunityId = opp.ID;
        oppShare.OpportunityAccessLevel = 'Read';
      
        return oppShare;
    }
    
    private static Map<ID,List<Call_Report__c>> getAccountToCallReportMap(Map<ID,Account> accountList)
    {
        Map<ID,List<Call_Report__c>> AccountToCallReport = new Map<ID,List<Call_Report__c>>();
       
        for(Call_Report__c callReport : [select ID,Relationship__r.ParentID,RelationShip__c,relationShip__r.Parent.OwnerID from Call_Report__c where Relationship__c IN: accountList.keySet()])
        {
            callReportIDSet.add(callReport.ID);
            if(AccountToCallReport.containsKey(callReport.Relationship__c))
            {
                AccountToCallReport.get(callReport.Relationship__c).add(callReport);
            }
            else
            {
                AccountToCallReport.put(callReport.Relationship__c,new List<Call_Report__c>{callReport});
            }
        }    
        return AccountToCallReport;
    }
    
    /**
    * @Author:          Dino Scarcella
    * @Company:         Absa Capital
    * @Description:     CIBDIGSALP-1384 - Sharing rules for matrix reporting
    * @param            List<Account> triggerNew, Map<Id, Account> triggerOld
    * @Returns:         void
    * History
    * <Date>      <Authors Name>    <Brief Description of Change> 
    *------------------------------------------------------------*/
    public static void updateOpportunityRelationshipOwnerRole(List<Account> triggerNew, Map<Id, Account> triggerOld) {
        Boolean RunTrigger = false;
        for(Account acc : triggerNew) {
            // Only run if the account owner has changed
            if (triggerOld.get(acc.Id).OwnerId != acc.OwnerId)
            {
                RunTrigger = true;
            }
        }
        if (!RunTrigger) return;
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        // Get all opportunities linked to the accounts being updated
        List<Opportunity> oppsPerAccount = [Select Id, AccountId, RelationshipOwnerRoleName__c FROM Opportunity WHERE AccountId =: triggerNew];
        // Go through the accounts being updated
        for(Account acc : [Select Id, OwnerId, Owner.UserRole.Name FROM Account WHERE Id =: triggerNew]) {
            // If the Relationship Owner has changed
            if (triggerOld.get(acc.Id).OwnerId != acc.OwnerId) {
                // Go through the opportunities for the account being updated
                for(Opportunity opp : oppsPerAccount) {
                    if (opp.AccountId != null && opp.AccountId == acc.Id
                        && opp.RelationshipOwnerRoleName__c != acc.Owner.UserRole.Name) {
                        opp.RelationshipOwnerRoleName__c = acc.Owner.UserRole.Name;
                        oppsToUpdate.add(opp);
                    }
                }
            }
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
    }
}