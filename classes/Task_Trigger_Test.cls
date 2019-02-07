/**
* Date   : 2017-01-13
* Author : RN - CloudSmiths
* Desc   : Task trigger Test class
**/

@isTest
public class Task_Trigger_Test {

    public static testMethod void taksTriggerTest(){
        
        //Test Data
        //Cloudsmiths_TestDataClass  testData = new Cloudsmiths_TestDataClass();

        CSC_TestDataFactory.testDataSize = 1;
        
        //test data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        Contact c = CSC_TestDataFactory.getDefaultEmailSupportContact();
        Database.DMLOptions dml = new Database.DMLOptions();
                                    
        dml.DuplicateRuleHeader.AllowSave = true;
        
        Database.SaveResult sr = Database.insert(c, dml);
        //insert c;

        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList('Complaint', UserInfo.getUserId());
        caseInsertList[0].Queue__c = 'Complaints Client';
        //caseInsertList[0].Department__c = 'EBSH';
        caseInsertList[0].Service_Type__c = 'Delays';
        caseInsertList[0].Service_Sub_Category__c = 'Takes to Long';
        caseInsertList[0].Service_Category__c = 'Complaint';
        caseInsertList[0].Division__c = 'CIB';
        caseInsertList[0].Business_Area__c = 'Banking';
        caseInsertList[0].Nature_Of_Complaint__c = 'Formal'; 
        //caseInsertList[0].ContactId = c.Id;        
        insert caseInsertList;

        Test.startTest();

        System.debug('Limit:'+Limits.getQueries());
        
        list<Task> taskList = new list<Task>();
        
        Task openTask = new Task();
        openTask.Description = 'New Open Task';
        openTask.Priority = 'Low';
        openTask.Status = 'Open';
        openTask.WhatId = caseInsertList[0].Id;
        openTask.Subject = 'Call';
        taskList.add(openTask);
        
        Task openTask2 = new Task();
        openTask2.Description = 'New Open Task2';
        openTask2.Priority = 'Low';
        openTask2.Status = 'Open';
        openTask2.WhatId = caseInsertList[0].Id;
        openTask2.Subject = 'Call';
        taskList.add(openTask2);
        
        insert taskList;        
        
        
        Case assertCase = [Select Id, Number_of_Open_Tasks__c From Case Where Id = :caseInsertList[0].Id];
        taskList[0].Status = 'Completed';
        update taskList[0];
        
        assertCase = [Select Id, Number_of_Open_Tasks__c From Case Where Id = :caseInsertList[0].Id];
        System.assertEquals(0, assertCase.Number_of_Open_Tasks__c);
        
        delete taskList[1];
        
        assertCase = [Select Id, Number_of_Open_Tasks__c From Case Where Id = :caseInsertList[0].Id];
        System.assertEquals(0, assertCase.Number_of_Open_Tasks__c);
        
        Test.stopTest();       
    }
    
    public static testMethod void testConditionChases()
    {    
        //Test Data
        Cloudsmiths_TestDataClass  testData = new Cloudsmiths_TestDataClass();

        Test.startTest();        

        Limits.getQueries();
        
        //New Task
        Task openTask = new Task();
        openTask.Description = 'New Open Task2';
        openTask.Priority = 'Low';
        openTask.Status = 'Open';
        openTask.WhatId = testData.TestConditionOccurrence.Id;
        openTask.Subject = 'Call';
        //insert openTask;

        //Different user.        
        User diffUser = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');        
        
        //New Task
        Task openTask2 = new Task();
        openTask2.Description = 'New Open Task2';
        openTask2.Priority = 'Low';
        openTask2.Status = 'Open';
        openTask2.WhatId = testData.TestConditionOccurrence.Id;
        openTask2.Subject = 'Call';
        
        System.runAs(diffUser)
        {
            insert openTask2;
        }

        delete openTask2;

        Test.stopTest();
    }

}