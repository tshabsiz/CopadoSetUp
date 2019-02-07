@isTest
public class BxdAgreementPermission_test {
    public static Map <String, Schema.RecordTypeInfo> mapAgreementRecordTypes = Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public static testMethod void TestAgreementPermissionController()
	{
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
		ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestAgreement);
		BxdAgreementPermission page = new BxdAgreementPermission(sc);

		//Main method.
		PageReference actionView = page.actionViewRoute();
        system.assert(actionView != null);
	}
    
    public static testMethod void TestAgreementPermissionMTController()
	{
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        Agreement__c TestAgreement = new Agreement__c();    
        TestAgreement.Matter_Deal__c =  testDataClass.TestMatter.Id;
        TestAgreement.Name = 'Agreement Test';
        TestAgreement.Agreement_Type__c =  testDataClass.TestProductAgreement.id;
        TestAgreement.TMG_Product_Level_3__c = testDataClass.TestProductLevel3.id;
        TestAgreement.Signature_Date__c = Date.today().addDays(5);
        TestAgreement.Effective_Date__c = Date.today().addDays(5);
        TestAgreement.RecordTypeId = mapAgreementRecordTypes.get('Prime Services Agreement').getRecordTypeId();
        TestAgreement.Limit__c = 10000;
        insert TestAgreement;
        
		ApexPages.StandardController sc = new ApexPages.standardController(TestAgreement);
		BxdAgreementPermission page = new BxdAgreementPermission(sc);

		//Main method.
		PageReference actionView = page.actionViewRoute();
        system.assert(actionView != null);
	}
}