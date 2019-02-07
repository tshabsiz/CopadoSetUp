/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a controller for JLOC_View page.
* @Date:        10/2015
* @ConstructorParam:    stdController - Standard Controller for "JLOC" object
* @TestClass:   ZZTEST_JLOC_ViewController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 12/2015     Marta Malinowska   Show popup with comments area while JLOC Attendees vote
* 3/2016      Marek Cech         changed checkIfDocExist and constructor because of checking all related attachments
* 04/2016     Nakedi Mashapa     added a field called RWA
* 29/06		  Mathieu Sroussi	 Add retrieval of Client Plan information and product level 3
* 2017.06.28  Dino Scarcella	 Add action to clone JLOC
* 2017.07.10  Mabhedle Tonga     Add ability to send to Opp Team Member
* 2017.10.17 Mabhedle Tonga Added validation  before submitting to secretary using forecast projects
*------------------------------------------------------------*/
public with sharing class JLOC_ViewController {
    public static String REJECT = 'Reject';
    public static String STATUS_DRAFT = 'Draft';
    public static String STATUS_SUBMITTED_TO_SECRETARY = 'Submitted to Secretary';
    public static String STATUS_SENT_TO_COMMITTEE = 'Sent to Committee';
    public static String STATUS_APPROVED = 'Approved';
    public static String STATUS_APPROVED_SUBJECT_TO = 'Approved Subject to';
    public static String STATUS_DECLINED = 'Declined';
    public static String STATUS_DEFERRED = 'Deferred';
    public static String GROUP_JLOC_SECRETARY = 'JLOC Secretary';
    
    private JLOC__c jloc;
    private Id currentUserId;
    private List<ProcessInstanceWorkItem> workItems;
    
    public List<OpportunityTeamMember> DealTeam { get; set; }
    
    public Boolean isDraft { get; set; }
    public Boolean isSubmittedToSecretary { get; set; }
    public Boolean isSentToCommittee { get; set; }
    public Boolean isApproved { get; set; }
    public Boolean isDeclined { get; set; }
    public Boolean isDeferred { get; set; }
    
    public Boolean isSecretary { get; set; }
    public Boolean isJlocCommitteeAttendee { get; set; }

    public Boolean voted { get; set; }
    public String  status { get; set; }
    public String  comments { get; set; }
    public Boolean displayPopup { get; set; }

    public JLOC_ViewController(ApexPages.StandardController stdController) {
        
        //Tonga MM : Modified constructer to dynamically include fields onto controller everytime new fields are added
        List<String> fieldNames  = new List<String>();
        
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.JLOC__c.fields.getMap();
        for (String fieldName: schemaFieldMap.keySet()) {
            fieldNames.add(fieldName);
        }
        if(!test.isRunningTest()) {
            stdController.addFields(fieldNames);
        }

        jloc = (JLOC__c)stdController.getRecord();
        currentUserId = UserInfo.getUserId();

        DealTeam = new List<OpportunityTeamMember>();

        if(jloc.Id != null) {
            DealTeam = [
                SELECT      Id, Opportunity.Name, User.Name, TeamMemberRole,UserID,OpportunityId 
                FROM        OpportunityTeamMember 
                WHERE       Opportunity.JLOC__c = :jloc.Id
                ORDER BY    Opportunity.Name
            ];
        }

        //Check if there are items pending approval
        workItems = [
            SELECT  Id 
            FROM    ProcessInstanceWorkItem 
            WHERE   ProcessInstance.TargetObjectId = :jloc.Id AND ActorId = :currentUserId AND ProcessInstance.Status = 'Pending'
        ];

        isDraft = jloc.JLOC_Status__c == STATUS_DRAFT ? true : false;
        isSubmittedToSecretary = jloc.JLOC_Status__c == STATUS_SUBMITTED_TO_SECRETARY && workItems.size() > 0 ? true : false;
        isSentToCommittee = jloc.JLOC_Status__c == STATUS_SENT_TO_COMMITTEE ? true : false;
        isApproved = jloc.JLOC_Status__c == STATUS_APPROVED ||  jloc.JLOC_Status__c == STATUS_APPROVED_SUBJECT_TO ? true : false;
        isDeclined = jloc.JLOC_Status__c == STATUS_DECLINED ? true : false;
        isDeferred = jloc.JLOC_Status__c == STATUS_DEFERRED ? true : false;

        displayPopup = false;
        
        //Check if is a part of "JLOC Secretary"
        List<GroupMember> jlocSecretaryMembers = [
            SELECT  Id 
            FROM    GroupMember 
            WHERE   Group.Name = :GROUP_JLOC_SECRETARY AND UserOrGroupId = :currentUserId
        ];

        if(jlocSecretaryMembers.size() > 0) {
            isSecretary = true;
        } else{
            isSecretary = false;
        }

        //Check if is a JLOC Attendee
        List<JLOC_Attendee__c> jlocAttendees = [
            SELECT  Id, Vote__c 
            FROM    JLOC_Attendee__c 
            WHERE   JLOC__c = :jloc.Id AND User__c = :currentUserId AND Group__c != 'Other'
        ];

        voted = false;
        if(jlocAttendees.size() > 0) {
            isJlocCommitteeAttendee = true;
            for(JLOC_Attendee__c jlocAttendee : jlocAttendees){
                if(String.isNotBlank(jlocAttendee.Vote__c)){
                    voted = true;
                    break;
                }
            }
        } else {
            isJlocCommitteeAttendee = false;
        }
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to generate pdf document and save it as attachment.
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 2017.06.30  Dino Scarcella	 Check if there are opportunities associated to JLOC
    *------------------------------------------------------------*/
    public PageReference generatePdf() {
        //PageReference printView = Page.JLOC_PrintView;
        PageReference printView = Page.JLOC_PrintView;
        printView.getParameters().put('id', jloc.Id);
        printView.setRedirect(true);
        
        //Check if there are opportunities associated to JLOC 
        if (JLOC_PrintViewController.getJLOCOpportunity(jloc.Id) == NULL && !Test.isRunningTest()) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_AtLeastOneOpportunityForJLOC));
            return null;
        }
        
        Attachment att = new Attachment();
        Blob body = Test.isRunningTest() ? Blob.ValueOf('dummy text') : printView.getContent();
        att.Body = body;
        att.Name = jloc.Name + '_' + jloc.JLOC_Status__c + '_' + System.now().format('yyyyMMdd') + '.pdf';
        att.parentId = jloc.id;
        try {
            INSERT att;
        } catch(DmlException ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
        }

        if(jloc.JLOC_Document_ID__c != null) {
            try {
                DELETE [SELECT Id, Name, Body FROM Attachment WHERE Id = :jloc.JLOC_Document_ID__c];
            } catch(DmlException ex) 
            {
                JLOC_Utility.logException(ex, 'JLOC_viewController', 'generatePdf', 'There was an error in Deleting JLOC Attachment ID '+jloc.JLOC_Document_ID__c);
            }
        }
        
        jloc.JLOC_Document_ID__c = att.Id;
        try{
            UPDATE jloc;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, jloc.JLOC_Status__c + ' document has been (re-)generated.'));
        } catch(DmlException ex) {
                JLOC_Utility.logException(ex, 'JLOC_viewController', 'generatePdf', 'There was an error in updating JLOC ID '+jloc.ID);
        }

        
        return null;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to check if JLOC can be submitted to Secretary and change the status or display error page.
    * @param        None
    * @Returns:     view page if JLOC can be submitted to Secretary
    *               error page if JLOC cannot be submited to Secretary
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference submitToSecretary() {
        
        if(jloc.Forecast_Not_Available__c)
        {
            return finalSubmissionToSecretary();
        }
        else
        {
            if((String.isBlank(jloc.Stress_Case_ID__c) && String.isBlank(jloc.Banker_Case_ID__c) && String.isBlank(jloc.Management_Case_ID__c)))
            { 
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Client Forecasts missing: To correct go to the \'About\' tab and add forecasts or indicate that forecasts are not applicable'));
                return null;
            }
            else
            {
                return finalSubmissionToSecretary();
            }
        }        
    }
    

    public PageReference finalSubmissionToSecretary()
    {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            
            if(jloc.Deal_Presented_To_Deal_Forum__c == false 
               || jloc.Go_Approval_From_Deal_Forum_Quorum__c == false
               || jloc.Approved_By_Financial_Crime_Compliance__c == false 
               || jloc.Deal_Team_Polices_Confirmation__c == false 
               || String.isBlank(jloc.Status__c) 
               || String.isBlank(jloc.CLGD_Consumption__c) 
               || jloc.Barclays_Commitment__c == null 
               || jloc.Barclays_Underwriting__c == null 
               || jloc.Barclays_Target_Hold__c == null) {
                   
                   PageReference pageRef = Page.JLOC_SubmitToSecretary;
                   pageRef.getParameters().put('id', jloc.Id);
                   return pageRef;
               } else {
                   Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                   req.setObjectId(jloc.Id);
                   requests.add(req);
               }
            
            try {
                List<Approval.ProcessResult> results = Approval.process(requests);
            } catch(Exception ex) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
                return null;
            }
            
            PageReference pageRef = new ApexPages.StandardController(jloc).view();
            return pageRef;
    }
    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to change the status of JLOC to "Sent to Committee".
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference sentToCommittee() {
        PageReference pageRef = Page.JLOC_InviteParticipants;
        pageRef.getParameters().put('id', jloc.Id);
        return pageRef;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to change the status of JLOC back to "Draft".
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference reject() {
        
        
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            for(ProcessInstanceWorkItem workItem : workItems) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction(REJECT);
                req.setWorkitemId(workItem.Id);
                requests.add(req);
            }
            
            try {
                List<Approval.ProcessResult> results = Approval.process(requests);
            } catch(Exception ex) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
                return null;
            }
            
            PageReference pageRef = new ApexPages.StandardController(jloc).view();
            return pageRef;
       
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used by Secretary to change the status of JLOC to "Approved".
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference finalApprove() {
        return secretaryVote(STATUS_APPROVED);
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used by Secretary to change the status of JLOC to "Declined".
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference finalDecline() {
        return secretaryVote(STATUS_DECLINED);
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used by Secretary to change the status of JLOC to "Deffered".
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference finalDefer() {
        return secretaryVote(STATUS_DEFERRED);
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used by JLOC Attendees to vote for "Approved".
    * @param        None
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public void approve() {
        showPopup();
        status = STATUS_APPROVED;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used by JLOC Attendees to vote for "Approved Subject to".
    * @param        None
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public void approveSubjectTo() {
        showPopup();
        status = STATUS_APPROVED_SUBJECT_TO;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used by JLOC Attendees to vote for "Declined".
    * @param        None
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public void decline() {
        showPopup();
        status = STATUS_DECLINED;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to vote on behalf of JLOC Attendee.
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference jlocAttendeeVote() {
        closePopup();

        List<JLOC_Attendee__c> jlocAttendees = [
            SELECT  Id, Vote__c, Comments__c 
            FROM    JLOC_Attendee__c 
            WHERE   JLOC__c = :jloc.Id AND User__c = :currentUserId AND Group__c != 'Other'
        ];

        if(jlocAttendees.size() > 0) {
            for(JLOC_Attendee__c jlocAttendee : jlocAttendees) {
                if(String.isBlank(jlocAttendee.Vote__c)) {
                    jlocAttendee.Vote__c = status;
                    jlocAttendee.Comments__c = comments;
                }
            }
        } else {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You are not allowed to vote for this JLOC.'));
            return null;
        }

        try {
            JLOC_ApprovalProcessUtils.updateJlocAttendees(jlocAttendees);
        } catch(DmlException ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
        }

        PageReference pageRef = new ApexPages.StandardController(jloc).view();
        return pageRef;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to vote on behalf of JLOC Secretary.
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference secretaryVote(String status) {
        jloc.JLOC_Status__c = status;
        try {
            JLOC_ApprovalProcessUtils.updateJloc(jloc);
        } catch(DmlException ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
        }

        PageReference pageRef = new ApexPages.StandardController(jloc).view();
        return pageRef;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to redirect to JLOC sharing page.
    * @param        None
    * @Returns:     sharing page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference sharing() {
        PageReference pageRef = new PageReference('/p/share/CustomObjectSharingDetail');
        pageRef.getParameters().put('parentId', jloc.Id);
        return pageRef;
    }

    public void showPopup() {
        displayPopup = true;
    }

    public void closePopup() {
        displayPopup = false;
    }
    
    /**
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: This method is used to redirect to JLOC Create Page to clone JLOC.
    * @param        None
    * @Returns:     create page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference cloneJLOC() {
        if (jloc.Id != null && jloc.Organisation__c != null) {
        	PageReference pageRef = new PageReference('/apex/JLOC_CreateNew');
            pageRef.getParameters().put('CF00N2400000EmGiw_lkid', jloc.Organisation__c);
            pageRef.getParameters().put('scontrolCaching', '1');
            pageRef.getParameters().put('retURL', jloc.Id);
            pageRef.getParameters().put('sfdc.override', '1');
            pageRef.getParameters().put('JLOCIdToClone', jloc.Id);
            return pageRef;
        } else {
         	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not enough information to clone this JLOC'));
        	return null;
        }
    }
    //Tonga MM : Send email to TeamMember;
    public  PageReference SendToTeam()
    {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String templateID ='';
        
        templateID = [Select id from EmailTemplate where DeveloperName = 'JLoc_Submit_To_Team' ].ID;
        
        if(jloc.JLOC_Document_ID__c!=null)
        {
            Attachment latestAttachment = [Select Name,Body from Attachment where ID =:jloc.JLOC_Document_ID__c limit 1];
            OrgWideEmailAddress[] owea = [select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName = :Label.lblSupportUserName limit 1];
            
            // Create the email attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(latestAttachment.Name);
            efa.setBody(latestAttachment.body);
            if(DealTeam.size()>0)
            {
                for(OpportunityTeamMember teamMember :DealTeam)
                {
                    emailList.add(generateEmail(teamMember.UserID,templateID,jloc.ID, efa,owea[0]));
                }
            }
            
            // Sends the email
            Messaging.sendEmail(emailList);  
            
         	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'A copy of the current JLoc has just been sent to Deal team members successfully'));
          
            return Apexpages.currentPage();
        }
         else 
         {
         	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please generate a Draft before sending to TeamMember'));
        	return null;
        }
    }
    
    //Tonga MM : Generate each email for each recipeint 
    public static Messaging.SingleEmailMessage generateEmail(ID teamMemberID,ID templateID,ID currentOppID, Messaging.EmailFileAttachment attachmentFile,OrgWideEmailAddress OWEA)
    {
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
        msg.setTargetObjectId(teamMemberID);
        msg.setTreatTargetObjectAsRecipient(true);
        msg.setReplyTo(OWEA.Address);
        msg.setOrgWideEmailAddressId(OWEA.ID);
        msg.setTemplateId(templateID);
        msg.setWhatId(currentOppID);
        msg.saveAsActivity  = false;
        
        msg.setFileAttachments(new Messaging.EmailFileAttachment[]{attachmentFile});
        return msg;
    }
}