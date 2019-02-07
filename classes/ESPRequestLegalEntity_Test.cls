@isTest
public class ESPRequestLegalEntity_Test {

    static testMethod void  requestLegalEntityCIFUpdate_Positive()
    {
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

        Test.startTest();
        ESPRequestLegalEntity.requestLegalEntityCIFUpdate(acc1.Id,'12334');
        Test.stopTest();
    }
    static testMethod void  requestLegalEntityCIFUpdate_Negative()
    {
        Test.startTest();
        ESPRequestLegalEntity.requestLegalEntityCIFUpdate('00122346efed','12334');
        Test.stopTest();
    }
}