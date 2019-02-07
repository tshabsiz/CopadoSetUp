public class evAddEventTeamMembers_Controller 
{
    public string selectedEvent {get;set;}
    
    public map<integer, Event_Team_Member__c> teamMembersToInsert {get;set;}
    public event__C EventRec{get;set;}
    public list<SelectOption> eventOptions {get;set;}
    public Integer SelectedTeamMember {get;set;}
     
    public evAddEventTeamMembers_Controller() 
    {
        eventOptions = new list<SelectOption>();
        teamMembersToInsert = new map<integer, Event_Team_Member__c>();
        selectedEvent = ApexPages.currentPage().getParameters().get('id');
        EventRec = 
            [
                SELECT 
                Id,
                Name,Registration_Process__c,
                Venue__c, 
                Private_Delegate_Account_Name__c,
                City__c,
                Maximum_Guests__c ,
                Start_Date__c,
                ( 
                    SELECT
                    Team_Member__c 
                    FROM 
                    Event_Teams__r
                    WHERE 
                    Team_Member__c = :UserInfo.getUserId()
                ) 
                FROM  
                Event__c 
                WHERE
                id =: selectedEvent
                ORDER BY 
                Start_Date__c
                ASC
            ];
        
       /* for(Event__c e :eventList)
        {
            Date dateOnly = e.Start_Date__c;
            String city = 'No City Specified';
            
            if(String.isNotBlank(e.City__c))
            {
                city = e.City__c;
            }
            
            eventOptions.add(new SelectOption(e.Id, dateOnly.format() + ' - ' + e.Name + ' - ' + city));
        }*/
        teamMembersToInsert.put( 0, new Event_Team_Member__c());
    }
    
    Public void AddTeamMemberRow()
    {
        //Make instance of Contact. Add to Contact Item List
        Event_Team_Member__c NewETM = new Event_Team_Member__c();
        SYstem.debug(teamMembersToInsert.size());
        teamMembersToInsert.put(teamMembersToInsert.size()+1,NewETM);
    }
    
    public void RemoveRow()
    {
        SYstem.debug(SelectedTeamMember);
        
        teamMembersToInsert.remove(SelectedTeamMember);
        
        SYstem.debug(teamMembersToInsert);
    } 
    
    public pageReference CreateTeamMembers()
    {
        try
        {
            set<id> userIdSet = new set<id>();
            for(Event_Team_Member__c ETM : teamMembersToInsert.values())
            {
                userIdSet.add(ETM.Team_Member__c);
            }
            
            map<id,user> UserMap = new map<id,user>
                ([
                    SELECT
                    id,
                    name 
                    FROM
                    User
                    WHERE
                    id in: userIdSet
                ]);
            
            for(Event_Team_Member__c ETM : teamMembersToInsert.values())
            {
                ETM.event__c = selectedEvent;
                ETM.name = UserMap.get(ETM.Team_Member__c).Name;
            }
            insert teamMembersToInsert.values();
            teamMembersToInsert.clear();
        }
        catch(exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'There was an issue creating the Team Members, please try again or contact a system administrator.'));     
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage() +' | Line :'+ex.getLineNumber()));     
            return null;
        }
         return new PageReference('/' + selectedEvent);
    }
      public pageReference Cancel()
      {
          return new PageReference('/' + selectedEvent);
      }
}