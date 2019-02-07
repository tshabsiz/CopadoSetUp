@isTest(SeeAllData=false)
private class Matter_Litigation_Controller_Test 
{	
    static testMethod void testController()
    {         
        //Test Data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        
        Test.startTest();

        Test.setCurrentPage(Page.Matter_Override_Litigation);
        Matter_Override_Litigation_Controller ctrl = new Matter_Override_Litigation_Controller();
        ApexPages.currentPage().getParameters().put('retUrl', '/home/home.jsp');

        ctrl.matterRec = testDataClass.TestMatter;
        
        ctrl.clearFinancial();        
        
        ctrl.matterRec.Claim_By_Against_Barclays__c = 'Claim By Barclays';
        ctrl.claimTypeChange();
        
        ctrl.matterRec.Claim_By_Against_Barclays__c = 'Claim Against Barclays';
        ctrl.claimTypeChange();
        
        ctrl.addClaim();        
        ctrl.addParticipant();        
        ctrl.getClaims();
        ctrl.getParticipants();        
        ctrl.removeClaim();        
        ctrl.removeParticipant();
        
        ctrl.matterRec.Name = 'Test';
        ctrl.matterRec.advpm__Description__c = 'Test';
        
        ctrl.searchDupes();
        for(Business_Unit_Claim__c ClaimRec  : ctrl.claims)
        {
            ClaimRec.Business_Unit__c  = testDataClass.TestBusinessUnit.Id;
            ClaimRec.Portion_of_Claim__c = 100;            
        }
        
        ctrl.done();
        apexpages.getmessages().clear();

        ctrl.createBox();
        apexpages.getmessages().clear();  

        //ctrl.saveParticipants();
        
        ctrl.cancel();        
        apexpages.getmessages().clear();
        
        Test.stopTest();
    }	
}