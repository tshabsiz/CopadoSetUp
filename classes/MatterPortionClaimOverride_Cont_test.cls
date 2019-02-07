@Istest
public class MatterPortionClaimOverride_Cont_test {
    public static testMethod void testAddPortion() {
        Cloudsmiths_TestDataClass cloudsmiths_TestDataClass = new Cloudsmiths_TestDataClass();
       	
        Test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.MatterPortionClaimOverride'));
		System.currentPageReference().getParameters().put('id', cloudsmiths_TestDataClass.TestMatter.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cloudsmiths_TestDataClass.TestMatter);
        MatterPortionClaimOverride_Cont testPortionClaim = new MatterPortionClaimOverride_Cont(sc);
        
        Business_Unit_Claim__c bu = new Business_Unit_Claim__c();
        bu.Matter__c = cloudsmiths_TestDataClass.TestMatter.id;
        bu.Business_Unit__c = cloudsmiths_TestDataClass.TestBusinessUnit.id;
        bu.Portion_of_Claim__c = 80;
        
        insert bu;
        
        Business_Unit_Claim__c abu = new Business_Unit_Claim__c();
        abu.Matter__c = cloudsmiths_TestDataClass.TestMatter.id;
        abu.Business_Unit__c = cloudsmiths_TestDataClass.TestBusinessUnit.id;
        abu.Portion_of_Claim__c = 20;
        
        testPortionClaim.addedBusinessUnitClaims.add(bu);
        testPortionClaim.addBusinessUnitClaims = abu;
            
        testPortionClaim.save();
        testPortionClaim.addClaimButton();
        
        testPortionClaim.claimId = bu.id;
        testPortionClaim.removeClaim();
        
        Business_Unit_Claim__c bu2 = new Business_Unit_Claim__c();
        bu2.Matter__c = cloudsmiths_TestDataClass.TestMatter.id;
        bu2.Business_Unit__c = cloudsmiths_TestDataClass.TestBusinessUnit.id;
        bu2.Portion_of_Claim__c = 80;
        testPortionClaim.addedBusinessUnitClaims.add(bu2);

        testPortionClaim.updateClaims();
        
        Test.stopTest();
    }
}