/*****************************************************************************************************\
@ Author        : Tracy de Bruin
@ Date          : 14/06/2016
@ Class Testing : 
------------------------------------------------------------------------------------------------------
@ Modified By   : 
@ Date          : 
@ Description   : 
------------------------------------------------------------------------------------------------------
******************************************************************************************************/
@isTest(SeeAllData=false)
public class TimeSheetEntries_Cont_Test 
{
	public static testMethod void testController()
	{
		Date weekstart = Date.today().toStartOfWeek();
		//User u = [SELECT Id FROM User WHERE isActive = true AND Profile.Name LIKE '%Legal%' LIMIT 1]; 

		//System.runAs(u)
		//{
			advpm__Timekeeper__c testTimekeeper = new advpm__Timekeeper__c(advpm__Staff__c = UserInfo.getUserId());
        
			insert testTimekeeper;

			List<advpm__Time__c> testTime = new List<advpm__Time__c>();

			for(Integer i = 0; i < 8; i++)
			{
				testTime.add(new advpm__Time__c(advpm__Entry_Date__c = weekstart.addDays(i), advpm__Timekeeper__c = testTimekeeper.Id));
			}
			
			insert testTime;

			//advpm__Matter__c testMatter = new advpm__Matter__c(OwnerId = u.Id);
			//insert testMatter;

			//advpm__Participant__c testParticipant = new advpm__Participant__c(advpm__Matter__c = testMatter.Id, advpm__Staff__c = u.Id, advpm__Role__c = 'Matter Owner');
			//insert testParticipant;

			ApexPages.StandardController std = new ApexPages.StandardController(testTime[0]);
			TimeSheetEntries_Cont ctrl = new TimeSheetEntries_Cont(std);
			Test.setCurrentPage(Page.TimeSheetEntries);

			ctrl.CancelPage();
			ctrl.changeDate();
			ctrl.getTimesheetDataTable();
			ctrl.getWeekItemTotal();
			ctrl.getCategoryList();
			ctrl.getMatterList();
			ctrl.evt.advpm__Entry_Date__c = weekstart.addDays(1);
			ctrl.changeDate();
			ctrl.getTimesheetDataTable();
			ctrl.AddTimeEntry();

			ApexPages.currentPage().getParameters().put('index', '0');
			ctrl.RemoveTimeEntry();

			ctrl.SaveTimeEntry();
		//}		
	}
    
    public static testMethod void createTimeEntryTest()
	{
		advpm__Time__c placHolderTime = new advpm__Time__c();
        advpm__Time__c timesheetWrap = new advpm__Time__c();
		date myDate = date.newInstance(2018, 02, 08);

		//timesheetWrap = null;

		//timesheetWrap.advpm__Time_In_Hours__c = 8;

		timesheetWrap.name = 'TestName';
		timesheetWrap.advpm__Billing_Status__c = 'Unprocessed';
		timesheetWrap.advpm__Entry_Date__c = myDate;

		//     timesheetWrap.advpm__Matter__c = placHolderTime.matterId;

		placHolderTime.Cluster__c = 'ClusterName';
		placHolderTime.Segment__c = 'SegmantTest';
		placHolderTime.advpm__Description__c = 'DescTest';

		TimeSheetEntries_Cont cont_test = new TimeSheetEntries_Cont();
		advpm__Time__c sheetEntries_contTest = new advpm__Time__c();
		sheetEntries_contTest = cont_test.createTimeEntry(placHolderTime,timesheetWrap,myDate);
	}
}