@isTest(SeeAllData=true)
public class ClientOnbaording_Controller_Test {

    static testMethod void myUnitTest()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
    
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        cont.AccountID = acc1.ID;
        update cont;
        
        acc1.Contact_Detail_Type__c  = 'LANDLINE';
        update acc1;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('ID',acc1.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc1);
        ClientOnbaording_Controller CC = new ClientOnbaording_Controller(sc);
        
        
        cc.getContactNames();
        CC.getLegalEntity();
        CC.getIDTypeOptions();
        CC.getClientGroupOptions();
        CC.getCountryOptions();
        CC.getCleintTypeOptions();
        
        CC.SelectedContactID = cont.ID;
        CC.sendToESP();
        
        CC.Cancel();
        Test.stopTest();
    }
}