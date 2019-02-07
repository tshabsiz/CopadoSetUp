/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Test Factory for Account
*                   
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 24.11.2015    Caro Reinecke   Replaced Buying Group with Relationship Group
* 24.02.2016    Caro Reinecke   Added Global ParentAccount and added Client Country 
* 23.05.2016	Mohsin Wadee	Suffixed test account name with current date/time in method getDefaultAccount()
*								to ensure duplicate detection does not trigger.
*								Switched off duplicate checking in method getInsertedDefaultAccount(), as the datetime suffix
*								was still not working.
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_F_Account {

	public enum AccountRecordType {DEFAULT_ACCOUNT, SDS_ACCOUNT, BUYING_GROUP, GENERIC_PRIVATE_SIDE_CLIENT, DEFAULT_ACCOUNT_WITH_OWNER}

	private static ZZTEST_F_Account instance;

	private Integer productCounter {get;set;}

	private ZZTEST_F_Account() {
		this.productCounter = 0;
    }

    public static ZZTEST_F_Account getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Account();
        }
        return instance;
    }

    public Account getProduct(AccountRecordType type, ZZTEST_DataContainer dataContainer) {
    	try {
    		productCounter++;
    		if (type == AccountRecordType.DEFAULT_ACCOUNT) {
    			return getDefaultAccount();
    		}
            if(type == AccountRecordType.SDS_ACCOUNT) {
                return getSDSClientAccount();
            }
            if(type == AccountRecordType.BUYING_GROUP) {
                return getBuyingGroup();
            }
            if(type == AccountRecordType.GENERIC_PRIVATE_SIDE_CLIENT) {
                return getGenericPrivateSideClientGroup();
            }
            if(type == AccountRecordType.DEFAULT_ACCOUNT_WITH_OWNER) {
                return getDefaultAccountWithOwner();
            }
    	} catch (Exception e) {
            System.debug('Exception content within getProduct:' + e);
    		return null;
    	}
    	return null;
    }

    public Account getInsertedProduct(AccountRecordType type, ZZTEST_DataContainer dataContainer) {
    	try {
    		productCounter++;
    		if (type == AccountRecordType.DEFAULT_ACCOUNT) {
    			return getInsertedDefaultAccount(dataContainer);
    		}
            if(type == AccountRecordType.SDS_ACCOUNT) {
                return getInsertedSDSAccount(dataContainer);
            }
            if(type == AccountRecordType.BUYING_GROUP) {
                return getInsertedBuyingGroup(dataContainer);
            }
            if(type == AccountRecordType.GENERIC_PRIVATE_SIDE_CLIENT) {
                return getInsertedGenericPrivateSideClientGroup(dataContainer);
            }
            if(type == AccountRecordType.DEFAULT_ACCOUNT_WITH_OWNER) {
                return getInsertedDefaultAccountWithOwner(dataContainer);
            }
    	} catch (Exception e) {
            System.debug('Exception content within getInsertedProduct: ' + e.getMessage());
    		return null;
    	}
    	return null;
    }

    private Account getDefaultAccount() {
    	Account ac = new Account();
        ac.Name = System.Datetime.now().format('yyyy-MM-dd HH:mm:ss.SSS') + ' Big Company a.s. ' + productCounter;
        ac.BillingStreet = 'Teststreet 13';
        ac.BillingPostalCode = '61208';
        ac.BillingCity = 'Mainz';
        ac.Description = 'Velka firma';
        ac.NumberOfEmployees = 12963;
        ac.Industry = 'Energy';
        ac.Phone = '223556875';
        ac.Rating = 'Hot';
        ac.Global_corporate__c = TRUE;
        //ac.SDS__c = String.valueOf(productCounter*1000);
        ac.Client_Country__c = 'South Africa';
        ac.Registration_Number__c = '12345609';
        return ac;
	}
    
    private Account getGlobalParentClientAccount()
    {
        String clientRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Account ac = new Account();
        ac.Name = 'Big Global Parent Corp';
        ac.BillingStreet = 'Teststreet 13';
        ac.BillingPostalCode = '61208';
        ac.BillingCity = 'Lodz';
        ac.Description = 'Clown Corp';
        ac.NumberOfEmployees = 1337;
        ac.Industry = 'Entertainment';
        ac.Phone = '223556875';
        ac.Rating = 'Hot';
        //ac.SDS__c = '10000651';
        ac.Global_corporate__c = TRUE;
        ac.Country_of_Operation__c = 'PL';
        ac.Country_of_Incorporation__c = 'PL';
        ac.Credit_Group__c = '1337';
        ac.RecordTypeId = clientRT_Id;
        ac.Registration_Number__c = '12345609';
        ac.Client_Country__c = 'Ghana';
        return ac;
    }
    private Account getSDSClientAccount()
    {
        String clientRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Account ac = new Account();
        ac.Name = 'Big SDS Corp';
        ac.BillingStreet = 'Teststreet 13';
        ac.BillingPostalCode = '61208';
        ac.BillingCity = 'Lodz';
        ac.Description = 'Clown Corp';
        ac.NumberOfEmployees = 1337;
        ac.Industry = 'Entertainment';
        ac.Phone = '223556875';
        ac.Rating = 'Hot';
        //ac.SDS__c = '10000650';
        ac.Global_corporate__c = TRUE;
        ac.Country_of_Operation__c = 'PL';
        ac.Country_of_Incorporation__c = 'PL';
        ac.Credit_Group__c = '1337';
        ac.RecordTypeId = clientRT_Id;
        ac.Registration_Number__c = '12345609';
        ac.Client_Country__c = 'Tanzania';
        return ac;
    }

    private Account getBuyingGroup()
    {
        String buyingGroupRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group').getRecordTypeId();
        Account ac = new Account();
        ac.Name = 'Test Relationship Group';
        ac.BillingCountry = 'South Africa';
        ac.Description = 'Relationship Group Description';
        ac.Type = 'Relationship Group';
        ac.Client_Country__c = 'Souht Africa';
        ac.RecordTypeId = buyingGroupRT_Id;
        return ac;
    }
    
    private Account getGenericPrivateSideClientGroup()
    {
        String GenericPrivateSideClientGroupRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group').getRecordTypeId();
        Account ac = new Account();
        ac.Name = 'Private Side Client';
        ac.BillingCountry = 'South Africa';
        ac.Description = 'Relationship Group Description';
        ac.Type = 'Relationship Group';
        ac.Client_Country__c = 'South Africa';
        ac.RecordTypeId = GenericPrivateSideClientGroupRT_Id;
        return ac;
    }
    
    private Account getDefaultAccountWithOwner() {
    	ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
    	Account ac = new Account();
        ac.Name = System.Datetime.now().format('yyyy-MM-dd HH:mm:ss.SSS') + ' Big Company a.s. ' + productCounter;
        ac.BillingStreet = 'Teststreet 13';
        ac.BillingPostalCode = '61208';
        ac.BillingCity = 'Mainz';
        ac.Description = 'Velka firma';
        ac.NumberOfEmployees = 12963;
        ac.Industry = 'Energy';
        ac.Phone = '223556875';
        ac.Rating = 'Hot';
        ac.Global_corporate__c = TRUE;
        //ac.SDS__c = String.valueOf(productCounter*1000);
        ac.Client_Country__c = 'South Africa';
        ac.Registration_Number__c = '12345609';
        ac.OwnerId = userFactory.getBarclaysStandardUser().Id;
        return ac;
	}

	private Account getInsertedDefaultAccount(ZZTEST_DataContainer dataContainer) {
		if (dataContainer.getSObjectMap(Account.getSObjectType()).isEmpty()) {
            Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.AllowSave = true; 
			Account acc = this.getDefaultAccount();
            Database.insert(acc, dml);
            dataContainer.put(acc);
            return acc;
		} 
		else {
            for(SObject s : dataContainer.getRecordTypeMap(Account.getSobjectType(), null).values()) {
            	return (Account) s;
            }
        }
        
        return null;
	}

    private Account getInsertedSDSAccount(ZZTEST_DataContainer dataContainer) {
        Schema.RecordTypeInfo c_rti = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client');
        if(dataContainer.getSObjectMap(Account.getSObjectType()).get(c_rti) == null)
        {
            Account acc = this.getSDSClientAccount();
            insert acc;
            dataContainer.put(acc);
            return acc;
        }
        else {
            for(SObject s : dataContainer.getRecordTypeMap(Account.getSobjectType(), c_rti).values()) {
                return (Account) s;
            }
        }
        
        return null;
    }

    private Account getInsertedBuyingGroup(ZZTEST_DataContainer dataContainer) {
        Schema.RecordTypeInfo c_rti = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group');
        if(dataContainer.getSObjectMap(Account.getSObjectType()).get(c_rti) == null)
        {
            Account acc = this.getBuyingGroup();
            insert acc;
            dataContainer.put(acc);
            return acc;
        }
        else {
            for(SObject s : dataContainer.getRecordTypeMap(Account.getSobjectType(), c_rti).values()) {
                return (Account) s;
            }
        }
        
        return null;
    }
    
    private Account getInsertedGenericPrivateSideClientGroup(ZZTEST_DataContainer dataContainer) {
        Schema.RecordTypeInfo c_rti = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group');
        if(dataContainer.getSObjectMap(Account.getSObjectType()).get(c_rti) == null)
        {
            Account acc = this.getGenericPrivateSideClientGroup();
            insert acc;
            dataContainer.put(acc);
            return acc;
        }
        else {
            for(SObject s : dataContainer.getRecordTypeMap(Account.getSobjectType(), c_rti).values()) {
                return (Account) s;
            }
        }
        
        return null;
    }
    
    private Account getInsertedDefaultAccountWithOwner(ZZTEST_DataContainer dataContainer) {
		if (dataContainer.getSObjectMap(Account.getSObjectType()).isEmpty()) {
            Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.AllowSave = true; 
			Account acc = this.getDefaultAccountWithOwner();
            Database.insert(acc, dml);
            dataContainer.put(acc);
            return acc;
		} 
		else {
            for(SObject s : dataContainer.getRecordTypeMap(Account.getSobjectType(), null).values()) {
            	return (Account) s;
            }
        }
        
        return null;
	}
}