Global class evTimeLine_Controller
{
    public evTimeLine_Controller() 
    {
        
        return;
    }
    
    @RemoteAction 
    //global static list<TimeLineItem> getTimeLineItems(String s)
    global static TimeLine getTimeLine(String s)
    {
        list<TimeLineItem> items = new list<TimeLineItem>();
        TimeLine tl = new TimeLine();
        
        system.debug('getTimeLineItems: s: '+s);
        // if no eventID then list all events (later need to filter on dates)
        if (String.isBlank(s))
        {
            system.debug('getTimeLineItems:  for all events.');
            
            list<Event__c> listEvents;
            listEvents = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Event__c
                          WHERE Start_Date__c > :Date.today().addmonths(-3) and
                          End_Date__c < :Date.today().addmonths(3) ];
            
            for (Event__c ev : listEvents)
            {
                If (ev.End_Date__c != ev.Start_Date__c) 
                {
                    items.add(new TimeLineItem(ev.Id, ev.Name, String.ValueOf(ev.Start_Date__c),
                                               String.ValueOf(ev.End_Date__c),null,null,null));
                }
                else
                {
                    items.add(new TimeLineItem(ev.Id, ev.Name, 
                                               String.ValueOf(ev.Start_Date__c),null,null,null,null));
                }
            }
            
            TimeLineOptions options = new TimeLineOptions();
            options.orientation = new TimeLineOrientation();
            options.orientation.axis = 'top';
            
            tl.items = items;
            tl.options = options;
            
            
        }
        else 
        {
            Id RecordId = s;
            if (RecordId.getSobjectType() == Event__c.getSobjectType())
            {
                system.debug('getTimeLineItems:  for EventID: '+RecordId);
                Datetime evStartDate; 
                Datetime evEndDate;
                
                Event__c thisEvent = [SELECT Id, Name, Start_Date__c, End_Date__c  FROM Event__c WHERE Id = :RecordId];
                evStartDate = thisEvent.Start_Date__c;
                evStartDate = evStartDate.addHours(-2);
                evEndDate = thisEvent.End_Date__c;
                evEndDate = evEndDate.addDays(1).addHours(-2);
                
                DateTime evStartRange = evStartDate;
                DateTime evEndRange = evEndDate;
                
                list<EM_Event_Email_Configuration__c> listMessages;
                
                listMessages = [SELECT Id, Name, Label__c, Start_Send_Date__c, Stop_Send_Date__c, SMS_Text__c 
                                FROM EM_Event_Email_Configuration__c WHERE Event__c = :recordId];
                
                // Add all the email schedules for this event                
                // Determine the earliest start and latest end date for the range of the time line
                for (EM_Event_Email_Configuration__c msg : listMessages)
                {
                    if (msg.Start_Send_Date__c < evStartRange)
                    {
                        evStartRange = msg.Start_Send_Date__c;
                    }
                    if (msg.Stop_Send_Date__c > evEndRange)
                    {
                        evEndRange = msg.Stop_Send_Date__c;
                    }
                    
                    String label = msg.Name;
                    if (!String.IsBlank(msg.Label__c))
                    {
                        label += ' - '+msg.Label__c ;        
                    }
                    if (!String.IsBlank(msg.SMS_Text__c))
                    {
                        label = 'SMS: '+label;
                    }
                    else
                    {
                        label = 'Email: '+label;
                    }
                    If (msg.Start_Send_Date__c != msg.Stop_Send_Date__c) 
                    {
                        items.add(new TimeLineItem(msg.Id, label, String.ValueOf(msg.Start_Send_Date__c),
                                                   String.ValueOf(msg.Stop_Send_Date__c),null,'2',null));
                    }
                    else
                    {
                        items.add(new TimeLineItem(msg.Id, label, String.ValueOf(msg.Start_Send_Date__c),null,null,'2',null));
                    }
                }
                
                
                items.add(new TimeLineItem('range', '',String.ValueOf(evStartRange), 
                                           String.ValueOf(evEndRange),'background',null,null));
                
                items.add(new TimeLineItem('event', '',String.ValueOf(evStartDate), 
                                           String.ValueOf(evEndDate),'background',null,'thisevent'));
                
                items.add(new TimeLineItem(thisEvent.Id, thisEvent.Name,String.ValueOf(evStartDate), 
                                           String.ValueOf(evEndDate),null,'0',null));
             /*   
                items.add(new TimeLineItem('approval', 'Approval',String.ValueOf(evStartDate.addDays(-11)), 
                                           null,'point','0',null));
                
                items.add(new TimeLineItem('rsvp', 'RSVP',String.ValueOf(evStartDate.addDays(-5)),
                                           null,'point','0',null));
                 */
                
                
                list<Event__c> listEvents;
                
                listEvents = [SELECT Id, Name, Start_Date__c, End_Date__c  FROM Event__c 
                              WHERE Id != :RecordId and
                              Start_Date__c >= :evStartRange.date().addDays(-15) AND End_Date__c <= :evEndRange.date().addDays(+15)];
                
                for (Event__c ev : listEvents)
                {
                    evStartDate = ev.Start_Date__c;
                    evStartDate = evStartDate.addHours(-2);
                    evEndDate = ev.End_Date__c;
                    evEndDate = evEndDate.addDays(1).addHours(-2);
                    
                    items.add(new TimeLineItem(ev.Id, ev.Name,String.ValueOf(evStartDate), 
                                               String.ValueOf(evEndDate),null,'1','otherevent'));
                }
                
                list<TimeLineGroup> groups = new list<TimeLineGroup>();
                
                groups.add(new TimeLineGroup ('0','This\nEvent'));
                groups.add(new TimeLineGroup ('1','Other\nEvents'));
                groups.add(new TimeLineGroup ('2','Scheduled\nMessages'));
                
                TimeLineOptions options = new TimeLineOptions();
                options.orientation = new TimeLineOrientation();
                options.orientation.axis = 'top';
                
                tl.items = items;
                tl.groups = groups;
                tl.options = options;
                
                
                
                /*
if (ev.RSVP_Date__c != null)
{
items.add(new TimeLineItem('rsvp', 'RSVP Date',String.ValueOf(ev.RSVP_Date__c), null));
}
*/                  
                //                    items.add(new TimeLineItem('1', 'item 1','2017-08-20', null));
                //                    items.add(new TimeLineItem('2', 'item 2','2017-08-25', null));
                //                   items.add(new TimeLineItem('3', 'item 3','2017-08-29', null));
                //                    items.add(new TimeLineItem('4', 'item 4','2017-09-05', null));
                
            }
            else 
            {
                system.debug('getTimeLineItems:  Unknown Id: '+RecordId);
                // do nothing as not a valid parameter
                
            }
        }
        return tl;
        //return items;
    }
    
    Global class TimeLineItem
    {
        global TimeLineItem (string i, string c, string s, string e, string t, string g, string cn)
        {
            id = i;
            content = c;
            start = s;
            end_x = e;
            type_x = t;
            group_x = g;
            className = cn;
        }
        String id{get;set;}
        String content{get;set;}
        String start{get;set;}
        String end_x{get;set;}
        String type_x{get;set;}
        String group_x{get;set;}
        String className{get;set;}
    }
    
    global class TimeLineGroup
    {
        String id {get;set;}
        String content{get;set;}
        global TimeLineGroup (string i, string c)
        {
            id = i;
            content = c;
        }
    }
    
    global class TimeLineOrientation 
    {
        String axis{get; set;}
    }
    
    global class TimeLineOptions
    {
        TimeLineOrientation orientation {get;set;}
    }
    
    global class TimeLine
    {
        list<TimeLineItem> items {get; set;}
        list<TimeLineGroup> groups {get; set;}
        TimeLineOptions options {get; set;}
    }
}