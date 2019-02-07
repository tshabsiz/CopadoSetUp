@isTest(SeeAllData=false)
public class Condition_Occurrence_Override_Test {

	public static testMethod void testController() 
	{	
		//Setup data data
		BXDtesclassdata.setupFolder();
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

		ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestConditionOccurrence);
		Condition_Occurrence_Override test = new Condition_Occurrence_Override(sc);
        
        //Insert Box Documents
        BoxDocument__c testBoxDocument = new BoxDocument__c(
            Box_Location__c = 'https://test.com',
            Condition_Occurrence__c = testDataClass.TestConditionOccurrence.id,
            Upload_Date__c = System.today(),
        	PII__c = 'Yes');
		insert testBoxDocument;
        
        Condition_Occurrence__c updateConditionOccurence = new Condition_Occurrence__c();
        
        updateConditionOccurence.id = testDataClass.TestConditionOccurrence.id;
        updateConditionOccurence.Comments__c = 'Testing 123';
        Update updateConditionOccurence;

		//Methods
		test.actionViewRoute();
		test.actionEditRoute();
	}
}