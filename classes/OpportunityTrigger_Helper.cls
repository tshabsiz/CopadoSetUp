/**
* @Author       Unknown
* @Company:     Deloitte
* @Description: Helper for Opportunity trigger
* @Date:        2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_OpportunityTrigger_Helper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 30.09.2015    Svata Sejkora   US-0599 Added new method to create Tender record upon creation or update of specific Opp
* 13.10.2015    Svata Sejkota   US-???? new method to set default pricebook after update
* 01.07.2016	Mohsin Wadee	SFA-327 Changed addAccountableBankerToOppTeam() and replaceAccountableBankerForOppTeam() methods
*										to add the banker as a team member regardless of private or public, 
*										or if the 'The accountable banker has been cleared' checkbox is ticked.
* 16.05.2017    Dino Scarcella  SFA-784 Private side client functionality refinement
* 17.05.2017    Tonga MM        SFA-836 Fixed issue in production when coverage bankers are added as team member they need edit permission on the opportunity
* 26.06.2017	Dino Scarcella  CIBDIGSALP-1100 Allow swopping from Private side client to original client on old opportunities that didn't have Private Side Classification set
* 31.01.2017    Sizwe Tshabalala SFA-1281 Added error handling for provate side opportunity for when an accountable banker is added without being cleard.
* 20.06.2018	Dino Scarcella  CIBDIGSALP-2109 Update Significant Pitch validation
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

public without sharing class OpportunityTrigger_Helper {
    
    public enum  OpportunityRT { PublicOpp, PrivateOpp }
    public static final String TEAM_ROLE_BANKER = 'Accountable Banker';
    public static Boolean FirstRun = true;
    public static Boolean isInsert = false;
    public static Account PrivateSideClient;
    public static Boolean PrivateSideClientSearched = false;
    public static Set<Id> modifyOpportunityForPrivateSideUser = new Set<Id>();
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     US-???? - Sets default pricebook for provided list of opportunities 
* @param            List<Opportunity> triggerNew
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    
    static public void setDefaultPriceBook(List<Opportunity> listOfOpp) {
        
        List<Pricebook2> pricebook = [SELECT Name, Id FROM Pricebook2 WHERE IsStandard = TRUE];
        
        if(pricebook.size() > 0) {
            for(Opportunity opp : listOfOpp) {
                if(opp.Pricebook2Id == null) {
                    opp.Pricebook2Id = pricebook[0].Id;
                }
                System.debug('XXXXXX actual code Opportunity pricebook changed to ' + opp.Pricebook2Id);
                System.debug('XXXXXX actual code Pricebook Id to be used ' + pricebook[0].Id);
            }
        }
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     US-???? - Sets default pricebook for provided list of opportunities after update (new method is needed as we need to update Pricebook after update, otherwise SF will delete it)
* @param            List<Opportunity> triggerNew
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    
    static public void setDefaultPriceBookAfterUpdate(List<Opportunity> listOfOpp, Map<Id, Opportunity> triggerold) {
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        Set<Id> oppsId = new Set<Id>();
        
        
        for(Opportunity opie: listOfOpp) {
            if(opie.Pricebook2Id == null) {
                oppsId.add(opie.Id);
            }
        }    
        
        if(oppsId.size() > 0) {
            List<Pricebook2> pricebook = [SELECT Name, Id FROM Pricebook2 WHERE IsStandard = TRUE];
            if (pricebook.size() > 0) {
                for(Opportunity opp : [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id in :oppsId]) {
                    
                    opp.Pricebook2Id = pricebook[0].Id;
                    
                    oppToUpdate.add(opp);
                    System.debug('XXXXXX actual code Opportunity pricebook changed to ' + opp.Pricebook2Id);
                    System.debug('XXXXXX actual code Pricebook Id to be used ' + pricebook[0].Id);
                }
                update oppToUpdate;
            }
        }
    }
    /**
* @ModifiedDate : 2017-05-17
* @ModifiedBy   : Tonga MM
* @Description  : Fixed issue in production when coverage bankers are added as team member they need edit permission on the opportunity
* */
    
    public static void addCoverageBanker(List<Opportunity> listOfOpp,Map<Id, Opportunity> triggerOld)
    {
        Boolean RunTrigger = false;
        for(Opportunity opp : listOfOpp)
        {
            if (triggerOld.get(opp.Id).ProductPartnerApprovalStatus__c != opp.ProductPartnerApprovalStatus__c
                && opp.ProductPartnerApprovalStatus__c == 'Approved'
                && opp.ProductPartner__c != NULL)
            {
                RunTrigger = true;
            }
        }
        if (RunTrigger == false) return;
        
        //get list of all Opportunity Team Members in the opportunities in question
        List<OpportunityTeamMember> oppteammembers = [SELECT UserId, OpportunityId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId IN :listOfOpp];
        
        
        Map<Id, Set<Id>> oppteammembermap = new Map<Id,  Set<Id>>(); 
        //create a map of Opportunities and Opportunity Team Members
        for (OpportunityTeamMember existingOppTeamMember : oppteammembers) {
            if (oppteammembermap.containsKey(existingOppTeamMember.OpportunityId)) {
                oppteammembermap.get(existingOppTeamMember.OpportunityId).add(existingOppTeamMember.UserId);
            } else {
                oppteammembermap.put(existingOppTeamMember.OpportunityId,  new Set<Id>{existingOppTeamMember.UserId});
            }
        }
        List<OpportunityTeamMember> oppTeamMembersToIns = new List<OpportunityTeamMember>();
        Map<Id, Set<Id>> mapOpportunityToTeamMember = new Map<Id, Set<Id>>();
        for(Opportunity opp : listOfOpp)
        {
            if (triggerOld.get(opp.Id).ProductPartnerApprovalStatus__c != opp.ProductPartnerApprovalStatus__c
                && opp.ProductPartnerApprovalStatus__c == 'Approved'
                && opp.ProductPartner__c != NULL
               )
            {
                // Add the Original Owner to the Deal Team if not there
                if (!oppteammembermap.containsKey(opp.Id) ||
                    !oppteammembermap.get(opp.Id).Contains(triggerOld.get(opp.Id).OwnerID)) {
                        OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                        oppTeamMember.OpportunityId = opp.Id;
                        oppTeamMember.UserId = triggerOld.get(opp.Id).OwnerID;
                        oppTeamMember.Accountable_Banker__c = true;
                        oppTeamMember.TeamMemberRole = 'Coverage Banker';
                        oppTeamMember.I_confirm_team_member_has_been_cleared__c  =true;
                        oppTeamMembersToIns.add(oppTeamMember);
                        if(mapOpportunityToTeamMember.containsKey(oppTeamMember.OpportunityId)){
                            mapOpportunityToTeamMember.get(oppTeamMember.OpportunityId).add(oppTeamMember.UserId);
                        } else{
                            mapOpportunityToTeamMember.put(oppTeamMember.OpportunityId, new Set<Id>{oppTeamMember.UserId});
                        }
                    }
                
                
            }
        }
        
        //Insert Opportunity Team Members
        insert oppTeamMembersToIns;
        
        List<OpportunityShare> oppShareToUpd = new List<OpportunityShare>();
        for(OpportunityShare oppShare : [SELECT Id, OpportunityAccessLevel, OpportunityId, UserOrGroupId 
                                         FROM OpportunityShare 
                                         WHERE OpportunityId IN :mapOpportunityToTeamMember.keySet() AND RowCause = 'Team']){
                                             if(mapOpportunityToTeamMember.get(oppShare.OpportunityId).contains(oppShare.UserOrGroupId)){
                                                 oppShare.OpportunityAccessLevel = 'Edit';
                                                 oppShareToUpd.add(oppShare);
                                             }
                                         }
        //Update Opportunity Access Level
        update oppShareToUpd;
    }
    /**
* @description Adds accountable banker to opportunity team members for provided list of opportunities 
* @param List<Opportunity> listOfOpp
*/
    static public void addAccountableBankerToOppTeam(List<Opportunity> listOfOpp){
        List<OpportunityTeamMember> oppTeamMembersToIns = new List<OpportunityTeamMember>();
        Map<Id, Set<Id>> mapOpportunityToTeamMember = new Map<Id, Set<Id>>();
        
        for(Opportunity opp : listOfOpp){
            if (String.isNotBlank(opp.Accountable_Banker__c)) {
                OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                oppTeamMember.OpportunityId = opp.Id;
                oppTeamMember.UserId = opp.Accountable_Banker__c;
                oppTeamMember.TeamMemberRole = TEAM_ROLE_BANKER;
                oppTeamMember.I_confirm_team_member_has_been_cleared__c = opp.The_accountable_banker_has_been_cleared__c;
                //This field is set in order to fire workflow
                oppTeamMember.Accountable_Banker__c = true;
                
                oppTeamMembersToIns.add(oppTeamMember);
                
                if(mapOpportunityToTeamMember.containsKey(oppTeamMember.OpportunityId)){
                    mapOpportunityToTeamMember.get(oppTeamMember.OpportunityId).add(oppTeamMember.UserId);
                } else{
                    mapOpportunityToTeamMember.put(oppTeamMember.OpportunityId, new Set<Id>{oppTeamMember.UserId});
                }
            }
            
        }			
        
        //Insert Opportunity Team Members
        Database.SaveResult[] results = Database.insert(oppTeamMembersToIns,false) ;
        
        Boolean foundError=false;
        String errorMessage = '';
        for(Database.SaveResult r : results)
        {
            if(!r.isSuccess())
            {
                foundError = true;
                for(Database.Error err : r.getErrors())
                {
                    errorMessage  = err.getMessage();   
                }
            }
        }
        
        if(foundError)
        {
            for(Opportunity opp : listOfOpp)
                opp.addError(errorMessage);
        }
        
        if (mapOpportunityToTeamMember.size() > 0) {
            List<OpportunityShare> oppShareToUpd = new List<OpportunityShare>();
            for(OpportunityShare oppShare : [SELECT Id, OpportunityAccessLevel, OpportunityId, UserOrGroupId 
                                             FROM OpportunityShare 
                                             WHERE OpportunityId IN :mapOpportunityToTeamMember.keySet() AND RowCause = 'Team']){
                                                 if(mapOpportunityToTeamMember.get(oppShare.OpportunityId).contains(oppShare.UserOrGroupId)){
                                                     oppShare.OpportunityAccessLevel = 'Edit';
                                                     oppShareToUpd.add(oppShare);
                                                 }
                                             }
            //Update Opportunity Access Level
            update oppShareToUpd;
        }
        
    }   
    
    /**
* @description Adds accountable banker to opportunity team members for provided list of opportunities 
* @param List<Opportunity> listOfOpp
*/
    static public void replaceAccountableBankerForOppTeam(Map<Id, Opportunity> oldOpp, Map<Id, Opportunity> newOpp){
        //Create map of Accountable Bankers that should be deleted from Opportunity Team Members
        Map<Id, Id> mapOppToOldAccountableBanker = new Map<Id, Id>();
        //Create list of Accountable Bankers that should be added to Opportunity Team Members
        List<Opportunity> oppListOfNewAccountableBankers = new List<Opportunity>();
        
        for(Id oppId : newOpp.keySet()){
            if(newOpp.get(oppId).Accountable_Banker__c != oldOpp.get(oppId).Accountable_Banker__c){
                oppListOfNewAccountableBankers.add(newOpp.get(oppId));
                mapOppToOldAccountableBanker.put(oppId, oldOpp.get(oppId).Accountable_Banker__c);
            }
        }
        
        //Insert new Opportunity Team Members
        addAccountableBankerToOppTeam(oppListOfNewAccountableBankers);
        
        if (mapOppToOldAccountableBanker.size() > 0) {
            List<OpportunityTeamMember> oppTeamMembersToDel = new List<OpportunityTeamMember>();
            for(OpportunityTeamMember oppTeamMember : [SELECT Id, UserId, OpportunityId FROM OpportunityTeamMember 
                                                       WHERE OpportunityId IN :mapOppToOldAccountableBanker.keySet()
                                                       AND TeamMemberRole = :TEAM_ROLE_BANKER]){
                                                           if(oppTeamMember.UserId == mapOppToOldAccountableBanker.get(oppTeamMember.OpportunityId)){
                                                               oppTeamMembersToDel.add(oppTeamMember);
                                                           }
                                                       }
            
            //Delete old Opportunity Team Members
            delete oppTeamMembersToDel; 
        }
    }
    
    /**
* @description Updates the 'income this year' for provided opportunities
* @param Map<Id, Opportunity> oldOpp
* @param Map<Id, Opportunity> newOpp
*/
    static public void updateIncomeThisYear(Map<Id, Opportunity> oldOpp, Map<Id, Opportunity> newOpp){
        List<Id> oppIds = new List<Id>();
        for(Id oppId : newOpp.keySet()){
            if(newOpp.get(oppId).CloseDate != oldOpp.get(oppId).CloseDate){
                oppIds.add(oppId);
            }
        }
        if (oppIds.Size() == 0) return;
        
        Date endOfYear;
        Integer daysFromCloseDateToEndOfYear;
        Integer monthsFromCloseDateToEndOfYear;
        List<OpportunityLineItem> oppLineItemsToUpd = new List<OpportunityLineItem>();
        for(OpportunityLineItem oppLineItem : [SELECT Id, Income_this_Year__c, Annualised_Income__c, Balance__c, Margin__c, Estimated_Utilisation__c,
                                               Recurring_Fees_Period__c, Recurring_Fees__c, Fees__c, Opportunity.CloseDate 
                                               FROM OpportunityLineItem WHERE OpportunityId IN :oppIds]){
                                                   OpportunityLineItem oppLineItemToUpd = new OpportunityLineItem(Id=oppLineItem.Id);
                                                   endOfYear = Date.newInstance(oppLineItem.Opportunity.CloseDate.year(), 12, 31);
                                                   daysFromCloseDateToEndOfYear = oppLineItem.Opportunity.CloseDate.daysBetween(endOfYear);
                                                   monthsFromCloseDateToEndOfYear = oppLineItem.Opportunity.CloseDate.monthsBetween(endOfYear);
                                                   Decimal nii = 0;
                                                   if(oppLineItem.Balance__c != null && oppLineItem.Margin__c != null && oppLineItem.Estimated_Utilisation__c != null){
                                                       nii = oppLineItem.Balance__c * oppLineItem.Margin__c / 100 * oppLineItem.Estimated_Utilisation__c / 100;
                                                   }
                                                   Decimal firstYearFees = 0;
                                                   if(oppLineItem.Recurring_Fees__c != null){
                                                       if(oppLineItem.Recurring_Fees_Period__c == 'Monthly'){
                                                           firstYearFees = oppLineItem.Recurring_Fees__c * monthsFromCloseDateToEndOfYear;
                                                       } else if(oppLineItem.Recurring_Fees_Period__c == 'Quarterly'){
                                                           firstYearFees = oppLineItem.Recurring_Fees__c * monthsFromCloseDateToEndOfYear / 3;
                                                       } else if(oppLineItem.Recurring_Fees_Period__c == 'Semi-Annually'){
                                                           firstYearFees = oppLineItem.Recurring_Fees__c * monthsFromCloseDateToEndOfYear / 6;
                                                       } 
                                                   }
                                                   Decimal upfrontFees = 0;
                                                   if(oppLineItem.Fees__c != null) {
                                                       upfrontFees = oppLineItem.Fees__c;    
                                                   }
                                                   Decimal incomeThisYear = nii * daysFromCloseDateToEndOfYear / 365 + firstYearFees + upfrontFees;
                                                   oppLineItemToUpd.Income_this_Year__c = incomeThisYear.setScale(0);
                                                   oppLineItemsToUpd.add(oppLineItemToUpd);
                                               }
        update oppLineItemsToUpd;
    }
    
    /**
* @description Sets checkbox 'private' to true for provided list of opportunities
* @param List<Opportunity> listOfOpp
*/
    static public void setPrivateCheckboxes(List<Opportunity> listOfOpp)
    {
        for(Opportunity opp : listOfOpp)
        {
            String oppRecordTypeId = getOpportunityRT(OpportunityRT.PrivateOpp);
            if(oppRecordTypeId == opp.RecordTypeId)
            {
                // opp.isPrivate = TRUE;
                opp.Private_Side__c = TRUE;
            }
        }
    }
    
    /**
* @description Gets opportunity record type id for provided opportunity
* @param OpportunityRT oppRT
* @return String opportunity record type id
*/
    static public String getOpportunityRT(OpportunityRT oppRT)
    {
        if(oppRT == OpportunityRT.PrivateOpp)
            return Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Private opportunity').getRecordTypeId();
        if(oppRT == OpportunityRT.PublicOpp)
            return Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Public opportunity').getRecordTypeId();
        
        return null;
    }
    
    /**
* @description Creates opportunity split for every triggered opportunity
* @param List<Opportunity> opps - list of triggered opportunities
*/
    static public void createDefaultOpportunitySplit(List<Opportunity> opps) {
        //creating list of Ids of triggered opportunities' accounts
        List<Id> accIds = new List<Id>();
        for (Opportunity opp: opps) {
            accIds.add(opp.AccountId);
        }
        
        //creating map of accounts because of split country
        List<Account> accounts = [SELECT Id, Client_Country__c From Account WHERE Id IN :accIds];
        Map<Id, Account> accountsMap = new Map<Id, Account>(accounts);
        
        //iterating over triggered opportunities and creating split for every opp
        List<Opportunity_Split__c> splits = new List<Opportunity_Split__c>();
        for (Opportunity opp: opps) {
            Opportunity_Split__c split = new Opportunity_Split__c();
            split.Percentage__c = 100;
            split.Country__c = accountsMap.get(opp.AccountId).Client_Country__c;
            split.Opportunity__c = opp.Id;
            splits.add(split);
        }
        insert splits;
    }
    
    /**
* @description Updates JLOC Sharing for provided opportunities
* @param Map<Id, Opportunity> oldOpp
* @param Map<Id, Opportunity> newOpp
*/
    static public void shareOpportunityTeamMembersWithJLOC(Map<Id, Opportunity> oldOpp, Map<Id, Opportunity> newOpp){
        Set<Id> oppIds = new Set<Id>();
        Set<Id> jlocIds = new Set<Id>();
        for(Id oppId : newOpp.keySet()){
            if(newOpp.get(oppId).JLOC__c != oldOpp.get(oppId).JLOC__c){
                if(newOpp.get(oppId).JLOC__c != null){
                    oppIds.add(oppId);
                }
                if(oldOpp.get(oppId).JLOC__c != null){
                    jlocIds.add(oldOpp.get(oppId).JLOC__c);
                }
            }
        }
        if(oppIds.size() > 0){
            List<OpportunityTeamMember> oppTeamMembersToShare = [SELECT Id, Opportunity.JLOC__c, UserId FROM OpportunityTeamMember WHERE OpportunityId IN :oppIds];
            JlocTrigger_Helper.shareJlocsWithOpportunityTeamMembers(oppTeamMembersToShare);
        }
        if(jlocIds.size() > 0){
            JlocTrigger_Helper.recalculateJlocSharingWithOpportunityTeamMembers(jlocIds);
        }
    }
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-501 - Update private side sharing model for Barclays Private Side User
* @param            List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOld
* @Returns:         void
* History
* <Date>      <Authors Name>    <Brief Description of Change>
* 2016-12-06  Dino Scarcella	Changed the method to cover create & update of opportunity 
*------------------------------------------------------------*/
    
    public static void modifyOpportunityForPrivateSideUser(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOld) {
        Boolean RunTrigger = false;
        for(Opportunity o : triggerNew) {
            if (!modifyOpportunityForPrivateSideUser.contains(o.Id)) { 
                modifyOpportunityForPrivateSideUser.add(o.id);
                RunTrigger = true;
            }
        }
        if (RunTrigger == false) return;
        
        List<Opportunity> openOppsToUpdate = new List<Opportunity>();
        List<Opportunity> closedOppsToUpdate = new List<Opportunity>();
        String PrivateSideClientName;String ClosedWon;String ClosedLost;
        for(Private_Side_Opportunity_Setting__mdt psos : [SELECT DeveloperName, MasterLabel FROM Private_Side_Opportunity_Setting__mdt WHERE DeveloperName IN('Private_Side_Client','Closed_Won','Closed_Lost')]){
            if (psos.DeveloperName == 'Private_Side_Client') PrivateSideClientName = psos.MasterLabel;
            if (psos.DeveloperName == 'Closed_Won') ClosedWon = psos.MasterLabel;
            if (psos.DeveloperName == 'Closed_Lost') ClosedLost = psos.MasterLabel;
        }
        if (PrivateSideClientName != null && PrivateSideClientName != '') {
            if (PrivateSideClient == NULL) {
                if (!PrivateSideClientSearched) {
                    try {
                        PrivateSideClientSearched = true;
                        
                        PrivateSideClient = [SELECT Id FROM Account WHERE Name =: PrivateSideClientName ORDER BY CreatedDate LIMIT 1];
                    } catch(Exception e) {
                        PrivateSideClientSearched = true;
                        return; // If we can't get the Generic Private Side Client then exit the method
                    }
                } else {
                    return;
                }
            }
            for(Opportunity opp : [SELECT Id, AccountId, RecordTypeId, Related_Group_Client__c, StageName, Account_Name__c, Original_Related_Group_Client__c, Original_Related_Group_Client__r.ParentId, PrivateSideClassification__c FROM Opportunity WHERE Id =: triggerNew]) {
                if (PrivateSideClient.Id != null) {
                    if(opp.RecordTypeId == getOpportunityRT(OpportunityRT.PrivateOpp)
                       && opp.StageName != ClosedWon
                       && opp.StageName != ClosedLost
                       && (triggerOld == null || 
                           (triggerOld.get(opp.Id) != null && 
                            (triggerOld.get(opp.Id).StageName == ClosedWon || triggerOld.get(opp.Id).StageName == ClosedLost)
                           )
                           
                           
                          )
                       // If PrivateSideClassification is null (meaning its legacy data) or PrivateSideClassification is 'Team head is conflicted'
                       && (opp.PrivateSideClassification__c == null || (opp.PrivateSideClassification__c != null && opp.PrivateSideClassification__c == 'Team head is conflicted'))
                      ) 
                    {
                        Opportunity oppupdate = new Opportunity(Id = opp.Id);
                        oppupdate.Account_Name__c = opp.AccountId;
                        oppupdate.Original_Related_Group_Client__c = opp.Related_Group_Client__c;
                        oppupdate.AccountId = PrivateSideClient.Id;
                        oppupdate.Related_Group_Client__c = null;
                        openOppsToUpdate.add(oppupdate);
                    } else if(opp.RecordTypeId == getOpportunityRT(OpportunityRT.PrivateOpp)
                              && opp.AccountId == PrivateSideClient.Id
                              && triggerOld != null
                              && triggerOld.get(opp.Id) != null
                              && triggerOld.get(opp.Id).StageName != ClosedWon
                              && triggerOld.get(opp.Id).StageName != ClosedLost
                              && (
                                  // If PrivateSideClassification is null (meaning its legacy data) or PrivateSideClassification is 'Team head is conflicted'
                                  ((opp.StageName == ClosedWon || opp.StageName == ClosedLost) && (opp.PrivateSideClassification__c == null || (opp.PrivateSideClassification__c != null && opp.PrivateSideClassification__c == 'Team head is conflicted')))
                                  ||
                                  // If PrivateSideClassification was null and we changed this field to 'Team head is not conflicted' item
                                  ((opp.StageName != ClosedWon && opp.StageName != ClosedLost) && triggerOld.get(opp.Id).PrivateSideClassification__c != opp.PrivateSideClassification__c && triggerOld.get(opp.Id).PrivateSideClassification__c == null && opp.PrivateSideClassification__c != null && opp.PrivateSideClassification__c == 'Team head is not conflicted')
                              )
                             )
                    {
                        // Update the generic "Private Side Client" to the original client
                        Opportunity oppupdate = new Opportunity(Id = opp.Id);
                        // If the lower level client is not populated just use the relationship group that was populated
                        if (opp.Original_Related_Group_Client__c == null) oppupdate.AccountId = opp.Account_Name__c;
                        // If the lower level client is populated use the current relationship group of that client
                        else oppupdate.AccountId = opp.Original_Related_Group_Client__r.ParentId;
                        oppupdate.Related_Group_Client__c = opp.Original_Related_Group_Client__c;
                        oppupdate.Account_Lock__c = false;
                        if (oppupdate.AccountId != null) closedOppsToUpdate.add(oppupdate);
                    }
                }
            }
            if (openOppsToUpdate.size() > 0) {
                try {
                    update openOppsToUpdate;
                    //make sure the Account Lock attribute is set
                    Integer i = 0;
                    for(Opportunity oppToUpdate : openOppsToUpdate) {
                        openOppsToUpdate[i].Account_Lock__c = true;
                        i++;
                    }
                    update openOppsToUpdate;
                } catch(Exception e) {
                    System.debug('We were not able to update Opportunity:' + e);
                }
            }
            if (closedOppsToUpdate.size() > 0) {
                try {
                    update closedOppsToUpdate; 
                } catch(Exception e) {
                    System.debug('We were not able to update Opportunity:' + e);
                }
            }
        }
    }  
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-547 - Update Segment on Opportunity in order for sharing rules to work
*					CIBDIGSALP-2403 - Sharing rule & Trigger Update - Agri 
* @param            List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOld
* @Returns:         void
* History
* <Date>      <Authors Name>    <Brief Description of Change> 
*------------------------------------------------------------*/
    
    public static void updateOpportunitySegmentAndIndustry(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOld) {
        Boolean RunTrigger = false;
        Set<Id> accids = new Set<Id>();
        for(Opportunity o : triggerNew) {
            if (
                triggerOld == null || 
                triggerOld.get(o.Id).AccountId != o.AccountId ||
                o.Segment__c == 'FireOpportunityUpdate' ||
                o.Industry__c == 'FireOpportunityUpdate'
            )
            {
                accids.add(o.AccountId);
                RunTrigger = true;
            }
        }
        if (RunTrigger == false) return;
        
        Map<Id, Account> accmapdetail = new  Map<Id, Account>([Select Id, OwnerId, Owner.UserRoleId, Owner.UserRole.Name, Segment__c, Industry FROM Account WHERE Id =: accids]);
        // Go through the opportunities updated
        for(Opportunity opp : triggerNew) {
            // Only check new opportunity/updated opportunity fields if account, segment or industry is changed
            if (
                triggerOld == null || 
                triggerOld.get(opp.Id).AccountId != opp.AccountId ||
                opp.Segment__c == 'FireOpportunityUpdate' ||
                opp.Industry__c == 'FireOpportunityUpdate'
            )
            {	
                //Update Segment
                if (opp.AccountId != null && accmapdetail.get(opp.AccountId).Segment__c != null && accmapdetail.get(opp.AccountId).Segment__c.Contains('Public Sector')) opp.Segment__c = 'Public Sector';
                else if (opp.AccountId != null && accmapdetail.get(opp.AccountId).Segment__c != null && accmapdetail.get(opp.AccountId).Segment__c.Contains('Global Corporate')) opp.Segment__c = 'Global Corporate';
                else if (opp.AccountId != null && accmapdetail.get(opp.AccountId).Segment__c != null && accmapdetail.get(opp.AccountId).Segment__c.Contains('Financial Institution')) opp.Segment__c = 'Financial Institution';
                else if (opp.AccountId != null && accmapdetail.get(opp.AccountId).Segment__c != null && accmapdetail.get(opp.AccountId).Segment__c.Contains('Global Development Organisation')) opp.Segment__c = 'Global Development Organisation';
                else if (opp.AccountId != null && accmapdetail.get(opp.AccountId).OwnerId != null && accmapdetail.get(opp.AccountId).Owner.UserRoleId != null && accmapdetail.get(opp.AccountId).Owner.UserRole.Name.Contains('Coverage - PS')) opp.Segment__c = 'Public Sector';
                else if (opp.AccountId != null && accmapdetail.get(opp.AccountId).OwnerId != null && accmapdetail.get(opp.AccountId).Owner.UserRoleId != null && accmapdetail.get(opp.AccountId).Owner.UserRole.Name.Contains('Global Corporates')) opp.Segment__c = 'Global Corporate';
                else opp.Segment__c = 'NULL';
                //Update Industry
                if (opp.AccountId != null && accmapdetail.get(opp.AccountId).Industry != null) opp.Industry__c = accmapdetail.get(opp.AccountId).Industry;
                else opp.Industry__c = 'NULL';
                //Update Relationship Owner Role Name if the account has changed
                if ((triggerOld == null || triggerOld.get(opp.Id).AccountId != opp.AccountId) && opp.AccountId != null && accmapdetail.get(opp.AccountId).OwnerId != null && accmapdetail.get(opp.AccountId).Owner.UserRoleId != null) 
                    opp.RelationshipOwnerRoleName__c = accmapdetail.get(opp.AccountId).Owner.UserRole.Name;
            }
        }
    }
    
    /**
* @Author:          Sizwe Tshabalala
* @Company:         Absa Capital
* @Description:     SFAFRICA-622 - Check that Opportunity name is not duplicated
* @Returns:         void
* History
* <Date>      <Authors Name>    <Brief Description of Change> 
*------------------------------------------------------------*/
    public static void checkOpportunityName(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOld)
    {
        // Get all the private opportunity names
        Set<String> oppnames = new Set<String>();
        for(Opportunity o : triggerNew) {
            if (o.RecordTypeId == getOpportunityRT(OpportunityRT.PrivateOpp)) oppnames.add(o.Name);
        }
        // Retrieve a set of names of private opportunities and their counts up front
        List<AggregateResult> namecountslist = [SELECT Name, COUNT(Id) CountOpp 
                                                FROM Opportunity
                                                WHERE RecordTypeId =: getOpportunityRT(OpportunityRT.PrivateOpp)
                                                AND Name =: oppnames
                                                GROUP BY Name];
        Map<String, Integer> namecountsmap = new Map<String, Integer>();
        for(AggregateResult namecount : namecountslist) namecountsmap.put(((String)namecount.get('Name')).toLowerCase(), (Integer)namecount.get('CountOpp'));
        
        for(Opportunity opp : triggerNew)
        {
            // only do duplicate check error if the name has changed on opportunity or if we've added an opportunity 
            // (triggerOld == null) or the recordtype has changed and the opportunity being updated/inserted is private
            if (
                (
                    triggerOld == null || 
                    triggerOld.get(opp.Id).Name.toLowerCase() != opp.Name.toLowerCase() ||
                    triggerOld.get(opp.Id).RecordTypeId != opp.RecordTypeId
                )
                && opp.RecordTypeId == getOpportunityRT(OpportunityRT.PrivateOpp)
            )
            {
                if (opp.Name != null && namecountsmap.containsKey(opp.Name.toLowerCase())) 
                    opp.addError('Private opportunity name is already in use. Please use a unique opportunity name');
            }
        }
    }
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-748 - Pipeline Management Process Phase 2 - method to force Product Level 3 on In Implementation Opportunities
* @Returns:         void
* History
* <Date>      <Authors Name>    <Brief Description of Change> 
*------------------------------------------------------------*/
    public static void CheckProductLevel3(Map<Id, Opportunity> triggerNew, Map<Id, Opportunity> triggerOld) {
        Boolean RunTrigger = false;
        Set<Id> oppids = new Set<Id>();
        for(Opportunity opp : triggerNew.values()) {
            oppids.add(opp.Id);
            // Only run if the Stage Name changed 
            if (triggerOld.get(opp.Id).StageName != triggerNew.get(opp.Id).StageName
                && 
                (triggerNew.get(opp.Id).StageName == 'In Implementation / Conditions Precedent' || triggerNew.get(opp.Id).StageName == 'Closed Won')
               )
            {
                RunTrigger = true;
            }
        }
        if (!RunTrigger) return;
        
        // Retrieve the count of level 3 products on an opportunity
        List<AggregateResult> countlevel3 = [SELECT OpportunityId, SUM(ProductLevel3Count__c) CountOppLineItem 
                                             FROM OpportunityLineItem
                                             WHERE OpportunityId in:oppids
                                             GROUP BY OpportunityId];
        for(AggregateResult countlvl3 : countlevel3) {
            Id oppid = (Id)countlvl3.get('OpportunityId');
            triggerNew.get(oppid).ProductLevel3Count__c = (Decimal)countlvl3.get('CountOppLineItem');
        }
    }
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-733 - Pipeline Management Process - method to promote Product Partner on Approval of Product Partner Approval Process
* @Returns:         void
* History
* <Date>      <Authors Name>    <Brief Description of Change> 
*------------------------------------------------------------*/
    public static void PromoteProductPartner(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOld)
    {   
        Boolean RunTrigger = false;
        for(Opportunity opp : triggerNew)
        {
            // If the Product Partner Approval Status has changed
            if (triggerOld.get(opp.Id).ProductPartnerApprovalStatus__c != opp.ProductPartnerApprovalStatus__c
                && opp.ProductPartnerApprovalStatus__c == 'Approved'
                && opp.ProductPartner__c != NULL
                && opp.ProductPartner__c != opp.OwnerId)
            {
                RunTrigger = true;
            }
        }
        if (!RunTrigger) return;
        
        Map<Id, Set<Id>> oppteammembermap = new Map<Id,  Set<Id>>();  	
        //get list of all Opportunity Team Members in the opportunities in question
        List<OpportunityTeamMember> oppteammembers = [SELECT UserId, OpportunityId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId IN :triggerNew];
        List<OpportunityTeamMember> oppTeamMembersToDelete = new List<OpportunityTeamMember>();
        
        for(Opportunity opp : triggerNew)
        {
            // If the Product Partner Approval Status has changed
            if (triggerOld.get(opp.Id).ProductPartnerApprovalStatus__c != opp.ProductPartnerApprovalStatus__c
                && opp.ProductPartnerApprovalStatus__c == 'Approved'
                && opp.ProductPartner__c != NULL
                && opp.ProductPartner__c != opp.OwnerId)
            {
                
                // Update the Owner to the latest Product Partner
                opp.OwnerId = opp.ProductPartner__c;
                // Get rid of previous Product Partner Approvers that existed
                for (OpportunityTeamMember existingOppTeamMember : oppteammembers) {
                    if (existingOppTeamMember.OpportunityId == opp.Id 
                        && existingOppTeamMember.TeamMemberRole == 'Product Partner Approver'
                        && existingOppTeamMember.UserId != opp.ProductPartner__c) {
                            oppTeamMembersToDelete.add(existingOppTeamMember);
                        }
                }
            }
        }
        
        try {
            if (oppTeamMembersToDelete.Size() > 0) delete oppTeamMembersToDelete;
        } catch (Exception e) {
            System.debug('Exception deleting previous Product Partner Approvers:' + e.getMessage());
        } 
    }
    
    public static void AddNewOpportunityShare(Map<Id,Opportunity> opportunityMap)
    {
        Set<ID> AccountIDSet = new Set<ID>();
        List<OpportunityShare> oppShareList = new List<OpportunityShare>();
        
        //Tonga MM : get All account Ids.
        for(Opportunity opp : opportunityMap.values())
        {
            AccountIDSet.add(opp.AccountID);
        }
        //Tonga MM : get Owner of Global Parent ti be shared with 
        Map<ID,Account> AccountMap = new Map<ID,Account>([Select recordTypeID, ID,Parent.OwnerID,OwnerID from Account where ID IN :AccountIDSet]);
        
        for(ID OpportunityID : opportunityMap.keySet())
        {
            Opportunity currentOpportunity = opportunityMap.get(OpportunityID);
            Account currentAccount = AccountMap.get(currentOpportunity.AccountID);
            
            if(currentAccount.recordTypeID==Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group').getRecordTypeId())
                if(currentOpportunity.RecordTypeId!=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Private opportunity').getRecordTypeId())
            {
                if(currentOpportunity.OwnerID!=currentAccount.OwnerID && currentOpportunity.OwnerID !=currentAccount.Parent.OwnerID)
                {
                    oppShareList.add(AccountTrigger_Helper.addOpportunityShare(currentOpportunity,currentAccount.Parent.OwnerID));
                }
            }
        }
        
        if(oppShareList.size()>0)
        {
            database.insert(oppShareList,false) ;
        }
    }
    
    public static void updateOpportunityShare(Map<ID,Opportunity> newOppTriggerMap,Map<Id,Opportunity> oldOppTriggerMap)
    {
        Map<ID,Opportunity> newOpportunityMap = new Map<ID,Opportunity>(); 
        Map<ID,Opportunity> oldOpportunityMap = new Map<ID,Opportunity>(); 
        for(Opportunity currentOpportunity : newOppTriggerMap.values())
        {
            //Tonga MM : Check is the opportunity accountID has changed
            if(currentOpportunity.RecordTypeId!=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Private opportunity').getRecordTypeId())
            {
                if(currentOpportunity.AccountId !=oldOppTriggerMap.get(currentOpportunity.ID).AccountId)
                {
                    newOpportunityMap.put(currentOpportunity.ID,currentOpportunity);
                    oldOpportunityMap.put(currentOpportunity.ID,oldOppTriggerMap.get(currentOpportunity.ID));
                }
            }           
        }
        
        //Tonga MM : if AccountID has changed on Opportunity, send records to methof to recalculate new sharing entries
        if(newOpportunityMap.size()>0)
        { 
            recalculateSharing(newOpportunityMap,oldOpportunityMap);
        }
    }
    
    //Tonga MM : Re-shuffle manual sharing entries
    private static void recalculateSharing(Map<ID,Opportunity> newOpportunityMap,Map<Id,Opportunity> oldOpportunityMap)
    {
        List<OpportunityShare> oppSharetoInsert = new List<OpportunityShare>();
        
        //Tonga MM : Sets for old values
        Set<ID> oldOwnerID = new Set<ID>();
        Set<ID> OldAccountID = new Set<ID>();
        
        //Tonga MM : Sets for new Values
        Set<ID> newAccountID = new Set<ID>();
        for(Opportunity oldOpp :[Select id,AccountID,account.ParentID,account.Parent.OwnerID from Opportunity where Id IN : newOpportunityMap.values()])
        {
            OldAccountID.add(oldOpp.accountID);
            oldOwnerID.add(oldOpp.Account.Parent.OwnerID);
        }
        for(Opportunity opp :newOpportunityMap.values())
        {
            newAccountID.add(opp.AccountID);
        }
        
        Map<ID,Account> newAccountOwnerList = new Map<ID,Account>([select id,Parent.ownerID,OwnerId from Account where ID IN:newAccountID]);
        
        List<OpportunityShare> opportunityShare = [Select ID 
                                                   from OpportunityShare 
                                                   where OpportunityID IN: oldOpportunityMap.keySet()
                                                   AND UserOrGroupID IN: oldOwnerID
                                                   AND rowCause='Manual'];
        
        //Tonga : MM Add new opportunity share required for Global parent
        
        for(Opportunity currentOpportunity :newOpportunityMap.values())
        {
            Account currentAccount = newAccountOwnerList.get(currentOpportunity.AccountID);
            if(currentOpportunity.OwnerID!=currentAccount.OwnerID && currentOpportunity.OwnerID !=currentAccount.Parent.OwnerID)
            {
                oppSharetoInsert.add(AccountTrigger_Helper.addOpportunityShare(currentOpportunity,currentAccount.Parent.OwnerID));
            }
        }
        
        if(opportunityShare.size()>0)
        {
            delete opportunityShare;
        }
        
        if(oppSharetoInsert.size()>0)
        {
            Database.insert(oppSharetoInsert,false);
        }
    }
    
    
    //Dino Scarcella: Method to mark a Project Name as used should it be in Project names Object and Unused
    public static void flagProjectNameAsUsed(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOld)
    {
        Set<String> projectNames = new Set<String>();
        // Get the names of opportunities we have inserted
        for(Opportunity opp : triggerNew)
        {
            if ((triggerOld == null || triggerOld.get(opp.Id).Name.toLowerCase() != opp.Name.toLowerCase()) 
                && opp.Name.length() > 8
                && opp.Name.substring(0,8).toLowerCase() == 'project '
                && opp.RecordTypeId == getOpportunityRT(OpportunityRT.PrivateOpp))
                projectNames.add(opp.Name.substring(8,opp.Name.length()));
        }
        
        List<ProjectName__c> projectNamesToUpdate = new List<ProjectName__c>();
        if (projectNames.size()> 0) {
            // Check if the Project Name is marked as not used in our list of potential project names and flag it as used
            for(ProjectName__c projectName : [SELECT Id, Name FROM ProjectName__c WHERE Used__c = false AND Name =: projectNames]) {
                projectNamesToUpdate.add(new ProjectName__c(Id = projectName.Id, Used__c = true));
            }
        }
        
        try {
            if (projectNamesToUpdate.size() > 0) update projectNamesToUpdate;
        } catch(Exception e) {
            System.debug('We were not able to update Project Names:' + e);
        }
    }
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     Warns a user that they haven't added an attachment if they have significant pitch set (supports lightning and classic)
* @Returns:         void
* History
* <Date>      <Authors Name>    <Brief Description of Change> 
*------------------------------------------------------------*/
    public static void AttachmentCheckSignificantPitch(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOld)
    {
        Set<Id> oppids = new Set<Id>();
        Boolean RunTrigger = false;
        for(Opportunity opp : triggerNew)
        {
            // If the Significant Pitch is set and none of fields related to when you 
            // add a product are changed (this avoids validation when adding a product)
            if (opp.Significant_Pitch__c == true
                && triggerOld != NULL
                && triggerOld.containsKey(opp.Id)
                && triggerOld.get(opp.Id).ProductList__c == opp.ProductList__c
                && triggerOld.get(opp.Id).ProductLevel2List__c == opp.ProductLevel2List__c
                && triggerOld.get(opp.Id).ProductLevel3List__c == opp.ProductLevel3List__c
                && triggerOld.get(opp.Id).ProductLevel3__c == opp.ProductLevel3__c
                && triggerOld.get(opp.Id).ProductPartner__c == opp.ProductPartner__c
                && triggerOld.get(opp.Id).ProductPartnerApprovalStatus__c == opp.ProductPartnerApprovalStatus__c
                && triggerOld.get(opp.Id).Amount == opp.Amount
                && triggerOld.get(opp.Id).ExpectedRevenue == opp.ExpectedRevenue
                && triggerOld.get(opp.Id).TotalOpportunityQuantity == opp.TotalOpportunityQuantity
                && triggerOld.get(opp.Id).HasOpportunityLineItem == opp.HasOpportunityLineItem
                && triggerOld.get(opp.Id).Weighted_Annualised_Income__c == opp.Weighted_Annualised_Income__c
                && triggerOld.get(opp.Id).Weighted_Income_this_Year__c == opp.Weighted_Income_this_Year__c
                && triggerOld.get(opp.Id).Annualised_Income__c == opp.Annualised_Income__c
                && triggerOld.get(opp.Id).Income_this_Year__c == opp.Income_this_Year__c
                && triggerOld.get(opp.Id).Total_Balance_Facility_Size__c == opp.Total_Balance_Facility_Size__c
                && triggerOld.get(opp.Id).Opportunity_Deal_Value__c == opp.Opportunity_Deal_Value__c
                && triggerOld.get(opp.Id).Weighted_Balance_Facility_Size__c == opp.Weighted_Balance_Facility_Size__c
                && triggerOld.get(opp.Id).Product_Family__c == opp.Product_Family__c
               )
            {
                oppIds.add(opp.Id);
                RunTrigger = true;
            }
        }
        if (!RunTrigger) return;
        
        //Classic
        List<AggregateResult> attachments = [SELECT ParentId, Count(Id) ATTCOUNTER
                                             FROM Attachment
                                             WHERE ParentId =: oppIds
                                             GROUP BY ParentId];
        //Lightning
        List<AggregateResult> files = [SELECT LinkedEntityId, Count(Id) FILECOUNTER
                                       FROM ContentDocumentLink
                                       WHERE LinkedEntityId =: oppIds
                                       GROUP BY LinkedEntityId];
        
        Map<Id, Integer> oppsattfilescountsmap = new Map<Id, Integer>();
        for(AggregateResult att : attachments) {
            if (!oppsattfilescountsmap.containsKey((Id)att.get('ParentId'))) oppsattfilescountsmap.put(((Id)att.get('ParentId')), (Integer)att.get('ATTCOUNTER'));
        }
        for(AggregateResult file : files) {
            if (!oppsattfilescountsmap.containsKey((Id)file.get('LinkedEntityId'))) oppsattfilescountsmap.put(((Id)file.get('LinkedEntityId')), (Integer)file.get('FILECOUNTER'));
        }
        
        for(Opportunity opp : triggerNew)
        {
            if (!oppsattfilescountsmap.containsKey(opp.Id) && opp.Call_Report__c == NULL)
                opp.addError(Label.errMsg_SignificantPitchValidation);	
        }
    }
}