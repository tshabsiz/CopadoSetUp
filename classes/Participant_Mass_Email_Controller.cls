/**

01/02/2018 - TdB -  Created class
01/02/2018 - TdB -  Limit Participants to Contacts only   
26/03/2018 - TdB -  Add getFromEmailAddressList() to set from email address  
17/09/2018 - TdB -  Remove debug statements and commented out code sections

**/ 

public with sharing class Participant_Mass_Email_Controller {
    
    public List<ParticipantWrapper> participantWrapperList { get; set; }
    public List<ParticipantWrapper> selectedparticipantWrapperList { get; set; }
    public List<advpm__Participant__c> existingParticipantList { get; set; }
    public Map<Id, String> relationshipMap { get; set; }
    public Set<String> roleSet { get; set; }
    public List<Id> selectedRelationshipId;
    public advpm__Participant__c participantRecord_temp { get; set; }
    public Set<Id> existingParticipantsSet { get; set; }
    public string selectedRoleValue { get;set; }
    public Id dealObjectId;
    public String emailSubject { get;set; } 
    public String emailBody { get;set; }
    public String fromEmailAddress { get;set; }
    public Boolean noError { get;set; }
    public List<RecordType> participantUserRecordTypeId;
    public String selectedFromAddress {set;get;}
    public Map<Id,Distribution_Group__c> distributionGroupMap;
    public List<ParticipantRelationshipWrapper> participantRelationshipWrapperList {set;get;}
    public Map<String, List<advpm__Participant__c>> accountParticipantMap;
    public SelectOption[] selectedRelationships{ get; set; }
    public SelectOption[] allRelationships { get; set; }
    public SelectOption[] selectedRoles{ get; set; }
    public SelectOption[] allRoles { get; set; }
    public String userSignature { get; set; }
    
    public Participant_Mass_Email_Controller()  
    {
        selectedRelationships = new List<SelectOption>();
        allRelationships = new List<SelectOption>();
        selectedRoles = new List<SelectOption>();
        allRoles = new List<SelectOption>();
        selectedRelationshipId = new List<Id>();
        accountParticipantMap = new Map<String, List<advpm__Participant__c>> ();
        existingParticipantList = new List<advpm__Participant__c> ();
        existingParticipantsSet = new Set<Id>();
        participantRecord_temp = new advpm__Participant__c ();
        distributionGroupMap = new Map<Id,Distribution_Group__c> ();
        noError = True;
        participantUserRecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Contact' AND SObjectType = 'advpm__Participant__c'];     
        
        //Get Record Id from URL
        if(ApexPages.currentPage().getParameters().get('Id') != null)
        {
            dealObjectId = Id.valueOf(ApexPages.currentPage().getParameters().get('Id'));
        }
        
        //Get Participants linked to the Deal (User/Contact)
        if(dealObjectId != null)
        {
            existingParticipantList = [SELECT Id, Name, advpm__Role__c , advpm__Matter__r.Name, advpm__Contact__c, advpm__Contact__r.AccountId, advpm__Contact__r.Account.Name,advpm__Contact__r.Email, Contacts_Email_Address__c 
                                       FROM advpm__Participant__c 
                                       WHERE advpm__Matter__c =: dealObjectId
                                       AND recordTypeId = :participantUserRecordTypeId[0].id
                                       AND advpm__Contact__r.Email != NULL
                                       ORDER BY advpm__Contact__r.Account.Name ASC];
            
            for(advpm__Participant__c eachParticipant : existingParticipantList)
            {
                String accountIdName_temp = eachParticipant.advpm__Contact__r.AccountId + '#_#' + eachParticipant.advpm__Contact__r.Account.Name;
                if(!accountParticipantMap.containsKey(accountIdName_temp))
                {
                    accountParticipantMap.put(accountIdName_temp, new List<advpm__Participant__c>());
                }
                
                if(accountParticipantMap.containsKey(accountIdName_temp))
                {
                    accountParticipantMap.get(accountIdName_temp).add(eachParticipant);
                }   
            }
            
            emailSubject = 'Matter: ' + existingParticipantList[0].advpm__Matter__r.Name + ' - ';
        }
        
        if(existingParticipantList.size() == 0 || existingParticipantList == null)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No Participants assigned to the Deal'));
            noError = False;
        }
        
        participantRecord_temp.RecordTypeId = participantUserRecordTypeId[0].id;
        
        initialiseWrapperList();     
        
        
        //Get logged in Users Signature
        List<User> currUser = [Select Id,Signature from User where Id=:userinfo.getuserId()];
        
        if(!currUser.isEmpty()) {
            userSignature = currUser[0].Signature;
            if (String.isNotBlank(userSignature)) {
                userSignature = userSignature.replace('\n','<br>');
                emailBody = ' <br> <br> ' +userSignature;
            } 
        } 
    }
    
    public void initialiseWrapperList()
    {
        participantWrapperList = new List<ParticipantWrapper>();
        relationshipMap = new Map<Id, String>();
        roleSet = new Set<String>();
        
        for(advpm__Participant__c eachParticipant : existingParticipantList)
        {
            ParticipantWrapper wrapperItem = new ParticipantWrapper();
            wrapperItem.participantRecord = eachParticipant;
            
            //Determine email address based on Contact 
            if (eachParticipant.advpm__Contact__c != null)
            {
                wrapperItem.participantEmail = eachParticipant.advpm__Contact__r.Email;
            }
            
            
            //Set selected as True
            if(existingParticipantsSet.contains(eachParticipant.Id))
            {
                wrapperItem.selected = true;   
            }
            
            //Add to main wrapper list.
            participantWrapperList.add(wrapperItem);
            
            //Add Relationship to Map
            relationshipMap.put(eachParticipant.advpm__Contact__r.AccountId, eachParticipant.advpm__Contact__r.Account.Name);
            
            //Add Roles to a Set
            roleSet.Add(eachParticipant.advpm__Role__c);
        }
        
        //Loop over relationship map and add to selectOption
        for(Id eachRelationship : relationshipMap.keySet())
        {
            allrelationships.add(new SelectOption(eachRelationship, relationshipMap.get(eachRelationship)));
        }
        
        //Loop over role map and add to selectOption
        for(String eachRole : roleSet)
        {
            allroles.add(new SelectOption(eachRole, eachRole));
        }
        
        //Populate participantRelationshipWrapper
        participantRelationshipWrapperList = new List<ParticipantRelationshipWrapper> ();
        for(String eachAccount : accountParticipantMap.keySet())
        {
            ParticipantRelationshipWrapper relationshipWrapperItem = new ParticipantRelationshipWrapper();
            List<ParticipantWrapper> participantWrapList = new List<ParticipantWrapper> ();
            
            //Split String to get AccountId and Name
            String[] arrSplit = eachAccount.split('#_#');
            relationshipWrapperItem.relationshipId = arrSplit[0]; 
            relationshipWrapperItem.relationshipName = arrSplit[1]; 
            
            for(advpm__Participant__c eachParticipant : accountParticipantMap.get(eachAccount))
            {
                ParticipantWrapper wrapperItem = new ParticipantWrapper();
                wrapperItem.participantRecord = eachParticipant;
                
                //Determine email address based on Contact 
                if (eachParticipant.advpm__Contact__c != null)
                {
                    wrapperItem.participantEmail = eachParticipant.advpm__Contact__r.Email;
                }
                
                //Set selected as True
                if(existingParticipantsSet.contains(eachParticipant.Id))
                {
                    wrapperItem.selected = true;   
                }
                
                participantWrapList.add(wrapperItem);
            }
            
            relationshipWrapperItem.participantWrapperList.addAll(participantWrapList) ;
            participantRelationshipWrapperList.add(relationshipWrapperItem);
        }   
    }
    
    public PageReference UpdateSearchResults()
    {
        updateParticipantList();
        
        return null;
    }
    
    public void updateParticipantList()
    {
        existingParticipantList = new List<advpm__Participant__c>();
        accountParticipantMap = new Map<String, List<advpm__Participant__c>> ();
        relationshipMap = new Map<Id, String>();
        Set<Id> relationshipsSetId = new Set<Id>();
        Set<String> roles_selected = new Set<String>();
        
        //Get all selected values for Relationship
        for ( SelectOption so : selectedRelationships )
        {
            relationshipsSetId.add(so.getValue());
        }
        
        //Get all selected values for Roles
        for ( SelectOption so : selectedRoles )
        {
            roles_selected.add(so.getValue());
        }
        
        //Update Participant list based on the Role filter selection only
        if(relationshipsSetId.isEmpty() && !roles_selected.isEmpty())
        {
            existingParticipantList = [SELECT Id, Name, advpm__Role__c , advpm__Contact__c, advpm__Contact__r.AccountId, advpm__Contact__r.Account.Name, advpm__Contact__r.Email, Contacts_Email_Address__c 
                                       FROM advpm__Participant__c 
                                       WHERE advpm__Matter__c =: dealObjectId
                                       AND advpm__Contact__r.Email != NULL
                                       AND advpm__Role__c IN :roles_selected
                                       AND recordTypeId = :participantUserRecordTypeId[0].id];
            
            if(existingParticipantList.size() == 0 || existingParticipantList == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Participant(s) assigned to the role(s) selected'));
            }
        }
        
        //Update Participant list based on the Relationship filter selection only
        else if(!relationshipsSetId.isEmpty() && roles_selected.isEmpty())
        {
            existingParticipantList = [SELECT Id, Name, advpm__Role__c , advpm__Contact__c, advpm__Contact__r.AccountId, advpm__Contact__r.Account.Name, advpm__Contact__r.Email, Contacts_Email_Address__c 
                                       FROM advpm__Participant__c 
                                       WHERE advpm__Matter__c =: dealObjectId
                                       AND advpm__Contact__r.Email != NULL 
                                       AND recordTypeId = :participantUserRecordTypeId[0].id
                                       AND advpm__Contact__r.AccountId IN :relationshipsSetId];
            
            if(existingParticipantList.size() == 0 || existingParticipantList == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Participant(s) assigned to the role(s) selected'));
            }
        }
        
        //Update Participant list based on the Role and Relationship filter selection
        else if(!relationshipsSetId.isEmpty() && !roles_selected.isEmpty())
        {
            existingParticipantList = [SELECT Id, Name, advpm__Role__c , advpm__Contact__c, advpm__Contact__r.AccountId, advpm__Contact__r.Account.Name, advpm__Contact__r.Email, Contacts_Email_Address__c 
                                       FROM advpm__Participant__c 
                                       WHERE advpm__Matter__c =: dealObjectId
                                       AND advpm__Contact__r.Email != NULL
                                       AND advpm__Role__c IN :roles_selected
                                       AND recordTypeId = :participantUserRecordTypeId[0].id
                                       AND advpm__Contact__r.AccountId IN :relationshipsSetId];
            
            if(existingParticipantList.size() == 0 || existingParticipantList == null)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Participant(s) assigned to the role(s) selected'));
            }
        }
        
        //Show all if no filter selected
        else
        {
            existingParticipantList = [SELECT Id, Name, advpm__Role__c , advpm__Contact__c, advpm__Contact__r.AccountId, advpm__Contact__r.Account.Name, advpm__Contact__r.Email, Contacts_Email_Address__c 
                                       FROM advpm__Participant__c 
                                       WHERE advpm__Matter__c =: dealObjectId
                                       AND recordTypeId = :participantUserRecordTypeId[0].id
                                       AND advpm__Contact__r.Email != NULL];
        }
        
        for(advpm__Participant__c eachParticipant : existingParticipantList)
        {
            String accountIdName_temp = eachParticipant.advpm__Contact__r.AccountId + '#_#' + eachParticipant.advpm__Contact__r.Account.Name;
            if(!accountParticipantMap.containsKey(accountIdName_temp))
            {
                accountParticipantMap.put(accountIdName_temp, new List<advpm__Participant__c>());
            }
            
            if(accountParticipantMap.containsKey(accountIdName_temp))
            {
                accountParticipantMap.get(accountIdName_temp).add(eachParticipant);
            }   
        }
        
        initialiseWrapperList();  
    }
    
    public PageReference NextPage() 
    {
        selectedparticipantWrapperList = new List<ParticipantWrapper>();
        
        
        for(ParticipantWrapper eachWrap : participantWrapperList)
        {
            if(eachWrap.selected == True)
            {
                selectedparticipantWrapperList.add(eachWrap);
            }
        }
        
        if(!selectedparticipantWrapperList.isEmpty())
        {
            //New Page Setup
            PageReference standardPage = new PageReference('/apex/Participant_Mass_Email'); 
            
            //Redirect.
            return standardPage;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No Participant(s) select, please ensure that atleast one Participant is selected'));
            return null;
        }
    }
    
    public List<SelectOption> getFromEmailAddressList()
    {
        //Get all Distribution Group
        List<Distribution_Group__c> distributionGroupList = new List<Distribution_Group__c>();
        List<SelectOption> emailAddressOptionList = new List<SelectOption>();
        
        distributionGroupMap = new Map<Id,Distribution_Group__c> ();
        distributionGroupList = [SELECT Id, Name, Email_Address__c FROM Distribution_Group__c];
        emailAddressOptionList.add(new SelectOption(UserInfo.getUserId() ,UserInfo.getName() + '  <' + UserInfo.getUserEmail() + '>'));
        for(Distribution_Group__c eachGroup : distributionGroupList )
        {
            emailAddressOptionList.add(new SelectOption(eachGroup.Id , eachGroup.Name + '  <' + eachGroup.Email_Address__c + '>'));
            distributionGroupMap.put(eachGroup.Id, eachGroup);
        }
        
        return emailAddressOptionList ;
    }
    
    public PageReference SendEmail() 
    { 
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<String> addresses = new List<String>(); 
        
        //Check for Subject and set email subject
        if(emailSubject != null)
        {
            singleEmail.setSubject(emailSubject);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Subject is required'));
            return null;
        }
        
        //Check for Body and set email body
        if(emailBody != null)
        {
            singleEmail.setHTMLBody(emailBody);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Body is required'));
            return null;
        }
        
        //Set email fields
        singleEmail.setTargetObjectId(null);
        singleEmail.setTreatTargetObjectAsRecipient(false); 
        //Link to deal to create email record
        singleEmail.setWhatId(dealObjectId);
        singleEmail.setUseSignature(false); 
        
        for(ParticipantWrapper eachselectedWrapper : selectedparticipantWrapperList)
        {
            addresses.add(eachselectedWrapper.participantEmail);
        }
        
        singleEmail.setBccAddresses(addresses);
        if(distributionGroupMap.containsKey(selectedFromAddress))
        {
            singleEmail.setReplyTo(distributionGroupMap.get(selectedFromAddress).Email_Address__c);
            singleEmail.setSenderDisplayName(distributionGroupMap.get(selectedFromAddress).Name);
        }
        emailMessages.add(singleEmail);
        
        try{
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e) ; 
            return null;
        }
        
        //New Page Setup
        PageReference standardPage = new PageReference('/' + dealObjectId); 
        standardPage.setRedirect(true);
        
        //Redirect.
        return standardPage;
    }
    
    public PageReference Cancel()
    {
        pagereference parentPage= new pagereference('/'+ dealObjectId );
        parentPage.setRedirect(true);
        return parentPage;
    }
    
    public class ParticipantWrapper
    {
        public Boolean selected { get; set; }
        public String participantEmail { get; set; }
        public advpm__Participant__c participantRecord { get; set; }
        
        //Blank constructor.
        public ParticipantWrapper() {
            selected = true;  
        }
    }
    
    public class ParticipantRelationshipWrapper
    {
        public Id relationshipId { get; set; }
        public String relationshipName { get; set; }
        public List<ParticipantWrapper> participantWrapperList { get; set; }
        
        //Blank constructor.
        public ParticipantRelationshipWrapper() {
            participantWrapperList = new List<ParticipantWrapper>();
        }
    }
}