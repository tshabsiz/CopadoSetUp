/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 28/09/2017 - PG    - Added "NOTI_PARTICIPANT_TYPES" and "NOTI_GROUP_TYPES" constants.
   
**/      
public class FitToLend_Override  
{
    /**
    * Variables
    **/
    private static final Map <String, Schema.RecordTypeInfo> NOTI_PARTICIPANT_TYPES = Notification_Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    private static final Map <String, Schema.RecordTypeInfo> NOTI_GROUP_TYPES = Notification_Group__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public Fit_To_Lend_Checklist__c fitToLendObject { get; set; }
    public List<ParticipantWrapper> participantsWrapper { get; set; }
    public List<DistroGroupWrapper> distroGroupsWrapper { get; set; }
    
    /**
    * Constructor
    **/
    public FitToLend_Override(ApexPages.StandardController stdController)
    {   
        //Blank variables.
        List<advpm__Participant__c> participants = new List<advpm__Participant__c>();
        List<Distribution_Group__c> distroGroups = new List<Distribution_Group__c>();
        
        //Empty wrappers
        participantsWrapper = new List<ParticipantWrapper>();
        distroGroupsWrapper = new List<DistroGroupWrapper>();

        List<String> fields = new List<String> {
            'Name', 
            'Deal__c',
            'Status__c',
            'CreatedById',
            'LastModifiedById'
        }; 
        
        if(!Test.isRunningTest())
        {
            //Add fields
            stdController.addFields(fields);
        }
        
        //Get the page record.
        this.fitToLendObject = (Fit_To_Lend_Checklist__c)stdController.getRecord();
        
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
                advpm__Matter__c = :fitToLendObject.Deal__c
                AND advpm__Staff__c != null
        ];
        
        //Build participants wrapper
        for(advpm__Participant__c participant : participants)
        {
            //New Wrapper
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
    
    /**
    * acton - Save record and selections.
    **/
    public pageReference saveRecord()
    {

        //Insert paretn object.
        if(fitToLendObject.id == null)
        {
            insert fitToLendObject;
        }
        

        List<Notification_Group__c> notificationGroups = new List<Notification_Group__c>();
        List<Notification_Participant__c> notificationParticipants = new List<Notification_Participant__c>();
        
        //Get all selected participants.
        for(ParticipantWrapper participantWrapper : participantsWrapper)
        {
            //Selected?
            if(participantWrapper.selected)
            {
                //New Notification_Participant__c 
                Notification_Participant__c pNotification = new Notification_Participant__c();
                pNotification.Participant__c = participantWrapper.participant.Id;
                pNotification.Fit_To_Lend_Checklist__c = fitToLendObject.Id;
                pNotification.RecordTypeId = NOTI_PARTICIPANT_TYPES.get('Fit To Lend Checklist').getRecordTypeId();
                
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
                gNotification.Fit_To_Lend__c = fitToLendObject.Id;
                gNotification.RecordTypeId = NOTI_GROUP_TYPES.get('Fit To Lend Checklist').getRecordTypeId();
                
                //Add to insert list.
                notificationGroups.add(gNotification);
            }
        }
        
        if(notificationParticipants.isEmpty() && notificationGroups.isEmpty())
        {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Notification Participants and/or Notification Groups'));
            return null;
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
        
        
        
        //New Page Setup
        PageReference standardPage = new PageReference('/'+fitToLendObject.Id); 
        standardPage.setRedirect(true);
        
        //Redirect.
        return standardPage;
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
}