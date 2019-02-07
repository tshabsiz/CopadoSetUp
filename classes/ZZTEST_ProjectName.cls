/**
* @Author:        Dino Scarcella
* @Company:       Absa Capital
* @Description:   Unit Tests for ProjectName Class
*                   Tests executed:
*                   1 - testGetNewName()
*                       Tests getting a new potential private opportunity name
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
private class ZZTEST_ProjectName {
	public static testMethod void testGetNewName() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            insert new ProjectName__c(Name = 'Mugello', Reserved__c = false, Used__c = false);
        	String newProjectName1 = ProjectName.getNewName();
        
            // create an opportunity that holds the suggested name
            Opportunity opp1 = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PRIVATE_OPPORTUNITY, dataContainer);
            insert opp1;
            opp1.Name = newProjectName1;
            update opp1;
            
            ProjectName__c pn1 = [SELECT Reserved__c, Used__c FROM ProjectName__c WHERE Name = 'Mugello' LIMIT 1];
            
            Opportunity opp2 = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PRIVATE_OPPORTUNITY, dataContainer);
            insert opp2;
            opp2.Name = 'Project San Marino';
            update opp2;
            
            insert new ProjectName__c(Name = 'San Marino', Reserved__c = false, Used__c = false);
            
            String newProjectName2 = ProjectName.getNewName();
			ProjectName__c pn2 = [SELECT Reserved__c, Used__c FROM ProjectName__c WHERE Name = 'San Marino' LIMIT 1];
            
            Test.startTest();
            // Test it retrieved a suggested Project Name
            System.assertNotEquals('', newProjectName1);
            // Test it reserved the name when pulling the name
            System.assertEquals(true, pn1.Reserved__c);
            // Test it flagged the Project Name as used when the opportunity was created after using the suggested name
            System.assertEquals(true, pn1.Used__c);
            // Test it couldn't find the second project name because an opportunity already exists with that name
            System.assertEquals('', newProjectName2);
            // Test it flagged the Project Name as used when the opportunity was created before using the suggested name
            System.assertEquals(true, pn2.Used__c);
            Test.stopTest();
        }
    }
}