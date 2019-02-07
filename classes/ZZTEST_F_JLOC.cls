/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - JLOC
*/
@isTest
public class ZZTEST_F_JLOC {
	public enum JlocRecordType {DEFAULT_JLOC}
    private static ZZTEST_F_JLOC instance;
    private Integer productCounter;
   
    private ZZTEST_F_JLOC() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_JLOC getInstance() {
        if(instance == null) {
            instance = new ZZTEST_F_JLOC();
        }
        return instance;
    }

    public JLOC__c getProduct(JlocRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if(type == JlocRecordType.DEFAULT_JLOC) {
                return getDefaultJloc(dataContainer);
            }
        } catch(Exception e) {
            return null;
        }

        return null;
    }
    
    public JLOC__c getInsertedProduct(JlocRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if(type == JlocRecordType.DEFAULT_JLOC) {
                return getInsertedDefaultJloc(dataContainer);
            }
        } catch(Exception e) {
            return null;
        }

        return null;
    }

    private JLOC__c getDefaultJloc(ZZTEST_DataContainer dataContainer) {
        JLOC__c jloc = new JLOC__c();
        jloc.JLOC_Type__c = 'JLOC';
        jloc.JLOC_Status__c = 'Draft';
        jloc.Date__c = Date.today();
        jloc.Coverage__c = false;
		jloc.Investment_Banking__c = false;
		jloc.Portfolio_Management__c = false;
		jloc.Markets__c = false;
		jloc.Trade__c = false;
        jloc.Forecast_Not_Available__c = true;

        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        jloc.Organisation__c = acc.Id;

        return jloc;
    }

    private JLOC__c getInsertedDefaultJloc(ZZTEST_DataContainer dataContainer) {
        if(dataContainer.getSObjectMap(JLOC__c.getSObjectType()).isEmpty()) {
            JLOC__c jloc = this.getDefaultJloc(dataContainer);
            INSERT jloc;
            
            dataContainer.put(jloc);
            return jloc;
        } else {
            for(SObject s : dataContainer.getRecordTypeMap(JLOC__c.getSobjectType(), null).values()) {
                return (JLOC__c) s;
            }
        }

        return null;
    }
}