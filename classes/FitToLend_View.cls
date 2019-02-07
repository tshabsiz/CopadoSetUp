/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

08/06/2017 - DF     - Created Class.
27/06/2017 - PG     - Added Multiple Borrowers to the Checklist view
29/06/2017 - PG     - Remove multi borrower and replaced with new consolidated field on occurrence for the parties.
17/10/2017 - RN     - CloudSmiths AUS - Remove the comments box per row and add one at th ebottom of the list
17/10/2017 - RN     - CloudSmiths AUS - Add a sequence number to each item in the list
06/11/2017 - TdB    - Add DoUpdateAndNotifyOnly() to attach checklist to fir to lend and email notification
14/12/2017 - TdB	- AddError Message on "Save and Submit For Approval" if deal parties does not have a SDS ID
08/02/2018 - TdB	- Remove No SDS Id Error Msg
07/03/2018 - TdB 	- Add Comments field to PDF attachment for Submit for Approval
08/03/2018 - TdB 	- Add Review_Checklist_Complete__c = True when Save and Notify selected
01/08/2018 - TdB	- Remove commeneted code
**/
public class FitToLend_View 
{
    public advpm__Matter__c MatterRec { get; set; }
    public List<Condition__c> ConditionList { get; set; }
    public List<Condition_Occurrence__c> ConditionOccuranceList { get; set; }
    public List<Condition__c> ConditionWithConditionOccuranceList { get; set; }
    public List<Agreement__c> AgreementList { get; set; }
    public List<AgreementWrapper> AgreementWrapperListToDisplay { get; set; }
    public Map<id,AgreementWrapper> AgreementWrapperMap { get; set; }
    public id PrecedenceRecordTypeid { get; set; } 
    public id GovernanceRecordTypeid { get; set; } 
    Public advpm__Participant__c UserParticipentRecForThisMatter  { get; set; } 
    public String renderAsPDF { get; set; }
    public List<Deal_Party__c> dealPartiesList { get; set; }
    //RN
    Public Fit_To_Lend_Checklist__c fit2Lend {get;set;}
    Private String originalComment = '';
    
    //Page messages vars.
    Public Boolean isDisplayLegalMessage{ get; set; } 
    Public Boolean isDisplayCreditMessage{ get; set; } 
    Public Boolean isDisplayProductMessage{ get; set; } 
    
    //Page Params
    public String paramMatterId { get; set; }
    public String paramFitToLendId { get; set; }
    
    //Multiple Borrowers
    public List<Condition__c> conditionWithParties { get; set; }
    public Map<Id, List<Condition_Party__c>> conditionBorrowers { get; set; }
    
    /**
* Agreement Wrapper Class.
**/
    public Class AgreementWrapper{
        Public Id idVar { get; set; }
        Public String Name { get; set; }
        Public List<Condition_Occurrence__c> AgreementConditionOccurenceList { get;set; } 
    }
    
    /**
* Constructor
**/
    public FitToLend_View() {
        //Variables
        Map<String, Schema.RecordTypeInfo> ConditionRecordTypeMap =  Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        PrecedenceRecordTypeid = ConditionRecordTypeMap.get('Condition Precedent').getRecordTypeId();
        GovernanceRecordTypeid = ConditionRecordTypeMap.get('Governance Check').getRecordTypeId();
        
        AgreementWrapperMap = new map<Id, AgreementWrapper>();
        List<String> ListOfSelectedParticipantRoles = new List<String>();
        List<Id> SelectedCondtions = new list<Id>();
        AgreementWrapperListToDisplay = new list<AgreementWrapper>();
        
        //PDF rendering handling.
        if(ApexPages.currentpage().getparameters().get('mode') == 'pdf')
        {
            renderAsPDF = 'pdf';
        }
        else
        {
            renderAsPDF = '';
        }
        
        Map<String, String> currentParams = ApexPages.CurrentPage().getParameters();
        
        //Page params
        paramMatterId = ApexPages.currentpage().getparameters().get('Id');
        paramFitToLendId = ApexPages.currentpage().getparameters().get('fId');
        
        //get fit to lead
        fit2Lend = [Select Id, Name, Comments__c From Fit_To_Lend_Checklist__c Where Id = :paramFitToLendId];
        if(String.isNotBlank(fit2Lend.Comments__c)){
            originalComment = fit2Lend.Comments__c;
            if(!currentParams.containsKey('submitApprove'))
            {
                fit2Lend.Comments__c = '';
            }            
        }
        
        Id Userid;
        
        try
        {
            //Current user id.
            Userid =  UserInfo.getUserId();
            
            //Get the current users participant record.
            UserParticipentRecForThisMatter = 
                [
                    SELECT 
                    Id, 
                    Name,
                    advpm__Role__c,
                    advpm__Staff__c
                    FROM
                    advpm__Participant__c
                    WHERE 
                    advpm__Matter__c =: paramMatterId
                    AND
                    advpm__Staff__c =: Userid
                ];
        }
        catch(Exception e)
        {
            UserParticipentRecForThisMatter = new advpm__Participant__c();
            UserParticipentRecForThisMatter.advpm__Role__c ='';
        }
        
        //Put all the roles for the current user into list.
        if(UserParticipentRecForThisMatter != null && UserParticipentRecForThisMatter.advpm__Role__c != null)
        {
            ListOfSelectedParticipantRoles= UserParticipentRecForThisMatter.advpm__Role__c.split(';');
        }
        //Detemine which message to display on page.
        for(string RoleString : ListOfSelectedParticipantRoles)
        {        
            if(RoleString == 'Product')
            {
                isDisplayProductMessage = true;
            }
            if(RoleString == 'Legal Counsel')
            {
                isDisplayLegalMessage = true;
            }
            if(RoleString == 'Credit')
            {
                isDisplayCreditMessage = true;
            }
        }
        
        //Get the deal record..
        MatterRec = [
            SELECT 
            Id, 
            Name,
            Relationship__c, 
            CIF_ID_Account__c,
            SDS_ID_Account__c
            FROM advpm__Matter__c   
            WHERE 
            Id =: paramMatterId
        ];
        
        System.debug('###MatterRec : ' + MatterRec);
        
        //Get the list of agreements for the deal.
        AgreementList = [
            SELECT 
            Id,  
            Name
            FROM Agreement__c
            WHERE Matter_Deal__c =: MatterRec.Id
        ];
        
        //Map to hold agreements.
        Map<Id, Agreement__c> AgreementMap = new Map<Id, Agreement__c>();
        
        //Build agreement map.
        for(Agreement__c Aggrec: AgreementList)
        {
            AgreementMap.Put(Aggrec.id,Aggrec);
        }
        
        //Get all conditions and occurrences for the deal.
        ConditionWithConditionOccuranceList = 
            [
                SELECT 
                Id,  
                Name,
                Status__c,
                Agreement__c,
                Agreement__r.Name,
                RecordType.Name,
                (  
                    SELECT 
                    Id,  
                    Name,
                    Status__c,
                    Comments__c,
                    Condition__c,
                    RecordType.Name,
                    Relationship_Consolidated__c,
                    LastModifiedDate,
                    Condition__r.Clause__c
                    FROM
                    Conditions_Due__r
                )
                FROM Condition__c
                WHERE 
                Matter__c =: MatterRec.id
                AND Active__c = True
                AND Agreement__c != null
                AND
                (
                    RecordTypeID = :PrecedenceRecordTypeid
                    OR
                    RecordTypeID = :GovernanceRecordTypeid
                )
                ORDER BY Agreement__r.name
            ];
        
        //Loop through conditions for deal.
        for(Condition__c Conrec: ConditionWithConditionOccuranceList)
        {
            //Blank wrapper.
            AgreementWrapper AggRec;
            
            try
            {
                AggRec = AgreementWrapperMap.get(Conrec.agreement__c);
            }
            Catch(exception e)
            {
                
            }
            
            //If wrapper os blank.
            if(AggRec ==  null)
            {
                AggRec = new AgreementWrapper();
                agreement__c TempAgg = AgreementMap.get(Conrec.agreement__c);
                AggRec.name = TempAgg.name;
                AggRec.idVar =  TempAgg.id;
                AggRec.AgreementConditionOccurenceList = new  List<Condition_Occurrence__c>();
            }
            
            //Add condition occurrences to wrapper  inner list..
            AggRec.AgreementConditionOccurenceList.addAll(Conrec.Conditions_Due__r);
            
            //Add to main wrapper list.
            AgreementWrapperMap.Put(AggRec.idVar,AggRec);
            
            SelectedCondtions.add(Conrec.id);
        }
        
        //Loop through agreement wrapper.
        for(AgreementWrapper Aggrec: AgreementWrapperMap.values())
        {
            AgreementWrapperListToDisplay.add(Aggrec);
        }
        
        //Get all conditions of type CP and GC for the deal.
        ConditionList = [
            SELECT 
            Id,  
            Name,
            Status__c,
            RecordType.Name,
            (  
                SELECT 
                Id,  
                Name,
                Condition__c,
                Status__c,
                Relationship_Consolidated__c,  
                Comments__c,
                RecordType.Name,
                lastModifiedDate,
                Condition__r.Clause__c
                FROM
                Conditions_Due__r
            )
            FROM Condition__c
            WHERE 
            Matter__c =: MatterRec.id
            AND Id NOT IN :SelectedCondtions
            AND
            (
                RecordTypeID = :PrecedenceRecordTypeid 
                OR
                RecordTypeID = :GovernanceRecordTypeid 
            ) 
        ];
        
        ConditionOccuranceList = new List<Condition_Occurrence__c>();  
        
        for(Condition__c ConRec: ConditionList)
        {
            ConditionOccuranceList.addAll(Conrec.Conditions_Due__r);
            
        }
    }
    
    /**
* ACTION - Cancel and record to deal.
**/
    Public PageReference DoCancel()
    {
        PageReference pageRef = new PageReference('/'+ paramFitToLendId); 
        return pageRef;
    }
    
    /**
* ACTION - Updates the occurrences with the comments.
**/
    Public PageReference DoUpdate(){
        //RN
        updateCommets();
        
        PageReference pageRef = new PageReference('/'+ paramFitToLendId); 
        return pageRef;
        
    }
    
    /**
* ACTION - Updates the occurrences with the comments and moves to the approval page.
**/
    public PageReference DoUpdateAndGoToApprovalSubmitPage(){        
        
        //Through exception if no SDS Id
        if(MatterRec.CIF_ID_Account__c == null && MatterRec.SDS_ID_Account__c == null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You are not allowed to "Submit for Approval" if the Client does not have a CIF Id and/or a SDS Id'));
            return null;        
        }else{
            //RN
            updateCommets();
            
            //Return
            PageReference pageRef = new PageReference('/apex/FitToLend_ApprovalSubmit?id='+ paramMatterId+'&fid='+paramFitToLendId); 
            return pageRef;
        }  
    }
    
    //RN - Update comments on the FTL record
    private void updateCommets(){
        if(String.isBlank(originalComment)){
            if(String.isNotBlank(fit2Lend.Comments__c)){
                fit2Lend.Comments__c = 'Comment Added:' + String.valueOf(System.now()) + '\n' + fit2Lend.Comments__c;
            }
        }else{
            if(String.isNotBlank(fit2Lend.Comments__c)){
                fit2Lend.Comments__c = originalComment + '\nComment Added:' + String.valueOf(System.now()) + '\n' + fit2Lend.Comments__c;
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            update fit2Lend;
        }catch(DMLException ex){
            System.debug('There was an error while updating the conditions for a Fit to Lend record');
            System.debug(ex.getMessage());
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your comments could not be saved at this point'));
        }
        
    }
    
    public PageReference DoUpdateAndNotifyOnly(){
        
        //Through exception if no SDS Id
        if(MatterRec.CIF_ID_Account__c == null && MatterRec.SDS_ID_Account__c == null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You are not allowed to "Save and Notify" if the Client does not have a CIF Id and/or a SDS Id.'));
            return null;        
        }else{
        
        PageReference pageRef = new PageReference('/'+ paramFitToLendId);
        Attachment fitToLendAttachment = new Attachment();
        
        //Update Fit to Lend Checklist Comments and Status. Send Notification Groups and Participants email
        if(String.isBlank(originalComment)){
            if(String.isNotBlank(fit2Lend.Comments__c)){
                fit2Lend.Comments__c = 'Comment Added:' + String.valueOf(System.now()) + '\n' + fit2Lend.Comments__c;
            }
        }else{
            if(String.isNotBlank(fit2Lend.Comments__c)){
                fit2Lend.Comments__c = originalComment + '\nComment Added:' + String.valueOf(System.now()) + '\n' + fit2Lend.Comments__c;
            }
        }
        
        try
        {
            //Get the pdf version of the checklist.
            PageReference pdf = Page.FitToLendChecklist_View ;
            pdf.getParameters().put('id',MatterRec.id);
            pdf.getParameters().put('fid',fit2Lend.Id);
            Blob pdfContent;
            If(test.isRunningTest() == false)//only do this if a test is not running
        	{
            	pdfContent = pdf.getContentAsPDF();
            }
            
            //No content returned during test runs, causing exception
            if(Test.isRunningTest())
                pdfContent = Blob.valueOf('Test');
            
            fitToLendAttachment.ParentId = fit2Lend.Id;
            fitToLendAttachment.Name = MatterRec.Name+' - Checklist - '+fit2Lend.Name+'.pdf';
            fitToLendAttachment.Body = pdfContent;
            fitToLendAttachment.Description = 'System Generated';
            
            //Insert attachment
            insert fitToLendAttachment;
            
        }
        catch(DMLException ex)
        {
            System.debug('There was an error while inserting the PDF Fit to Lend Checklist ad an attachment');
            System.debug(ex.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while inserting a copy of the Fit to Lend Checklist'));
            return null; 
        }
        
        
        try
        {
            //Org Wide
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'xradocmanvalidations@barclayscapital.com'];

            //Blank list.
            List<Fit_To_Lend_Checklist__c> fitToLends = new List<Fit_To_Lend_Checklist__c>();

            //Get any contact for email template.  Never emailed...
            Id randomContactId = [SELECT Id FROM Contact WHERE Email != null LIMIT 1].Id;

            //Final list of all email messages for sending.
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            
            //Get the ids of the email template
            Id publicEmailTempateId     = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Public_Fit_to_Lend_Notification'].Id;
            Id privateEmailTempateId    = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Private_Fit_to_Lend_Notification'].Id;
            
            //Get the fit to lend records and notificiation groups.
            fitToLends = [
                SELECT 
                Id,
                Name,
                (
                    SELECT 
                    Id,
                    Distribution_Group__c,
                    Distribution_Group__r.Name,
                    Distribution_Group__r.Email_Address__c,
                    Distribution_Group__r.Group_Type__c
                    FROM Notification_Groups__r
                ),
                (
                    SELECT 
                    Id,
                    Email_Address__c,
                    Participant__c,
                    Participant__r.advpm__Role__c
                    FROM Notification_Participants__r
                )
                FROM Fit_To_Lend_Checklist__c
                WHERE
                Id = :fit2Lend.Id
            ];
            
            System.debug('### fitToLends : ' + fitToLends);
            
            if(fitToLends.size() > 0)
            {
                if(fitToLends[0].Notification_Groups__r.size() == 0  && fitToLends[0].Notification_Participants__r.size() == 0)
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please add at least one Notification Group(s) and/or Participants(s) before you can Notify them'));
                    return null;
                }
                else
                {                    
                    //Create the email attachment
                    Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                    emailAttachment.setFileName(fitToLendAttachment.Name);
                    emailAttachment.setBody(fitToLendAttachment.Body);
                    
                    //Loop through notification groups.
                    for(Notification_Group__c notifyGroup : fitToLends[0].Notification_Groups__r)
                    {
                        //Group email address.
                        List<String> toAddresses = new List<String> { notifyGroup.Distribution_Group__r.Email_Address__c };
                            System.debug('### toAddresses : ' + toAddresses);
                            
                        //Single email object.
                        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                        singleEmail.setTargetObjectId(randomContactId);
                        singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
                        singleEmail.setToAddresses(toAddresses);
                        singleEmail.setWhatId(fitToLends[0].Id);
                        if(owea.size() >0)
                        {
                            singleEmail.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        
                        
                        //Private
                        if(notifyGroup.Distribution_Group__r.Group_Type__c == 'Private')
                        {
                            singleEmail.setTemplateId(privateEmailTempateId);
                            
                            //Add file attachment.
                            singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                        }
                        //Public
                        else
                        {
                            singleEmail.setTemplateId(publicEmailTempateId); 
                        }
                        
                        //Add to list.
                        emailMessages.add(singleEmail);
                    }
                    
                    //Loop through participant notifications.
                    for(Notification_Participant__c notifyParticipant : fitToLends[0].Notification_Participants__r)
                    {
                        //Group email address.
                        List<String> toAddresses = new List<String> { notifyParticipant.Email_Address__c };
                            System.debug('### toAddresses : ' + toAddresses);
                            
                        //Single email object.
                        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                        singleEmail.setTargetObjectId(randomContactId);
                        singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
                        singleEmail.setToAddresses(toAddresses);
                        singleEmail.setWhatId(fitToLends[0].Id);
                        singleEmail.setTemplateId(privateEmailTempateId);
                        if(owea.size() >0)
                        {
                        	singleEmail.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        
                        //Add file attachment.
                        singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                        
                        //Add to list.
                        emailMessages.add(singleEmail);
                    }
                }
            }
            
            //Send emails.
            if(emailMessages.size() > 0)
            {
                System.debug('### emailMessages : ' + emailMessages);
                Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);
                fit2Lend.status__c = 'Completed';
        		fit2Lend.Notification_emails_sent__c = True;
                fit2Lend.Review_Checklist_Complete__c = True;
            }
        }catch(DMLException ex){
            System.debug('There was an error while sending Notifications Emails to Participants and Groups');
            System.debug(ex.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while sending Notifications Emails to Participants and Groups'));
			return null;
        }
        
        
        Savepoint sp = Database.setSavepoint();
                
        try{
            update fit2Lend;
        }catch(DMLException ex){
            System.debug('There was an error while updating the Status for a Fit to Lend record');
            System.debug(ex.getMessage());
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your Status could not be updated to Completed at this point'));
        }
        
        return pageRef;
        }
        
    }
}