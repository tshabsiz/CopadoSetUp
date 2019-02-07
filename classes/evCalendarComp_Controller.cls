/****************************************************************************
* @Author     : Daniel Field
* @Date       : 13/10/2016
* @Description: Controller class used for the Full calendar on the caseware community training pages, Fetches events and puts them in a unique list that is used by the Calendar JS
* @Purpose    : Controller class
* @Pages      :
* @Test Class : CQS_CasewareBookingController_Test
* @Notes : It takes 5 paremeters,
EventIDforcal - value of ID paremeter in the page URL
queryStart - datetime in miliseconds for the select
queryStart - datetime in miliseconds for the select
EventType  - The Type of event that will be selected, if left blank then it is not used as criteria
CourseID   - The ID of the course that events being selected should be linked to, If Left blank then it is not used as criteria
//----------------------------------------------------------------------------*/
Global class evCalendarComp_Controller 
{
    @RemoteAction
    global static list<calendarEvent> getEvents(id EventIDforcal, double queryStart, double queryEnd, String EventType, string coursetype ,  String CourseIDString , String EventCity)
    {
        try
        {
            ID Courseid;
            String eventQueryString;
            
            if(CourseIDString != null && CourseIDString != '')
            {
                Courseid =     id.valueOf(CourseIDString);
            }
            
            list<calendarEvent> events = new list<calendarEvent>();
            
            datetime startDate = datetime.newInstance(0);
            Integer startInt = integer.valueOf(queryStart);
            startDate = startDate.addSeconds(startInt);
            
            datetime endDate = datetime.newInstance(0);
            Integer endInt = integer.valueOf(queryEnd);
            endDate = endDate.addSeconds(endInt);
            
            //List used to exclude "Other" cities in City filter
            List<String> namedCities = new List<String>();
            namedCities.add('Johannesburg'); 
            namedCities.add('Durban'); 
            namedCities.add('Cape Town'); 
            namedCities.add('East London'); 
            namedCities.add('Port Elizabeth'); 
            namedCities.add('Bloemfontein'); 
            namedCities.add('Nelspruit'); 
            namedCities.add('Polokwane'); 
            
            
            //List used to group "Customer" course types 
            List<String> customerList = new List<String>();
            customerList.add('Customer'); 
            customerList.add('Marketing'); 
            customerList.add('User Group'); 
            
            List<String> StringOfEventTypesForQuery = new List<String>(); 
            list<event__c> EventList;
            
            String startdatestring = startDate.format('yyyy-MM-dd');
            
            String enddatestring = endDate.format('yyyy-MM-dd');
            
            String todaydatestring = DateTime.now().format('yyyy-MM-dd');
            
            eventQueryString=   
                'SELECT '+ 
                    'Name,'+
                    'Owner.Name,' +
                    'Start_Date__c,'+
                    'End_Date__c,'+
                    'EventStartTime__c,'+
                    'EventEndTime__c,'+
                    'Duration__c,'+
                    'Duration_Units__c,'+
                    'Type__c, '+
                    'City__c,'+
                    'Country__c,'+
                    'Venue__r.Name, '+
                    'Venue__r.Address__c, '+
                    'Capacity_Status__c, ' +
                    'Capacity__c, ' +
                    'Number_Registered__c, ' +
                    'Internal_Trainer__r.Name, '+
                    'Internal_Trainer__r.FullPhotoUrl, '+
                    'Outside_Trainer__c '+
                'FROM '+
                	'event__c '+
                'WHERE '+
                	'(RecordType.DeveloperName != \'Archived\' AND RecordType.DeveloperName != \'Event_Request\') ' +
                ' AND '+
                	'Hide__c = false';
                    
            system.debug('EventType : '+ EventType);
            if (EventType != null && EventType != '')
            {
                eventQueryString += ' AND Type__c =: EventType ';
            }
            
            EventList = new list<event__c>();
            List<sObject> sobjListOfEvents =  new List<sObject>();
            
            sobjListOfEvents =   Database.query(eventQueryString);
            
            EventList = sobjListOfEvents;
            
            for(event__c e : EventList)
            {
                calendarEvent thisEvent = new calendarEvent();
                
                thisEvent.id = e.id;
                thisEvent.title = e.name;       
                if( e.EventStartTime__c != null)
                {
                    
                    thisEvent.startTime = string.valueof(e.EventStartTime__c).left(5);
                }
                else
                {
                    thisEvent.startTime = 'TBC';
                }
                
                if( e.EventEndTime__c != null)
                {
                    thisEvent.endTime = string.valueof(e.EventEndTime__c).left(5);
                }
                else
                {
                    thisEvent.endTime = 'TBC';
                }
                
                thisEvent.venue = e.Venue__r.name;
                thisEvent.address = e.Venue__r.Address__c + ', ' + e.City__C + ', ' + e.Country__C;
                thisEvent.allDay = false;
                thisEvent.color = '#006991';
                
                if (e.Type__c == 'Customer' || e.Type__c == 'User Group' || e.Type__c == 'Marketing')
                {
                    thisEvent.color = '#77b800';
                }
                if (e.Type__c == 'Training' )
                {
                    thisEvent.color = '#006991';
                }
                if (e.Type__c == 'Webinar' )
                {
                    thisEvent.color = '#51626F';
                }
                
                if (e.City__C != null)
                {
                    if (e.City__C == 'Johannesburg')
                    {
                        thisEvent.title = 'JHB - '+  +thisEvent.title;
                    }
                    else if (e.City__C == 'Cape Town')
                    {
                        thisEvent.title = 'CPT - '+  +thisEvent.title;
                    }
                    else if (e.City__C == 'Durban')
                    {
                        thisEvent.title = 'DBN - '+  +thisEvent.title;
                    }                    
                    else
                    {
                        thisEvent.title = 'Other - '+  +thisEvent.title;
                    }
                }
                
                if (e.Capacity_Status__c == 'Full' || e.Capacity_Status__c == 'Overbooked')// if No spaces are availible put 'FULL' in front of event name and make it red
                {
                    thisEvent.title = 'FULL: '+  +thisEvent.title;
                    thisEvent.color = 'Red';
                   // thisEvent.space = 'hidden';
                }
                
                thisEvent.title += ' ('+e.Number_Registered__c + '/' + e.Capacity__c + ')';
                
                datetime StartDateTimeReplacement = e.Start_Date__c;
                datetime EndDateTimeReplacement = e.End_Date__c;
                
                double startDateTime 	= (dateTime.valueOf(StartDateTimeReplacement).getTime());
                double endDateTime 		= (dateTime.valueOf(EndDateTimeReplacement).getTime());
                
                thisEvent.start 	=	startDateTime;
                thisEvent.Eventend 	=	endDateTime;
                
                thisEvent.detailData = new map<string,string>();
                
                thisEvent.detailData.put('Name', e.name);
                thisEvent.detailData.put('Start date', e.Start_Date__c.format());
                thisEvent.detailData.put('End date', e.End_Date__c.format());
                
                if(e.Internal_Trainer__c != null && e.Internal_Trainer__r.name != null)
                {
                    thisEvent.detailData.put('trainer_name',  e.Internal_Trainer__r.name);
                    if(e.Internal_Trainer__r.FullPhotoUrl != null)
                    {
                        thisEvent.detailData.put('trainer_avatar', e.Internal_Trainer__r.FullPhotoUrl);
                    }
                    Else
                    {
                        thisEvent.detailData.put('trainer_avatar','https://c.eu7.content.force.com/servlet/servlet.ImageServer?id=0150J000003rPRs&oid=00D20000000BO9d');
                    }
                }
                else if(e.Internal_Trainer__c == null && e.Outside_Trainer__c != null)
                {
                    thisEvent.detailData.put('trainer_name',  e.Outside_Trainer__c);
                    thisEvent.detailData.put('trainer_avatar','https://c.eu7.content.force.com/servlet/servlet.ImageServer?id=0150J000003rPRs&oid=00D20000000BO9d');
                }
                else
                {
                    thisEvent.detailData.put('trainer_name',  e.owner.name);
                    thisEvent.detailData.put('trainer_avatar','https://c.eu7.content.force.com/servlet/servlet.ImageServer?id=0150J000003rPRs&oid=00D20000000BO9d');
                }
                thisEvent.detailData.put('duration',  e.Duration__c + ' ' + e.Duration_Units__c);
                PageReference prEvent =  new PageReference('/'+ e.id);
                thisEvent.detailData.put('event_url', prEvent.getUrl());
                events.add(thisEvent);
            }
            system.debug('events ' + events);
            return events;
        }
        Catch(Exception e)
        {
            return null;
            // do nothing as the calendar doesn't output an error
        }
        
    }
    Global class calendarEvent
    {
        string id{get;set;}
        string title{get;set;}
        string courseType{get;set;}
        string space{get;set;}
        string city{get;set;}
        string address{get;set;}
        string country{get;set;}
        string venue{get;set;}
        string color{get;set;}
        boolean allDay{get;set;}
        string startTime{get;set;}
        string endTime{get;set;}
        double start{get;set;}
        double Eventend{get;set;}
        string url{get;set;}
        map<string,string> detailData{get;set;}
        boolean editable{get;set;}
    }
}