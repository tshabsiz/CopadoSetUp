@isTest
public class CollateralControllerExtension_test {
    
    public static testmethod void TestControllerSave() {

        Test.startTest();

       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();

        Test.stopTest();
    }
    
    public static testmethod void TestControllerWithNullSDSId() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Collateral__c collateral = AcmCollateralTestData.TestCollateral;
        collateral.Beneficiary__c = AcmCollateralTestData.TestAccountWithoutSDS.Id;
        ApexPages.StandardController collateralController = new ApexPages.StandardController(collateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();

        Test.stopTest();
    }
    
    public static testmethod void TestControllerSaveWithFacilityScope() {

        Test.startTest();

       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(acmCollateralTestData.TestCollateralFacilityScope);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();

        Test.stopTest();
    }
    
    public static testmethod void TestControllerGetCollateralGroups() { 

        Test.startTest();

       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(acmCollateralTestData.TestCollateralFacilityScope);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.getCollateralGroups();

        Test.stopTest();
    }
    
    public static testmethod void TestControllerGetCollateralTypes() {
         Test.startTest();

       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(acmCollateralTestData.TestCollateralFacilityScope);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.getCollateralTypes();
        
        Test.stopTest();
    }
    
    public static testmethod void TestControllerWithUnSavedCollateralAndCallWebservice() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(acmCollateralTestData.TestCollateralUnsaved);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestControllerCancel() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(acmCollateralTestData.TestCollateralUnsaved);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.Cancel();
        Test.stopTest();
    }
    
    public static testmethod void TestControllerWithUnSavedErroneousCollateral() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Collateral__c TestCollateralUnsavedErroneous = acmCollateralTestData.TestCollateralUnsaved;
        TestCollateralUnsavedErroneous.Beneficiary__c = null;
        TestCollateralUnsavedErroneous.Scope__c = 'Beneficiary';       
        ApexPages.StandardController collateralController = new ApexPages.StandardController(TestCollateralUnsavedErroneous);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
        Test.stopTest();
    }
    
    
	public static testmethod void TestControllerSaveNew() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(acmCollateralTestData.TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.saveNew();
        Test.stopTest();
    }
    
   public static testmethod void TestControllerCallWebsrvice() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(acmCollateralTestData.TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
       Test.stopTest();
    }
    
   public static testmethod void TestControllerGetAndCreateFacilities() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(acmCollateralTestData.TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.GetAndCreateFacilities();
        Test.stopTest();
    }
    
   public static testmethod void TestControllerValidationOptions() {
		Test.startTest();
    
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Collateral__c TestCollateral = acmCollateralTestData.TestCollateralUnsaved;
        // When collateral Type does not match collateral Group
        Collateral_Group__c TestCollateralGroupUnMatch = new Collateral_Group__c
            (
                Name = 'AVIATION BOND',
                Credit_Code__c = 'AVIATION_BOND'
            );
        Insert TestCollateralGroupUnMatch;
        TestCollateral.Collateral_Group__c =  TestCollateralGroupUnMatch.Id;
        ApexPages.StandardController collateralController = new ApexPages.StandardController(TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
       
        // When collateral Type is null
        TestCollateral.Collateral_Type1__c = null;
        collateralController = new ApexPages.StandardController(TestCollateral);
        collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();

       //When released with no supporting docs
        TestCollateral.Supporting_Documentation_Uploaded__c = false;
        TestCollateral.Status__c = 'Released';
        collateralController = new ApexPages.StandardController(TestCollateral);
        collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
       

       //When Facility does not match facility beneficiary
        Collateral__c testCollateralFacilityScope = acmCollateralTestData.TestCollateralFacilityScope;
        testCollateralFacilityScope.Facility_Client__c = acmCollateralTestData.TestAccountWithoutSDS.Id;
 		collateralController = new ApexPages.StandardController(testCollateralFacilityScope);
        collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
       
        //When Value type is limited but value is null
        testCollateralFacilityScope = acmCollateralTestData.TestCollateralFacilityScope;
        testCollateralFacilityScope.Value_Type__c = 'Limited';
        testCollateralFacilityScope.Value__c = null;
 		collateralController = new ApexPages.StandardController(testCollateralFacilityScope);
        collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
       
       // When provider has null SDS
        testCollateralFacilityScope = acmCollateralTestData.TestCollateralFacilityScope;
        testCollateralFacilityScope.Account__c = acmCollateralTestData.TestAccountWithoutSDS.Id;
 		collateralController = new ApexPages.StandardController(testCollateralFacilityScope);
        collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();

        Test.stopTest();
   }
    
     public static testmethod void TestControllerValidationOtherOptions() {
       	Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Collateral__c TestCollateral = acmCollateralTestData.TestCollateralUnsaved;
        // When providers change
        TestCollateral = acmCollateralTestData.TestCollateral;
 		ApexPages.StandardController collateralController = new ApexPages.StandardController(TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        TestCollateral.Account__c = acmCollateralTestData.TestAccountChanged.Id;
        collateralControllerExtension.save();
       
        // When beneficiaries change
        TestCollateral = acmCollateralTestData.TestCollateral;
 		collateralController = new ApexPages.StandardController(TestCollateral);
        collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        TestCollateral.Beneficiary__c = acmCollateralTestData.TestAccountChanged.Id;
        collateralControllerExtension.save();
        Test.stopTest();
     }
    
    public static testmethod void TestControllerValidationFacilityChange() {
        // When facilities change
        Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Collateral__c TestCollateral = acmCollateralTestData.TestCollateralUnsaved;
        Collateral__c testCollateralFacilityScope = acmCollateralTestData.TestCollateralFacilityScopeWithoutFacility;
        
 		ApexPages.StandardController collateralController = new ApexPages.StandardController(testCollateralFacilityScope);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        testCollateralFacilityScope.AcmFacility__c = acmCollateralTestData.TestAcmFacilityChange.Id;
        collateralControllerExtension.save();
        Test.stopTest();
    }
    
    public static testmethod void TestControllerValidationOptionsStatusFiveHundred() {
        Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Collateral__c TestCollateral = acmCollateralTestData.TestCollateralUnsaved;
        ApexPages.StandardController collateralController = new ApexPages.StandardController(TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        
        AcmIntegration__c status500 = acmCollateralTestData.TestAcmIntegration;
        status500.POST_URL__c = 'http:\\test.url\FiveHundred';
        update status500;
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        collateralController = new ApexPages.StandardController(AcmCollateralTestData.testCollateralFacilityScope);
        collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
   
        collateralControllerExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestControllerValidationOptionsStatusFourHundred() {
        Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Collateral__c TestCollateral = acmCollateralTestData.TestCollateralUnsaved;
        ApexPages.StandardController collateralController = new ApexPages.StandardController(TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        
        // When status is 400
        AcmIntegration__c status400 = acmCollateralTestData.TestAcmIntegration;
        status400.POST_URL__c = 'http:\\test.url\FourHundred';
        update status400;
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        collateralController = new ApexPages.StandardController(AcmCollateralTestData.testCollateralFacilityScope);
        collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();

        collateralControllerExtension.CallWebService();
        Test.stopTest();
    }
    
   public static testmethod void TestAcmCollateralTriggerAfter() {
        Test.startTest(); 
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Collateral__c TestCollateralOne = acmCollateralTestData.TestCollateralUnsaved;
        Collateral__c TestCollateralTwo = acmCollateralTestData.TestCollateralUnsavedBenef;
        List<Collateral__c> collateralInserts  = new List<Collateral__c>();
        collateralInserts.add(TestCollateralOne);
       	collateralInserts.add(TestCollateralTwo);
        Insert collateralInserts;
       
        update collateralInserts;
        Test.stopTest();
    }
    
    public static testmethod void TestControllerCallWebsrviceScopeChange() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController collateralController = new ApexPages.StandardController(acmCollateralTestData.TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
       Test.stopTest();
    }
    
    public static testmethod void TestControllerWithUnSavedErroneousCollateralScopeFac() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Collateral__c TestCollateral = new Collateral__c
            (
                Scope__c = 'Beneficiary',
                Name = 'Collateral Test',
                Status__c = 'Outstanding',
                Account__c = acmCollateralTestData.TestAccount.Id,
                Beneficiary__c = acmCollateralTestData.TestAccount.Id,
                Collateral_Group__c = acmCollateralTestData.TestCollateralGroup.Id,
                Collateral_Type1__c = acmCollateralTestData.TestCollateralType.Id
            );     
        ApexPages.StandardController collateralController = new ApexPages.StandardController(TestCollateral);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestControllerCollateralChangeScope() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();   
        Collateral__c Cl = acmCollateralTestData.TestCollateral;
        CL.Scope__c = 'Facility';
        CL.Facility_Client__c = acmCollateralTestData.TestAccount.Id;
        CL.ACMFacility__c = acmCollateralTestData.TestAcmFacility.Id;
        update CL;
        ApexPages.StandardController collateralController = new ApexPages.StandardController(Cl);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestControllerCollateralChangeScopeBen() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();   
        Collateral__c Cl = acmCollateralTestData.TestCollateralFacilityScope;
        CL.Scope__c = 'Beneficiary';
        CL.Beneficiary__c = acmCollateralTestData.TestAccountChanged.Id;
        update CL;
        ApexPages.StandardController collateralController = new ApexPages.StandardController(Cl);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestControllerCollateralChangeScopeBenActive() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();   
        Collateral__c Cl = acmCollateralTestData.TestCollateral;
        Collateral_Relationship__c Cr = acmCollateralTestData.TestCollateralRelationshipBeneficiary;
        cr.Active__c = true;  
        cr.isPrimaryRelationship__c = true;
        update Cr;
            
        ApexPages.StandardController collateralController = new ApexPages.StandardController(Cl);
        CollateralControllerExtension collateralControllerExtension = new CollateralControllerExtension(collateralController);
        collateralControllerExtension.save();
        collateralControllerExtension.CallWebService();
        Test.stopTest();
    }
}