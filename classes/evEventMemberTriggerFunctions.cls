/**
* Author : Rudolf Niehaus
* Date   : 2017-08-09
* Desc   : Trigger functions class for the trigger evEventMemberTrigger
*        : Methods:
*          blockDuplicateMembers(trigger.new)
*          Prevent a user from adding more than one event team member to the same event, cater
*          for bulk mixed member / event uploads.
**/
public class evEventMemberTriggerFunctions {
    
    public static void blockDuplicateMembers(list<Event_Team_Member__c> newMembers){
        
        set<String> membersIds = new set<String>();
        set<Id> eventIds = new set<Id>();
        map<String, list<Event_Team_Member__c>> eventmemberMap = new map<String, list<Event_Team_Member__c>>();
        String eventX = '';
        String eventY = '';
        list<Event_Team_Member__c> memberList = new list<Event_Team_Member__c>();
        
        //Add list of members per event (in case we have mixed event members being added to different events
        for(Event_Team_Member__c tm :newMembers){
            
            eventIds.add(tm.Event__c);
            
            eventX = tm.Event__c;
            
            if(eventX == eventY || eventY == ''){
                memberList.add(tm);
            }else{
                list<Event_Team_Member__c> newList = new list<Event_Team_Member__c>(memberList);
                eventmemberMap.put(eventY, newList);
                memberList.clear();
                memberList.add(tm);
            }
            
             eventY = tm.Event__c;
        }
         //add last list of members to the map after we exit the loop
        eventmemberMap.put(eventY, memberList);

        //get existing members per event within the trigger context
        for(Event_Team_Member__c xm :[Select Event__c, Team_Member__c From Event_Team_Member__c Where Event__c IN :eventIds]){
            String GUID = (String)xm.Event__c + (String)xm.Team_Member__c;
            membersIds.add(GUID);
        }
     
        //block any duplicate members per event
        for (Id recordId :eventmemberMap.keySet()){
            for (Event_Team_Member__c m :eventmemberMap.get(recordId)){
                String GUID = (String)m.Event__c + (String)m.Team_Member__c;
                if(membersIds.contains(GUID)){
                    m.Team_Member__c.addError('Duplicate Team Member For this Event, please select a different member');
                }
            }
        }
        
    }
}