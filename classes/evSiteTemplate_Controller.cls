public class evSiteTemplate_Controller 
/*
 * 2017-08-10	DH	Created dedicated controller for the event site templates
 * 
 * 
 */
{
    private Id 						DelegateID;
    private Id 						EventID;
    
    public Delegate__c 				thisDelegate      {get;set;} 
    Public Event__c    				thisEvent         {get;set;}

    public class MyException extends Exception {} 

    
    public evSiteTemplate_Controller ()
    {
        system.debug('evSiteTemplate_Controller constructor starting...');
        DelegateID = ApexPages.currentPage().getParameters().get('delid');
        EventID = ApexPages.currentPage().getParameters().get('evid');
        if (EventID == null)
        {
        	EventID = ApexPages.currentPage().getParameters().get('id');    
        }
        
        
        system.debug('DelegateID: '+DelegateID);
        system.debug('EventID: '+EventID);
        
        if (DelegateID != null) 
        {
            thisDelegate 	= evRegistration.GetDelegate(DelegateID);
        }
        
        if (EventID != null)
        {
            if (DelegateID != null) 
            {
                // does the delegate belong to event?
                if (thisDelegate.event__c != EventID) 
                {
                    system.debug('ERROR: Mismatched Event ID on Delegate');
                    throw new MyException ('An unexpected error (ERR-ID01) has been encountered.  Please accept our apologies for any inconvenience.\n\n');
                }
            }
            thisEvent 		= evRegistration.GetEvent(EventID);
        }
        else //EventID is null so use the event from the Delegate
        {
            thisEvent 		= evRegistration.GetEvent(thisDelegate.event__c);
        }
	    system.debug(logginglevel.DEBUG, 'evSiteTemplate_Controller constructor starting...');
    } // evSiteTemplate_Controller constructor
}