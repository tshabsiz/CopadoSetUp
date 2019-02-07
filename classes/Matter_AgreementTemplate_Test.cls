/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***
11/01/2018 - PG     - Not sure what or who create this test, however testData was in the incorrect place.   Corrected this now. 

**/ 
@isTest(SeeAllData=false)
private class Matter_AgreementTemplate_Test 
{
	static testMethod void testFromDeal()
	{
        //Test Data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

        Test.startTest();        

        //VF page
        PageReference pageRef = Page.Matter_AgreementTemplate;
        Test.setCurrentPage(pageRef);

        //Page params
        ApexPages.currentPage().getParameters().put('Id', testDataClass.TestMatter.Id);
        ApexPages.currentPage().getParameters().put('agreementId', null);

        //Controller
        Matter_AgreementTemplate controller = new Matter_AgreementTemplate();  

        System.debug('### Matter_AgreementTemplate_Test : productAgreementsWrapper :'+controller.productAgreementsWrapper);

        controller.actionEntryHandler();

        //Select an agreement template.
        controller.productAgreementsWrapper[0].selected = true;

        //Main methods
        controller.actionCreateAgreements();

        System.debug('### Matter_AgreementTemplate_Test : controller.agreementConditionWrappers : '+controller.agreementConditionWrappers);
        
        //Select condition.
        controller.agreementConditionWrappers[0].conditions[0].selected = true;
        controller.agreementConditionWrappers[0].conditions[1].selected = true;

        //Bulk update conditions
        controller.actionBulkUpdate();

        //Make condition invalid i.e. cause failure.
        controller.agreementConditionWrappers[0].conditions[0].condition.Active__c = true;
        controller.agreementConditionWrappers[0].conditions[0].condition.Due_Date__c = Date.today().addDays(-30);

        controller.actionSaveConditions();        
        controller.getFilterOptions();
        controller.actionFilterConditions();
        controller.actionFilterRecurrence();
        controller.actionFilterDate();
        controller.actionLoadValidation();
        controller.Searchagreement();
        controller.GenerateSearchAgreements();
        
        
        controller.actionCancel(); 

        Test.stopTest();
	}

    static testMethod void testFromAgreement()
    {
        //Test Data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

        Test.startTest();        

        //VF page
        PageReference pageRef = Page.Matter_AgreementTemplate;
        Test.setCurrentPage(pageRef);

        //Page params
        ApexPages.currentPage().getParameters().put('Id', null);
        ApexPages.currentPage().getParameters().put('agreementId', testDataClass.TestAgreement.Id);

        //Controller
        Matter_AgreementTemplate controller = new Matter_AgreementTemplate();  

        System.debug('### Matter_AgreementTemplate_Test : productAgreementsWrapper :'+controller.productAgreementsWrapper);

        controller.actionEntryHandler();

        //Main methods
        controller.actionCreateAgreements();
        
        controller.getFilterOptions();
        controller.actionFilterConditions();
        controller.actionBulkUpdate();
        controller.actionSaveConditions();
        controller.actionCancel(); 

        Test.stopTest();
    }
}