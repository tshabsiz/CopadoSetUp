/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for CallReportTrigger
*/
@isTest
private class ZZTEST_CallReportTrigger {

	public static testMethod void testCreateEmployeeAttendee() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Call_Report callReportFactory = ZZTEST_DataFactoryFacade.callReport;

		Test.startTest();

        Call_Report__c callRep = callReportFactory.getInsertedProduct(ZZTEST_F_Call_Report.CallReportRecordType.DEFAULT_CALL_REPORT, 
            dataContainer);

		Attendee__c attendee = [SELECT Id, Name, Barclays_Attendee__c FROM Attendee__c WHERE Call_Report__c = :callRep.Id];
		Call_Report__c callRepIns = [SELECT Id, Name, OwnerId FROM Call_Report__c WHERE Id = :callRep.Id];

		System.assertEquals(attendee.Barclays_Attendee__c, callRepIns.OwnerId);
		
		Test.stopTest();
	}

	public static testMethod void testCreateEmployeeAttendeeBatch() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select Id from user where Id=:UserInfo.getUserId()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Call_Report callReportFactory = ZZTEST_DataFactoryFacade.callReport;
            List<Call_Report__c> callReps =  new List<Call_Report__c>();
            
            Test.startTest();
            
            for(Integer i=0; i<=200; i++){
                callReps.add(callReportFactory.getProduct(ZZTEST_F_Call_Report.CallReportRecordType.DEFAULT_CALL_REPORT, dataContainer));
            }
            
            insert callReps;
            List<Attendee__c> attendees = [SELECT Id, Name FROM Attendee__c];
            System.assertEquals(attendees.size(), 201);
            
            Test.stopTest();    
        }
        
	}

}