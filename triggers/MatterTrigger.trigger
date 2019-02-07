/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 @author Peter Guest
 
*** CHANGE LOG ***
    
    PG - 23/04/2017 - Add GBP Conversion, Formatted existing code a bit better.
    PG - 13/06/2017 - Added logic to initialise first "Borrower" on deal.  Removed contact email logic.
    PG - 20/06/2017 - Added logic to initialise first "Conditions Monitored By" on deal. 
    TdB- 18/09/2017 - Add MatterTrigger_Functions.calculateNextReviewDate - To calculate next review date based on frequency selected 
    PG - 11/10/2017 - Removed Currency conversion code.
    TdB- 01/11/2017 - Removed Next Review Date Overdue = True flag
	TdB- 17/05/2018 - Libra: Update Party B relationship is Market Transaction (Deal/Matter) Relationship changed
	TdB- 01/08/2018 - Remove todaysDate (not used). Move reviewMatterList and matterStatusList to before the loop
    TdB- 17/09/2018 - Remove BeforeUpdate ...no value, remove reduntant isBefore
						

**/
trigger MatterTrigger on advpm__Matter__c (before update, after update, after insert, before insert) 
{  
    System.debug(logginglevel.INFO, 'MatterTrigger : START');

    List<advpm__Matter__c> insertedMatters { get; set; }
    set<Id> matterIDs = new set<Id>();
    List<advpm__Matter__c> reviewMatterList = new List<advpm__Matter__c>();
    List<advpm__Matter__c> matterStatusList = new List<advpm__Matter__c>();
    
    //Blank variables.
    List<Deal_Party__c> dealParties = new List<Deal_Party__c>();
    Id dealRecordTypeId = CloudSmiths_Utils.getObjectRecordTypeId(advpm__Matter__c.SObjectType, 'Deal');
    id libraDealPartyRecordId = Schema.SObjectType.Deal_Party__c.getRecordTypeInfosByName().get('CNSG Deal Party').getRecordTypeId();
    id tmgDealPartyRecordId = Schema.SObjectType.Deal_Party__c.getRecordTypeInfosByName().get('TMG Deal Party').getRecordTypeId();
    List<Approval.ProcessSubmitRequest> processRequests = new List<Approval.ProcessSubmitRequest>();
    List<Approval__c> approvalRequests = new List<Approval__c>();  
    Id litigationId;
    
    Map<Id,advpm__Matter__c> masterTranscMap = new Map<Id,advpm__Matter__c>();
    List<Deal_Party__c> dealParty_PartyB = new List<Deal_Party__c>();
    List<Deal_Party__c> dealPartyUpdate = new List<Deal_Party__c>();
    
    //BEFORE CONTEXT
    if(Trigger.isBefore)
    {
        //INSERT OR AFTER CONTEXT
        if(Trigger.isInsert || Trigger.isUpdate)
        {        
            reviewMatterList = new List<advpm__Matter__c>();
            matterStatusList = new List<advpm__Matter__c>();
            //Loop through inserted.
            for(advpm__Matter__c iMatter : Trigger.new)
            {
                if(Trigger.isUpdate)
                {                   
                    advpm__Matter__c oldMatter = Trigger.oldmap.get(iMatter.Id);

                    if(iMatter.Approval_Status__c == 'Pending Approval' && iMatter.Probable_For_Approval__c != oldMatter.Probable_For_Approval__c)
                    {
                        iMatter.addError('Probable (For Approval) cannot be edited while approval is in progress');
                    }

                    if((Trigger.oldMap.get(iMatter.id).Current_Status__c != iMatter.Current_Status__c) || iMatter.hNext_Review_Date_Overdue__c == True && iMatter.recordTypeId != dealRecordTypeId)
                    {
                        matterStatusList.add(iMatter);
                        reviewMatterList.add(iMatter);
                    }
                    
                    if(iMatter.Relationship__c != null && oldMatter.Relationship__c != iMatter.Relationship__c)
                    {
                        masterTranscMap.put(iMatter.Id,iMatter);
                    }
                    
                    if(!masterTranscMap.isEmpty())
            		{
                        iMatter.Netting_Complete__c = false;
                    }
                }                
            }
            
            //TdB: Call method to insert next Matter Task based on "Current Status" field change
            if(Trigger.isUpdate)
            {
                if(MatterTrigger_Functions.firstRun)
                {
                    if(matterStatusList != null)
                    {
                        MatterTrigger_Functions.createNewMatterStatusTask(matterStatusList);
                    }
                    MatterTrigger_Functions.firstRun=false;
                }
            }
            
            //TdB: Call method to calculate next review date
            if(reviewMatterList != null)
            {
                MatterTrigger_Functions.calculateNextReviewDate(reviewMatterList);
            }  
                    
        }
        //INSERT OR UPDATE AFTER CONTEXT END
    }
    //BEFORE CONTEXT
    
        
    //AFTER CONTEXT
    if(Trigger.isAfter)
    {        
        if(litigationId == null)
            litigationId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Litigation_Matter' AND sObjectType = 'Approval__c'].Id;

        //AFTER INSERT
        if(Trigger.isInsert)
        {                 
            //Loop through inserted matters.
            for(advpm__Matter__c matter : Trigger.new)
            {
                if(matter.advpm__Primary_Account__c != null && matter.RecordTypeId == dealRecordTypeId)
                {
                    //Deal party object.
                    Deal_Party__c dealParty = new Deal_Party__c();
                    dealParty.Deal__c = matter.Id;
                    dealParty.Relationship__c = matter.advpm__Primary_Account__c;  
                    dealParty.Party_Type__c = 'Borrower';
                    dealParty.RecordTypeId = tmgDealPartyRecordId;
                    
                    //Add to list
                    dealParties.add(dealParty);
                }

                //See if matter needs to be approved
                if(matter.Probable_For_Approval__c > 0 && matter.Claim_By_Against_Barclays__c == 'Claim Against Barclays')
                {
                    Approval__c approvalRequest = new Approval__c(RecordTypeId = litigationId, Matter_Deal__c = matter.Id);                    
                    approvalRequests.add(approvalRequest);
                }
            }
            
            //Insert deal parties.
            insert dealParties;
            //Submit for approval
            insert approvalRequests;             
        }
        //AFTER INSERT END
        
        //UPDATE CONTEXT
        if(Trigger.isUpdate)
        {
            //Loop through matter in trigger.
            for (advpm__Matter__c m : (list<advpm__Matter__c>) trigger.new)
            {
                advpm__Matter__c oldMatter = trigger.oldmap.get(m.Id);
                //when Matter is updated and Status is 'In Appeal'.
                if (m.advpm__Status__c == 'In Appeal')
                {
                    matterIDs.add(m.Id);  
                }     

                //See if matter needs to be approved, create an approval record
                if(oldMatter.Probable_For_Approval__c != m.Probable_For_Approval__c &&  m.Probable_For_Approval__c > 0 && m.Claim_By_Against_Barclays__c == 'Claim Against Barclays')
                {
                    Approval__c approvalRequest = new Approval__c(RecordTypeId = litigationId, Matter_Deal__c = m.Id);                    
                    approvalRequests.add(approvalRequest);
                }     
                
                if(m.Relationship__c != null && oldMatter.Relationship__c != m.Relationship__c)
                {
                    //masterTranscIds.add(m.Id);
                    masterTranscMap.put(m.Id,m);
                }
            }
            
            insert approvalRequests;
            
            //Libra - Get Party B (Deal Party) and update Relationship if the Matter/Deal Relationship changed
			if(!masterTranscMap.isEmpty())
            {
                System.debug('masterTranscMap.keySet() : ' + masterTranscMap.keySet());
            	//Get all related Party B Deal Parties
            	for(Deal_Party__c eachDealParty : [SELECT Id, Deal__c, Relationship__c 
                                                   FROM Deal_Party__c
                                                  WHERE Deal__c IN : masterTranscMap.keySet()
                                                  AND Party_B__c = TRUE])
                {
                    Deal_Party__c tempParty = new Deal_Party__c();
                    tempParty.id = eachDealParty.id;
                    tempParty.Relationship__c = masterTranscMap.get(eachDealParty.Deal__c).Relationship__c;
                    tempParty.RecordTypeId = libraDealPartyRecordId;
                    dealPartyUpdate.add(tempParty);
                }
            }
            
            if(!dealPartyUpdate.isEmpty())
            {
                update dealPartyUpdate;
            }
                      
        }
        //UPDATE CONTEXT

        //Approvals can be requested either on update or insert
        if(!approvalRequests.isEmpty())
        {
            for(Approval__c approvalReq: approvalRequests)
            {
                Approval.ProcessSubmitRequest processRequest = new Approval.ProcessSubmitRequest();
                processRequest.setObjectId(approvalReq.Id);
                processRequests.add(processRequest);            
            }
            system.debug('*****'+processRequests);
            Approval.process(processRequests);
        }
    }
    //AFTER CONTEXT END    
    
    System.debug(logginglevel.INFO, 'MatterTrigger : END');    
}