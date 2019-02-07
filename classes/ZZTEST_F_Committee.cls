/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Initiative
*/
@isTest
public class ZZTEST_F_Committee {
	public enum CommitteeRecordType {DEFAULT_COMMITTEE}

    private static ZZTEST_F_Committee instance;

    private Integer productCounter;
   	
    private ZZTEST_F_Committee() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Committee getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Committee();
        }
        return instance;
    }

    public Committee__c getProduct(CommitteeRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getDefaultCommittee(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Committee__c getInsertedProduct(CommitteeRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getInsertedDefaultCommittee(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Committee__c getDefaultCommittee(ZZTEST_DataContainer dataContainer) {
        Committee__c comm = new Committee__c();
        comm.Name = 'Test Committee';
        comm.Private__c = true;
        comm.Start__c = Date.today();
        comm.End__c = Date.today().addDays(7) ;
        comm.Description__c = 'Sample Description';

        return comm;
    }

    private Committee__c getInsertedDefaultCommittee(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Committee__c.getSObjectType()).isEmpty()) {
            Committee__c comm = this.getDefaultCommittee(dataContainer);
            insert comm;
            dataContainer.put(comm);
            return comm;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Committee__c.getSobjectType(), null).values()) {
                return (Committee__c) s;
            }
        }
        return null;
    }
}