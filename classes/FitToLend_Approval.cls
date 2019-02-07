/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

21/09/2017  - PG    - Created Class.
                    - Rewrote based on the original by Daniel.  Was not happy with how some of the logic was structured. 
07/03/2018 - TdB 	- Add Comments field to PDF attachment for Submit for Approval
08/03/2018 - TdB 	- Add Review_Checklist_Complete__c = True when submitted for Approval
01/08/2018 - TdB	- Remove commeneted code, remove the if statements with the same actions (sFlow == true and sFlow == false)
**/
public class FitToLend_Approval 
{
    /**
* Variables
**/
    private static final Map<String, Schema.RecordTypeInfo> APPROVAL_TYPES =  Approval__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static final Map<String, Schema.RecordTypeInfo> FITTOLEND_TYPES =  Fit_To_Lend_Checklist__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public advpm__Matter__c matterRecord { get; set;}  
    public Approval__c  AppRec { get; set;}
    public List<SelectOption> options { get; set; }
    public List<advpm__Participant__c> participantList { get; set; }
    public List<ParticipantWrapper> participantWrapperList { get; set; } 
    public PageReference pageRef { get; set;}
    public Id approvalRecordTypeId { get; set; } 
    public Fit_To_Lend_Checklist__c fitToLend { get; set; }
    public List<Fit_To_Lend_Checklist__c> fitToLends { get; set; }
    public String commentsCaptured;
    
    //Page Params
    public String paramMatterId { get; set; }
    public String paramFitToLendId { get; set; }
    
    //Other Stuff 
    public Boolean isFlow { get; set; }
    public Set<String> uniqueRoleCheck { get; set; }
    public Boolean debug { get; set; }
    public Boolean hasError { get; set; }
    public Boolean missingRoles { get; set; }
    public Boolean userCanSubmit { get; set; }
    Private String originalComment = '';
    
    /**
* Constructor
**/
    public FitToLend_Approval() 
    {
        System.debug('### FitToLend_Approval');
        
        //Blank Variables.
        participantWrapperList =  new List<ParticipantWrapper>();
        participantList =  new List<advpm__Participant__c>();
        uniqueRoleCheck = new Set<String>();
        fitToLends = new List<Fit_To_Lend_Checklist__c>();
        
        //Set some defult values.
        userCanSubmit = false;
        debug = false;
        hasError = false;
        missingRoles = false;
        userCanSubmit = false;
                
        //Page params
        paramMatterId = ApexPages.currentpage().getparameters().get('id');
        paramFitToLendId = ApexPages.currentpage().getparameters().get('fid'); 
        
        //Query the fit to lend record for the passed in URL param.
        if(!String.isBlank(paramFitToLendId))
        {
            fitToLends = 
                [
                    SELECT
                    Id,
                    Name,
                    Deal__c,
                    Status__c,
                    Comments__c
                    FROM Fit_To_Lend_Checklist__c
                    WHERE 
                    Id = :paramFitToLendId
                ];
            
            //Got records.
            if(!fitToLends.isEmpty())
            {
                //Assign record.
                fitToLend = fitToLends[0];
                
                //Get deal record for fit to lend.
                matterRecord = 
                    [
                        SELECT 
                        Id, 
                        Name,
                        Standard__c
                        FROM advpm__Matter__c
                        WHERE 
                        Id = :fitToLend.Deal__c
                    ];
                
                //Set isFlow for easy of use in IF statements.
                isFlow = (matterRecord.Standard__c == false) ? false : true;
                
                //Get deal participants.
                participantList = 
                    [
                        SELECT 
                        Id, 
                        Name,
                        advpm__Role__c,
                        advpm__Staff__c, //USER
                        Primary_Contact_for_Role__c
                        FROM advpm__Participant__c
                        WHERE 
                        advpm__Matter__c = :fitToLend.Deal__c
                        AND advpm__Staff__c != null
                        AND advpm__Role__c != null
                    ];
                
                //Role & Participant Checks
                Set<String> uniqueRoles = new Set<String>();
                
                //Loop over participants.
                for(advpm__Participant__c participant : participantList){
                    
                    //Flag to prevent duplication if a particpant has multiple roles.
                    Boolean added = false;
                    
                    //Has a role(s) defined.
                    if(!String.isBlank(participant.advpm__Role__c))
                    {
                        //Participant roles.
                        List<String> roles = participant.advpm__Role__c.split(';');
                        
                        //Loop through participant roles.
                        for(String role : roles)
                        {
                            //Make sure that user looking at page, is a TA person on deal.
                            if(participant.advpm__Staff__c == UserInfo.getUserId() && role == 'Transaction Administration')
                            {
                                userCanSubmit = true;
                            }

                            //Required role and not duplicated.
                            if(added == false)
                            {
                                //New Wrapper Item
                                ParticipantWrapper wrapperItem = new ParticipantWrapper();
                                wrapperItem.record = participant;
                                wrapperItem.selected = true;
                                
                                //Add to main wrapper list.
                                participantWrapperList.add(wrapperItem);
                                
                                //Set flag.
                                added = true;
                            }
                            
                            //Add to unique check set.
                            uniqueRoles.add(role);

                        }
                    }
                    //IF END
                }
                //FOR END
            }
            else 
            {
                //Flag error.
                hasError = true;
                
                //Show error message.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an error selecting Fit To Lend record, please contact your system administrator'));
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
    
    /**
* Action - Cancel page action.
**/
    public PageReference actionCancel()
    {
        PageReference pageRef = new PageReference('/'+ paramFitToLendId); 
        return pageRef;
    }
    
    /**
* Action - Save and submit for approval.
**/
    public PageReference actionSubmitApproval()
    {
        //List of approvals.
        List<Approval__c> AppsToInsert =  new List<Approval__c>();
        Map<Id, advpm__Participant__c> mapOfParticipantstoThierIds=  new Map<Id, advpm__Participant__c>();
        Set<String> uniqueSelectedRoles = new Set<String>();
        
        //Loop through selected participants and build approval record.
        for(ParticipantWrapper WrapRec  : ParticipantWrapperList)
        {
            //Add to map
            mapOfParticipantstoThierIds.put(WrapRec.record.id, WrapRec.record);
            
            //Selected participant.
            if(WrapRec.selected == true)
            {
                AppRec =  new Approval__c
                    (
                        Fit_To_Lend_Checklist__c = fitToLend.Id,
                        Matter_Deal__c = matterRecord.Id,
                        RecordTypeID = APPROVAL_TYPES.get('Fit To Lend Approval').getRecordTypeId(),
                        Status__c = 'New',
                        Participant__c = WrapRec.record.id
                    );
                
                //Add to approvals list.
                AppsToInsert.add(AppRec);
            }
        }
        
        //Insert approval records.
        insert AppsToInsert;
        
        //Loop through each approval records and submit it.
        for(Approval__c AppRec : AppsToInsert)
        {
            advpm__Participant__c PartRec = mapOfParticipantstoThierIds.get(AppRec.Participant__c);
            
            //Process approval submission for approval records.
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(AppRec.id);
            req1.setNextApproverIds(new Id[] {PartRec.advpm__Staff__c});
            Approval.ProcessResult result =   Approval.process(req1);
        }
        
        //Get the pdf version of the checklist.
        Blob pdfContent = CloudSmiths_Utils.convertUrlToBlob('/apex/FitToLendChecklist_View?Id='+paramMatterId+'&fid='+paramFitToLendId+'&submitApprove=1'+'&mode=pdf');
        
        //No content returned during test runs, causing exception
        if(Test.isRunningTest())
            pdfContent = Blob.valueOf('Test');
        
        List<Attachment> approvalAttachments = new List<Attachment>();
        
        for(Approval__c insertedApproval : AppsToInsert)
        {
            //Attachment object.
            Attachment approvalAttachment = new Attachment();
            approvalAttachment.ParentId = insertedApproval.Id;
            approvalAttachment.Name = matterRecord.Name+' - Checklist - '+fitToLend.Name+'.pdf';
            approvalAttachment.Body = pdfContent;
            
            //Add to list.
            approvalAttachments.add(approvalAttachment);
        }
        
        //Insert attachments to approvals.
        insert approvalAttachments;
        
        //Insert a copy on the Checklist level as well.
        //Attachment object.
        Attachment fitToLendAttachment = new Attachment();
        fitToLendAttachment.ParentId = fitToLend.Id;
        fitToLendAttachment.Name = matterRecord.Name+' - Checklist - '+fitToLend.Name+'.pdf';
        fitToLendAttachment.Body = pdfContent;
        //RN - to identify the att in the attachements trigger in order to block other attachements added by users later
        fitToLendAttachment.Description = 'System Generated';
        insert fitToLendAttachment;
        
        //Update Fit to Lend
        System.debug('fitToLend.status__c : ' + fitToLend.status__c);
        fitToLend.status__c = 'Pending Approval';
        fitToLend.Review_Checklist_Complete__c = True;
        
        //Update Fit to Lend Record
        Update fitToLend;
        
        //Redirect URL.
        pageRef = new PageReference('/'+ fitToLend.Id);
        
        //Default return.
        Return pageRef;
    }
    
    public Integer getUniqueRolesSize()
    {
        return uniqueRoleCheck.size();
    }
    
    /**
* Wrapper class/
**/
    public Class ParticipantWrapper
    {
        public advpm__Participant__c record { get; set; }
        public Boolean selected { get; set; } 
    }
}