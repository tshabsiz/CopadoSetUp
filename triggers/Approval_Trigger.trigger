/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 RN - 20171211 		- Create Risk cases for all approved legal matters 
 Tdb - 2018/01/17	- Add Agreement "'Review Completed" updates
 15/03/2018 - TdB	- Add Lender Portion approval process and validation for Drawdown Agency
 17/03/2018 - TdB	- Add Limit exceed approval process and validation for 	Drawdown Normal

**/ 
trigger Approval_Trigger on Approval__c (after update, after insert)
{
    System.debug('Approval trigger running .....');
    //Blank list.
	Map <String, Schema.RecordTypeInfo> approval_recordTypes = Approval__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    Map <String, Schema.RecordTypeInfo> DrawDown_recordTypes = Drawdown__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    List<Fit_To_Lend_Checklist__c> fitToLends = new List<Fit_To_Lend_Checklist__c>();
    List<Drawdown__c> drawdownAgencyUpdateList = new List<Drawdown__c>();
    List<Drawdown__c> drawdownNormalUpdateList = new List<Drawdown__c>();
    Set<Id> drawdownNormalIdSet = new Set<Id>();
    Set<Id> agreementIds = new Set<Id>();
    List<Agreement__c> agreementUpdateList = new List<Agreement__c>();
    Agreement__c agreementRecord = new Agreement__c();
    Drawdown__c drawdownRecord = new Drawdown__c();
    Set<Id> fitToLendIds = new Set<Id>();
    
    //After Update
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        
        System.debug('### Approval_Trigger : AFTER UPDATE : START');
        Id litigation = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Litigation_Matter' AND sObjectType = 'Approval__c'].Id;
        Set<Id> rejectedMatters = new Set<Id>();
        Set<Id> approvedMatters = new Set<Id>();
        System.debug('Loop through updated approvals');
        //Loop through updated records.
        for(Approval__c approval : Trigger.new)
        {
            //Previous record and its values.
            Approval__c oldApproval = Trigger.oldMap.get(approval.Id);
            
            //Has the status changed?
            //Lit to Lend Approval
            if(approval.Status__c <> oldApproval.Status__c && approval.Fit_To_Lend_Checklist__c != null && approval.recordTypeId == approval_recordTypes.get('Fit To Lend Approval').getRecordTypeId())
            {
                //Is the assocaited fitToLend id in the set?
                if(!fitToLendIds.contains(approval.Fit_To_Lend_Checklist__c))
                {
                    //Add to set.
                    fitToLendIds.add(approval.Fit_To_Lend_Checklist__c); 
                }
            }
			
            //Litigation Approval
            if(approval.Litigation_Matter_Approved__c != oldApproval.Litigation_Matter_Approved__c && approval.RecordTypeId == litigation )
               {
                if(approval.Litigation_Matter_Approved__c == 'Yes')
                {
                    approvedMatters.add(approval.Matter_Deal__c);
                }
                else if(approval.Litigation_Matter_Approved__c == 'No')
                {
                    rejectedMatters.add(approval.Matter_Deal__c);
                }
            }
            
            //Agreement Approval
            System.debug('DrawDown_recordTypes : ' + DrawDown_recordTypes);
            if (approval.Agreement__c != null && approval.Status__c != 'New' && approval.recordTypeId == approval_recordTypes.get('Agreement Approval').getRecordTypeId())
            {
                System.debug('in agreement if -  update');
                agreementRecord = new Agreement__c();
                agreementRecord.id = approval.Agreement__c;
                agreementRecord.Review_Status__c = 'Review Completed';
                agreementRecord.ReviewDate__c = System.today();   
                agreementUpdateList.add(agreementRecord);
            }
            
            //Drawdown Approval
            //Update related Drawdown Approval Status based on Approval Status changes
            if(approval.Drawdown__c != null && approval.recordTypeId == approval_recordTypes.get('Drawdown Approval').getRecordTypeId())
            {
                drawdownRecord = new Drawdown__c();
                drawdownRecord.id = approval.Drawdown__c;
                drawdownRecord.Approval_Status__c = approval.Status__c;
                drawdownAgencyUpdateList.add(drawdownRecord);
                drawdownNormalIdSet.add(drawdownRecord.Id);
            }
        }
        
        //If not empty.
        if(!fitToLendIds.isEmpty())
        {
            //Work out approval status on Fit To Lend levels.
            fitToLends = FitToLend_Helper.approvalStatuses(fitToLendIds);
            
            //Update records
            update fitToLends;
        }
        
         //Update drawdown
        if(!drawdownAgencyUpdateList.isEmpty())
        {
            update drawdownAgencyUpdateList;
        }
        //Normal Drawdown - Call approvalStatuses() method to create multiple approval records
        if(!drawdownNormalIdSet.isEmpty())
        {
            drawdownNormalUpdateList = Drawdown_Override.approvalStatuses(drawdownNormalIdSet);
            
            update drawdownNormalUpdateList;
        }

        if(!agreementUpdateList.isEmpty())
        {
            update agreementUpdateList;
        }

        if(!rejectedMatters.isEmpty() || !approvedMatters.isEmpty())
        {
            List<advpm__Matter__c> allMatters = [SELECT Id, OwnerId, Approval_Status__c, Approved__c, Probable_For_Approval__c, 
                                                 Probable_Approved__c, Cost_Centre__c, Probable_For_Approval_Total__c, Name,
                                                 Deal_Description__c, Claim_By_Against_Barclays__c  
                                                FROM advpm__Matter__c WHERE Id IN :rejectedMatters OR Id IN :approvedMatters];
            
            //RN - List of approved matter to be used for case creation
            list<advpm__Matter__c> approvedMatterList = new list<advpm__Matter__c>();
            
            for(advpm__Matter__c matter: allMatters)
            {
                if(rejectedMatters.contains(matter.Id))
                {
                    matter.Approval_Status__c = 'Rejected';
                    continue;
                }

                matter.Approval_Status__c = 'Approved';
                matter.Approved__c += 1;
               
                if(matter.Probable_Approved__c==null || matter.Probable_Approved__c==0){
                    matter.Probable_Approved__c =matter.Probable_For_Approval__c;
                }
                else{
                    matter.Probable_Approved__c = +matter.Probable_Approved__c+ matter.Probable_For_Approval__c;
                }
                matter.Probable_For_Approval__c = null;
                System.debug('Add matter to list');
                //RN
                approvedMatterList.add(matter);
             }

            update allMatters;
            
            //RN - push all approved matters to the method
            System.debug('Push matter to case create method');
            createCases(approvedMatterList);
            
        }
        
        System.debug('### Approval_Trigger : AFTER UPDATE : END');
    }
    
    //***********After Insert***************
    if(Trigger.isAfter && Trigger.isInsert)
    {
        for(Approval__c approval : Trigger.new)
        {
            //Update related Drawdown Approval Status based on Approval Status changes
            if(approval.Drawdown__c != null)
            {
                drawdownRecord = new Drawdown__c();
                drawdownRecord.id = approval.Drawdown__c;
                drawdownRecord.Approval_Status__c = approval.Status__c;
                drawdownAgencyUpdateList.add(drawdownRecord);
                drawdownNormalIdSet.add(drawdownRecord.Id);
            }
        }
        
        //Update drawdown
        if(!drawdownAgencyUpdateList.isEmpty())
        {
            update drawdownAgencyUpdateList;
        }
        
        //Normal Drawdown - Call approvalStatuses() method to create multiple approval records
         if(!drawdownNormalIdSet.isEmpty())
        {
            drawdownNormalUpdateList = Drawdown_Override.approvalStatuses(drawdownNormalIdSet);
            
            update drawdownNormalUpdateList;
        }
    }
    
    //RN - CloudSmiths - 2017-12-11
    private static void createCases(list<advpm__Matter__c> approvedMatterList){
        System.debug('Creat Case method running now......');
        //get the case record types
        map<String, Schema.RecordTypeInfo> caseRecordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        list<Case> newCaseList = new list<Case>();
         System.debug('Loop through the approved matters');
        for(advpm__Matter__c m :approvedMatterList){
              System.debug('create case in memory ');            
            Case c = new Case();
            c.Subject = m.Name;
            c.Description = m.Claim_By_Against_Barclays__c;
            c.Matter__c = m.Id;
            c.Cost_Centre__c = m.Cost_Centre__c;
            //c.ParentId = m.Id;
            c.Refund_Amount__c = m.Probable_For_Approval_Total__c;
            c.RecordTypeId = caseRecordTypeMap.get('Query/Matter Request').getRecordTypeId();
            c.OwnerId = m.OwnerId;
            
            newCaseList.add(c);
        }
         
        try{
             System.debug('insert case now....');
            insert newCaseList;
        }catch(DMLException ex){
            System.debug(ex.getMessage());
        }
    }
}