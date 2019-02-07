/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Product Level 2
*/
@isTest
public class ZZTEST_F_Product_Level_2 {

    public enum ProductLevel2RecordType {DEFAULT_PRODUCT, ELECTRONIC_BANKING_PRODUCT, CURRENT_ACCOUNT_DEPOSIT_PRODUCT}

    private static ZZTEST_F_Product_Level_2 instance;

    private Integer productCounter;

    private ZZTEST_F_Product_Level_2() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Product_Level_2 getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Product_Level_2();
        }
        return instance;
    }

    public Product_Level_2__c getInsertedProduct(ProductLevel2RecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == ProductLevel2RecordType.DEFAULT_PRODUCT) {
                return getInsertedDefaultProduct(dataContainer);
            }
            if (type == ProductLevel2RecordType.ELECTRONIC_BANKING_PRODUCT) {
                return getInsertedElectronicBankingProduct(dataContainer);
            }
            if (type == ProductLevel2RecordType.CURRENT_ACCOUNT_DEPOSIT_PRODUCT) {
                return getInsertedCurrentAccountDepositProduct(dataContainer);
            }
        } catch (Exception e) {
            System.debug('Exception within product level 2: ' + e);
            return null;
        }
        return null;
    }

    private Product_Level_2__c getDefaultProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_2__c p = new Product_Level_2__c();
        p.Name = 'Karel Kakadu lvl 2';
        p.Active__c = true;
        
        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        Product2 product = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, 
            dataContainer);
        p.Product__c = product.Id;
        p.Product__r = product;
        
        return p;
    }
    
    private Product_Level_2__c getElectronicBankingProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_2__c p = new Product_Level_2__c();
        p.Name = 'Electronic Banking';
        p.Active__c = true;
        
        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        Product2 product = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.TRANSACTIONS_PRODUCT, 
            dataContainer);
        p.Product__c = product.Id;
        p.Product__r = product;
        
        return p;
    }
    
    private Product_Level_2__c getCurrentAccountDepositProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_2__c p = new Product_Level_2__c();
        p.Name = 'Current Account Deposit';
        p.Active__c = true;
        
        ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;
        PricebookEntry pe = pricebookEntryFactory.getInsertedProduct(ZZTEST_F_PricebookEntry.PricebookEntryRecordType.DEPOSITS_PRICEBOOK_ENTRY, dataContainer);
        p.Product__c = pe.Product2Id;
        p.Product__r = pe.Product2;
        
        return p;
    }

    private Product_Level_2__c getInsertedDefaultProduct(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Product_Level_2__c.getSObjectType()).isEmpty()) {
            Product_Level_2__c p = this.getDefaultProduct(dataContainer);
            insert p;
            dataContainer.put(p);
            return p;
        } 
        else {
            for(SObject s :dataContainer.getRecordTypeMap(Product_Level_2__c.getSobjectType(), null).values()) {
                return (Product_Level_2__c) s;
            }
        }
        return null;
    }
    
    private Product_Level_2__c getInsertedElectronicBankingProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_2__c p = this.getElectronicBankingProduct(dataContainer);
        insert p;
        dataContainer.put(p);
        return p;
    }
    
    private Product_Level_2__c getInsertedCurrentAccountDepositProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_2__c p = this.getCurrentAccountDepositProduct(dataContainer);
        insert p;
        dataContainer.put(p);
        return p;
    }
}