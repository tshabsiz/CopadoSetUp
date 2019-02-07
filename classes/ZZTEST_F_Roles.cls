/**
* @Author       Svata Sejkora
* @Company:     Deloitte
* @Description: Unit Tests Helper - Contact Association
* @Date:        15.10.2015
* @ConstructorParam:      None
* @TestClass:   none
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 15.10.2015    Svata Sejkora           Class Created
* 13.06.2016	Mohsin Wadee	Changed phone numbers to correct format in all methods where applicable.
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
public class ZZTEST_F_Roles {

    public enum ContactRecordType {DEFAULT_ROLES}

    private static ZZTEST_F_Roles instance;

    private Integer productCounter;

    private ZZTEST_F_Roles() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Roles getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Roles();
        }
        return instance;
    }

    
    public Roles__c getProduct(ContactRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == ContactRecordType.DEFAULT_ROLES) {
                return getDefaultRoles(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    
    public Roles__c getInsertedProduct(ContactRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == ContactRecordType.DEFAULT_ROLES) {
                return getInsertedDefaultRoles(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Roles__c getDefaultRoles(ZZTEST_DataContainer dataContainer) {
        Roles__c conAss = new Roles__c();
            conAss.Active__c = true;
            conAss.Email__c = 'testaccount@email' + productCounter + '.com';
            conAss.Role__c = 'Chief Investment Officer';
            conAss.Primary_Role__c = false;
            conAss.Phone__c = '4207 777 7777';
            conAss.Active__c = true;


            ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
            Contact con = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
            
            conAss.Contact__c = con.Id;
            conAss.Account__c = con.AccountId;
            //conAss.Name = con.LastName + ' ' + con.FirstName;
        return conAss;
    }

    private Roles__c getInsertedDefaultRoles(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Roles__c.getSObjectType()).isEmpty()) {
            Roles__c cA = this.getDefaultRoles(dataContainer);
            insert cA;
            dataContainer.put(cA);
            return cA;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Roles__c.getSobjectType(), null).values()) {
                return (Roles__c) s;
            }
        }
        return null;
    }

}