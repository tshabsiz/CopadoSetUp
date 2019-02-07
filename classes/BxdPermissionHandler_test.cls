@Istest
public class BxdPermissionHandler_test {
    
    public static testmethod void BxdPermissionHandler(){      
        test.startTest();
        BXDtesclassdata.setupFolder();  
        BXDTestclassData2.Cloudsmiths_TestDataClass();
        Account acc = [select id from Account limit 1];
        String userId = UserInfo.getUserId();
        
        BxdPermissionHandler BxdPermissionHandler = new BxdPermissionHandler();
        BxdPermissionHandler.createPermissionForUser(acc.Id);
        BxdPermissionHandler.createPermissionForUser(acc.Id,userId);
        
        test.stopTest();
    }
    
    public static testmethod void BxdPermissionHandler1() {     
        test.startTest();
        BXDtesclassdata.setupFolder();  
        BXDTestclassData2.Cloudsmiths_TestDataClass();
        Account acc = [select id from Account limit 1];
        
        User U = [Select id, ProfileId from User Where Isactive=True AND Profile.Name='Barclays Read Only' limit 1];
        
        BxdPermissionHandler BxdPermissionHandler = new BxdPermissionHandler();
        BxdPermissionHandler.createPermissionForUser(acc.Id);
        BxdPermissionHandler.createPermissionForUser(acc.Id,U.Id);	
        
        
        test.stopTest();
    }
    
    public static testmethod void BxdPermissionHandler2(){      
        test.startTest();
        BXDtesclassdata.setupFolder();  
        BXDTestclassData2.Cloudsmiths_TestDataClass();
        Account acc = [select id from Account limit 1];
        
        User U = [Select id, ProfileId from User Where Isactive=True AND Profile.Name='System Administrator' limit 1];
        
        BxdPermissionHandler BxdPermissionHandler = new BxdPermissionHandler();
        BxdPermissionHandler.createPermissionForUser(acc.Id);	
        
        BxdPermissionHandler.createPermissionForUser(acc.Id,U.Id);
        test.stopTest();
    }
    
    public static testmethod void testPagePermissions() {      
        BXDtesclassdata.setupFolder();
        PageReference actionView;
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        //FACILITY
        ApexPages.StandardController facilityCtrl = new ApexPages.standardController(testDataClass.TestFacility);
        BxdFacilityPermission facilityPage = new BxdFacilityPermission(facilityCtrl);
        
        actionView = facilityPage.actionViewRoute();
        system.assert(actionView != null);
        
        //TRANCHE
        ApexPages.StandardController trancheCtrl = new ApexPages.standardController(testDataClass.TestFacilityTranche);
        BxdFacilityTranchePermission tranchePage = new BxdFacilityTranchePermission(trancheCtrl);
        
        actionView = tranchePage.actionViewRoute();
        system.assert(actionView != null);
        
        //AGENCY
        ApexPages.StandardController agencyCtrl = new ApexPages.standardController(testDataClass.TestAgencyTransfer);
        BxdAgencyTransferPermission agencyPage = new BxdAgencyTransferPermission(agencyCtrl);
        
        actionView = agencyPage.actionViewRoute();
        system.assert(actionView != null);
        
        //COLLATERAL
        ApexPages.StandardController collateralCtrl = new ApexPages.standardController(testDataClass.testCollateral);
        BxdCollateralPermission collateralPage = new BxdCollateralPermission(collateralCtrl);
        
        actionView = collateralPage.actionViewRoute();
        system.assert(actionView != null);
        
        //COLLATERAL VALUATION
        ApexPages.StandardController valuationCtrl = new ApexPages.standardController(testDataClass.testCollateralValuation);
        BxdCollateralValuationPermission valuationPage = new BxdCollateralValuationPermission(valuationCtrl);
        BxdCollateralValuationService collService = new BxdCollateralValuationService();
        collService.createBoxFolderSync(testDataClass.testCollateralValuation.Id);
        
        actionView = valuationPage.actionViewRoute();
        system.assert(actionView != null);
        
        //TRIGGER
        ApexPages.StandardController triggerCtrl = new ApexPages.standardController(testDataClass.TestTrigger);
        BxdTriggerPermission triggerPage = new BxdTriggerPermission(triggerCtrl);
        
        actionView = triggerPage.actionViewRoute();
        system.assert(actionView != null);
        

    }
    
    public static testmethod void testSecondPagePermissions() {      
        BXDtesclassdata.setupFolder();
        PageReference actionView;
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        //WATCHER
        ApexPages.StandardController watcherCtrl = new ApexPages.standardController(testDataClass.testCollateralValuationWatcher);
        BxdWatcherPermission watcherPage = new BxdWatcherPermission(watcherCtrl);
        BxdWatcherService watcherService = new BxdWatcherService();
        watcherService.createBoxFolderSync(testDataClass.testCollateralValuationWatcher.Id);
        
        actionView = watcherPage.actionViewRoute();
        system.assert(actionView != null);
        
        //MARGIN
        ApexPages.StandardController marginCtrl = new ApexPages.standardController(testDataClass.testEventMarginRatchet);
        BxdMarginRatchetPermission marginPage = new BxdMarginRatchetPermission(marginCtrl);
        BxdMarginRatchetService marginService = new BxdMarginRatchetService();
        marginService.createBoxFolderSync(testDataClass.testEventMarginRatchet.Id);
        
        actionView = marginPage.actionViewRoute();
        system.assert(actionView != null);
    }
    
    public static testmethod void testSPVItemPermission() {
        BXDtesclassdata.setupFolder();
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        
        ApexPages.StandardController itemCtrl = new ApexPages.standardController(testDataClass.TestSPVItem);
        BxdSPVItemPermission itemPage = new BxdSPVItemPermission(itemCtrl);
        
        //Main method.
        PageReference actionView = itemPage.actionViewRoute();
        system.assert(actionView != null);
    }
    
    public static testmethod void testValidateCollaboration() {
        BXDtesclassdata.setupFolder();
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        
        String userId = UserInfo.getUserId();
        box.Toolkit.CollaborationType collaborationType = box.Toolkit.CollaborationType.EDITOR;
        
        box__FRUP__c frup = new box__FRUP__c 
        (
            box__Box_user__c = '030303',
            box__Object_Name__c = 'Test',
            box__Salesforce_User__c = userId
        );
        insert frup;

        test.startTest();
        BxdPermissionHelper.validateCollaboration(userId, testDataClass.TestMatter.Id, '12345', collaborationType);
        test.stopTest();
    }
}