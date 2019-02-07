@isTest
public class evCalendarComp_Controller_test
{
    /****************************************************************************
* @Author     : Daniel Field
* @Date       : 13/11/2016
* @Description: Controller class used for the caseware CQS_TrainingCalendar_Controller
* @Purpose    : Test class
* @Class 	  : CQS_TrainingCalendar_Controller 
//----------------------------------------------------------------------------*/
    
    static testMethod void evCalendarComp_Controller_test()
    {
        
        evTestDataGenerator TDG = new evTestDataGenerator();
        TDG.TestEvent.Capacity__c = 0;
        update TDG.TestEvent;
        
        recordType FunctionRecType = 
            [
                SELECT
                id,
                name
                from
                recordType
                where
                developerName = 'Function'
                AND
                SobjectType = 'Event__c'
            ];
        
        TDG.TestEvent.recordtypeID = FunctionRecType.id;
        UPdate TDG.TestEvent;
        
        datetime startdate;
        startdate =  datetime.now();
        datetime enddate ;
        enddate =  datetime.now();
        enddate = enddate.addDays(31);
        
        PageReference pageRef = Page.evEventCalendar;
        Test.setCurrentPage(pageRef);    	    	
        
        evCalendarComp_Controller ConTest = new evCalendarComp_Controller();
        
        system.debug('startdate.getTime() :  '+ startdate.getTime());
        
        evCalendarComp_Controller.getEvents(TDG.TestEvent.id, startdate.getTime()/1000, enddate.getTime()/1000, '', '','','');
        
    }
    
}