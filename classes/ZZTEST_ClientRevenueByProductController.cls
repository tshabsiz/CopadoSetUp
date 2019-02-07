@isTest
public class ZZTEST_ClientRevenueByProductController {
	
	@testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
	}

	static testMethod void testGetSectorOverviewErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
       	PageReference pr = Page.ClientPlan;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientPlanRevenueByProductController ctrl = new ClientPlanRevenueByProductController();

        Test.startTest();

        Client_Plan_Revenue_By_Product__c rbp = ctrl.revByProd;
        rbp.F12P_AssetSalesFinance__c = 100;

        ctrl.save();

        System.assertNotEquals(null, rbp);
    }
    
    static testMethod void testPullFromMyMI() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
       	PageReference pr = Page.ClientPlan;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientPlanRevenueByProductController ctrl = new ClientPlanRevenueByProductController();
        
        MyMI mymifeed = new MyMI();
        String MYMI_BASE_ENDPOINT; String MYMI_OPERATION_GETTOKEN; String MYMI_OPERATION_CLIENTGROUPS;
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        for(Integration_Setting__mdt settings : [SELECT DeveloperName, Setting__c FROM Integration_Setting__mdt WHERE DeveloperName IN('MYMI_BASE_ENDPOINT','MYMI_OPERATION_GETTOKEN','MYMI_OPERATION_CLIENTGROUPS')]){
            if (settings.DeveloperName == 'MYMI_BASE_ENDPOINT') MYMI_BASE_ENDPOINT = settings.Setting__c;
            if (settings.DeveloperName == 'MYMI_OPERATION_GETTOKEN') MYMI_OPERATION_GETTOKEN = settings.Setting__c;
            if (settings.DeveloperName == 'MYMI_OPERATION_CLIENTGROUPS') MYMI_OPERATION_CLIENTGROUPS = settings.Setting__c;
        }
        multimock.setStaticResource(MYMI_BASE_ENDPOINT + MYMI_OPERATION_GETTOKEN, 'MyMITokenResponse');
        multimock.setStaticResource(MYMI_BASE_ENDPOINT + MYMI_OPERATION_CLIENTGROUPS + '?cibkey=CIB5850', 'MyMIClientGroupResponse');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multimock);
        mymifeed.RetrieveClientGroupFeedSync('CIB5850');
        System.assertEquals(4, mymifeed.ClientGroupFeed.Subsidiaries.size());
        System.assertEquals('CIB5850', mymifeed.ClientGroupFeed.Key);
        System.assertEquals('NORTH WEST PROVINCIAL GOVERNMENT', mymifeed.ClientGroupFeed.Name);
        System.assertEquals(1105360.6707, mymifeed.ClientGroupFeed.Revenue);
        System.assertEquals(27587.44181419, mymifeed.ClientGroupFeed.RWA);
        System.assertEquals(mymifeed.ClientGroupFeed.Subsidiaries[0].Products[0].getDataDate, mymifeed.ClientGroupFeed.DataDate);
        System.assertEquals('NORTH WEST PROVINCIAL LEGISLATURE', mymifeed.ClientGroupFeed.Subsidiaries[0].Name);
        System.assertEquals('NORTH WEST PROVINCIAL GOVERNMENT', mymifeed.ClientGroupFeed.Subsidiaries[0].ParentName);
        System.assertEquals('CIB5850', mymifeed.ClientGroupFeed.Subsidiaries[0].ParentKey);
        System.assertEquals('NWPROVI019', mymifeed.ClientGroupFeed.Subsidiaries[0].SDS);
        System.assertEquals(80626.9, mymifeed.ClientGroupFeed.Subsidiaries[0].Revenue);
        System.assertEquals(27587.44181419, mymifeed.ClientGroupFeed.Subsidiaries[0].RWA);
        System.assertEquals(DateTime.newInstance(2016, 10, 1, 0, 0, 0), mymifeed.ClientGroupFeed.Subsidiaries[0].Products[0].getMaturityDate);
        System.assertEquals('ABSA VEHICLE AND COMMERCIAL ASSET FINANCE', mymifeed.ClientGroupFeed.Subsidiaries[0].Products[0].Name);
        System.assertEquals(3.1610008424115, mymifeed.ClientGroupFeed.Subsidiaries[0].Products[0].CostOfCapital);
        System.assertEquals(0, mymifeed.ClientGroupFeed.Subsidiaries[0].Products[0].RoRWA);
        System.assertEquals(-3.1610008424115, mymifeed.ClientGroupFeed.Subsidiaries[0].Products[0].RevenueNetCostOfCapital);        
        System.assertEquals('ABSA VEHICLE AND COMMERCIAL ASSET FINANCE', mymifeed.ClientGroupFeed.Subsidiaries[0].Products[0].ProductHouse);        
        System.assertEquals('RBB', mymifeed.ClientGroupFeed.Subsidiaries[0].Products[0].BusinessArea);
        System.assertEquals('', mymifeed.ClientGroupFeed.Subsidiaries[0].Products[0].ProductType);
        
        Client_Plan_Revenue_By_Product__c rbp = ctrl.revByProd;
        ctrl.CIBKey = 'CIB5850';
        ctrl.pullFromMyMI();
        System.assertEquals(DateTime.newInstance(2017, 7, 31, 0, 0, 0), ctrl.revByProd.LastPulledfromMyMI__c);
        ctrl.clearLastPulledFromMyMIDate();
        System.assertEquals(NULL, ctrl.revByProd.LastPulledfromMyMI__c);
        Test.stopTest();
    }
}