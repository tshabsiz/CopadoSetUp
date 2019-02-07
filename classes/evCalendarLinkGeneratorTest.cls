@isTest
public class evCalendarLinkGeneratorTest 
{
    static testMethod void evCalendarLinkGeneratorTest() 
    {
        evTestDataGenerator TestDataCon = new evTestDataGenerator();
        evCalendarLinkGenerator con = new evCalendarLinkGenerator();
        con.delegateId = TestDataCon.TestDelegate.id;
        con.linkImage = 'test';
        con.getCalendarLink();
        con.getShowImage();
        con.setShowImage(true);
        
    }
}