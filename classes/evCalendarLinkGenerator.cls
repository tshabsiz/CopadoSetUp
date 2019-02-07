public class evCalendarLinkGenerator {
	
    public String delegateId { get; set; }
    public String linkText { get; set; }
    public String linkImage { get; set; }
    
    public Boolean showImage;
    

    public evCalendarLinkGenerator() { 
    }
    
    public void setShowImage(Boolean inputValue) {
        showImage = inputValue;
    }
    
    public Boolean getShowImage() {
        
        System.debug('delegateId:'+delegateId);
        System.debug('linkText:'+linkText);
        System.debug('linkImage:'+linkImage);
        
        if(showImage == null) {  
        	showImage = String.isBlank(linkImage) ? false : true;
        }

        return showImage;
    }
    
    public String getCalendarLink() {
        
        if(String.isBlank(delegateId)) {
            throw new CustomException('Invalid Delegate Id provided.');
        }
        
        DateTime calendarStart;
        DateTime calendarEnd;
        
        //Get delegate and event details.
       	Delegate__c delegate = [
            SELECT 
            	Event__r.Name,
            	Event__r.Start_Date__c, 
            	Event__r.End_Date__c, 
            	Event__r.EventStartTime__c, 
            	Event__r.EventEndTime__c,
            	Event__r.City__c,
            	Event__r.Country__c,
            	Event__r.Calendar_Organiser_Name__c,
            	Event__r.Calendar_Organiser_Email__c,
            	Event__r.Venue__r.Name,
            	Event__r.Venue__r.Address__c
           	FROM Delegate__c
            WHERE
            	Id = :delegateId
        ];
        
        //Get the session bookings associated with the delegate for event. 
        List<Event_Session_Booking__c> eventSessionBookings = new List<Event_Session_Booking__c>([
            SELECT 
                Id, 
                Session__r.Name, 
                Session__r.Date__c,  
                Session__r.Start_Time__c,
                Session__r.End_Time__c
            FROM Event_Session_Booking__c 
            WHERE 
            	Delegate__c = :delegateId     	
        ]); 
        
      	//Has session bookings so rather use these for calendar invite.
        if(!eventSessionBookings.isEmpty()) {
        
            //Loop over sessions to determine the calendar max and min invite date / times.
            for(Event_Session_Booking__c sessionBooking : eventSessionBookings) {
                
                DateTime startTimestamp = DateTime.newInstance(sessionBooking.Session__r.Date__c, sessionBooking.Session__r.Start_Time__c);
                DateTime endTimestamp = DateTime.newInstance(sessionBooking.Session__r.Date__c, sessionBooking.Session__r.End_Time__c);
                
                if(calendarStart == null) {
                    calendarStart = startTimestamp;
                    calendarEnd = endTimestamp;
                }
                
                if(startTimestamp < calendarStart) {
                    calendarStart = startTimestamp;
                }
                
                if(endTimestamp > calendarEnd) {
                    calendarEnd = endTimestamp;
                }   
            }
        }
        //There are session booking records, so use the event dates and times.
        else {
            calendarStart = DateTime.newInstance(delegate.Event__r.Start_Date__c, delegate.Event__r.EventStartTime__c);
            calendarEnd = DateTime.newInstance(delegate.Event__r.End_Date__c, delegate.Event__r.EventEndTime__c);
        }
        
        //Build calendar link.
        String linkUrl = 'http://addtocalendar.com/atc/outlook?f=m&e[0][date_start]='+calendarStart+'&e[0][date_end]='+calendarEnd+'&e[0][timezone]=Africa%2FJohannesburg&e[0][title]='+delegate.Event__r.Name+'&e[0][description]=&e[0][location]='+delegate.Event__r.Venue__r.Name + '&e[0][organizer]='+delegate.Event__r.Calendar_Organiser_Name__c+'&e[0][organizer_email]='+delegate.Event__r.Calendar_Organiser_Email__c+'&e[0][privacy]=public';
        
        return linkUrl;
    }
    
    public class CustomException extends Exception {}
}