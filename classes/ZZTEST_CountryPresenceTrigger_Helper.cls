/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for CountryPresenceTrigger_Helper
*                 Tests executed:
*                 1 - testInsertWithNoError()
*                   Tests insert with no error
*                 2 - testInsertWithError()
*                   Tests insert with error
*                 3 - testUpdateWithNoError()
*                   Tests update with no error
*                 4 - testUpdateWithError()
*                   Tests update with error
*                 5 - testCountryNotFilled()
*                   Tests situation when country is null
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_CountryPresenceTrigger_Helper {
    
    private static Account acc1;
    
    private static Client_Plan__c plan1;
    
    //custom exception class
    private class ZZTEST_CountryPresenceTrigger_HelperException extends Exception {
    }

    //prepares account and client plan
    private static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        plan1 = new Client_Plan__c();
        plan1.Relationship__c = acc1.Id;
        
        //creation of data which should not be processed by tested trigger
        Client_Plan__c plan2 = new Client_Plan__c();
        plan2.Relationship__c = acc1.Id;
        
        List<Client_Plan__c> plans = new List<Client_Plan__c>{plan1, plan2};
        insert plans;
        
        Country_Presence__c cp1 = new Country_Presence__c();
        cp1.Client_Plan__c = plan2.Id;
        cp1.Banking_Country__c = 'Kenya';
        insert cp1;
    }
    
    static testMethod void testInsertWithNoError() {
        setup();
        
        Country_Presence__c cp1 = new Country_Presence__c();
        cp1.Client_Plan__c = plan1.Id;
        cp1.Banking_Country__c = 'Kenya';
        
        try {
            insert cp1;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_CountryPresenceTrigger_HelperException);
        }
        
        Country_Presence__c cp2 = new Country_Presence__c();
        cp2.Client_Plan__c = plan1.Id;
        cp2.Banking_Country__c = 'Egypt';
        
        Country_Presence__c cp3 = new Country_Presence__c();
        cp3.Client_Plan__c = plan1.Id;
        cp3.Banking_Country__c = 'Nigeria';
        
        List<Country_Presence__c> cps = new List<Country_Presence__c>{cp2, cp3};
        try {
            insert cps;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_CountryPresenceTrigger_HelperException);
        }
     }
     
    static testMethod void testInsertWithError() {
        setup();
        
        Country_Presence__c cp1 = new Country_Presence__c();
        cp1.Client_Plan__c = plan1.Id;
        cp1.Banking_Country__c = 'Kenya';
        
        try {
            insert cp1;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_CountryPresenceTrigger_HelperException);
        }
        
        Country_Presence__c cp2 = new Country_Presence__c();
        cp2.Client_Plan__c = plan1.Id;
        cp2.Banking_Country__c = 'Kenya';
        
        Country_Presence__c cp3 = new Country_Presence__c();
        cp3.Client_Plan__c = plan1.Id;
        cp3.Banking_Country__c = 'Kenya';
        
        List<Country_Presence__c> cps = new List<Country_Presence__c>{cp2, cp3};
        
        try {
            insert cps;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof DmlException);
            String expextedMessage = 'Kenya ' + Label.errMsg_AlreadyUsed;
            System.assertEquals(true, e.getMessage().contains(expextedMessage));
        }
    }
     
    static testMethod void testUpdateWithNoError() {
        setup();
        
        Country_Presence__c cp2 = new Country_Presence__c();
        cp2.Client_Plan__c = plan1.Id;
        cp2.Banking_Country__c = 'Egypt';
        
        Country_Presence__c cp3 = new Country_Presence__c();
        cp3.Client_Plan__c = plan1.Id;
        cp3.Banking_Country__c = 'Nigeria';
        
        List<Country_Presence__c> cps = new List<Country_Presence__c>{cp2, cp3};
        try {
            insert cps;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_CountryPresenceTrigger_HelperException);
        }
        
        cp2.Banking_Country__c = 'Nigeria';
        cp3.Banking_Country__c = 'Egypt';
        try {
            update cps;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_CountryPresenceTrigger_HelperException);
        }
    }
     
    static testMethod void testUpdateWithError() {
        setup();
        
        Country_Presence__c cp2 = new Country_Presence__c();
        cp2.Client_Plan__c = plan1.Id;
        cp2.Banking_Country__c = 'Egypt';
        
        Country_Presence__c cp3 = new Country_Presence__c();
        cp3.Client_Plan__c = plan1.Id;
        cp3.Banking_Country__c = 'Nigeria';
        
        List<Country_Presence__c> cps = new List<Country_Presence__c>{cp2, cp3};
        try {
            insert cps;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_CountryPresenceTrigger_HelperException);
        }
        
        cp2.Banking_Country__c = 'Nigeria';
        try {
            update cps;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof DmlException);
            String expextedMessage = 'Nigeria ' + Label.errMsg_AlreadyUsed;
            System.assertEquals(true, e.getMessage().contains(expextedMessage));
        }
        
        Country_Presence__c cp1 = new Country_Presence__c();
        cp1.Client_Plan__c = plan1.Id;
        cp1.Banking_Country__c = 'Kenya';
        
        try {
            insert cp1;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_CountryPresenceTrigger_HelperException);
        }
        
        cp2.Banking_Country__c = 'Kenya';
        try {
            update cps;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof DmlException);
            String expextedMessage = 'Kenya ' + Label.errMsg_AlreadyUsed;
            System.assertEquals(true, e.getMessage().contains(expextedMessage));
        }
    }
     
    static testMethod void testCountryNotFilled() {
        setup();
        
        Country_Presence__c cp2 = new Country_Presence__c();
        cp2.Client_Plan__c = plan1.Id;
        
        Country_Presence__c cp3 = new Country_Presence__c();
        cp3.Client_Plan__c = plan1.Id;
        cp3.Banking_Country__c = '';
        
        List<Country_Presence__c> cps = new List<Country_Presence__c>{cp2, cp3};
        try {
            insert cps;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_CountryPresenceTrigger_HelperException);
        }
        
        cp3.Primary_Bank__c = 'Barclays';
        try {
            update cps;
            throw new ZZTEST_CountryPresenceTrigger_HelperException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_CountryPresenceTrigger_HelperException);
        }
     }
     
}