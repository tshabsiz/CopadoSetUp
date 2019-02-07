/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Initiative
*/
@isTest
public class ZZTEST_F_Initiative {
	public enum InitiativeRecordType {DEFAULT_INITIATIVE}

    private static ZZTEST_F_Initiative instance;

    private Integer productCounter;
   	
    private ZZTEST_F_Initiative() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Initiative getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Initiative();
        }
        return instance;
    }

    public Initiative__c getProduct(InitiativeRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getDefaultInitiative(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Initiative__c getInsertedProduct(InitiativeRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getInsertedDefaultInitiative(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Initiative__c getDefaultInitiative(ZZTEST_DataContainer dataContainer) {
        Initiative__c init = new Initiative__c();
        init.Description__c = 'Initiative Test Description';
        init.Start_Date__c = Date.today();
        init.End_Date__c = Date.today().addDays(7) ;
        init.Stage__c = 'Planned';
        init.Status__c = 'Green';

        return init;
    }

    private Initiative__c getInsertedDefaultInitiative(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Initiative__c.getSObjectType()).isEmpty()) {
            Initiative__c init = this.getDefaultInitiative(dataContainer);
            insert init;
            dataContainer.put(init);
            return init;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Initiative__c.getSobjectType(), null).values()) {
                return (Initiative__c) s;
            }
        }
        return null;
    }
}