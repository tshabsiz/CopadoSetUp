/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 14/09/2017 - PG    - Created Class. 

**/
@isTest
public class Tranche_Party_Test
{
	/**
	* Facility_Party_Override.cls 
	**/
	private static testMethod void test_Tranche_Party_Override() 
	{
        CloudSmiths_TestDataClass testData  = new CloudSmiths_TestDataClass();

		Test.startTest();

		Limits.getQueries();        
                
        Facility_Party__c TestFacilityParty2 = new Facility_Party__c
        (
            Facility__c = testData.TestFacility.id,
            Agreement_Party__c  = testData.TestAgreementParty.id,
            Facility_Amount__c = null               
        );
        insert TestFacilityParty2;

		//Standard Controller.
		ApexPages.StandardController stdController = new ApexPages.StandardController(testData.TestFacilityTranche);
		Tranche_Party_Override extController = new Tranche_Party_Override(stdController); 

        extController.partyWrappers[0].selected = True;
        extController.partyWrappers[1].selected = False;
        
		//Save selection.
		extController.saveRecord();
        
        //Standard Controller.
		ApexPages.StandardController stdController2 = new ApexPages.StandardController(testData.TestFacilityTranche);
		Tranche_Party_Override extController2 = new Tranche_Party_Override(stdController); 

        extController2.partyWrappers[1].selected = True;
        extController2.partyWrappers[0].selected = False;
        
		//Save selection.
		extController2.saveRecord();
        
        try{
        
            extController.showError = True;
            extController.saveRecord();
        
        } 
        catch(Exception error) 
        {
            System.assert(error.getMessage().contains('You must select at least one facility party'));
		}
        
        
        testData.TestTrancheParty.Facility_Amount__c = 0;
        update testData.TestTrancheParty;
        
        try{
        
        testData.TestTrancheParty.Facility_Amount__c = 50;
        update testData.TestTrancheParty;
        
        } catch(Exception error) {
            //System.assert(error.getMessage().contains('Please ensure that the Facility Amount does not exceed the corresponding Facility Party Facility Amount'));
		}
        
         try{
             
        testData.TestTrancheParty.Facility_Percentage__c = 50;
        testData.TestTrancheParty.Facility_Amount__c = null; 
        update testData.TestTrancheParty;
             
             } catch(Exception error) {
            //System.assert(error.getMessage().contains('Please ensure that the Facility Amount does not exceed the corresponding Facility Party Facility Amount'));
		}
        
        try{
        
        testData.TestFacilityTranche.Tranche_Limit__C = null;
        update testData.TestFacilityTranche;
            
        testData.TestTrancheParty.Facility_Amount__c = 50;
        update testData.TestTrancheParty;
        
        } catch(Exception error) {
            System.assert(error.getMessage().contains('Please ensure there is a Facility Limit specified on the Facility Tranche'));
		}

		Test.stopTest();
	}
}