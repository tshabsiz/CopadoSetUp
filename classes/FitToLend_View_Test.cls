@isTest(SeeAllData=false)
private class FitToLend_View_Test 
{
        static testMethod void testController()
        {
            Map <String, Schema.RecordTypeInfo> mapConditionRecordTypes = Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
            Test.startTest();
            
            //Test Data
            Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
            testDataClass.testCondition.Active__c = True;
            testDataClass.testCondition.recordTypeID = mapConditionRecordTypes.get('Governance Check').getRecordTypeId()  ;
        	upsert testDataClass.testCondition;
            
        	ConditionSchedulingSettings__c setting  = new ConditionSchedulingSettings__c(Name = 'Default', Months_In_Advance__c = 1, Business_Hours__c = 'Default');
            insert setting;

            Contact random = new Contact(LastName = 'Smit', FirstName = 'Jan', Email = 'test@fakeDomain.com');
            insert random;

            Fit_To_Lend_Checklist__c testRecord = new Fit_To_Lend_Checklist__c(Deal__c = testDataClass.TestMatter.Id, Status__c = 'New');
            insert testRecord;
            
            Notification_Group__c TestNotificationGroup_F2L_Public = new Notification_Group__c
            (
                Distribution_Group__c = testDataClass.TestDistroGroupPublic.Id,
                Fit_To_Lend__c = testRecord.Id
            ); 
       	 	insert TestNotificationGroup_F2L_Public;
            
            Notification_Participant__c TestNotificationParticipant =  new Notification_Participant__c
            (
                Fit_To_Lend_Checklist__c = testRecord.id,
                Participant__c = testDataClass.TestParticipant1.id 
            );
            insert TestNotificationParticipant;

            Test.setCurrentPage(Page.FitToLendChecklist_View);
            ApexPages.currentPage().getParameters().put('fid', testRecord.Id);
            ApexPages.currentPage().getParameters().put('id', testDataClass.TestMatter.Id);
            FitToLend_View ctrl = new FitToLend_View();

            ctrl.DoUpdateAndGoToApprovalSubmitPage();
            ctrl.DoCancel();
            ctrl.DoUpdate();

            Test.stopTest();
        }
    
    static testMethod void testNotifyOnly()
        {

            //Test Data
            Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        
        	ConditionSchedulingSettings__c setting  = new ConditionSchedulingSettings__c(Name = 'Default', Months_In_Advance__c = 1, Business_Hours__c = 'Default');
            insert setting;

            Contact random = new Contact(LastName = 'Smit', FirstName = 'Jan', Email = 'test@fakeDomain.com');
            insert random;

            Fit_To_Lend_Checklist__c testRecord = new Fit_To_Lend_Checklist__c(Deal__c = testDataClass.TestMatter.Id, Status__c = 'New');
            insert testRecord;
            
            Notification_Group__c TestNotificationGroup_F2L_Public = new Notification_Group__c
            (
                Distribution_Group__c = testDataClass.TestDistroGroupPublic.Id,
                Fit_To_Lend__c = testRecord.Id
            ); 
       	 	insert TestNotificationGroup_F2L_Public;
            
            Notification_Group__c TestNotificationGroup_F2L_Public2 = new Notification_Group__c
            (
                Distribution_Group__c = testDataClass.TestDistroGroupPrivate.Id,
                Fit_To_Lend__c = testRecord.Id
            ); 
       	 	insert TestNotificationGroup_F2L_Public2;
            
            Notification_Participant__c TestNotificationParticipant =  new Notification_Participant__c
            (
                Fit_To_Lend_Checklist__c = testRecord.id,
                Participant__c = testDataClass.TestParticipant1.id 
            );
            insert TestNotificationParticipant;

            Test.setCurrentPage(Page.FitToLendChecklist_View);
            ApexPages.currentPage().getParameters().put('fid', testRecord.Id);
            ApexPages.currentPage().getParameters().put('id', testDataClass.TestMatter.Id);
            FitToLend_View ctrl = new FitToLend_View();

            Test.startTest();
            
            ctrl.DoUpdateAndNotifyOnly();
            Test.stopTest();
        }
}