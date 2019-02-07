/****************************************************************************
* @Author     : Daniel Field
* @Date       : 2017-10-10
* @Description: Trigger used to add the Event Creator to the Event Team as a Event_Team_Member__c
* @Purpose    : Trigger
* @Pages      : N/A
* @Test Class : evDelegate_Trigger_Test
****************************************************************************/
trigger evEvent_Trigger on Event__c (before insert, before update, after insert) 
{
    if(trigger.isbefore && (trigger.isInsert || trigger.isUpdate))
    {
        for(event__C eventRec : trigger.new) 
        {
            String[] SelectedFields;
            String[] SelectedMandatoryFields;
            event__C OldEvent ;
            
            if(trigger.isUpdate)
            {
                OldEvent =  trigger.oldMap.get(eventRec.id);
            }
            
            if(trigger.isinsert || (EventRec.Booking_Confirmation_Fields__c != OldEvent.Booking_Confirmation_Fields__c || EventRec.Booking_Confirmation_Mandatory_Fields__c != OldEvent.Booking_Confirmation_Mandatory_Fields__c) )
            {
                if(eventRec.Booking_Confirmation_Fields__c != null)
                {
                    SelectedFields = eventRec.Booking_Confirmation_Fields__c.split(';');
                }
                else
                {
                    SelectedFields =  new list<string>();
                }
                
                if(eventRec.Booking_Confirmation_Mandatory_Fields__c != null)
                {
                    SelectedMandatoryFields = eventRec.Booking_Confirmation_Mandatory_Fields__c .split(';');
                }
                else
                {
                    SelectedMandatoryFields =  new list<string>();
                }
                
                for(string MandetoryFieldVar : SelectedMandatoryFields)
                {
                    if(SelectedFields.contains(MandetoryFieldVar) ==  false)
                    {
                        eventRec.Booking_Confirmation_Mandatory_Fields__c.adderror('Please ensure the Booking Confirmation Fields has the '+ MandetoryFieldVar +' field selected before adding it to the Booking Confirmation Mandatory Fields.');
                        continue;
                    }
                }
            }
        }
    }
    
    if(trigger.isAfter && trigger.isInsert)
    {
        List<Event_Team_Member__c> ListOfEventTeamMembersToInsert = new List<Event_Team_Member__c>();
        
        for(event__C eventRec : trigger.new) 
        {
            Event_Team_Member__c ETM = new Event_Team_Member__c
                (
                    Event__c 								= eventRec.id,
                    Team_Member__c 							= eventRec.CreatedById,
                    Maximum_Number_of_Actual_Invitees__c 	= 0,
                    Maximum_Number_of_Proposed_Invitees__c 	= 0,
                    Event_Team_Member_Role__c 				= 'Requestor'
                );
            
            ListOfEventTeamMembersToInsert.add(ETM);            
        }
        
        Insert ListOfEventTeamMembersToInsert;
    }
}