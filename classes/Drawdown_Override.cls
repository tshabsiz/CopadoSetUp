/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 10/06/2017 - PG    - Created Class. 
 27/06/2017 - PG    - Added "Borrower" field to SOQL.
 18/07/2017 - PG    - Removed try catch in saveRecord method.
 18/08/2017 - PG    - Added logic to default "Borrower" if there is only 1 agreement party.
 05/09/2017 - PG    - Added record type vars.
 06/09/2017 - PG    - Added methods "populateBankDetails" and "actionUpdateBankDetails".
                    - Added methods "buildLendersWrapper".
                    - Updated "saveRecord" method to handle agency.
                    - Added LenderWrapper wrapper class.
 09/08/2017 - PG    - Added update record in saveRecord method.
                    - Added Page Messge if currency is not found. 
 10/08/2017 - PG    - Added "Payment_Expected__c" field.
 21/09/2017 - PG    - Added logic to clear fields when it is a "clone" action.
 28/09/2017 - PG    - Added "NOTI_PARTICIPANT_TYPES" and "NOTI_GROUP_TYPES" constants
 08/11/2017 - TdB   - Add Facility and Facility Tranche fields based on where you create the Drawdown from
 14/11/2017 - TdB   - Make sure that lowest Parent Limit (Agreement/Facility/Tranche) is not exceeded when creating a Drawdown
 14/12/2017 - TdB   - Add default limit amount based on the agreement, facility and tranche limit
 15/01/2017 - TdB   - Add 0% if no lenderPortion.Responsible_Percentage__c defined
 17/01/2018 - TdB   - Add default values for Drawdown clone (Support documentation and status)
 27/01/2018 - TdB  - Comment out the code that validate all drawdown limits
 09/03/2018 - TdB   - Add Warning message when lender portion less that 100%
 12/03/2018 - TdB   - Agreement Limit optional (prevent Users from creating Drawdown and Agency with no Agreement Limit) 
 15/03/2018 - TdB	- Add Lender Portion approval process and validation for Drawdown Agency
 17/03/2018 - TdB	- Add Limit exceed approval process and validation for 	Drawdown Normal
 17/03/2018 - TdB	- Agency Drawdown lender portion change - Change Approval to go to Head
 01/08/2018 - TdB	- Remove commeneted code
**/   
public class Drawdown_Override   
{
    /**
    * Variables
    **/
    public static Map <String, Schema.RecordTypeInfo> lenderPortion_RecordTypes = Lender_Portion__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static final Map <String, Schema.RecordTypeInfo> recordTypes = Drawdown__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    private static final Map <String, Schema.RecordTypeInfo> lookupTypes = Lookup__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static final Map <String, Schema.RecordTypeInfo> NOTI_PARTICIPANT_TYPES = Notification_Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    private static final Map <String, Schema.RecordTypeInfo> NOTI_GROUP_TYPES = Notification_Group__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    private static final Map<String, Schema.RecordTypeInfo> APPROVAL_TYPES =  Approval__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public Drawdown__c drawdownObject { get; set; }
    public List<ParticipantWrapper> participantsWrapper { get; set; }
    public List<DistroGroupWrapper> distroGroupsWrapper { get; set; }
    public List<sObject> parties { get; set; }
    public List<Lender_Portion__c> existingLenderPortions { get; set; } 
    public Id matterId { get; set; }
    public List<LenderWrapper> lendersWrapper { get; set; }
    private Map<String, Lookup__c> bankDetailsMap { get; set; }
    public Boolean hideSave { get; set; }
    public String selectedCurrency { get; set; }
    public Integer borrowerCount;
    public Id borrowerId;
    public Decimal totalLenderPortionPercentage;
    public Decimal totalLenderPortionPercentage_New;
    public Boolean limitSpecified;
    public Boolean exceedingLimit { get; set; }
    public Boolean triggerLenderPortionChange { get; set; }
    public Decimal parentLimit { get; set; }
    
    /**
    * Constructor
    **/
    public Drawdown_Override(ApexPages.StandardController stdController)
    {   
        System.debug('### Drawdown_Override');

        //Blank variables.
        List<advpm__Participant__c> participants = new List<advpm__Participant__c>();
        List<Distribution_Group__c> distroGroups = new List<Distribution_Group__c>();
        borrowerCount = 0;
        borrowerId = null;
        existingLenderPortions = new List<Lender_Portion__c>();
        bankDetailsMap = new Map<String, Lookup__c>(); 
        limitSpecified = True;
        exceedingLimit = False;
        triggerLenderPortionChange = False;
        parentLimit = 0;
        
        //Empty wrappers
        participantsWrapper = new List<ParticipantWrapper>();
        distroGroupsWrapper = new List<DistroGroupWrapper>();
        
        List<String> fields = new List<String>
        {
            //Drawdown Detail
            'Id',
            'Name',
            'CurrencyISOCode',
            'Agreement__c', 
            'Agreement_Type__c',
            'Payment_Expected__c',
            'Deal__c',
            'Relationship__c', 
            'Borrower__c',
            'Facility__c',
            'Facility_Tranche__c',
            'Status__c',
            'Interest_Period__c',
            'Period__c',
            'Interest_Type__c',
            'Our_Portion__c',
            'Advance_Amount__c',
            'Current_Utilisation__c',
            'Facility_Limit__c',
            'Supporting_Documentation_Uploaded__c',
            //Account Details
            'Account_Name__c',
            'Account_Bank__c',
            'SWIFT_ID__c',
            'Account_Number__c',
            'Account_Branch__c',
            'Reference__c',
            //Dates
            'Advance_Date__c',
            'Request_Date__c',
            'Agent_Notice_Date__c',
            'Lender_Portion_Changed__c',
            'Approval_Status__c'
        };

        if(!Test.isRunningTest())
        {
            //Add fields
            stdController.addFields(fields);
        }
        
        //Get the page record.
        this.drawdownObject = (Drawdown__c)stdController.getRecord();
        
        allLenderParties();
         
        System.debug('drawdownObject.CurrencyISOCode' + drawdownObject.CurrencyISOCode);

        //If this is a "clone" ation, then we need to clear some fields.
        if(ApexPages.currentPage().getParameters().get('clone') == '1')
        {
            //Clear Id.
            drawdownObject.Id = null;

            //Amounts
            drawdownObject.Current_Utilisation__c = null;
            drawdownObject.Advance_Amount__c = null;

            //Dates
            drawdownObject.Advance_Date__c = null;
            drawdownObject.Request_Date__c = null;
            drawdownObject.Payment_Expected__c = null;
            drawdownObject.Agent_Notice_Date__c = null; 
            drawdownObject.Approval_Status__c = null;
            drawdownObject.Lender_Portion_Changed__c = False;
            
            //drawdownObject.Status__c = 'Governance and Documentation Check Incomplete';
            drawdownObject.Supporting_Documentation_Uploaded__c = False;
        }

        //If there is an agreement associated.
        if(!String.isBlank(drawdownObject.Agreement__c))
        {
            System.debug('### Drawdown_Override : Has Agreement');

            //Get the agreements matter / deal.
            matterId = [SELECT Matter_Deal__c FROM Agreement__c WHERE Id = :drawdownObject.Agreement__c].Matter_Deal__c; 
        
            //Populate participants on Deal.
            participants = [
                SELECT 
                    Id, 
                    Name,
                    advpm__Matter__c, //Deal
                    advpm__Staff__c,
                    advpm__Staff__r.Email,
                    advpm__Role__c
                FROM advpm__Participant__c
                WHERE
                    advpm__Matter__c = :matterId
                    AND advpm__Staff__c != null
            ];

            System.debug('### Drawdown_Override : participants : '+participants);

            //Detemine if we can default the "borrower" if only 1 party.
            if(borrowerCount == 1)
            {
                drawdownObject.Borrower__c = borrowerId;
            }
        }
        
        //NORMAL RECORD TYPE
        if(drawdownObject.RecordTypeId == recordTypes.get('Drawdown').getRecordTypeId())
        {
            //Build participants wrapper
            for(advpm__Participant__c participant : participants)
            {
                ParticipantWrapper pWrapper = new ParticipantWrapper();
                pWrapper.selected = false;
                pWrapper.participant = participant;
                
                //Add to wrapper list.
                participantsWrapper.add(pWrapper);
            }
            
            //Get distrubution groups.
            distroGroups = [
                SELECT 
                    Id, 
                    Name,
                    Description__c,
                    Email_Address__c,
                    Group_Type__c
                FROM Distribution_Group__c
            ];
            
            //Build distrubution wrapper
            for(Distribution_Group__c distroGroup : distroGroups)
            {
                DistroGroupWrapper dWrapper = new DistroGroupWrapper();
                dWrapper.selected = false;
                dWrapper.distroGroup = distroGroup;
                
                //Add to wrapper list.
                distroGroupsWrapper.add(dWrapper);
            }
        }

        //AGENCY RECORD TYPE
        if(drawdownObject.RecordTypeId == recordTypes.get('Drawdown - Agency').getRecordTypeId())
        {
            System.debug('### Drawdown_Override : Drawdown - Agency');

            //Build initial wrapper.
            buildLendersWrapper();

            //Get agency bank detail record type id.
            Id bankDetailTypeId = lookupTypes.get('Agency Bank Detail').getRecordTypeId();

            //Blank list.
            List<Lookup__c> agencyBankDetails = new List<Lookup__c>();

            //Get the bank details in the system.
            agencyBankDetails = [
                SELECT
                    Id,
                    Active__c,
                    CurrencyISOCode,
                    Account_Branch__c,
                    Account_Name__c,
                    Account_Number__c,
                    Account_Bank__c
                FROM Lookup__c
                WHERE 
                    Active__c = true
                    AND RecordTypeId = :bankDetailTypeId
            ];

            //Got records.
            if(!agencyBankDetails.isEmpty())
            {
                for(Lookup__c bankDetail : agencyBankDetails)
                {
                    //Add to map.
                    bankDetailsMap.put(bankDetail.CurrencyISOCode, bankDetail); 
                }
            }

            //Set the default bank details.
            populateBankDetails();
        }
    }
    
    /**
    * acton - Save record and selections.
    **/
    public pageReference saveRecord()
    {
        System.debug('### Drawdown_Override : saveRecord');
        
        Decimal drawdownLimit = 0.00;
        String dynamicDrawDownQuery = '';
        String dynamicTotalDrawDownQuery = '';
        List<sObject> sObjectLimitRecord = new List<sObject>();
        List<AggregateResult> dynamicTotalDrawDown;
            
        //Logic to prompt the User link Drawdown to a Facility if Agreement is link to a Facility
        if(drawdownObject.Facility__c == null && [SELECT Id FROM Facility__c WHERE Agreement__c =: drawdownObject.Agreement__c].size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is Facilities linked to the Agreement, please select a Facility'));   
            return null;
        }
           
        //Logic to prompt the User link Drawdown to a Facility Tranche if Facility is link to a Facility Tranche
        if(drawdownObject.Facility_Tranche__c == null && drawdownObject.Facility__c != null && [SELECT Id FROM Facility_Tranche__c WHERE Facility__c =: drawdownObject.Facility__c].size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is Facilities Tranches linked to the Facility, please select a Facilities Tranche'));   
            return null;
        }
        
        if(drawdownObject.Facility_Limit__c != null)
        {
            drawdownLimit = drawdownObject.Facility_Limit__c;
        }
        
        try 
        {
            totalLenderPortionPercentage_New = 0;
            
            for(LenderWrapper lenderWrapper : lendersWrapper)
            {
                //"New" amount captured,update new percentage
                if(drawdownObject.Advance_Amount__c != null && lenderWrapper.record.Committed_Responsible_Amount__c != null)
                {
                    lenderWrapper.record.Committed_Responsible_Percentage__c = (lenderWrapper.record.Committed_Responsible_Amount__c / drawdownObject.Advance_Amount__c) * 100;
                }
                //"New" percentage captured,update new amount
                else if(drawdownObject.Advance_Amount__c != null && lenderWrapper.record.Committed_Responsible_Percentage__c != null)
                {
                    lenderWrapper.record.Committed_Responsible_Amount__c = drawdownObject.Advance_Amount__c * (lenderWrapper.record.Committed_Responsible_Percentage__c / 100);
                }
                //Else default to 0
                else
                {
                    lenderWrapper.record.Committed_Responsible_Percentage__c = 0;
                }
                
                totalLenderPortionPercentage_New = totalLenderPortionPercentage_New + lenderWrapper.record.Committed_Responsible_Percentage__c;
            }
            
            //Display error if Lender Portion percentage more than 100
            if(totalLenderPortionPercentage_New > 100)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'The Total Lender Portion cannot exceed 100%'));
                return null;
            }
            
            if(!Test.isRunningTest()){
                if(drawdownObject.Id == null)
                {
                    //Insert paretn object.
                    insert drawdownObject;
                }
                else
                {
                    update drawdownObject;
                }
            }

            //NORMAL RECORD TYPE
            if(drawdownObject.RecordTypeId == recordTypes.get('Drawdown').getRecordTypeId())
            {
                List<Notification_Group__c> notificationGroups = new List<Notification_Group__c>();
                List<Notification_Participant__c> notificationParticipants = new List<Notification_Participant__c>();
                
                //If Normal drawdown limit exceeded, get TL and TH (based on Role Hierachy) to create approval records
                if(exceedingLimit == True)
                {
                    Approval__c  approvalRecord = new Approval__c();
                    UserRole loggedInUserRole =  new UserRole();
                    UserRole teamLeaderRole =  new UserRole();
                    List<User> approvalUsers = new List<User>();
                    
                    //Get TL and TH Roles with Users in that Role
                    if(UserInfo.getUserRoleId() != null)
                    {
                        loggedInUserRole = [SELECT ParentRoleId, Name, Id FROM UserRole WHERE Id=:UserInfo.getUserRoleId()];
                        teamLeaderRole = [SELECT ParentRoleId, Name, Id FROM UserRole WHERE Id=:loggedInUserRole.ParentRoleId];
                        approvalUsers = [SELECT Id, Name, UserRoleId FROM User WHERE (UserRoleId =:loggedInUserRole.ParentRoleId OR UserRoleId =:teamLeaderRole.ParentRoleId) AND isActive = True AND Profile.UserLicense.LicenseDefinitionKey = 'SFDC'];
                    }
                    //Display error message if no Role on logged in User record specified
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Logged in User have no Role specified on his/her User Record'));
                        return null;
                    }
                    
                    if(!approvalUsers.isEmpty())
                    {
                        if(drawdownObject.Approval_Status__c == 'New' || drawdownObject.Approval_Status__c == null)
                        {
                            for(User eachApprover : approvalUsers)
                            {
                                //Create Approval record
                                approvalRecord =  new Approval__c
                                    (
                                        DrawDown__c = drawdownObject.Id,
                                        Agreement__c = drawdownObject.Agreement__c,
                                        RecordTypeID = APPROVAL_TYPES.get('Drawdown Approval').getRecordTypeId(),
                                        Status__c = 'New',
                                        Reviewer__c = eachApprover.id,
                                        Requestor__c = UserInfo.getUserId()
                                    );
                                
                                insert approvalRecord;
                                
                                //Submit for Approval 
                                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                                req1.setObjectId(approvalRecord.id);
                                req1.setNextApproverIds(new Id[] {eachApprover.id});
                                Approval.ProcessResult result = Approval.process(req1);
                            }
                        }
                    }
                    //Display error message if no active Users in the TL or TH Roles
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Drawdown cannot be submitted for approval without a Team Leader and Team Head, please contact Salesforce Administrator'));
                        return null;
                    }
                }
                
                //Get all selected participants.
                for(ParticipantWrapper participantWrapper : participantsWrapper)
                {
                    //Selected?
                    if(participantWrapper.selected)
                    {
                        //New Notification_Participant__c 
                        Notification_Participant__c pNotification = new Notification_Participant__c();
                        pNotification.Participant__c = participantWrapper.participant.Id;
                        pNotification.Drawdown__c = drawdownObject.Id;
                        pNotification.RecordTypeId = NOTI_PARTICIPANT_TYPES.get('Drawdown').getRecordTypeId();
                        
                        //Add to insert list.
                        notificationParticipants.add(pNotification);
                    }
                }
            
                //Get all selected dsitro group.
                for(DistroGroupWrapper distroGroupWrapper : distroGroupsWrapper)
                {
                    //Selected?
                    if(distroGroupWrapper.selected)
                    {
                        //New Notification_Participant__c 
                        Notification_Group__c gNotification = new Notification_Group__c();
                        gNotification.Distribution_Group__c = distroGroupWrapper.distroGroup.Id;
                        gNotification.Drawdown__c = drawdownObject.Id;
                        gNotification.RecordTypeId = NOTI_GROUP_TYPES.get('Drawdown').getRecordTypeId();
                        
                        //Add to insert list.
                        notificationGroups.add(gNotification);
                    }
                }
            
                //Insert notification records for both objects.
                if(!notificationParticipants.isEmpty())
                {
                    insert notificationParticipants;
                }
                
                if(!notificationGroups.isEmpty())
                {
                    insert notificationGroups;
                }
            }

            //AGENCY RECORD TYPE
            if(drawdownObject.RecordTypeId == recordTypes.get('Drawdown - Agency').getRecordTypeId())
            {
                totalLenderPortionPercentage_New = 0;
                System.debug('### Drawdown_Override : saveRecord : AGENCY'); 

                if(!bankDetailsMap.containsKey(drawdownObject.CurrencyISOCode))
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There are no banking details defined for this currency.   Please contact your system administrator for assistance.');
                    ApexPages.addMessage(myMsg);
                    return null;
                }

                List<Lender_Portion__c> upsertLenderPortions = new List<Lender_Portion__c>();

                if(!lendersWrapper.isEmpty())
                {
                    for(LenderWrapper lenderWrapper : lendersWrapper)
                    {
                        //Set drawdown on new record.
                        if(lenderWrapper.record.Id == null)
                        {
                            lenderWrapper.record.Drawdown__c = drawdownObject.Id; 
                        }
                        
                        //Add to upsert list.
                        upsertLenderPortions.add(lenderWrapper.record);
                    }
                }

                System.debug('### Drawdown_Override : saveRecord : upsertLenderPortions : '+upsertLenderPortions); 

                //Upsert the records.
                upsert upsertLenderPortions;      
            }
            
            //New Page Setup
            PageReference standardPage = new PageReference('/'+drawdownObject.Id); 
            standardPage.setRedirect(true);
            
            //Redirect.
            return standardPage; 
        }
        catch(Exception e)
        {
            //Show page error.
            ApexPages.addMessages(e);
            return null;
        }        
    }
    
    //Save Drawdown and submite for approval - Only applicable for Agency Drawdowns
    public pageReference saveAndSubmitRecord()
    {
        Approval__c  approvalRecord = new Approval__c();
        UserRole loggedInUserRole =  new UserRole();
        UserRole teamLeaderRole =  new UserRole();
        List<User> teamHeadList = new List<User>();
        
        //Get active User in Team Head Role (Based on Role Hierachy)
        if(UserInfo.getUserRoleId() != null)
        {
            loggedInUserRole = [SELECT ParentRoleId, Name, Id FROM UserRole u WHERE u.Id=:UserInfo.getUserRoleId()];
            if(loggedInUserRole.ParentRoleId != null)
            {
                teamLeaderRole = [SELECT ParentRoleId, Name, Id FROM UserRole WHERE Id=:loggedInUserRole.ParentRoleId];
                
                if(teamLeaderRole.ParentRoleId != null)
                {
                    teamHeadList = [SELECT Id, Name, UserRoleId FROM User WHERE UserRoleId =:teamLeaderRole.ParentRoleId AND isActive = True AND Profile.UserLicense.LicenseDefinitionKey = 'SFDC'];
                }
            }
            else
            {
                teamHeadList = [SELECT Id, Name, UserRoleId FROM User WHERE Id=:UserInfo.getUserId()];
            }
        }
        //Display error if no Role specified on logged in User record
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Logged in User have no Role specified on his/her User Record'));
            return null;
        }
        
        if(!teamHeadList.isEmpty())
        {
            Try{
                saveRecord();
                
                if(drawdownObject.Approval_Status__c == 'New' || drawdownObject.Approval_Status__c == null)
                {
                    Try{
                        for(User eachApprover : teamHeadList)
                        {
                            //Create Approval record
                            approvalRecord =  new Approval__c
                                (
                                    DrawDown__c = drawdownObject.Id,
                                    Agreement__c = drawdownObject.Agreement__c,
                                    RecordTypeID = APPROVAL_TYPES.get('Drawdown Approval').getRecordTypeId(),
                                    Status__c = 'New',
                                    Reviewer__c = eachApprover.id,
                                    Requestor__c = UserInfo.getUserId()
                                );
                            
                            insert approvalRecord;
                            //Submit for Approval 
                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                            req1.setObjectId(approvalRecord.id);
                            req1.setNextApproverIds(new Id[] {eachApprover.id});
                            Approval.ProcessResult result = Approval.process(req1);
                        }
                    }
                    catch(Exception e)
                    {
                        //Show page error.
                        ApexPages.addMessages(e);
                        return null;
                    }  
                }
            }
            catch(Exception e)
            {
                //Show page error.
                ApexPages.addMessages(e);
                return null;
            }  
        }
        //If no active user in TL Role, display error
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Lender Portion cannot be submitted for approval without a Team Leader'));
                return null;
            }
        
        if(drawdownObject.Id != null)
        {
            //New Page Setup
            PageReference standardPage = new PageReference('/'+drawdownObject.Id); 
            standardPage.setRedirect(true);
            
            //Redirect.
            return standardPage; 
        }
        else
        {
            return null;
        }
        
    }


    public PageReference actionUpdateLenders()
    {
        System.debug('### Drawdown_Override : actionUpdateLenders');
        totalLenderPortionPercentage = 0;
        //Loop through list.
        for(LenderWrapper lenderWrapper : lendersWrapper)
        {
            if(drawdownObject.Advance_Amount__c != null)
            {
            	lenderWrapper.record.Responsible_Amount__c = drawdownObject.Advance_Amount__c * (lenderWrapper.record.Responsible_Percentage__c / 100); 
            }
        }
        
        return null;
    }
    
   
    public void allLenderParties()
    {
        parties = new List<sObject>();
        existingLenderPortions = new List<Lender_Portion__c>();   
        lendersWrapper = new List<LenderWrapper>();  
        borrowerCount = 0;
        borrowerId = null;
        limitSpecified = True;
        
        Facility__c facilityRecord;
        Agreement__c agreementRecord;
        Facility_Tranche__c facilityTrancheRecord;
        
        //Create Drawdown from Facility Tranches Level
         if(drawdownObject.Facility_Tranche__c != null)
        {
            facilityTrancheRecord = [SELECT id,  CurrencyISOCode, Tranche_Limit__c, Facility__c, Facility__r.Agreement__c
                         FROM  Facility_Tranche__c
                         WHERE id = : drawdownObject.Facility_Tranche__c
                         LIMIT 1];
            
            drawdownObject.CurrencyISOCode = facilityTrancheRecord.CurrencyISOCode;
            parentLimit = facilityTrancheRecord.Tranche_Limit__c;
            if(drawdownObject.Agreement__c == null)
            {
                drawdownObject.Facility__c = facilityTrancheRecord.Facility__c;
                drawdownObject.Agreement__c = facilityTrancheRecord.Facility__r.Agreement__c;
            }
            
            If(facilityTrancheRecord.Tranche_Limit__c == null || facilityTrancheRecord.Tranche_Limit__c == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'You are not allowed to create a Drawdown without specifying a Tranche Limit'));
              limitSpecified = False;
            }

            if(drawdownObject.Facility_Limit__c == null)
            {
                drawdownObject.Facility_Limit__c = facilityTrancheRecord.Tranche_Limit__c;
            }
            
            //Get all the facility tranche parties for the associated facility tranche.
            parties = [
                SELECT
                    Id,
                    Name,
                    Facility_Tranche__c,
                    Party_Type__c,
                    Facility_Percentage__c 
                FROM Tranche_Party__c
                WHERE
                    Facility_Tranche__c = :drawdownObject.Facility_Tranche__c
            ];

            System.debug('### Drawdown_Override : trancheParties : '+parties);
   
        }
         //Create Drawdown from Facility Level
        else if(drawdownObject.Facility__c != null)
        {
            facilityRecord = [SELECT id, Agreement__c, CurrencyISOCode,Facility_Limit__c
                         FROM Facility__c
                         WHERE id = : drawdownObject.Facility__c
                         LIMIT 1];
            drawdownObject.CurrencyISOCode = facilityRecord.CurrencyISOCode;
            parentLimit = facilityRecord.Facility_Limit__c;
            if(drawdownObject.Agreement__c == null)
            {
                drawdownObject.Agreement__c = facilityRecord.Agreement__c;
            }
            
            If(facilityRecord.Facility_Limit__c == null || facilityRecord.Facility_Limit__c == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'You are not allowed to create a Drawdown without specifying a Facility Limit'));
              limitSpecified = False;
            }

            if(drawdownObject.Facility_Limit__c == null)
            {
                drawdownObject.Facility_Limit__c = facilityRecord.Facility_Limit__c;
            }

            //Get all the facility parties for the associated facility.
            parties = [
                SELECT
                    Id,
                    Name,
                    Facility__c,
                    Agreement_Party__r.Relationship__c,
                    Party_Type__c,
                    Facility_Percentage__c 
                FROM Facility_Party__c
                WHERE
                    Facility__c = :drawdownObject.Facility__c
            ];

            System.debug('### Drawdown_Override : facilityParties : '+parties);
  
        }
        //Create Drawdown from Agreement Level
        else if(drawdownObject.Agreement__c != null )
        {
            agreementRecord = [SELECT Id, Limit__c, CurrencyISOCode
                              FROM Agreement__c
                              WHERE Id = : drawdownObject.Agreement__c
                              LIMIT 1];
            drawdownObject.CurrencyISOCode = agreementRecord.CurrencyISOCode;
            parentLimit = agreementRecord.Limit__c;
            If(agreementRecord.Limit__c == null || agreementRecord.Limit__c == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'You are not allowed to create a Drawdown without specifying a Agreement Limit'));
              limitSpecified = False;
            }
            else
            {
              drawdownObject.Facility_Limit__c = agreementRecord.Limit__c;
            }

            //Get all the agreement parties for the associated agreement.
            parties = [
                SELECT
                    Id,
                    Name,
                    Agreement__c,
                    Relationship__c,
                    Party_Type__c,
                    Lender_Percentage__c 
                FROM Agreement_Party__c
                WHERE
                    Agreement__c = :drawdownObject.Agreement__c
            ];

            System.debug('### Drawdown_Override : agreementParties : '+parties);

            //Any agreement parties?
            if(!parties.isEmpty())
            {

                for(sObject agreementParty : parties)
                {
                    if(agreementParty.get('Party_Type__c') == 'Borrower')
                    {
                        borrowerId = agreementParty.Id;
                        borrowerCount++;
                    }
                }
            }
        }
        
        //Only if this is an existing drawdown, ie. Edit
            if(drawdownObject.Id != null)
            {
                //Get existing Lender portions
                existingLenderPortions = [
                    SELECT
                        Id,
                        Drawdown__c,
                        Agreement_Party__c,
                        Facility_Party__c,
                        Tranche_Party__c,
                        Responsible_Percentage__c,
                    	Committed_Responsible_Percentage__c,
                    	Committed_Responsible_Amount__c,
                        Responsible_Amount__c,
                        CurrencyISOCode
                    FROM Lender_Portion__c 
                    WHERE
                        Drawdown__c = :drawdownObject.Id
                ];
            }        
    }
    
     public PageReference actionUpdateLenderParties()
    {
        allLenderParties();
        buildLendersWrapper();

        //Loop through list.
        for(LenderWrapper lenderWrapper : lendersWrapper)
        {
            //Calculate Responsible Amount
            if(drawdownObject.Advance_Amount__c == null)
            {
                lenderWrapper.record.Responsible_Amount__c = 0;
            }
            else
            {
                lenderWrapper.record.Responsible_Amount__c = drawdownObject.Advance_Amount__c * (lenderWrapper.record.Responsible_Percentage__c / 100); 
                lenderWrapper.record.Committed_Responsible_Amount__c = drawdownObject.Advance_Amount__c * (lenderWrapper.record.Responsible_Percentage__c / 100); 
            }
        }
            return null;        
    }
    

    public void buildLendersWrapper()
    {
        System.debug('### Drawdown_Override : buildLendersWrapper'); 

        //Track existing agreement parties.
        Set<Id> partyIds = new Set<Id>();
    	totalLenderPortionPercentage = 0;
        
        //Loop through existing Lender Portions
        for(Lender_Portion__c lenderPortion : existingLenderPortions)
        {
            //New wrapper item.
            LenderWrapper wrapperItem = new LenderWrapper();
            wrapperItem.record = lenderPortion;
      
            //Add to wrapper list.
            lendersWrapper.add(wrapperItem);

            //Add to set for tracking
            if(lenderPortion.Tranche_Party__c != null)
            {
                 partyIds.add(lenderPortion.Tranche_Party__c);
            }
            else if(lenderPortion.Facility_Party__c != null)
            {
                partyIds.add(lenderPortion.Facility_Party__c);
            }
            else if(lenderPortion.Agreement_Party__c != null)
            {
                 partyIds.add(lenderPortion.Agreement_Party__c);
            }
           
        }

        //Loop through parties to see if they exist or not.
        for(sObject eachParty : parties)
        {
            String partyTypeName = eachParty.getSObjectType().getDescribe().getName();
            System.debug('partyTypeName : ' + partyTypeName);
            
            if(!partyIds.contains((Id)eachParty.get('Id')) && eachParty.get('Party_Type__c') == 'Lender')
            {
                //New Lender Portion Record
                Lender_Portion__c lenderPortion = new Lender_Portion__c();
                lenderPortion.Drawdown__c = drawdownObject.Id;
                
                //Tranche Party
                if(partyTypeName == 'Tranche_Party__c')
                {
                    lenderPortion.Tranche_Party__c = (Id)eachParty.get('Id');
                    lenderPortion.RecordTypeId = lenderPortion_RecordTypes.get('Lender Portion Tranche').getRecordTypeId();
                    
                    //Set Responsible Percentage
                    if(eachParty.get('Facility_Percentage__c') == null || String.isBlank(String.valueOf(eachParty.get('Facility_Percentage__c'))))
                    {
                        lenderPortion.Responsible_Percentage__c = 0;
                        lenderPortion.Committed_Responsible_Percentage__c = 0;
                    }
                    else
                    {
                        lenderPortion.Responsible_Percentage__c = (Decimal)eachParty.get('Facility_Percentage__c') ;
                        lenderPortion.Committed_Responsible_Percentage__c = (Decimal)eachParty.get('Facility_Percentage__c') ;
                    }
                }
                //Facility Party
                else if(partyTypeName == 'Facility_Party__c')
                {
                    lenderPortion.Facility_Party__c = (Id)eachParty.get('Id');
                    lenderPortion.RecordTypeId = lenderPortion_RecordTypes.get('Lender Portion Facility').getRecordTypeId();
                    
                    //Set Responsible Percentage
                    if(eachParty.get('Facility_Percentage__c') == null || String.isBlank(String.valueOf(eachParty.get('Facility_Percentage__c'))))
                    {
                        lenderPortion.Responsible_Percentage__c = 0;
                        lenderPortion.Committed_Responsible_Percentage__c = 0;
                    }
                    else
                    {
                        lenderPortion.Responsible_Percentage__c = (Decimal)eachParty.get('Facility_Percentage__c') ;
                        lenderPortion.Committed_Responsible_Percentage__c = (Decimal)eachParty.get('Facility_Percentage__c') ;
                    }
                }
                //Agreement Party
                else if(partyTypeName == 'Agreement_Party__c')
                {
                    lenderPortion.Agreement_Party__c = (Id)eachParty.get('Id');
                    lenderPortion.RecordTypeId = lenderPortion_RecordTypes.get('Lender Portion Agreement').getRecordTypeId();
                    
                    //Set Responsible Percentage
                    if(eachParty.get('Lender_Percentage__c') == null || String.isBlank(String.valueOf(eachParty.get('Lender_Percentage__c'))))
                    {
                        lenderPortion.Responsible_Percentage__c = 0;
                        lenderPortion.Committed_Responsible_Percentage__c = 0;
                    }
                    else
                    {
                        lenderPortion.Responsible_Percentage__c = (Decimal)eachParty.get('Lender_Percentage__c') ;
                        lenderPortion.Committed_Responsible_Percentage__c = (Decimal)eachParty.get('Lender_Percentage__c') ;
                    }
                }
                
                //Default Responsible Amount
                if(drawdownObject.Advance_Amount__c == null || String.isBlank(String.valueOf(drawdownObject.Advance_Amount__c)) )
                {
                    lenderPortion.Responsible_Amount__c = 0;
                }

                //New Wrapper Item.
                LenderWrapper wrapperItem = new LenderWrapper();
                wrapperItem.record = lenderPortion;
                
                if(drawdownObject.Lender_Portion_Changed__c == True)
                {
                    totalLenderPortionPercentage = totalLenderPortionPercentage + lenderPortion.Committed_Responsible_Percentage__c;
                }
                else
                {
                    totalLenderPortionPercentage = totalLenderPortionPercentage + lenderPortion.Responsible_Percentage__c;
                }

                //Add to wrapper list.
                lendersWrapper.add(wrapperItem); 
            }   
        }
        
        if(totalLenderPortionPercentage < 100 && limitSpecified == True)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Warning,'The lenders portion is less than 100%. Do you want to proceed?'));
        }

        System.debug('### Drawdown_Override : buildLendersWrapper : lendersWrapper : '+lendersWrapper); 
    }

    public PageReference actionUpdateBankDetails()
    {
        //Updates the bank details.
        populateBankDetails();

        return null;
    }
    
    public PageReference actionChangeLenderPortions()
    {
		drawdownObject.Lender_Portion_Changed__c = True;    
        actionUpdateLenders();

        System.debug('drawdownObject : ' + drawdownObject);
        return null; 
    }

    public void populateBankDetails()
    {
        if(bankDetailsMap.containsKey(drawdownObject.CurrencyISOCode))
        {
            drawdownObject.Account_Number__c = bankDetailsMap.get(drawdownObject.CurrencyISOCode).Account_Number__c;
            drawdownObject.Account_Name__c = bankDetailsMap.get(drawdownObject.CurrencyISOCode).Account_Name__c;
            drawdownObject.Account_Branch__c = bankDetailsMap.get(drawdownObject.CurrencyISOCode).Account_Branch__c;
            drawdownObject.Account_Bank__c = bankDetailsMap.get(drawdownObject.CurrencyISOCode).Account_Bank__c;

            //Update the currency on lender records.
            for(LenderWrapper lender : lendersWrapper)
            {
                lender.record.CurrencyISOCode = drawdownObject.CurrencyISOCode;
            }
        }
        else 
        {
            drawdownObject.Account_Number__c = 'No bank details for currency.';
            drawdownObject.Account_Name__c = 'No bank details for currency.';
            drawdownObject.Account_Branch__c = 'No bank details for currency.';
            drawdownObject.Account_Bank__c = 'No bank details for currency.';
        }
    }
    
    public pageReference drawDownLimitCheck()
    {
        //If (Advance Amount + Current Utilisation) greater than limit, display warning
        //Set limit exceed flag for user in approval process
        if(drawdownObject.Advance_Amount__c != null && drawdownObject.Current_Utilisation__c != null && drawdownObject.Facility_Limit__c != null)
        {
            if((drawdownObject.Advance_Amount__c + drawdownObject.Current_Utilisation__c) > parentLimit)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Drawdown Amount exceeds the Facility Limit. Approval is required, would you like to proceed?'));   
                exceedingLimit = True;
            }
            else
            {
                exceedingLimit = False;
            }

        }
        return null;
    }
    
    //Method to set the Approval Status on Approval Object based on the number of Approvals/Rejections
    public static List<Drawdown__c> approvalStatuses(Set<Id> inputDrawdowns)
    {
        List<Drawdown__c> drawdownList = [
            SELECT
                Id,
                Name,
                Status__c,
                (
                    SELECT
                        Id,
                        Status__c
                    FROM
                    Approvals__r
                )
            FROM Drawdown__c
            WHERE 
                Id IN :inputDrawdowns
        ];

        //Loop through all 
        for(Drawdown__c eachDrawdown : drawdownList)
        {
            //Number of approvals on this item.
            Integer numApprovals    = eachDrawdown.Approvals__r.size();
            
            //Counters to determine status
            Integer numApproved     = 0;
            Integer numRejected     = 0;
            
            //Loop through related approval records an count statuses.
            for(Approval__c approvalRecord : eachDrawdown.Approvals__r)
            {
                if(approvalRecord.Status__c == 'Approved')
                {
                   numApproved++;
                }
                
                if(approvalRecord.Status__c == 'Rejected')
                {
                   numRejected++;
                }
            }
            
            //Set the overall status for drwdown record.
            if(numApprovals == numApproved)
            {
               eachDrawdown.Approval_Status__c = 'Approved'; 
            }
            else if(numRejected > 0)
            {
               eachDrawdown.Approval_Status__c = 'Rejected'; 
            }
            else
            {
                eachDrawdown.Approval_Status__c = 'Submitted'; 
            }
        }
        
        //Default return.
        return drawdownList;
    }
    
    /**
    * Participant Wrapper
    **/
    public class ParticipantWrapper
    {
        public Boolean selected { get; set; }
        public advpm__Participant__c participant { get; set; }
        
        //Blank constructor.
        public ParticipantWrapper() { }
    }
    
    /**
    * Distro Group Wrapper
    **/
    public class DistroGroupWrapper
    {
        public Boolean selected { get; set; }
        public Distribution_Group__c distroGroup { get; set; }
        
        //Blank constructor.
        public distroGroupWrapper() { }
    }

    /**
    * Lender Wrapper
    **/
    public class LenderWrapper
    {
        public Lender_Portion__c record { get; set; }
        public LenderWrapper() { }
    }
}