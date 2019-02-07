@isTest
public class evEventCalendar_Controller_test 
{
    static testMethod void evCalendarComp_Controller_test()
    {
        evEventCalendar_Controller tempCon = new evEventCalendar_Controller();
        tempCon.getCitySelectOptions();
        tempCon.getEventTypeSelectOptions();
    }
}