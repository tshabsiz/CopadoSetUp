/**
* @Author:        Dino Scarcella
* @Company:       Absa Capital
* @Description:   Unit Tests for New Opportunity From Task Controller (lightning button on task layout)
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ------------------------------------------------------------------------------------------------------*/
@isTest
public class NewOpportunityFromTaskController_Test {
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
    	Task task = new Task(
            Status = 'Converted',
            WhatId = acc1.Id
        );
        insert task;
	}
    
	public static testMethod void testGetTaskFields() {
        Task newTask = [SELECT Id, Status, What.RecordType.Name FROM Task LIMIT 1];
        Task queryTask = NewOpportunityFromTaskController.getTaskFields(newtask.Id);
        System.assertEquals(newTask.Id, queryTask.Id);
        System.assertEquals(newTask.Status, queryTask.Status);
        System.assertEquals(newTask.What.RecordType.Name, queryTask.What.RecordType.Name);
    }
    
    public static testMethod void testFetchRecordTypeValues() {
        List<Schema.RecordTypeInfo> recordtypes = Opportunity.SObjectType.getDescribe().getRecordTypeInfos();    
        Map<Id, String> recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master' && rt.isAvailable())
            recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }
        
        List<String> recordtypevalues = NewOpportunityFromTaskController.fetchRecordTypeValues();
        System.assertEquals(recordtypemap.values().size(), recordtypevalues.size());
        
        Id actual_recid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordtypevalues[0]).getRecordTypeId();
        Id expected_recid = NewOpportunityFromTaskController.getRecTypeId(recordtypevalues[0]);
        System.assertEquals(actual_recid, expected_recid);
    }
}