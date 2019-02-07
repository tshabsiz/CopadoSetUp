/**
* @Author:        Unknown
* @Company:       Deloitte
* @Description:   Unit Tests for OpportunityTrigger_Helper
*                   Tests executed:
*                   1 - testOpportunityDefaultPriceBook()
*                       Checks that pricebook is correctly assigned every time an OPP is created
*                   2 - testAddAccountableBankerToOppTeam()
*                       
*                   3 - testUpdateIncomeThisYear()
*                       
*                   4 - testPrivateOpportunity()
*                       
*                   5 - testPublicOpportunity()
*                       
*                   6 - testCreateDefaultOpportunitySplit()
*                       
*                   7 - testCreateDefaultOpportunitySplitBulk()
*                       
*                   8 - shareJlocWithOpportunityTeamMembers()
*                       
*                   9 - testTenderCreateOppUpdateSuccess()
*                       Checks that method is creating tender record and updating opp record accordingly
*                   10 - testTenderCreationBulk()
*                       Checks that the trigger is bulkified
*                   11 - testOpportunityDefaultPriceBookAfterInsert()
*                       Checks that after changing currency of OPP standard pricebook is assigned
*					12 - testModifyOpportunityForPrivateSideUser()
*						Tests that when private opportunity is created its Private Side Client and when Won/Lost
*						goes back to the original client
*					13 - testUpdateOpportunitySegment
*						Tests the update of the opportunity segment when updating opportunity or account
*					14 - testPromoteProductPartner
*						Tests the promotion of the Product Partner as owner of Opportunity
*                   15 - testCheckProductLevel3
*						Tests the ProductLevel3Count is updated on opportunity
*					16 - testAttachmentCheckSignificantPitch
*						Tests the Attachment check on Significant Pitch Opportunities works
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 30.09.2015    Svata Sejkora   Adding Test methods for new method in the handler test methods 9 and 10 / US - 0599
* 13.10.2015    Svata Sejkora   Adding Test methods for new method in the handler test methods 11 and 12 / US - ???? / testOpportunityDefaultPriceBook
* 07.12.2015	Mohsin Wadee	US-0775 - Modified testUpdateIncomeThisYear method to call 
										ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem
* 10-Dec-2015 	Mohsin Wadee 	US-0775 Replace method call ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem
*			with ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem
* 11-May-2017	Mohsin Wadee - Unmarked test methods testTenderCreateOppUpdateSuccess, testTenderCreationBulk, as a lookup to 
*								Opportunity was created in the custom Tender object. These methods don't create tenders.
* 10.10.2017	Dino Scarcella	Modified testUpdateOpportunitySegment to include check on opp.RelationshipOwnerRoleName__c
*								Used for sharing rules referred to in 	CIBDIGSALP-1384
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
private class ZZTEST_OpportunityTrigger_Helper {
    
    @isTest(SeeAllData=true)
    public static void testOpportunityDefaultPriceBook() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        
        User user1 = [Select ID from User where id =:UserInfo.getUserId()];
        
        System.runAs(user1)
        {
            Test.startTest();
            Id pricebookId = Test.getStandardPricebookId();
            System.debug('XXXXXXXXXXXXXX test pricebook Id' + pricebookId);
            
            // creating Opp
            Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            
            Test.stopTest();
            
            // select updated value of Opportunity pricebook2 entry
            List<Opportunity> opie = [SELECT Id, Name, PriceBook2Id FROM Opportunity WHERE Id = :opp.Id];
            
            // assert the value of pricebook assigned to Opp
            System.assertEquals(pricebookId, opie[0].PriceBook2Id);    
        }
        
    }   

    public static testMethod void testAddAccountableBankerToOppTeam() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;  

        User user1  =[Select ID from User where ID=:userInfo.getUserId()];
        
        System.runAs(user1)
        {
             ZZTEST_F_User zzu = ZZTEST_F_User.getInstance();
        //User u = zzu.getExistingUserByProfile('Barclays Standard User');
        Profile barclaysStdUser = [SELECT Id FROM Profile WHERE Name='Barclays Standard User']; 
        User u;
        try{
            u = [SELECT UserName,Email FROM User WHERE ProfileId = :barclaysStdUser.Id AND IsActive = TRUE LIMIT 1]; 
        } catch(Exception ex){
            u = new User(Alias = 'barclays', Email='barclays@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_ZA', ProfileId = barclaysStdUser.Id, 
            TimeZoneSidKey='Africa/Johannesburg', UserName='barclays@testorg.com', BRID__c = 'TESTBRID');
            insert u;
        }

        system.assertNotEquals(null, u.Id);

        Integer batchSize = 100;
        List<Opportunity> opps = new List<Opportunity>();
        
        for(Integer i=0; i<=batchSize; i++){
            Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            opp.Accountable_Banker__c = UserInfo.getUserId();
            opp.Private_Side__c = true;
            opps.add(opp);
        }
        insert opps;

        Test.startTest();
            for(Opportunity opp : opps){
                opp.Accountable_Banker__c = u.Id;
                opp.The_accountable_banker_has_been_cleared__c = true;
            }
            update opps;
        Test.stopTest();

        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : opps){
            oppIds.add(opp.Id);
        }
        List<OpportunityTeamMember> oppTeamMembers = [SELECT Id, UserId, Opportunity.Accountable_Banker__c, TeamMemberRole 
                                                        FROM OpportunityTeamMember WHERE OpportunityId IN :oppIds];
        
        System.assertEquals(oppTeamMembers.size(), batchSize+1);
        for(OpportunityTeamMember oppTeamMember : oppTeamMembers){
            System.assertEquals(oppTeamMember.UserId, oppTeamMember.Opportunity.Accountable_Banker__c);
            System.assertEquals(oppTeamMember.TeamMemberRole, OpportunityTrigger_Helper.TEAM_ROLE_BANKER);
        }
        }
       
    }

    public static testMethod void testUpdateIncomeThisYear() {
        
        User user1 = [Select ID from User where ID =:UserInfo.getUserId()];
        
        System.runAs(user1)
        {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity; 
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;  
            
            Integer batchSize = 100;
            
            List<Opportunity> opportunities = new List<Opportunity>();
            for(Integer i=0; i<=batchSize; i++){
                Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
                opportunities.add(opp);
            }
            insert opportunities;
            
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            for(Integer i=0; i<=batchSize; i++){
                OpportunityLineItem oli = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
                oli.OpportunityId = opportunities[i].Id;
                oli.Recurring_Fees_Period__c = 'Monthly';
                oppLineItems.add(oli);
                
            }
            insert oppLineItems;
            
            Test.startTest();
            for(Opportunity opp : opportunities){
                opp.CloseDate = opp.CloseDate.addMonths(3);
            }
            update opportunities;
            Test.stopTest();	
        }
        
    }

    @isTest(SeeAllData=true)
    public static void testPrivateOpportunity() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        
        User user1 = [Select id from User where id =:UserInfo.getUserId()];
        
        System.runAs(user1)
        {
            Test.startTest();
            
            Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PRIVATE_OPPORTUNITY, dataContainer);
            
            // select updated value of Opportunity pricebook2 entry
            Opportunity myOpp = [SELECT Id, Name, Private_side__c FROM Opportunity WHERE Id = :opp.Id][0];
            
            // Trigger should set "Private_side__c" as true 
            System.assertEquals(true,myOpp.Private_Side__c);
            
            Test.stopTest();
        }
        
    }   

    @isTest(SeeAllData=true)
    public static void testPublicOpportunity() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        
        Test.startTest();

        Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PUBLIC_OPPORTUNITY, dataContainer);
        
        // select updated value of Opportunity pricebook2 entry
        Opportunity myOpp = [SELECT Id, Name, Private_side__c FROM Opportunity WHERE Id = :opp.Id][0];

        // Trigger should set "Private_side__c" as true 
        System.assertEquals(false,myOpp.Private_Side__c);

        Test.stopTest();
    }
    
    public static testMethod void testCreateDefaultOpportunitySplit() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        
        Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        acc.Client_Country__c = 'Seychelles';
        update acc;
        
        Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PUBLIC_OPPORTUNITY, dataContainer);
        
        List<Opportunity_Split__c> splits = [SELECT Percentage__c, Country__c, Opportunity__c FROM Opportunity_Split__c];
        System.assertEquals(1, splits.size());
        System.assertEquals(100, splits[0].Percentage__c);
        System.assertEquals(acc.Client_Country__c, splits[0].Country__c);
        System.assertEquals(opp.Id, splits[0].Opportunity__c);
    }
    
    public static testMethod void testCreateDefaultOpportunitySplitBulk() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        
        Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        update acc;
        
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PUBLIC_OPPORTUNITY, dataContainer);
            opps.add(opp);
        }
        
        Test.startTest();
        insert opps;
        Test.stopTest();
        
        List<Opportunity_Split__c> splits = [SELECT Percentage__c, Country__c, Opportunity__c FROM Opportunity_Split__c];
        System.assertEquals(200, splits.size());
    }

    public static testMethod void shareJlocWithOpportunityTeamMembers()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

        User user1 = [Select id from User where ID =:UserInfo.getUserId()];
        
        JLOC__c jloc1;
        JLOC__c jloc2;
        System.runAs(user1)
        {
            jloc1 = jlocFactory.getProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
            jloc2 = jlocFactory.getProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
            
            List<JLOC__c> jlocs = new List<JLOC__c>();
            jlocs.add(jloc1);
            jlocs.add(jloc2);
            insert jlocs;
            
            Integer batchSize = 200;
            List<Opportunity> opportunities = new List<Opportunity>();
            for(Integer i=0; i<=batchSize; i++){
                Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
                opp.JLOC__c = jloc1.Id;
                opportunities.add(opp);
            }
            insert opportunities;
            
            User barclaysStdUser = userFactory.getBarclaysStandardUser();
            List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
            for(Opportunity opp : opportunities){
                oppTeamMembers.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId=barclaysStdUser.Id, I_confirm_team_member_has_been_cleared__c=true));
            }
            insert oppTeamMembers;
            
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            
            Test.startTest();
            
            for(Opportunity opp : opportunities){
                opp.JLOC__c = jloc2.Id;
            }
            List<Database.SaveResult> srList = Database.update(opportunities,dml);
            
            List<JLOC__Share> dealTeamSharings = [SELECT Id FROM JLOC__Share WHERE RowCause = 'Opportunity_Team_Member__c' AND UserOrGroupId = :barclaysStdUser.Id AND ParentId = :jloc2.Id];
            System.assertEquals(dealTeamSharings.size(), 1);
        }
        
        
       

        Test.stopTest();
    }

    //@isTest
    static void testTenderCreateOppUpdateSuccess() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;

        Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);

        opp.Require_Proposal_Support__c = 'Yes';
        opp.Tender_Created__c = false;
        opp.Estimated_Proposal_Submission_date__c = System.today();

        Test.startTest();
            insert opp;
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, Tender__c, Tender_Created__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];

        System.assert(true, updatedOpp.Tender_Created__c);

        List<Tender__c> createdTender = [SELECT Id FROM Tender__c WHERE Id =: updatedOpp.Tender__c];

        System.assertEquals(1, createdTender.size());

    }

    //@isTest
    static void testTenderCreationBulk() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        List<Opportunity> bulkOpp = new List<Opportunity>();
        Set<Id> createdOppId = new Set<Id>();
        Set<Id> createdTenderId = new Set<Id>();

        for(Integer i = 0; i < 200; i++) {
            Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
                opp.Require_Proposal_Support__c = 'Yes';
                opp.Tender_Created__c = false;
                opp.Estimated_Proposal_Submission_date__c = System.today();
            bulkOpp.add(opp);    
        }

        Test.startTest();
            insert bulkOpp;
        Test.stopTest();

        for(Opportunity createdOpp : bulkOpp) {
            createdOppId.add(createdOpp.Id);
        }

        for(Opportunity updOpp : [SELECT Id, Tender__c, Tender_Created__c FROM Opportunity WHERE Id = :createdOppId]) {
            System.assert(true, updOpp.Tender_Created__c);
            createdTenderId.add(updOpp.Tender__c);
        }

        List<Tender__c> createdTender = [SELECT Id FROM Tender__c WHERE Id =: createdTenderId];

        System.assertEquals(200, createdTender.size());
    }

    @isTest(SeeAllData=true)
    public static void testOpportunityDefaultPriceBookAfterInsert() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;

        User user1 = [Select id from User where ID =: UserInfo.getUserId()];
        System.runAs(user1)
        {
            Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            Id pricebookId = Test.getStandardPricebookId();
            System.debug('XXXXXXXXXXXXXX test pricebook Id' + pricebookId);        
            
            Test.startTest();
            // updating Opp
            opp.CurrencyIsoCode = 'BWP';
            update opp;
            Test.stopTest();
            
            // select updated value of Opportunity pricebook2 entry
            List<Opportunity> opie = [SELECT Id, Name, PriceBook2Id FROM Opportunity WHERE Id = :opp.Id];
            // assert the value of pricebook assigned to Opp
            System.assertEquals(pricebookId, opie[0].PriceBook2Id); 
        }
       
        
          
    }
    
    public static testMethod void testModifyOpportunityForPrivateSideUser() {
    	ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
    	ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
		
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
	        Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PRIVATE_OPPORTUNITY_WITH_ACCOUNT_OWNER, dataContainer);
	        Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.GENERIC_PRIVATE_SIDE_CLIENT, dataContainer);
	        User barclaysStdUser = userFactory.getBarclaysStandardUser();
	        
	        insert opp;
	        
            Test.startTest();
	       
	        Opportunity insertedOpp = [SELECT Id, AccountId, Related_Group_Client__c, Account_Name__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
	       
	        System.assertEquals(insertedOpp.AccountId, acc.Id);
	        System.assertEquals(insertedOpp.Account_Name__c, opp.AccountId);
	        System.assertEquals(insertedOpp.Related_Group_Client__c, null);
            
            OpportunityTrigger_Helper.modifyOpportunityForPrivateSideUser.clear();
	        insertedOpp.StageName = 'Closed Won';
	        insertedOpp.Reason_Won_Lost__c = 'Test Won/Lost Reason';
            insertedOpp.ProductLevel3Count__c = 1;
             insertedOpp.Notify_ABSA_Insurance_Of_This_Deal__c = 'No';
			 update insertedOpp;
	        
	        insertedOpp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
	        System.assertEquals(insertedOpp.AccountId, opp.AccountId);
            
            OpportunityTrigger_Helper.modifyOpportunityForPrivateSideUser.clear();
	        insertedOpp.StageName = 'Identified';
	        update insertedOpp;
	        
	        insertedOpp = [SELECT AccountId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
	        System.assertEquals(insertedOpp.AccountId, acc.Id);
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testUpdateOpportunitySegmentAndIndustry() {
    	ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
		
		User thisUser = [SELECT Id, UserRole.Name, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        User anotherUser = [SELECT Id, UserRole.Name FROM User WHERE UserRoleId != NULL AND UserRoleId != :thisUser.UserRoleId AND IsActive = true LIMIT 1];
        System.runAs (thisUser) {
	        Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
	        opp.Segment__c = 'Public Sector';
	        insert opp;
	        Account acc = new Account(Id = opp.AccountId);
	        acc.Segment__c = 'Global Corporate';
            acc.Industry = 'Agriculture';
            acc.OwnerId = anotherUser.Id;
            acc.Relationship_Corridor__c = 'CHINA';
	        update acc;
	        Opportunity insertedOpp = [SELECT Id, Segment__c, Industry__c, RelationshipOwnerRoleName__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
	        System.assertEquals(insertedOpp.Segment__c, 'Global Corporate');
            System.assertEquals(insertedOpp.Industry__c, 'Agriculture');
            System.assertEquals(anotherUser.UserRole.Name, insertedOpp.RelationshipOwnerRoleName__c);
        }
    }
    
    public static testMethod void testPromoteProductPartner() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	System.runAs (thisUser) {
	    	ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
		
			User anotherUser = [SELECT Id FROM User 
                                WHERE Id != :UserInfo.getUserId()
                                AND isActive = true
                                AND profile.UserLicense.Name  = 'Salesforce'
                                
                                AND ManagerId != NULL LIMIT 1];
			dataContainer.put(anotherUser);
		
			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProduct = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);

            Test.startTest();
			//Update pricebook reference on Opp
			opp.Pricebook2Id = Test.getStandardPricebookId();
			UPDATE opp;
        
	        oli1.OpportunityId = opp.id;
	        oli1.ProductPartner__c = anotherUser.Id;
	        insert oli1;
	        
	        Opportunity insertedOpp = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
	        System.assertEquals(insertedOpp.OwnerId, thisUser.Id);
	        
	        opp.ProductPartnerApprovalStatus__c = 'Approved';
	        update opp;
	        
	        insertedOpp = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
	        System.assertEquals(insertedOpp.OwnerId, anotherUser.Id);
            Test.stopTest();
        }
    }
    
    public static testMethod void testCheckProductLevel3() {
    	ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
		
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
	        Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
	        User barclaysStdUser = userFactory.getBarclaysStandardUser();
	        
	        insert opp;
	        
	        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
	        OpportunityLineItem oli = oppLineItemFactory.getProduct(
            ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli.OpportunityId = opp.Id;
        	insert oli;
	       
	        Opportunity insertedOpp = [SELECT Id, ProductLevel3Count__c FROM Opportunity WHERE Id =:opp.Id LIMIT 1];
	       
	        Test.startTest();
	        System.assertEquals(0, insertedOpp.ProductLevel3Count__c);
	       
	        insertedOpp.StageName = 'In Implementation / Conditions Precedent';
	        update insertedOpp;

	        insertedOpp = [SELECT Id, ProductLevel3Count__c FROM Opportunity WHERE Id =:opp.Id LIMIT 1];
	        System.assertEquals(1, insertedOpp.ProductLevel3Count__c);
            
	        Test.stopTest();
        }    
    }
    
    public static testMethod void testAttachmentCheckSignificantPitch() {
    	ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
		
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
	        Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
	        User barclaysStdUser = userFactory.getBarclaysStandardUser();
	     	insert opp;
            
            Opportunity insertedOpp = [SELECT Id, Significant_Pitch__c FROM Opportunity WHERE Id =:opp.Id LIMIT 1];
            insertedOpp.Significant_Pitch__c = true;
            
            Test.startTest();
            try {
                OpportunityTrigger_Helper.isInsert = false;
                update insertedOpp;
            } catch (Exception e){
                insertedOpp = [SELECT Significant_Pitch__c FROM Opportunity LIMIT 1];
                // Test the update didn't happen
                System.assertEquals(false, insertedOpp.Significant_Pitch__c);
            }
            Test.stopTest();
        }
    }
}