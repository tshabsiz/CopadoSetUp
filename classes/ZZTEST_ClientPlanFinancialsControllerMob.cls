/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanFinancialsControllerMobile
*                 Tests executed:
*                 1 - testGetClientPlan()
*                   Tests querying of client plan
*                 2 - testGetClientFinancials()
*                   Tests getter of client financials
*                 3 - testGetRatingMetadata()
*                   Tests getter of fields' metadata
*                 4 - testSaveRating()
*                   Tests saving of client plan fields
*                 5 - testGetFacilitiesAndSecurity()
*                   Tests getter of facilities and securities
*                 6 - testGetFacility()
*                   Tests getter of facility
*                 7 - testGetFacilityMetadata()
*                   Tests getter of facility's fields' metadata
*                 8 - testAddFacility()
*                   Tests adding a facility
*                 9 - testEditFacility()
*                   Tests editation of a facility
*                 10 - testGetSecurity()
*                   Tests getter of security
*                 11 - testAddSecurity()
*                   Tests adding a security
*                 12 - testEditSecurity()
*                   Tests editation of a secutity
*                 13 - testGetFinancialInformation()
*                   Tests getter of financial information
*                 14 - testGetFinancialsYears()
*                   Tests getter of years available for adding
*                 15 - testAddFinancials()
*                   Tests adding of financials
*                 16 - testEditFinancials()
*                   Tests editation of financials
*                 17 - testRemoveFinancials()
*                   Tests removing financials
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanFinancialsControllerMob {

    private class ClientPlanFinancialsControllerMobException extends Exception {
    }
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }
    
    static testMethod void testGetClientPlan() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
    
        //not-existind planId
        Client_Plan__c result = ClientPlanFinancialsControllerMobile.getClientPlan(null);
        System.assertEquals(null, result);
        
        result = ClientPlanFinancialsControllerMobile.getClientPlan('asdfasdf');
        System.assertEquals(null, result);
        
        //working code
        result = ClientPlanFinancialsControllerMobile.getClientPlan(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(plan.Id, result.Id);
    }
    
    static testMethod void testGetClientFinancials() {
        
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        String fiId = prepareFinancialInformation(plan.Relationship__c);
        
        //not-existind planId
        List<Financial_Information__c> result = ClientPlanFinancialsControllerMobile.getClientFinancials(null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanFinancialsControllerMobile.getClientFinancials('asdf');
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        //working code
        result = ClientPlanFinancialsControllerMobile.getClientFinancials(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(fiId, result[0].Id);
    }
    
    static testMethod void testGetRatingMetadata() {
        
        Schema.DescribeFieldResult fieldResult = Client_Plan__c.FAIS_Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> faisOptions = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            faisOptions.add(f.getLabel());
        }
        
        fieldResult = Client_Plan__c.Financial_Year_End__c.getDescribe();
        entries = fieldResult.getPicklistValues();
        List<String> fyeOptions = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            fyeOptions.add(f.getLabel());
        }
        
        Map<String, List<String>> result = ClientPlanFinancialsControllerMobile.getRatingMetadata();
        System.assertEquals(2, result.keyset().size());
        
        List<String> fais = result.get('fais');
        System.assertNotEquals(null, fais);
        System.assertEquals(faisOptions.size(), fais.size());
        
        for (Integer i = 0; i < faisOptions.size(); i++) {
            System.assertEquals(faisOptions[i], fais[i]);
        }
        
        List<String> fye = result.get('financialYearEnd');
        System.assertNotEquals(null, fye);
        System.assertEquals(fyeOptions.size(), fye.size());
        
        for (Integer i = 0; i < fyeOptions.size(); i++) {
            System.assertEquals(fyeOptions[i], fye[i]);
        }
    }
    
    static testMethod void testSaveRating() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //not-existing planId
        Boolean result = ClientPlanFinancialsControllerMobile.saveRating(null, null, null, null, null, null);
        System.assertEquals(true, result);
        
        result = ClientPlanFinancialsControllerMobile.saveRating('asdf', null, null, null, null, null);
        System.assertEquals(true, result);
        
        //working code 1
        result = ClientPlanFinancialsControllerMobile.saveRating(plan.Id, null, null, null, null, null);
        System.assertEquals(false, result);

        List<Client_Plan__c> plans = [
            SELECT TFL__c, FAIS_Status__c, Last_Review_Date__c, Financial_Year_End__c,
                Latest_Audited_Financial_Statement__c
            FROM Client_Plan__c
        ];
        System.assertEquals(1, plans.size());
        System.assertEquals(null, plans[0].TFL__c);
        System.assertEquals(null, plans[0].FAIS_Status__c);
        System.assertEquals(null, plans[0].Last_Review_Date__c);
        System.assertEquals(null, plans[0].Financial_Year_End__c);
        System.assertEquals(null, plans[0].Latest_Audited_Financial_Statement__c);
        
        //working code 2
        result = ClientPlanFinancialsControllerMobile.saveRating(plan.Id, 0, 'fais', '200000', 'September', '40000');
        System.assertEquals(false, result);

        plans = [
            SELECT TFL__c, FAIS_Status__c, Last_Review_Date__c, Financial_Year_End__c,
                Latest_Audited_Financial_Statement__c
            FROM Client_Plan__c
        ];
        System.assertEquals(1, plans.size());
        System.assertEquals(0, plans[0].TFL__c);
        System.assertEquals('fais', plans[0].FAIS_Status__c);
        System.assertNotEquals(null, plans[0].Last_Review_Date__c);
        System.assertEquals('September', plans[0].Financial_Year_End__c);
        System.assertNotEquals(null, plans[0].Latest_Audited_Financial_Statement__c);
    }

    static testMethod void testGetFacilitiesAndSecurity() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        Client_Plan_Facility__c absa = new Client_Plan_Facility__c();
        absa.Relationship__c = plan.Relationship__c;
        absa.Type_Of_Facility__c = ClientPlanFinancialsControllerMobile.ABSA;
        insert absa;

        Client_Plan_Facility__c other = new Client_Plan_Facility__c();
        other.Relationship__c = plan.Relationship__c;
        other.Type_Of_Facility__c = ClientPlanFinancialsControllerMobile.OTHER;
        insert other;

        Client_Plan_Security__c sec = new Client_Plan_Security__c();
        sec.Relationship__c = plan.Relationship__c;
        insert sec;

        //not-existing planId
        String resultJson = ClientPlanFinancialsControllerMobile.getFacilitiesAndSecurity('asdf');
        System.assertNotEquals(null, resultJson);

        ClientPlanFinancialsControllerMobile.FacilitiesAndSecurity result;
        try {
            result = (ClientPlanFinancialsControllerMobile.FacilitiesAndSecurity) JSON.deserialize(resultJson, 
                ClientPlanFinancialsControllerMobile.FacilitiesAndSecurity.class);

            throw new ClientPlanFinancialsControllerMobException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ClientPlanFinancialsControllerMobException);
        }

        System.assertEquals(true, result.absaFacilities.isEmpty());
        System.assertEquals(true, result.otherFacilities.isEmpty());
        System.assertEquals(true, result.security.isEmpty());

        //working code
        resultJson = ClientPlanFinancialsControllerMobile.getFacilitiesAndSecurity(plan.Id);
        System.assertNotEquals(null, resultJson);

        try {
            result = (ClientPlanFinancialsControllerMobile.FacilitiesAndSecurity) JSON.deserialize(resultJson, 
                ClientPlanFinancialsControllerMobile.FacilitiesAndSecurity.class);

            throw new ClientPlanFinancialsControllerMobException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ClientPlanFinancialsControllerMobException);
        }

        System.assertEquals(1, result.absaFacilities.size());
        System.assertEquals(1, result.otherFacilities.size());
        System.assertEquals(1, result.security.size());

        System.assertEquals(absa.Id, result.absaFacilities[0].Id);
        System.assertEquals(other.Id, result.otherFacilities[0].Id);
        System.assertEquals(sec.Id, result.security[0].Id);
    }

    static testMethod void testGetFacility() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);

        Client_Plan_Facility__c absa = new Client_Plan_Facility__c();
        absa.Relationship__c = plan.Relationship__c;
        absa.Type_Of_Facility__c = ClientPlanFinancialsControllerMobile.ABSA;
        absa.Limit__c = 1000;
        absa.Product_Level_3__c = productLvl31.Id;
        absa.Utilisation__c = 700;
        absa.Bank__c = 'a bank';
        absa.CurrencyIsoCode = 'EUR';
        insert absa;

        //null facilityId
        List<Client_Plan_Facility__c> result = ClientPlanFinancialsControllerMobile.getFacility(null);
        System.assertEquals(true, result.isEmpty());

        //not-existing facilityId
        result = ClientPlanFinancialsControllerMobile.getFacility('asdf');
        System.assertEquals(true, result.isEmpty());

        //working code
        result = ClientPlanFinancialsControllerMobile.getFacility(absa.Id);
        System.assertEquals(1, result.size());
        System.assertEquals(absa.Id, result[0].Id);
        System.assertEquals(absa.Limit__c, result[0].Limit__c);
        System.assertEquals(absa.Product_Level_3__c, productLvl31.Id);
        System.assertEquals(absa.Utilisation__c, result[0].Utilisation__c);
        System.assertEquals(absa.Bank__c, result[0].Bank__c);
        System.assertEquals(absa.CurrencyIsoCode, result[0].CurrencyIsoCode);
    }

    static testMethod void testGetFacilityMetadata() {
        List<String> expectedCurrency = new List<String>();
        Schema.DescribeFieldResult f = Client_Plan_Facility__c.CurrencyIsoCode.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();

        for (Schema.PicklistEntry e: p) {
            expectedCurrency.add(e.getValue());
        }

        Map<String, List<String>> result = ClientPlanFinancialsControllerMobile.getFacilityMetadata();
        System.assertNotEquals(null, result);

        List<String> currencyResult = result.get('currencyIsoCode');
        System.assertNotEquals(null, currencyResult);
        System.assertEquals(expectedCurrency.size(), currencyResult.size());

        for (Integer i = 0; i < expectedCurrency.size(); i++) {
            System.assertEquals(expectedCurrency[i], currencyResult[i]);
        }
    }

    static testMethod void testAddFacility() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);

        //not-existing planId
        Boolean result = ClientPlanFinancialsControllerMobile.addFacility('asdf', productLvl31.Id, 
            null, null, null, null, true);
        System.assertEquals(true, result);

        //null isBarclays
        result = ClientPlanFinancialsControllerMobile.addFacility(plan.Id, productLvl31.Id, 
            null, null, null, null, null);
        System.assertEquals(true, result);

        //working code
        result = ClientPlanFinancialsControllerMobile.addFacility(plan.Id, productLvl31.Id, 
            1000, 'EUR', 700, 'bank', false);
        System.assertEquals(false, result);

        List<Client_Plan_Facility__c> facs = [
            SELECT Limit__c, Product_Level_3__c, Utilisation__c, Bank__c, CurrencyIsoCode
            FROM Client_Plan_Facility__c
        ];
        System.assertEquals(1, facs.size());
        System.assertEquals(1000, facs[0].Limit__c);
        System.assertEquals(productLvl31.Id, facs[0].Product_Level_3__c);
        System.assertEquals(null, facs[0].Utilisation__c);
        System.assertEquals('bank', facs[0].Bank__c);
        System.assertEquals('EUR', facs[0].CurrencyIsoCode);
    }

    static testMethod void testEditFacility() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);

        Client_Plan_Facility__c fac = new Client_Plan_Facility__c();
        fac.Relationship__c = plan.Relationship__c;
        fac.Type_Of_Facility__c = ClientPlanFinancialsControllerMobile.ABSA;
        insert fac;

        //null params
        Boolean result = ClientPlanFinancialsControllerMobile.editFacility(null, null, null, null, null, 
            null, null);
        System.assertEquals(true, result);

        //not-existing facilityId
        result = ClientPlanFinancialsControllerMobile.editFacility('asdf', productLvl31.Id, null, 'EUR', null, 
            null, true);
        System.assertEquals(true, result);

        //absa facility
        result = ClientPlanFinancialsControllerMobile.editFacility(fac.Id, productLvl31.Id, 1000, 'EUR', 700, 
            'bank', true);
        System.assertEquals(false, result);

        List<Client_Plan_Facility__c> facs = [
            SELECT Id, Product_Level_3__c, Limit__c, CurrencyIsoCode, Utilisation__c, Bank__c
            FROM Client_Plan_Facility__c
            WHERE Id = :fac.Id
        ];
        System.assertEquals(1, facs.size());
        System.assertEquals(fac.Id, facs[0].Id);
        System.assertEquals(productLvl31.Id, facs[0].Product_Level_3__c);
        System.assertEquals(1000, facs[0].Limit__c);
        System.assertEquals('EUR', facs[0].CurrencyIsoCode);
        System.assertEquals(700, facs[0].Utilisation__c);
        System.assertEquals(null, facs[0].Bank__c);

        //other facility
        result = ClientPlanFinancialsControllerMobile.editFacility(fac.Id, productLvl31.Id, 2000, 'ZAR', 1400, 
            'bank2', false);
        System.assertEquals(false, result);

        facs = [
            SELECT Id, Product__c, Limit__c, CurrencyIsoCode, Utilisation__c, Bank__c
            FROM Client_Plan_Facility__c
            WHERE Id = :fac.Id
        ];
        System.assertEquals(1, facs.size());
        System.assertEquals(fac.Id, facs[0].Id);
        System.assertEquals(productLvl31.Id, productLvl31.Id);
        System.assertEquals(2000, facs[0].Limit__c);
        System.assertEquals('ZAR', facs[0].CurrencyIsoCode);
        System.assertEquals(700, facs[0].Utilisation__c);
        System.assertEquals('bank2', facs[0].Bank__c);

        //errors handling
        String bank = '';
        for (Integer i = 0; i < 10; i++) {
            bank += 'ppppppp';
        }
        result = ClientPlanFinancialsControllerMobile.editFacility(fac.Id, productLvl31.Id, 2000, 
            'ZAR', 1400, bank, false);
        System.assertEquals(true, result);
    }

    static testMethod void testGetSecurity() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        Client_Plan_Security__c sec = new Client_Plan_Security__c();
        sec.Relationship__c = plan.Relationship__c;
        sec.Security_Description__c = 'desc';
        sec.Value__c = 1000;
        sec.CurrencyIsoCode = 'ZAR';
        insert sec;

        //null securityId
        List<Client_Plan_Security__c> result = ClientPlanFinancialsControllerMobile.getSecurity(null);
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.isEmpty());

        //not-existing securityId
        result = ClientPlanFinancialsControllerMobile.getSecurity('asdf');
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.isEmpty());

        //working code
        result = ClientPlanFinancialsControllerMobile.getSecurity(sec.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(sec.Id, result[0].Id);
        System.assertEquals(sec.Security_Description__c, result[0].Security_Description__c);
        System.assertEquals(sec.Value__c, result[0].Value__c);
        System.assertEquals(sec.CurrencyIsoCode, result[0].CurrencyIsoCode);
    }

    static testMethod void testAddSecurity() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

        //errors handling
        Boolean result = ClientPlanFinancialsControllerMobile.addSecurity('asdf', null, null);
        System.assertEquals(true, result);

        //working code
        result = ClientPlanFinancialsControllerMobile.addSecurity(plan.Id, 'desc', 1000);
        System.assertEquals(false, result);

        List<Client_Plan_Security__c> secs = [
            SELECT Security_Description__c, Value__c, Relationship__c
            FROM Client_Plan_Security__c
        ];
        System.assertEquals(1, secs.size());
        System.assertEquals('desc', secs[0].Security_Description__c);
        System.assertEquals(1000, secs[0].Value__c);
    }

    static testMethod void testEditSecurity() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        Client_Plan_Security__c sec = new Client_Plan_Security__c();
        sec.Relationship__c = plan.Relationship__c;
        sec.Security_Description__c = 'desc';
        sec.Value__c = 1000;
        sec.CurrencyIsoCode = 'ZAR';
        insert sec;

        //not-exisiting securityId
        Boolean result = ClientPlanFinancialsControllerMobile.editSecurity(null, null, null);
        System.assertEquals(true, result);

        //working code
        result = ClientPlanFinancialsControllerMobile.editSecurity(sec.Id, 'desc2', 2000);
        System.assertEquals(false, result);

        List<Client_Plan_Security__c> secs = [
            SELECT Relationship__c, Security_Description__c, Value__c
            FROM Client_Plan_Security__c
        ];
        System.assertEquals(1, secs.size());
        System.assertEquals(plan.Relationship__c, secs[0].Relationship__c);
        System.assertEquals('desc2', secs[0].Security_Description__c);
        System.assertEquals(2000, secs[0].Value__c);
    }

    static testMethod void testGetFinancialInformation() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        String fiId = prepareFinancialInformation(plan.Relationship__c);

        //null finId
        List<Financial_Information__c> result = ClientPlanFinancialsControllerMobile.getFinancialInformation(null);
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.isEmpty());

        //not-existing finId
        result = ClientPlanFinancialsControllerMobile.getFinancialInformation('asdf');
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.isEmpty());

        //working code
        result = ClientPlanFinancialsControllerMobile.getFinancialInformation(fiId);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(fiId, result[0].Id);
    }
    
    static testMethod void testGetFinancialsYears() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        Financial_Information__c fi1 = new Financial_Information__c();
        fi1.Relationship__c = plan.Relationship__c;
        fi1.Year__c = '2015';

        Financial_Information__c fi2 = new Financial_Information__c();
        fi2.Relationship__c = plan.Relationship__c;
        fi2.Year__c = '2016';

        insert new List<Financial_Information__c>{fi1, fi2};

        //null planId
        List<String> result = ClientPlanFinancialsControllerMobile.getFinancialsYears(null);
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.isEmpty());

        //not-existing planId
        result = ClientPlanFinancialsControllerMobile.getFinancialsYears('asdf');
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.isEmpty());

        //working code
        result = ClientPlanFinancialsControllerMobile.getFinancialsYears(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(2, result.size());
        System.assertEquals('2016', result[0]);
        System.assertEquals('2015', result[1]);
    }
    
    static testMethod void testAddFinancials() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        //not-existing planId
        Boolean result = ClientPlanFinancialsControllerMobile.addFinancials('asdf', '2016', 1, 
            2, 3, 4, 5, 6, 7, 8, 9, 10, '1:1', 12, '1:3');
        System.assertEquals(true, result);

        //working code
        result = ClientPlanFinancialsControllerMobile.addFinancials(plan.Id, '2016', 1, 
            2, 3, 4, 5, 6, 7, 8, 9, 10, '1:1', 12, '1:3');
        System.assertEquals(false, result);

        List<Financial_Information__c> fis = [
            SELECT Relationship__c, Year__c, Turnover__c
            FROM Financial_Information__c
        ];
        System.assertEquals(1, fis.size());
        System.assertEquals(plan.Relationship__c, fis[0].Relationship__c);
        System.assertEquals('2016', fis[0].Year__c);
        System.assertEquals(1, fis[0].Turnover__c);
    }

    static testMethod void testEditFinancials() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        String fiId = prepareFinancialInformation(plan.Relationship__c);

        //not-existing financialsId
        Boolean result = ClientPlanFinancialsControllerMobile.editFinancials('asdf', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, '1:1', 12, '1:3');
        System.assertEquals(true, result);

        //working code
        result = ClientPlanFinancialsControllerMobile.editFinancials(fiId, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, '1:1', 12, '1:3');
        System.assertEquals(false, result);

        List<Financial_Information__c> fis = [
            SELECT Relationship__c, Year__c, Turnover__c
            FROM Financial_Information__c
        ];
        System.assertEquals(1, fis.size());
        System.assertEquals(plan.Relationship__c, fis[0].Relationship__c);
        System.assertEquals(null, fis[0].Year__c);
        System.assertEquals(1, fis[0].Turnover__c);
    }

    static testMethod void testRemoveFinancials() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        String fiId = prepareFinancialInformation(plan.Relationship__c);

        //not-existing financialsId
        Boolean result = ClientPlanFinancialsControllerMobile.removeFinancials('adsf');
        System.assertEquals(true, result);

        List<Financial_Information__c> fis = [
            SELECT Id
            FROM Financial_Information__c
        ];
        System.assertEquals(1, fis.size());
        System.assertEquals(fiId, fis[0].Id);

        //working code
        result = ClientPlanFinancialsControllerMobile.removeFinancials(fiId);
        System.assertEquals(false, result);

        fis = [
            SELECT Id
            FROM Financial_Information__c
        ];
        System.assertEquals(true, fis.isEmpty());
    }
    
    private static String prepareFinancialInformation(String accId) {
    
        Financial_Information__c fi = new Financial_Information__c();
        fi.Relationship__c = accId;
        insert fi;
        
        return fi.Id;
    }
    
}