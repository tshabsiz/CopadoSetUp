/**
* @Author:        Dino Scarcella
* @Company:       Absa Capital
* @Description:   Unit Tests for DrawdownsTrigger_Helper
*                   Tests executed:
*                   1 - testUpdateFirstDrawdown()
*                       Checks that the First Drawdown Date and Amount gets updated on the opportunity when inserting, updating and deleting drawdowns
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
public class ZZTEST_DrawdownsTrigger_Helper {
	public static testMethod void testUpdateFirstDrawdown() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        User user1 = [Select id from User where id =:UserInfo.getUserId()];
        
        System.runAs(user1)
        {
            Test.startTest();
            
            Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PUBLIC_OPPORTUNITY, dataContainer);
            
            // select the opportunity
            Opportunity myOpp = [SELECT Id, Name, First_Drawdown_Manual__c, First_Drawdown_Amount__c FROM Opportunity WHERE Id = :opp.Id][0];
            myOpp.isExternal__c = true;
            update myOpp;
            
            // Trigger should not update the first drawdown
            System.assertEquals(NULL, myOpp.First_Drawdown_Manual__c);
            System.assertEquals(NULL, myOpp.First_Drawdown_Amount__c);
          
            DrawDowns__c dd = new DrawDowns__c(Drawdown_date__c = System.today(), Drawdown_Amount__c = 1234, Opportunity__c = opp.Id);
			insert dd;
            
            // select the opportunity
            myOpp = [SELECT Id, Name, First_Drawdown_Manual__c, First_Drawdown_Amount__c FROM Opportunity WHERE Id = :opp.Id][0];
            // Trigger should update the first drawdown
            System.assertEquals(System.today(), myOpp.First_Drawdown_Manual__c);
            System.assertEquals(1234, myOpp.First_Drawdown_Amount__c);
            
            dd = [SELECT Id, Drawdown_date__c, Drawdown_Amount__c FROM DrawDowns__c WHERE Id =:dd.Id][0];
            dd.Drawdown_date__c = System.today() - 1;
            dd.Drawdown_Amount__c = 12345;
            update dd;
            
            // select the opportunity
            myOpp = [SELECT Id, Name, First_Drawdown_Manual__c, First_Drawdown_Amount__c FROM Opportunity WHERE Id = :opp.Id][0];
            // Trigger should update the first drawdown
            System.assertEquals(System.today() - 1, myOpp.First_Drawdown_Manual__c);
            System.assertEquals(12345, myOpp.First_Drawdown_Amount__c);
            
            delete dd;
            
            // select the opportunity
            myOpp = [SELECT Id, Name, First_Drawdown_Manual__c, First_Drawdown_Amount__c FROM Opportunity WHERE Id = :opp.Id][0];
            // Trigger should update the first drawdown to NULL
            System.assertEquals(NULL, myOpp.First_Drawdown_Manual__c);
            System.assertEquals(NULL, myOpp.First_Drawdown_Amount__c);
            
            Test.stopTest();
        }        
    }
}