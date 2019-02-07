@isTest(SeeAllData=false)
public class ConvertCaseToMatter_Cont_Test {
	
	public static testMethod void controllerTest () 
	{
		//Setup data data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

		Map<String, Schema.RecordTypeInfo> mapCaseRecordTypes = Case.sObjectType.getDescribe().getRecordTypeInfosByName();          

		Test.startTest();

		Limits.getQueries();

		//CASE - LEGAL
        Case TestCaseLegal = new Case
        (
            Division__c = 'CIB',
            Business_Area__c = 'Banking',
            RecordTypeId = mapCaseRecordTypes.get('Query/Matter Request').getRecordTypeId()
        );
        insert TestCaseLegal;  

		//Convert page + Params
		PageReference pageRef = Page.ConvertCaseToMatter;
		Test.setCurrentPage(pageRef);

		//Add parameters to URL.
		ApexPages.currentPage().getParameters().put('caseId', TestCaseLegal.Id);

		//standard controller
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testDataClass.TestMatter);

    	//ext controller
		ConvertCaseToMatter_Cont extController = new ConvertCaseToMatter_Cont(stdController);

		//Add parameters to URL.
		ApexPages.currentPage().getParameters().put('caseId', TestCaseLegal.Id); 

		//Convert method
		extController.convertCaseToMatter();

		Test.stopTest();
	} 
}