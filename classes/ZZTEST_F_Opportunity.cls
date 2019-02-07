/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Opportunity
*
* 07.07.2016	Mohsin Wadee	In getDefaultOpportunity() method specified Accountable Banker, and stage as 'Opportunity Identified'.
*/
@isTest
public class ZZTEST_F_Opportunity {
	
	public enum OpportunityRecordType {DEFAULT_OPPORTUNITY, PUBLIC_OPPORTUNITY, PRIVATE_OPPORTUNITY, PRIVATE_OPPORTUNITY_WITH_ACCOUNT_OWNER}

    private static ZZTEST_F_Opportunity instance;

    private Integer productCounter;
    // loading stages from DB to be able to dynamically use them
    private List<OpportunityStage> oppStage = [SELECT MasterLabel, SortOrder FROM OpportunityStage WHERE IsWon = FALSE AND IsClosed = FALSE AND IsActive = TRUE ORDER BY SortOrder asc];

    private ZZTEST_F_Opportunity() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Opportunity getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Opportunity();
        }
        return instance;
    }

    public Opportunity getProduct(OpportunityRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == OpportunityRecordType.DEFAULT_OPPORTUNITY)
                return getDefaultOpportunity(dataContainer);
            if(type == OpportunityRecordType.PRIVATE_OPPORTUNITY)
                return getPrivateOpportunity(dataContainer);
            if(type == OpportunityRecordType.PUBLIC_OPPORTUNITY)
                return getPublicOpportunity(dataContainer);
            if(type == OpportunityRecordType.PRIVATE_OPPORTUNITY_WITH_ACCOUNT_OWNER)
                return getPrivateOpportunityWithAccountOwner(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Opportunity getInsertedProduct(OpportunityRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if(type == OpportunityRecordType.DEFAULT_OPPORTUNITY) 
                return getInsertedDefaultOpportunity(dataContainer);
            if(type == OpportunityRecordType.PRIVATE_OPPORTUNITY)
                return getInsertedPrivateOpportunity(dataContainer);
            if(type == OpportunityRecordType.PUBLIC_OPPORTUNITY)
                return getInsertedPublicOpportunity(dataContainer);

        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Opportunity getDefaultOpportunity(ZZTEST_DataContainer dataContainer) {
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        
        Opportunity opty = new Opportunity();
        opty.Accountable_Banker__c = userFactory.getBarclaysStandardUser().Id;
        opty.Name = 'Big Company ' + productCounter;
        opty.StageName = 'Opportunity Identified';
        opty.Probability = 10;
        opty.CloseDate = Date.today().addMonths(6);
        opty.Amount = 12345;
        opty.Description = 'Big opportunity for our company.';
        opty.IsPrivate = false;
        opty.TotalOpportunityQuantity = 12;
        opty.The_accountable_banker_has_been_cleared__c = true;

    	ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
    	Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        opty.Account = acc;
        opty.AccountId = acc.Id;
        return opty;
    }

    private Opportunity getPublicOpportunity(ZZTEST_DataContainer dataContainer) {
        Opportunity opty = new Opportunity();
        opty.Name = 'Public Opp ' + productCounter;
        opty.StageName = oppStage[0].MasterLabel;
        opty.CloseDate = Date.today().addMonths(6);
        opty.Amount = 54321;
        opty.Description = 'Big opportunity for our company.';
        opty.IsPrivate = false;
        opty.TotalOpportunityQuantity = 12;
        opty.RecordTypeId = OpportunityTrigger_Helper.getOpportunityRT(OpportunityTrigger_Helper.OpportunityRT.PublicOpp);
		opty.Opportunity_Country__c = 'South Africa';
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        opty.Account = acc;
        opty.AccountId = acc.Id;
        return opty;
    }

    private Opportunity getPrivateOpportunity(ZZTEST_DataContainer dataContainer) {
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        
        Opportunity opty = new Opportunity();
        opty.Name = 'Private Opp ' + productCounter;
        opty.StageName = oppStage[0].MasterLabel;
        opty.CloseDate = Date.today().addMonths(6);
        opty.Amount = 54321;
        opty.Description = 'Big opportunity for our company.';
        opty.IsPrivate = false; 
        opty.TotalOpportunityQuantity = 12;
        opty.RecordTypeId = opty.RecordTypeId = OpportunityTrigger_Helper.getOpportunityRT(OpportunityTrigger_Helper.OpportunityRT.PrivateOpp);
        opty.Accountable_Banker__c = userFactory.getBarclaysStandardUser().Id;
        opty.The_accountable_banker_has_been_cleared__c = true;
        opty.PrivateSideClassification__c = 'Team head is conflicted';

        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        opty.Account = acc;
        opty.AccountId = acc.Id;
        return opty;
    }
    
    private Opportunity getPrivateOpportunityWithAccountOwner(ZZTEST_DataContainer dataContainer) {
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        
        Opportunity opty = new Opportunity();
        opty.Name = 'Private Opp ' + productCounter;
        opty.StageName = oppStage[0].MasterLabel;
        opty.CloseDate = Date.today().addMonths(6);
        opty.Amount = 54321;
        opty.Description = 'Big opportunity for our company.';
        opty.IsPrivate = false; 
        opty.TotalOpportunityQuantity = 12;
        opty.RecordTypeId = opty.RecordTypeId = OpportunityTrigger_Helper.getOpportunityRT(OpportunityTrigger_Helper.OpportunityRT.PrivateOpp);
        opty.Accountable_Banker__c = userFactory.getBarclaysWealthUser().Id;
        opty.The_accountable_banker_has_been_cleared__c = true;
        opty.PrivateSideClassification__c = 'Team head is conflicted';

        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT_WITH_OWNER, dataContainer);
        opty.Account = acc;
        opty.AccountId = acc.Id;
        return opty;
    }

    private Opportunity getInsertedDefaultOpportunity(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Opportunity.getSObjectType()).isEmpty()) {
            Opportunity opty = this.getDefaultOpportunity(dataContainer);
            insert opty;
            dataContainer.put(opty);
            return opty;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Opportunity.getSobjectType(), null).values()) {
                return (Opportunity) s;
            }
        }
        return null;
    }


    private Opportunity getInsertedPublicOpportunity(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Opportunity.getSObjectType()).isEmpty()) {
            Opportunity opty = this.getPublicOpportunity(dataContainer);
            insert opty;
            dataContainer.put(opty);
            return opty;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Opportunity.getSobjectType(), null).values()) {
                return (Opportunity) s;
            }
        }
        return null;
    }


    private Opportunity getInsertedPrivateOpportunity(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Opportunity.getSObjectType()).isEmpty()) {
            Opportunity opty = this.getPrivateOpportunity(dataContainer);
            insert opty;
            dataContainer.put(opty);
            return opty;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Opportunity.getSobjectType(), null).values()) {
                return (Opportunity) s;
            }
        }
        return null;
    }
}