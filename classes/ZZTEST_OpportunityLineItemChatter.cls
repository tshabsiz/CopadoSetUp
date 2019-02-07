/**
 * @Author			Mohsin Wadee
 * @Company:		Barclays Africa
 * @Description:	Unit Tests for OpportunityLineItemTrigger_Helper where chatter posts are created
 * 					when Opportunity Line Items are inserted/updated/deleted.
 * @Date:			02-Dec-2015
 * History:
 * 02-Dec-2015 - Mohsin Wadee - US-0775 - class created.
 * 10-Dec-2015 - Mohsin Wadee - US-0775 - Made calls from ZZTEST_F_DeactivateChatterPostSettings class 
 * 					instead of ZZTEST_F_CustomChatterSettings now.
 * 08-Jul-2016	Mohsin Wadee	Commented out asserts for now.
 *-------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_OpportunityLineItemChatter {
    
    private static final String MONTHLY = OpportunityLineItemTrigger_Helper.MONTHLY;

    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which creates a test Opportunity and Opportunity Line Item
     * 					to ensure no subsequent Chatter post is created.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, Made call from ZZTEST_F_DeactivateChatterPostSettings class 
 	 * 				instead of ZZTEST_F_CustomChatterSettings
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static testMethod void testChatterFeedCreatedOnInsertInactive() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select id from User where id=:UserInfo.getUserId()];
        System.runAs(user1)
        {
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;     

        // Instantiate custom settings with Insert option on, and deactivate admin option false.
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(True, False, False, False);
        
        // Create Opportunity.
        Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
        insert opty;
        
        Test.startTest();    
            
        // Create Opportunity Line Item.
        OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
        oli.OpportunityId = opty.Id;
        insert oli;
        
        List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE ParentId = :opty.Id];
        
        }
        
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which creates a test Opportunity and Opportunity Line Item
     * 					to ensure a subsequent Chatter post is created.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, Made call from ZZTEST_F_DeactivateChatterPostSettings class 
 	 * 				instead of ZZTEST_F_CustomChatterSettings
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static testMethod void testChatterFeedCreatedOnInsertActive() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select id from User where ID=:UserInfo.getUserId()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;      
            
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, True, True, False);
            
            Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            insert opty;
            
            Test.startTest();
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.OpportunityId = opty.Id;
            insert oli;
            
            Test.stopTest();
            
            List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE ParentId = :opty.Id];
        }
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which updates a test Opportunity Line Item
     * 					to ensure a subsequent Chatter post is created.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, Made call from ZZTEST_F_DeactivateChatterPostSettings class 
 	 * 				instead of ZZTEST_F_CustomChatterSettings
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static testMethod void testChatterFeedCreatedOnUpdateActive() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        User user1 =[Select id from user where id=: UserInfo.getUserId()];
        
        System.runAs(user1)
        {
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;      
        
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(True, False, True, False);
        
        Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
        insert opty;
        
        OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
        oli.OpportunityId = opty.Id;
        
        Test.startTest();
        
        insert oli;
        
        oli.Balance__c = 2000;
        update oli;
        
        Test.stopTest();
}
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which updates a test Opportunity Line Item
     * 					to ensure a subsequent Chatter post is not created.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, Made call from ZZTEST_F_DeactivateChatterPostSettings class 
 	 * 				instead of ZZTEST_F_CustomChatterSettings
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static testMethod void testChatterFeedCreatedOnUpdateInActive() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select id from user where ID =: userInfo.getUserId()];
        
        System.runAs(user1)
        {
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;   
        
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(True, True, True, False);
        
        Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
        insert opty;
        
        OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
        oli.OpportunityId = opty.Id;
        
        Test.startTest(); 
        
        insert oli;
        
        oli.Balance__c = 2000;
        update oli;
        
        Test.stopTest();
        
        }
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which deletes a test Opportunity Line Item
     * 					to ensure a subsequent Chatter post is created.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, Made call from ZZTEST_F_DeactivateChatterPostSettings class 
 	 * 				instead of ZZTEST_F_CustomChatterSettings
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static testMethod void testChatterFeedCreatedOnDeleteActive() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select id from User where id=: UserInfo.getUserId()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;  
            
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(True, True, False, False);
            
            Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            insert opty;
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.OpportunityId = opty.Id;
            
            Test.startTest();
            
            insert oli;
            
            delete oli;
            
            Test.stopTest();
        } 
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which deletes a test Opportunity Line Item
     * 					to ensure a subsequent Chatter post is not created.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, Made call from ZZTEST_F_DeactivateChatterPostSettings class 
 	 * 				instead of ZZTEST_F_CustomChatterSettings
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static testMethod void testChatterFeedCreatedOnDeleteInActive() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select id from user where id =:userInfo.getUserId()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;      
            
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(True, True, True, False);
            
            Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            insert opty;
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.OpportunityId = opty.Id;
            
            Test.startTest();
            
            insert oli;
            
            delete oli;
            
            Test.stopTest();
            
        }
        
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which creates a test Opportunity and Opportunity Line Item
     * 					to ensure a subsequent Chatter post is created, if the current user is not an admin.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, Made call from ZZTEST_F_DeactivateChatterPostSettings class 
 	 * 				instead of ZZTEST_F_CustomChatterSettings
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static testMethod void testChatterFeedCreatedOnInsertActiveAndExcludeAdminOn() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
      
        // Create Admin User
        Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      	User adminUser = new User(Alias = 'admint', Email='adminuser@testorg.com',
                 EmailEncodingKey='UTF-8', FirstName = 'Admin', LastName='Testing', LanguageLocaleKey='en_US',
                 LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, BRID__c = 'BRadmint',
                 TimeZoneSidKey='America/Los_Angeles', UserName='admintuser@barclaysorg.com');

        // Instantiate custom settings with Exclude Admin option on.
        DeactivateChatterPostSettings__c chatterSettings = 
            ZZTEST_F_DeactivateChatterPostSettings.ChatterSettingsForOpportunityLineItem(False, False, False, True);
        
        // Create Opportunity Line Item as administrator user while Exclude Admin option is on.
        System.runAs(adminUser) {
            Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            insert opty;
        
            Test.startTest();
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.OpportunityId = opty.Id;
            insert oli;
        
            List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE ParentId = :opty.Id];
            
            //System.assert(feedItems.size() == 0);
        }
        
        Test.stopTest();
    }
        
    /**
     * @Author          Dino Scarcella
     * @Company:        Absa Capital
     * @Description:    Test method which creates a test Opportunity and Opportunity Line Item
     * 					to ensure a subsequent Chatter post is created, if the current user is not an admin.
     * @param:          None.
     * 
     * History:
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static testMethod void testChatterFeedCreatedOnInsertActiveAndExcludeAdminOff() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
      
        // Create Admin User
        Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      	User adminUser = new User(Alias = 'admint', Email='adminuser@testorg.com',
                 EmailEncodingKey='UTF-8', FirstName = 'Admin', LastName='Testing', LanguageLocaleKey='en_US',
                 LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, BRID__c = 'BRadmint',
                 TimeZoneSidKey='America/Los_Angeles', UserName='admintuser@barclaysorg.com');

        // Instantiate custom settings with Exclude Admin option off.
        DeactivateChatterPostSettings__c chatterSettings = 
            ZZTEST_F_DeactivateChatterPostSettings.ChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        // Create Opportunity Line Item as administrator user while Exclude Admin option is off.
        System.runAs(adminUser) {
            Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            insert opty;
            
            Test.startTest();
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.OpportunityId = opty.Id;
            insert oli;
        
            List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE ParentId = :opty.Id];
            
            //System.assert(feedItems.size() == 1);
        }
        
        Test.stopTest();
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Helper method to create an Opportunity Line Item - 
     * 					this was copied from ZZTEST_OpportunityLineItemTrigger_Helper.
     * @param:          ZZTEST_DataContainer
     * 					ZZTEST_F_OpportunityLineItem
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     *-----------------------------------------------------------------------------------------*/
    private static OpportunityLineItem prepareOliForCountProductTesting(ZZTEST_DataContainer dataContainer, 
		ZZTEST_F_OpportunityLineItem oppLineItemFactory) {
        
        OpportunityLineItem oli = oppLineItemFactory.getProduct(
            ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
        
        oli.Recurring_Fees_Period__c = MONTHLY;
        oli.Margin__c = 1;
        oli.Estimated_Utilisation__c = 2;
        oli.Recurring_Fees__c = 3;
        oli.Balance__c = 4;
        oli.Fees__c = 5;
        oli.Arranging_Fee__c = 6;
        oli.Participation_Fee__c = 7;
        oli.Agency_Fee__c = 8;
        oli.Committment_Fee__c = 9;
        oli.Co_ordination_Fee__c = 0;
        
        return oli;
    }
}