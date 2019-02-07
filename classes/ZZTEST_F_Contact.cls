/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Contact
*
*	10-May-2016 - Mohsin Wadee - US-1089 - In getDefaultContact() method specified phone numbers in correct format to 
*											avoid validation errors.
*/
@isTest
public class ZZTEST_F_Contact {

    public enum ContactRecordType {DEFAULT_CONTACT}

    private static ZZTEST_F_Contact instance;

    private Integer productCounter;

    private ZZTEST_F_Contact() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Contact getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Contact();
        }
        return instance;
    }

    
    public Contact getProduct(ContactRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == ContactRecordType.DEFAULT_CONTACT) {
                return getDefaultContact(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    
    public Contact getInsertedProduct(ContactRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == ContactRecordType.DEFAULT_CONTACT) {
                return getInsertedDefaultContact(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Contact getDefaultContact(ZZTEST_DataContainer dataContainer) {
        Contact cont = new Contact();
        cont.Email = 'testaccount@email' + productCounter + '.com';
        cont.Birthdate = Date.today().addYears(-30);
        cont.MobilePhone = '4 277 7777777';
        cont.Firstname = 'Pepa';
        cont.Lastname = 'Flaska';
        cont.Phone = '112 2232 2222';
        cont.Job_Role__c = 'Chief Investment Officer';

        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account account = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        cont.Account = account;
        cont.AccountId = account.Id;
        return cont;
    }

    private Contact getInsertedDefaultContact(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Contact.getSObjectType()).isEmpty()) {
            Contact c = this.getDefaultContact(dataContainer);

            //disabling dedup rules
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.SaveResult sr = Database.insert(c,dml);
            system.debug(sr);

            dataContainer.put(c);
            return c;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Contact.getSobjectType(), null).values()) {
                return (Contact) s;
            }
        }
        return null;
    }

}