/* CHANGE LOG ***

 16-01-2018 - TdB    - Created Class.

**/

public class Agreement_Approval {
    
    private static final Map<String, Schema.RecordTypeInfo> APPROVAL_TYPES =  Approval__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public List<ParticipantWrapper> participantWrapperList { get; set; } 
    public List<advpm__Participant__c> participantList { get; set; }
    public List<Agreement__c> agreementList { get; set; }
    public List<Approval__c> existingApprovals { get; set; }
    public Agreement__c agreementRecord { get; set; }
    public String paramAgreementId { get; set; }
    public Boolean hasError { get; set; }
    public Id  participantSelectedId {get; set;} 
    public PageReference pageRef;
    
    public Agreement_Approval() 
    {
        participantWrapperList =  new List<ParticipantWrapper>();
        participantList =  new List<advpm__Participant__c>();
        agreementList = new List<Agreement__c>();
        agreementRecord = new Agreement__c();
        hasError = false;
        
        //Get Agreement Id in URL
        paramAgreementId = ApexPages.currentpage().getparameters().get('id');
        
        if(!String.isBlank(paramAgreementId))
        {
            //Get Agreement record with additional fields
            agreementList = [
                SELECT
                Id,
                Name,
                Matter_Deal__c,
                Client_Name__c,
                Agreement_Type__c,
                Review_Due_Date__c,
                Review_Comments__c,
                Last_HotDocs_Answer_Set_ID__c 
                FROM Agreement__c
                WHERE 
                Id = :paramAgreementId
            ];
            
            if(!agreementList.isEmpty())
            {
                if(agreementList[0].Last_HotDocs_Answer_Set_ID__c == null)
                {
                    //Flag error.
                    hasError = true;
                    
                    //Show error message.
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Unable to Submit for Approval, no Agreement document(s) generated from HotDocs'));
                }
                agreementRecord = agreementList[0];
                
                //Get all Approvals linked to Agreement 
                existingApprovals = [
                    SELECT Id 
                    FROM Approval__c 
                    WHERE Agreement__c = : agreementRecord.id 
                    AND HotDocs_Answer_Set_ID__c = : agreementRecord.Last_HotDocs_Answer_Set_ID__c 
                ];
                
                if(existingApprovals.size() > 0)
                {
                     //Flag error.
                    hasError = true;
                    
                    //Show error message.
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Unable to Submit for Approval, Agreement document(s) current version already reviewed'));
                }
                
                //Get Participants related to the Agreement Deal
                participantList = [
                    SELECT 
                    Id, 
                    Name,
                    advpm__Role__c,
                    advpm__Staff__c, //USER
                    Primary_Contact_for_Role__c
                    FROM advpm__Participant__c
                    WHERE 
                    advpm__Matter__c = :agreementRecord.Matter_Deal__c
                    AND advpm__Staff__c != null
                    AND advpm__Role__c != null
                ];
                
                
                //Loop over participants
                for(advpm__Participant__c participant : participantList)
                {
                    //Flag to prevent duplication if a particpant has multiple roles.
                    Boolean added = false;
                    
                    if(added == false)
                    {
                        //New Wrapper Item
                        ParticipantWrapper wrapperItem = new ParticipantWrapper();
                        wrapperItem.record = participant;
                        wrapperItem.selected = false;
                        
                        //Add to main wrapper list.
                        participantWrapperList.add(wrapperItem);
                        
                        //Set flag.
                        added = true;
                    }
                }
            }
            else 
            {
                //Flag error.
                hasError = true;
                
                //Show error message.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an error selecting Agreement record, please contact your system administrator'));
            }
        }
        else
        {
            //Flag error.
            hasError = true;
            
            //Show error message.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Request URL is invalid, please contact your system administrator'));
        }
    }
    
    public PageReference actionSubmitApproval()
    {
        List<Approval__c> ApprovalsInsertList =  new List<Approval__c>();
        Approval__c approvalRecord = new Approval__c();
        Map<Id, advpm__Participant__c> participantsIdMap =  new Map<Id, advpm__Participant__c>();
        
        if(participantSelectedId == null)
        {
            //Show error message.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a Approver'));
            return null;
        }
        
        //Loop through selected participants and build approval record.
        for(ParticipantWrapper WrapRec  : ParticipantWrapperList)
        {
            //Add to map
            participantsIdMap.put(WrapRec.record.id, WrapRec.record);
            
            //Selected participant.
            if(WrapRec.selected == true)
            {
                approvalRecord =  new Approval__c
                    (
                        Agreement__c = agreementRecord.Id,
                        Matter_Deal__c = agreementRecord.Matter_Deal__c,
                        RecordTypeID = APPROVAL_TYPES.get('Agreement Approval').getRecordTypeId(),
                        Status__c = 'New',
                        HotDocs_Answer_Set_ID__c = agreementRecord.Last_HotDocs_Answer_Set_ID__c,
                        Participant__c = WrapRec.record.id,
                        Requestor__c = UserInfo.getUserId(),
                        Reviewer__c = WrapRec.record.advpm__Staff__c,
                        Requested_Date__c = System.today(),
                        Comments__c = agreementList[0].Review_Comments__c
                        
                    );
                
                //Add to approvals list.
                ApprovalsInsertList.add(approvalRecord);
            }
        }
        
        if(ApprovalsInsertList.size() > 0)
        {
            //Insert approval records.
            insert ApprovalsInsertList;
            
            //Loop through each approval records and submit it.
            for(Approval__c eachApproval : ApprovalsInsertList)
            {
                advpm__Participant__c PartRec = participantsIdMap.get(eachApproval.Participant__c);
                
                //Process approval submission for approval records.
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(eachApproval.id);
                req1.setNextApproverIds(new Id[] {PartRec.advpm__Staff__c});
                Approval.ProcessResult result =   Approval.process(req1);
            }
            
            agreementRecord.Review_Status__c = 'Review in Progress';
            update agreementRecord;
        }
        
        
        //Redirect URL.
        pageRef = new PageReference('/'+ paramAgreementId);
        
        //Default return.
        Return pageRef;
    }
    
    public PageReference actionCancel()
    {
        pageRef = new PageReference('/'+ paramAgreementId); 
        return pageRef;
    }
    
    public Class ParticipantWrapper
    {
        public advpm__Participant__c record { get; set; }
        public Boolean selected { get; set; } 
    }
    
    
    
    public void disableCheckbox()
    {
    	//iterate over your wrapper and set eachWrapper.selected false except selected one
       for(ParticipantWrapper eachWrapper: participantWrapperList)
       {
            if(eachWrapper.record.id == participantSelectedId)
            {
    			eachWrapper.selected = True;
            }
            else{
              eachWrapper.selected = False;
            }
       }
    }

}