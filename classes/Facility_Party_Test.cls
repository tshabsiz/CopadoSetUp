/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 14/09/2017 - PG    - Created Class. 
 10/01/2018 - TdB

**/
@isTest
public class Facility_Party_Test
{
	/**
	* Facility_Party_Override.cls
	**/
	private static testMethod void test_Facility_Party_Override() 
	{
		Test.startTest();

		CloudSmiths_TestDataClass testData  = new CloudSmiths_TestDataClass();
        
        Agreement_Party__c TestAgreementParty2 = new Agreement_Party__c
        (
            Agreement__c = testData.TestAgreement.id,
            Deal_Party__c  = testData.TestDealParty.id,
            Lender_Amount__c = null               
        );
        insert TestAgreementParty2;

		//Standard Controller.
		ApexPages.StandardController stdController = new ApexPages.StandardController(testData.TestFacility);
		Facility_Party_Override extController = new Facility_Party_Override(stdController); 
        
        extController.partyWrappers[0].selected = True;
        extController.partyWrappers[1].selected = False;
        

		//Save selection.
		extController.saveRecord();

		/*try{
        
            extController.showError = True;
        extController.saveRecord();
        
        } catch(Exception error) {
            System.assert(error.getMessage().contains('You must select at least one facility party'));
		}*/
        
        
        testData.TestFacilityParty.Facility_Amount__c = 0;
        update testData.TestFacilityParty;
        
        try{
        
        testData.TestFacilityParty.Facility_Amount__c = 50;
        update testData.TestFacilityParty;
        
        } catch(Exception error) {
            System.assert(error.getMessage().contains('Update failed.'));
            System.assert(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            System.assert(error.getMessage().contains('Please ensure that the Facility Amount does not exceed the corresponding Agreement Party Facility Amount'));
		}
        
         try{
             
        testData.TestFacilityParty.Facility_Percentage__c = 50;
        testData.TestFacilityParty.Facility_Amount__c = null; 
        update testData.TestFacilityParty;
             
             } catch(Exception error) {
            //System.assert(error.getMessage().contains('Please ensure that the Facility Amount does not exceed the corresponding Agreement Party Facility Amount'));
		}
        
        try{
        
        testData.TestFacility.Facility_Limit__C = null;
        update testData.TestFacility;
            
        testData.TestFacilityParty.Facility_Amount__c = 50;
        update testData.TestFacilityParty;
        
        } catch(Exception error) {
            System.assert(error.getMessage().contains('Update failed.'));
            System.assert(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            System.assert(error.getMessage().contains('Please ensure that the Facility Limit is not exceeded'));
		}

		Test.stopTest();
	}
}