/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
30/10/2017 - PG     - Created class.
                                                   
**/ 
@isTest
public class Agreement_Party_Helper_Test 
{
	@isTest
	static void Agreement_Party_Helper_Test()
    {       
        Cloudsmiths_TestDataClass testData =  new Cloudsmiths_TestDataClass();

        Test.startTest();

        //Updat documentation status.
        testData.TestDealParty.Party_Type__c = 'Lender';
		update testData.TestDealParty;
        
        testData.TestAgreementParty.Lender_Amount__c = 100.00;
        update testData.TestAgreementParty;

        Test.stopTest();     
    }
}