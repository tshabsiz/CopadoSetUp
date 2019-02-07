/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Product
*/
@isTest
public class ZZTEST_F_Product {

	public enum ProductRecordType {DEFAULT_PRODUCT, TRANSACTIONS_PRODUCT, DEPOSITS_PRODUCT}

    private static ZZTEST_F_Product instance;

    private Integer productCounter;

    private ZZTEST_F_Product() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Product getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Product();
        }
        return instance;
    }

    public Product2 getProduct(ProductRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == ProductRecordType.DEFAULT_PRODUCT) {
                return getDefaultProduct(dataContainer);
            }
            if (type == ProductRecordType.TRANSACTIONS_PRODUCT) {
                return getTransactionsProduct(dataContainer);
            }
            if (type == ProductRecordType.DEPOSITS_PRODUCT) {
                return getDepositsProduct(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    public Product2 getInsertedProduct(ProductRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == ProductRecordType.DEFAULT_PRODUCT) {
                return getInsertedDefaultProduct(dataContainer);
            }
            if (type == ProductRecordType.TRANSACTIONS_PRODUCT) {
                return getInsertedTransactionsProduct(dataContainer);
            }
            if (type == ProductRecordType.DEPOSITS_PRODUCT) {
                return getInsertedDepositsProduct(dataContainer);
            }
        } catch (Exception e) {
        	System.debug('Exception within product2: ' + e);
            return null;
        }
        return null;
    }

    private Product2 getDefaultProduct(ZZTEST_DataContainer dataContainer) {
        Product2 p = new Product2();
        p.Name = 'Karel Kakadu';
        p.IsActive = true;
        p.ProductCode = '364SN4SF';
        p.Description = 'Tool for data backup';
        p.CurrencyIsoCode = 'GBP';
        return p;
    }
    
    private Product2 getTransactionsProduct(ZZTEST_DataContainer dataContainer) {
        Product2 p = new Product2();
        p.Name = 'Transactions';
        p.IsActive = true;
        p.ProductCode = '365DN6SD';
        p.Description = 'Product for Testing';
        p.CurrencyIsoCode = 'GBP';
        return p;
    }
    
    private Product2 getDepositsProduct(ZZTEST_DataContainer dataContainer) {
        Product2 p = new Product2();
        p.Name = 'Deposits';
        p.IsActive = true;
        p.ProductCode = '365DN6SE';
        p.Description = 'Product for Testing';
        p.CurrencyIsoCode = 'GBP';
        return p;
    }

    private Product2 getInsertedDefaultProduct(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Product2.getSObjectType()).isEmpty()) {
        	system.debug('inside if getInsertedDefaultProduct2');
            Product2 p = this.getDefaultProduct(dataContainer);
            insert p;
            dataContainer.put(p);
            return p;
        } 
        else {
          	system.debug('inside else getInsertedDefaultProduct2');
            for(SObject s :dataContainer.getRecordTypeMap(Product2.getSobjectType(), null).values()) {
                return (Product2) s;
            }
        }
        return null;
    }
    
    private Product2 getInsertedTransactionsProduct(ZZTEST_DataContainer dataContainer) {
        system.debug('inside getTransactionsProduct2');
        Product2 p = this.getTransactionsProduct(dataContainer);
        insert p;
        dataContainer.put(p);
        return p;
    }
    
    private Product2 getInsertedDepositsProduct(ZZTEST_DataContainer dataContainer) {
        system.debug('inside getDepositsProduct2');
        Product2 p = this.getDepositsProduct(dataContainer);
        insert p;
        dataContainer.put(p);
        return p;
    }
}