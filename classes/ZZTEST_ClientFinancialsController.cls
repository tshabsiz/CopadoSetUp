/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientFinancialsController
*                 Tests executed:
*                 1 - testQueryPlan()
*                   Tests querying of client plan
*                 2 - testQueryPlanWithWrongId()
*                   Tests querying of client plan with errors
*                 3 - testSave()
*                   Tests saving
*                 4 - testSaveFinValueErrors()
*                   Tests errors handling of financial info records saving
*                 5 - testSaveFinValueAndQuery()
*                   Tests financial info records saving and querying
*                 6 - testGetFAISOptions()
*                   Tests preparation of FAIS select options
*                 7 - testGetFiscalMonthOptions()
*                   Tests preparation of fiscal year select options
*                 8 - testPrepareTimestampFromDate()
*                   Tests method converting date to timestamp
*                 9 - testErrorMessages()
*                   Tests of methods handling error messaged
*                 10 - testDeleteFinValue()
*                   Test deleting of the financial information
*                 11 - testEditFinInfo()
*                   test editing of all fields in the financial information
*                 12 - test testAddFinInfo()
*                   test adding new finacial information + testing retreiving of actual year data
*                 13 - test testEditFacilityAndQuery()
*                   test editing Absa facility and query them back
*                 14 - testAddFacilityAndQuery()
*                   test adding Absa Facility and querry them back
*				  15 - testDeleteSecurity()
*					test Deleting a security
*				  16 - testDeleteFacility()
*					test Deleting a facility
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 22.2.2016     Svata Sejkora   Modified and added maethods to test new fucntionalities (edit: testSave, add: testDeleteFinValue, testEditFinInfo, testAddFinInfo, testEditFacilityAndQuery,  testAddFacilityAndQuery)
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientFinancialsController {
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        Product2 prod = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
        
    }
    
    static testMethod void testQueryPlan() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
       
        
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        
        System.assertNotEquals(null, ctrl.plan);
        System.assertEquals(plan.Id, ctrl.plan.Id);
        System.assertEquals(true, ctrl.planLoaded);
    }
    
    static testMethod void testQueryPlanWithWrongId() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', 'asdfasdf');
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        
        System.assertEquals(null, ctrl.plan);
        System.assertEquals(false, ctrl.planLoaded);
    }
    
    static testMethod void testSave() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        ctrl.dateOfLatestAFS = DateTime.now().getTime();
        ctrl.lastReviewDate = DateTime.now().getTime();
        
        PageReference result = ctrl.save();
        System.assertEquals(null, result);
        
        plan = [SELECT Id, Latest_Audited_Financial_Statement__c, Last_Review_Date__c FROM Client_Plan__c LIMIT 1];
        System.assertEquals(Date.today(), plan.Latest_Audited_Financial_Statement__c);
        System.assertEquals(Date.today(), plan.Last_Review_Date__c);
    }
    
    static testMethod void testSaveFinValueErrors() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
    
        Financial_Information__c fi = new Financial_Information__c();
        fi.Relationship__c = plan.Relationship__c;
        fi.Year__c = String.valueOf(Date.today().year());
        insert fi;
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        ctrl.recordId = fi.Id;
        ctrl.finFieldName = 'asdf';
        
        PageReference result = ctrl.saveFinValue();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringSaving, ctrl.getErrorMessage());
    }

    static testMethod void testSaveFinValueAndQuery() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
    
        Financial_Information__c fi = new Financial_Information__c();
        fi.Relationship__c = plan.Relationship__c;
        fi.Year__c = String.valueOf(Date.today().year());
        insert fi;
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        ctrl.recordId = fi.Id;
        ctrl.finFieldName = 'Total_Assets__c';
        ctrl.finValue = '250';
        
        PageReference result = ctrl.saveFinValue();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        List<Financial_Information__c> fis = [SELECT Id, Total_Assets__c FROM Financial_Information__c];
        System.assertEquals(1, fis.size());
        System.assertEquals(fi.Id, fis[0].Id);
        System.assertEquals(250, fis[0].Total_Assets__c);
    }
    
    static testMethod void testGetFAISOptions() {
        Schema.DescribeFieldResult f = Client_Plan__c.FAIS_Status__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> expected = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            expected.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        
        List<SelectOption> result = ctrl.getFAISOptions();
        System.assertNotEquals(null, result);
        System.assertEquals(expected.size(), result.size());
        
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testGetFiscalMonthOptions() {
        Schema.DescribeFieldResult f = Client_Plan__c.Financial_Year_End__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> expected = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            expected.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        
        List<SelectOption> result = ctrl.getFiscalMonthOptions();
        System.assertNotEquals(null, result);
        System.assertEquals(expected.size(), result.size());
        
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testPrepareTimestampFromDate() {
        ClientFinancialsController ctrl = new ClientFinancialsController();
        Long result = ctrl.prepareTimestampFromDate(null);
        System.assertEquals(0l, result);
        
        Date today = Date.today();
        Long expected = DateTime.newInstance(today.year(), today.month(), today.day()).getTime();
        result = ctrl.prepareTimestampFromDate(today);
        System.assertEquals(expected, result);
    }
    
    static testMethod void testErrorMessages() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', 'asdfasdf');
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        
        System.assertEquals(null, ctrl.errorMessage);
        
        String expected = 'This is an error message';
        ctrl.setErrorMessage(expected);
        System.assertEquals(expected, ctrl.errorMessage);
        
        String result = ctrl.getErrorMessage();
        System.assertEquals(expected, result);
        System.assertEquals(null, ctrl.errorMessage);
        
        System.assertEquals(null, ctrl.getErrorMessage());
    }
    
    static testMethod void testDeleteFinValue() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
    
        Financial_Information__c fi = new Financial_Information__c();
        fi.Relationship__c = plan.Relationship__c;
        fi.Year__c = String.valueOf(Date.today().year());
        insert fi;
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        ctrl.recordId = fi.Id;
        
        PageReference result = ctrl.deleteFinInfo();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        List<Financial_Information__c> fis = [SELECT Id FROM Financial_Information__c];
        System.assertEquals(0, fis.size());
    }
    
    static testMethod void testGetYearOptions() {
        Schema.DescribeFieldResult f = Financial_Information__c.Year__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> expected = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            expected.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        
        List<SelectOption> result = ctrl.getYearOptions();
        System.assertNotEquals(null, result);
        System.assertEquals(expected.size(), result.size());
        
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testGetMonthOptions() {
        Schema.DescribeFieldResult f = Financial_Information__c.Month__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> expected = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            expected.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        
        List<SelectOption> result = ctrl.getMonthOptions();
        System.assertNotEquals(null, result);
        System.assertEquals(expected.size(), result.size());
        
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testEditFinInfo() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
    
        Financial_Information__c fi = new Financial_Information__c();
        fi.Relationship__c = plan.Relationship__c;
        fi.Year__c = String.valueOf(Date.today().year());
        insert fi;
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        ctrl.recordId = fi.Id;
        ctrl.yearValue = String.valueOf(Date.today().year());
        ctrl.netAssetValue = 23000000;
        ctrl.turnover = 23000000;
        ctrl.totalAssets = 50000000;
        //ctrl.interestBearingDebt = 456000;
        ctrl.cashGenByOperations = 566700;
        ctrl.ebitda = 23333333;
        ctrl.ebit = 2333333;
        ctrl.roe = 23;
        ctrl.roa = 23;
        ctrl.debtEquity = 7890987;
        ctrl.currentRatio = '1:1';
        ctrl.eps = 80000;
        ctrl.interestCoverRatio = '2:2';
        
        PageReference result = ctrl.modifyYear();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
              
        List<Financial_Information__c> fis = [SELECT Id, Total_Assets__c, Net_Asset_Value__c, Turnover__c, Total_Interest_Bearing_Debt__c, Cash_Generated_by_Operations__c, EBITDA__c,
                                                EBIT__c, ROE__c, ROA__c, Debt_Equity__c, Current_Ratio__c, EPS__c, Interest_Cover_Ratio__c
                                              FROM Financial_Information__c];

        System.assertEquals(1, fis.size());
        System.assertEquals(fi.Id, fis[0].Id);
        System.assertEquals(50000000, fis[0].Total_Assets__c);
        System.assertEquals(23000000, fis[0].Net_Asset_Value__c);
        System.assertEquals(23000000, fis[0].Turnover__c);
        System.assertEquals(566700, fis[0].Cash_Generated_by_Operations__c);
        System.assertEquals(23333333, fis[0].EBITDA__c);
        System.assertEquals(2333333, fis[0].EBIT__c);
        System.assertEquals(23, fis[0].ROE__c);
        System.assertEquals(23, fis[0].ROA__c);
        System.assertEquals(7890987, fis[0].Debt_Equity__c);
        System.assertEquals('1:1', fis[0].Current_Ratio__c);
        System.assertEquals(80000, fis[0].EPS__c);
        System.assertEquals('2:2', fis[0].Interest_Cover_Ratio__c);
    }
    
    static testMethod void testAddFinInfo() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        ctrl.recordId = '';
        ctrl.yearValue = String.valueOf(Date.today().year());
        ctrl.netAssetValue = 23000000;
        ctrl.turnover = 23000000;
        ctrl.totalAssets = 50000000;
        //ctrl.interestBearingDebt = 456000;
        ctrl.cashGenByOperations = 566700;
        ctrl.ebitda = 23333333;
        ctrl.ebit = 2333333;
        ctrl.roe = 23;
        ctrl.roa = 23;
        ctrl.debtEquity = 7890987;
        ctrl.currentRatio = '1:1';
        ctrl.eps = 80000;
        ctrl.interestCoverRatio = '2:2';

        
        PageReference result = ctrl.modifyYear();       
        String existingYear = ctrl.getExistingYearOptions();        

        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        List<Financial_Information__c> fis = [SELECT Id, Total_Assets__c, Net_Asset_Value__c, Turnover__c, Total_Interest_Bearing_Debt__c, Cash_Generated_by_Operations__c, EBITDA__c,
                                                EBIT__c, ROE__c, ROA__c, Debt_Equity__c, Current_Ratio__c, EPS__c, Interest_Cover_Ratio__c
                                              FROM Financial_Information__c];

        System.assertEquals(1, fis.size());
        System.assertEquals(50000000, fis[0].Total_Assets__c);
        System.assertEquals(23000000, fis[0].Net_Asset_Value__c);
        System.assertEquals(23000000, fis[0].Turnover__c);
        System.assertEquals(566700, fis[0].Cash_Generated_by_Operations__c);
        System.assertEquals(23333333, fis[0].EBITDA__c);
        System.assertEquals(2333333, fis[0].EBIT__c);
        System.assertEquals(23, fis[0].ROE__c);
        System.assertEquals(23, fis[0].ROA__c);
        System.assertEquals(7890987, fis[0].Debt_Equity__c);
        System.assertEquals('1:1', fis[0].Current_Ratio__c);
        System.assertEquals(80000, fis[0].EPS__c);
        System.assertEquals('2:2', fis[0].Interest_Cover_Ratio__c);

        List<String> years = (List<String>)JSON.deserialize(existingYear, List<String>.Class);

        System.assertEquals(years[0], String.valueOf(Date.today().year()));
    }
    
    static testMethod void testEditFacilityAndQuery() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);
    
        Client_Plan_Facility__c fac = new Client_Plan_Facility__c();
            fac.Relationship__c = plan.Relationship__c;
            fac.Type_Of_Facility__c = 'ABSA';
        insert fac;
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();

        ctrl.facilityId = fac.Id;
        ctrl.bank = '';
        ctrl.utilisation = 345000000;
        ctrl.productLvl3 = productLvl31.Id;
        ctrl.facLimit = 200000000;

        PageReference result = ctrl.modifyFacility();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        List<Client_Plan_Facility__c> faci = [
            SELECT Id, Type_Of_Facility__c, Bank__c, Utilisation__c, Product_Level_3__c, Limit__c 
            FROM Client_Plan_Facility__c
        ];

        System.assertEquals(1, faci.size());
        System.assertEquals('ABSA', faci[0].Type_Of_Facility__c);
        System.assertEquals(null, faci[0].Bank__c);
        System.assertEquals(345000000, faci[0].Utilisation__c);
        System.assertEquals(productLvl31.Id, faci[0].Product_Level_3__c);
        System.assertEquals(200000000, faci[0].Limit__c);
    }

    static testMethod void testAddFacilityAndQuery() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);
          
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();

        ctrl.facType = 'ABSA';
        ctrl.bank = '';
        ctrl.utilisation = 345000000;
        ctrl.productLvl3 = productLvl31.Id;
        ctrl.facLimit = 200000000;

        PageReference result = ctrl.modifyFacility();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        List<Client_Plan_Facility__c> faci = [
            SELECT Id, Type_Of_Facility__c, Bank__c, Utilisation__c, Product_Level_3__c, Limit__c 
            FROM Client_Plan_Facility__c
        ];

        System.assertEquals(1, faci.size());
        System.assertEquals('ABSA', faci[0].Type_Of_Facility__c);
        System.assertEquals(null, faci[0].Bank__c);
        System.assertEquals(345000000, faci[0].Utilisation__c);
        System.assertEquals(productLvl31.Id, faci[0].Product_Level_3__c);
        System.assertEquals(200000000, faci[0].Limit__c);
    }

    static testMethod void testEditSecurityAndQuery() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
    
        Client_Plan_Security__c sec = new Client_Plan_Security__c();
            sec.Relationship__c = plan.Relationship__c;
            sec.Security_Description__c = 'Wub WUb';
            sec.Value__c = 200000;
        insert sec;
        
        PageReference pr = Page.ClientFinancials;
            pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();

            ctrl.absaSecId = sec.Id;
            ctrl.value = 345000000;
            ctrl.clientSecurity = 'Wub WUb';

            PageReference result = ctrl.modifySecurity();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        List<Client_Plan_Security__c> seci = [SELECT Id, Security_Description__c, Value__c FROM Client_Plan_Security__c];

        System.assertEquals(1, seci.size());
        System.assertEquals('Wub WUb', seci[0].Security_Description__c);
        System.assertEquals(345000000, seci[0].Value__c);
    }

    static testMethod void testAddSecurityAndQuery() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        Client_Plan_Security__c clientPlanSecurity = new Client_Plan_Security__c(Relationship__c = plan.Relationship__c,
                                                                                 Security_Description__c='jabababa',
                                                                                 value__c=345000000);
        insert clientPlanSecurity;
        
        Client_Plan_Security__c clientPlanSecurity2 = new Client_Plan_Security__c(Relationship__c = plan.Relationship__c,
                                                                                 Security_Description__c='jabababa',
                                                                                 value__c=345000000);
        insert clientPlanSecurity2;
        
        PageReference pr = Page.ClientFinancials;
            pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        
            ctrl.value = 345000000;
            ctrl.clientSecurity = 'jabababa';

            PageReference result = ctrl.modifySecurity();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        List<Client_Plan_Security__c> seci = [SELECT Id, Security_Description__c, Value__c FROM Client_Plan_Security__c];

        System.assertEquals(3, seci.size());
        System.assertEquals('jabababa', seci[0].Security_Description__c);
        System.assertEquals(345000000, seci[0].Value__c);
    }
    
    static testMethod void testDeleteSecurity() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
    
        Client_Plan_Security__c sec = new Client_Plan_Security__c();
        sec.Relationship__c = plan.Relationship__c;
        sec.Security_Description__c = 'Wub WUb';
        sec.Value__c = 200000;
        insert sec;
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        ctrl.absaSecId = sec.Id;
        
        List<Client_Plan_Security__c> cps = [SELECT Id FROM Client_Plan_Security__c];
        System.assertEquals(1, cps.size());
        
        PageReference result = ctrl.deleteSecurity();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        cps = [SELECT Id FROM Client_Plan_Security__c];
        System.assertEquals(0, cps.size());
    }
    
    static testMethod void testDeleteFacility() {
		Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
    
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);
        
        Client_Plan_Facility__c facility = new Client_Plan_Facility__c();
        facility.Type_Of_Facility__c = 'OTHER';
        facility.Relationship__c = plan.Relationship__c;
        facility.Bank__c = 'Test Bank';
        facility.Country__c = 'South Africa';
        facility.Product_Level_3__c = productLvl31.Id;
        facility.Limit__c = 123456;
        insert facility;
        
        PageReference pr = Page.ClientFinancials;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientFinancialsController ctrl = new ClientFinancialsController();
        ctrl.facilityId = facility.Id;
        
        List<Client_Plan_Facility__c> cpf = [SELECT Id FROM Client_Plan_Facility__c];
        System.assertEquals(1, cpf.size());
        
        PageReference result = ctrl.deleteFacility();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        cpf = [SELECT Id FROM Client_Plan_Facility__c];
        System.assertEquals(0, cpf.size());    
    }
}