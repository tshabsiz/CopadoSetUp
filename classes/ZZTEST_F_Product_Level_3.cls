/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Product Level 3
*/
@isTest
public class ZZTEST_F_Product_Level_3 {

    public enum ProductLevel3RecordType {DEFAULT_PRODUCT, CURRENT_ACCOUNT_DEPOSIT_PRODUCT, DOMESTIC_PAYMENTS_PRODUCT}

    private static ZZTEST_F_Product_Level_3 instance;

    private Integer productCounter;

    private ZZTEST_F_Product_Level_3() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Product_Level_3 getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Product_Level_3();
        }
        return instance;
    }

    public Product_Level_3__c getInsertedProduct(ProductLevel3RecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == ProductLevel3RecordType.DEFAULT_PRODUCT) {
                return getInsertedDefaultProduct(dataContainer);
            }
            if (type == ProductLevel3RecordType.CURRENT_ACCOUNT_DEPOSIT_PRODUCT) {
                return getInsertedCurrentAccountDepositProduct(dataContainer);
            }
            if (type == ProductLevel3RecordType.DOMESTIC_PAYMENTS_PRODUCT) {
                return getInsertedDomesticPaymentsProduct(dataContainer);
            }
        } catch (Exception e) {
            System.debug('Exception within product level 3: ' + e);
            return null;
        }
        return null;
    }

    private Product_Level_3__c getDefaultProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_3__c p = new Product_Level_3__c();
        p.Name = 'Karel Kakadu lvl 3';
        p.Active__c = true;
        
        ZZTEST_F_Product_Level_2 productLvl2Factory = ZZTEST_DataFactoryFacade.productLvl2;
        Product_Level_2__c productLvl2 = productLvl2Factory.getInsertedProduct(
            ZZTEST_F_Product_Level_2.ProductLevel2RecordType.DEFAULT_PRODUCT, dataContainer);
        p.Product_Level_2__c = productLvl2.Id;
        p.Product_Level_2__r = productLvl2;
        
        return p;
    }

    private Product_Level_3__c getCurrentAccountDepositProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_3__c p = new Product_Level_3__c();
        p.Name = 'Current Account Deposit';
        p.Active__c = true;
        
        ZZTEST_F_Product_Level_2 productLvl2Factory = ZZTEST_DataFactoryFacade.productLvl2;
        Product_Level_2__c productLvl2 = productLvl2Factory.getInsertedProduct(
        ZZTEST_F_Product_Level_2.ProductLevel2RecordType.CURRENT_ACCOUNT_DEPOSIT_PRODUCT, dataContainer);
        p.Product_Level_2__c = productLvl2.Id;
        p.Product_Level_2__r = productLvl2;
        
        return p;
    }
    
    private Product_Level_3__c getDomesticPaymentsProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_3__c p = new Product_Level_3__c();
        p.Name = 'Domestic Payments (Host - Payments)';
        p.Active__c = true;
        
        ZZTEST_F_Product_Level_2 productLvl2Factory = ZZTEST_DataFactoryFacade.productLvl2;
        Product_Level_2__c productLvl2 = productLvl2Factory.getInsertedProduct(
        ZZTEST_F_Product_Level_2.ProductLevel2RecordType.ELECTRONIC_BANKING_PRODUCT, dataContainer);
        p.Product_Level_2__c = productLvl2.Id;
        p.Product_Level_2__r = productLvl2;
        
        return p;
    }
    
    private Product_Level_3__c getInsertedDefaultProduct(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Product_Level_3__c.getSObjectType()).isEmpty()) {
            Product_Level_3__c p = this.getDefaultProduct(dataContainer);
            insert p;
            dataContainer.put(p);
            return p;
        } 
        else {
            for(SObject s :dataContainer.getRecordTypeMap(Product_Level_3__c.getSobjectType(), null).values()) {
                return (Product_Level_3__c) s;
            }
        }
        return null;
    }
    
    private Product_Level_3__c getInsertedCurrentAccountDepositProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_3__c p = this.getCurrentAccountDepositProduct(dataContainer);
        insert p;
        dataContainer.put(p);
        return p;
    }
    
    private Product_Level_3__c getInsertedDomesticPaymentsProduct(ZZTEST_DataContainer dataContainer) {
        Product_Level_3__c p = this.getDomesticPaymentsProduct(dataContainer);
        insert p;
        dataContainer.put(p);
        return p;
    }
}