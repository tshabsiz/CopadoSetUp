/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __| 
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
*** CHANGE LOG ***
 
29/09/2018 - SKM    - Created Class.
26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist

**/ 
@isTest
public class Matter_ConvertFromOpportunities_Test {
    
    public static testMethod void Matter_ConvertFromOpportunities_Test()
    {  
        DateTime todaysDate_nextMonth = System.now().addMonths(1);
        //The test Data
        //Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        User TestUser = Cloudsmiths_TestDataClass.createUser('Barclays Standard User','AdvoUser@fakeddomain11235z.co.za');
        insert TestUser;
        
        Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Account TestAccount = new Account
            (
                Name = 'Test Account 1', 
                Type = 'Client',
                Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'),
                SDS__c = 'test',
                RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId()
            );
        insert TestAccount;
        
        Opportunity TestOpportunity = new Opportunity
            (
                Name = 'Test Opp' ,
                StageName = 'Opportunity Identified',
                CloseDate = Date.today().addMonths(6),
                Amount = 54321,
                Description = 'Big opportunity for our company.',
                IsPrivate = false,
                TotalOpportunityQuantity = 12,
                AccountId = TestAccount.Id
            );
        insert TestOpportunity;      
                
        OpportunityTeamMember testOpportunityMember = new OpportunityTeamMember
        (
            OpportunityId = TestOpportunity.Id, 
            I_confirm_team_member_has_been_cleared__c = true,
            UserId=TestUser.Id, 
            TeamMemberRole='Member Role'
        );
        insert testOpportunityMember;

        //The page reference
        PageReference pageRef = Page.Matter_ConvertFromOpportunities;
        Test.setCurrentPage(pageRef);
        
        //The VisualForce page
        ApexPages.StandardController stdController = new ApexPages.StandardController(TestAccount);
        Matter_ConvertFromOpportunities extController = new Matter_ConvertFromOpportunities(stdController);
        
        //TheParameters
        ApexPages.currentPage().getParameters().put('Id', null);
        ApexPages.currentPage().getParameters().put('AccountId', TestAccount.Id);
        
        Test.startTest();
        
        extController.opportunityWrappers[0].selected = false;
        extController.submitRecord();

        extController = new Matter_ConvertFromOpportunities(stdController);
        extController.opportunityWrappers[0].selected = true;
        extController.submitRecord();
        
        
        Test.stopTest();
    }
}