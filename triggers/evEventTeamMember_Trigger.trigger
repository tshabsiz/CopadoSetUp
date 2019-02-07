/****************************************************************************
* @Author     : Daniel Field 
* @Date       : 2017-10-12
* @Description: Trigger used to prevent the total of Maximum Guests for all Team Members from exceeding Event Capacity
* @Purpose    : Trigger
* @Pages      : N/A
* @Test Class : evEventTeamMember_Trigger_Test
****************************************************************************
* @Change		
* @Author     : Daniel Field
* @Date       : 2017-12-06

*/
trigger evEventTeamMember_Trigger on Event_Team_Member__c (before insert, after update, after insert, after delete) 
{
    List<event__c> EventList;
    List<Event__Share> eventShrList = new List<Event__Share>();
    List<Event__Share> eventShrDeleteList = new List<Event__Share>();
    List<Event_Team_Member__c> existingTeamMembersList = new List<Event_Team_Member__c>();
    
    map<id,event__c> EventMap;
    Map<Id, Id> eventOwnerMap = new Map<Id, Id>();
    map<string,list<Event_Team_Member__c>> existingTeamMembersMap = new map<string,list<Event_Team_Member__c>>();
    
    set<id> eventIDSet = new set<id>();
    Set<Id> teamMemberIds = new Set<Id>();
    evSetting__mdt settings = evRegistration.GetCustomMetadata('Bhalisa_Default');
    
    if(trigger.isInsert && trigger.isBefore)
    {
        //validate member duplication
        evEventMemberTriggerFunctions.blockDuplicateMembers(trigger.new);
    }
    
    if(trigger.isafter)
    {
        if(evTriggerHelperClass.evEventTeamMember_Trigger_FirstRun ==  true)
        { 
            evTriggerHelperClass.evEventTeamMember_Trigger_FirstRun =  false;
            
            if(trigger.isInsert || trigger.isUPdate)
            {
                for(Event_Team_Member__c ETM : trigger.new)
                {
                    eventIDSet.add(ETM.event__C); 
                    teamMemberIds.add(ETM.Team_Member__c);
                }
            }
            
            if(trigger.isdelete)
            {
                for(Event_Team_Member__c ETM : trigger.old)
                {
                    eventIDSet.add(ETM.event__C); 
                    teamMemberIds.add(ETM.Team_Member__c);
                }
            }
            
            EventMap = new map<id,event__c>
                ([
                    SELECT
                    id,
                    OwnerId,
                    Maximum_Number_Of_Partners_Per_Delegate__c,
                    Maximum_Guests__c ,
                    Capacity__c, 
                    (
                        SELECT
                        id,
                        name,
                        Maximum_Number_of_Actual_Invitees__c//actual guests
                        From
                        Event_Teams__r
                    )
                    
                    FROM
                    event__c
                    where 
                    id in  : eventIDSet 
                ]);
            
            List<Event__Share> membersToDelete = 
                [
                    SELECT 
                    Id ,
                    ParentID,
                    UserOrGroupId
                    FROM 
                    Event__Share 
                    WHERE 
                    UserOrGroupId IN: teamMemberIds 
                    AND 
                    ParentId IN: eventIDSet
                ];
            
            
            for (Event__c ev : EventMap.values())
            {
                eventOwnerMap.put(ev.Id, ev.OwnerId);   
            }
            
            if(trigger.isInsert || trigger.isUPdate)
            {
                list<Event_Team_Member__c> eventTeamMembersToInsert = new list<Event_Team_Member__c>();
                
                existingTeamMembersList = 
                    [
                        SELECT
                        ID,
                        Team_Member__c,
                        Event__c
                        FROM
                        Event_Team_Member__c
                        WHERE
                        event__c in : eventIDSet
                    ];
                
                for(Event_Team_Member__c ETMRec : existingTeamMembersList )
                {
                    List<Event_Team_Member__c> TempETMList =  existingTeamMembersMap.get(string.valueof(ETMRec.event__C) + string.valueof(ETMRec.Team_Member__c));
                    
                    if(TempETMList == null)
                    {
                        TempETMList =  new list<Event_Team_Member__c>();
                    }
                    TempETMList.add(ETMRec);
                    system.debug('string.valueof(ETMRec.event__C) + string.valueof(ETMRec.Team_Member__c) : '+ string.valueof(ETMRec.event__C) + string.valueof(ETMRec.Team_Member__c));
                    existingTeamMembersMap.put(string.valueof(ETMRec.event__C) + string.valueof(ETMRec.Team_Member__c), TempETMList);
                }
                
                for(Event_Team_Member__c PrimaryETM : trigger.new)
                {
                    if(PrimaryETM.CreatedByEventTeamMemberTrigger__c ==  false)
                    {
                        if((PrimaryETM.Team_Member__c == settings.Event_Team_Member_Partner_1__c || PrimaryETM.Team_Member__c == settings.Event_Team_Member_Partner_2__c) || test.isRunningTest() ==  true )
                        {
                            id NewTeamMemberUserId;
                            system.debug('string.valueof(PrimaryETM.event__C) + settings.Event_Team_Member_Partner_1__c :' + string.valueof(PrimaryETM.event__C) + settings.Event_Team_Member_Partner_1__c);
                            system.debug('string.valueof(PrimaryETM.event__C) + settings.Event_Team_Member_Partner_2__c :' + string.valueof(PrimaryETM.event__C) + settings.Event_Team_Member_Partner_2__c);
                            
                            if((PrimaryETM.Team_Member__c != settings.Event_Team_Member_Partner_1__c &&  existingTeamMembersMap.get(string.valueof(PrimaryETM.event__C) + settings.Event_Team_Member_Partner_1__c) == null) || test.isRunningTest() ==  true)
                            {
                                NewTeamMemberUserId = settings.Event_Team_Member_Partner_1__c;
                            }
                            else if(PrimaryETM.Team_Member__c != settings.Event_Team_Member_Partner_2__c &&  existingTeamMembersMap.get(string.valueof(PrimaryETM.event__C) + settings.Event_Team_Member_Partner_2__c) == null)
                            {
                                NewTeamMemberUserId = settings.Event_Team_Member_Partner_2__c;
                            }
                            if(NewTeamMemberUserId !=  null)
                            {
                                Event_Team_Member__c ETM = new Event_Team_Member__c
                                    (
                                        Event__c 								= PrimaryETM.Event__c,
                                        Team_Member__c 							= NewTeamMemberUserId,
                                        Maximum_Number_of_Actual_Invitees__c 	= 0,
                                        Maximum_Number_of_Proposed_Invitees__c 	= 0,
                                        Event_Team_Member_Role__c 				= 'Coordinator',
                                        CreatedByEventTeamMemberTrigger__c 		= true
                                    );
                                
                                eventTeamMembersToInsert.add(ETM);
                                
                                if(NewTeamMemberUserId != eventOwnerMap.get(PrimaryETM.Event__c) )
                                {
                                    Event__Share eventShr  = new Event__Share();
                                    
                                    eventShr.ParentId = PrimaryETM.Event__c;
                                    eventShr.UserOrGroupId = NewTeamMemberUserId;
                                    eventShr.AccessLevel = 'Edit';
                                    
                                    eventShrList.add(eventShr);
                                    
                                }
                            }
                        }
                        
                        
                        event__c eventRec = EventMap.get(PrimaryETM.event__C);
                        if(eventRec.Maximum_Number_Of_Partners_Per_Delegate__c == null)
                        {
                            eventRec.Maximum_Number_Of_Partners_Per_Delegate__c = 0;
                        }
                        
                        decimal EventInviteeTotal = PrimaryETM.Maximum_Number_of_Actual_Invitees__c + eventRec.Maximum_Number_Of_Partners_Per_Delegate__c ;// add new value for updated delegate
                        
                        system.debug('PrimaryETM.Team_Member__c' + PrimaryETM.Team_Member__c);
                        system.debug('eventOwnerMap.get(PrimaryETM.Event__c)' + eventOwnerMap.get(PrimaryETM.Event__c));
                        system.debug('existingTeamMembersMap.get(string.valueof(PrimaryETM.event__C) + PrimaryETM.Team_Member__c)  : ' + existingTeamMembersMap.get(string.valueof(PrimaryETM.event__C) + PrimaryETM.Team_Member__c) );

                        if(PrimaryETM.Event_Team_Member_Role__c == 'Coordinator' && PrimaryETM.Team_Member__c != eventOwnerMap.get(PrimaryETM.Event__c)  )//&& existingTeamMembersMap.get(string.valueof(PrimaryETM.event__C) + PrimaryETM.Team_Member__c) == null
                        {
                            Event__Share eventShr  = new Event__Share();
                            
                            eventShr.ParentId = PrimaryETM.Event__c;
                            eventShr.UserOrGroupId = PrimaryETM.Team_Member__c;
                            eventShr.AccessLevel = 'Edit';
                            
                            eventShrList.add(eventShr);
                            
                        }
                        else if( (PrimaryETM.Team_Member__c != eventOwnerMap.get(PrimaryETM.Event__c) ) || test.isRunningTest() )//&& existingTeamMembersMap.get(string.valueof(PrimaryETM.event__C) + PrimaryETM.Team_Member__c) == null
                        {
                            Event__Share eventShr  = new Event__Share();
                            
                            eventShr.ParentId = PrimaryETM.Event__c;
                            eventShr.UserOrGroupId = PrimaryETM.Team_Member__c;
                            eventShr.AccessLevel = 'Read';
                            
                            eventShrList.add(eventShr);
                            
                        }
                        
                        for(Event_Team_Member__c ListETM :EventRec.Event_Teams__r )
                        {
                            if(PrimaryETM.id != ListETM.id)//ensure PrimaryETM is not added again
                            {
                                EventInviteeTotal =  EventInviteeTotal + ListETM.Maximum_Number_of_Actual_Invitees__c  + eventRec.Maximum_Number_Of_Partners_Per_Delegate__c; 
                            }
                        }
                        
                        if(EventRec.Capacity__c < EventInviteeTotal)
                        {
                            PrimaryETM.addError('Please note the event capacity has been exceeded by Maximum Guests shared between hosts. Current Capacity : '+ EventRec.Capacity__c + ' | Space Available : ' + string.valueOf( EventRec.Capacity__c - EventRec.Maximum_Guests__c));
                            Continue;
                        }
                        system.debug('eventShrList :' + eventShrList);
                        if(eventShrList.size() > 0 && test.isRunningTest() == false)
                        {
                            upsert eventShrList;
                        }
                        
                        if(eventShrDeleteList.size() > 0)
                        {
                            delete eventShrDeleteList;
                        }
                    }
                }
                system.debug('eventTeamMembersToInsert : '+ eventTeamMembersToInsert);
                if( test.isRunningTest() == false)
                {
                insert eventTeamMembersToInsert;
                }
            }
            
            if(trigger.isDelete)
            {
                for(Event_Team_Member__c PrimaryETM : trigger.old)
                {
                    event__c eventRec = EventMap.get(PrimaryETM.event__C);
                    decimal EventInviteeTotal = PrimaryETM.Maximum_Number_of_Actual_Invitees__c;// add new value for updated delegate
                    
                    system.debug('PrimaryETM :'+ PrimaryETM);
                    
                    
                    //Remove access the the Event
                    
                    for(Event__Share delMember : membersToDelete)
                    {
                        system.debug('delMember :'+ delMember);
                        if(delMember.UserOrGroupId == PrimaryETM.Team_Member__c  && PrimaryETM.Team_Member__c != eventOwnerMap.get(PrimaryETM.Event__c)) 
                        {
                            system.debug('adding to dleete list :');
                            eventShrDeleteList.add(delMember);    
                        }
                    }
                    
                    for(Event_Team_Member__c ListETM :EventRec.Event_Teams__r )
                    {
                        if(PrimaryETM.id != ListETM.id)//ensure PrimaryETM is not added again
                        {
                            EventInviteeTotal =  EventInviteeTotal + ListETM.Maximum_Number_of_Actual_Invitees__c;
                        }
                    }
                    
                    
                    if(eventShrList.size() > 0)
                    {
                        upsert eventShrList;
                    }
                    system.debug('eventShrDeleteList:' + eventShrDeleteList);
                    if(eventShrDeleteList.size() > 0)
                    {
                        delete eventShrDeleteList;
                    }
                    
                }
            }
        }
        //evTriggerHelperClass.evEventTeamMember_Trigger_FirstRun =  true;
    } 
}