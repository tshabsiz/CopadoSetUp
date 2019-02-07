/**
@author : Mabhedle Tonga
@since: 2018-11-16
@description: Test Class for BriefingNoteController
*/
@isTest
public class BriefingNoteControllerTest {

    static testMethod void myUnitTest()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Call_Report callReportFactory = ZZTEST_DataFactoryFacade.callReport;

		Test.startTest();

        Call_Report__c callRep = callReportFactory.getInsertedProduct(ZZTEST_F_Call_Report.CallReportRecordType.DEFAULT_CALL_REPORT, 
            dataContainer);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(callRep);
        BriefingNoteController BC = new BriefingNoteController(sc);
        
        BC.getClientAttendee();
        BC.getStuffAttendee();
        BC.getClientPlan();
        BC.getOpportunities();
        
        System.assertEquals(callRep.ID, BC.callReport.Id);
        
        
        Test.stopTest();
    }
}