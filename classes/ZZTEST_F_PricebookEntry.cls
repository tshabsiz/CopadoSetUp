/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - PricebookEntry
*/
@isTest
public class ZZTEST_F_PricebookEntry {

	public enum PricebookEntryRecordType {DEFAULT_PRICEBOOK_ENTRY, TRANSACTIONS_PRICEBOOK_ENTRY, DEPOSITS_PRICEBOOK_ENTRY}

    private static ZZTEST_F_PricebookEntry instance;

    private Integer productCounter;

    private ZZTEST_F_PricebookEntry() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_PricebookEntry getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_PricebookEntry();
        }
        return instance;
    }

    public PricebookEntry getProduct(PricebookEntryRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == PricebookEntryRecordType.DEFAULT_PRICEBOOK_ENTRY) {
                return getDefaultProduct(dataContainer);
            }
            if (type == PricebookEntryRecordType.TRANSACTIONS_PRICEBOOK_ENTRY) {
                return getTransactionsProduct(dataContainer);
            }
            if (type == PricebookEntryRecordType.DEPOSITS_PRICEBOOK_ENTRY) {
                return getDepositsProduct(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public PricebookEntry getInsertedProduct(PricebookEntryRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == PricebookEntryRecordType.DEFAULT_PRICEBOOK_ENTRY) {
                return getInsertedDefaultProduct(dataContainer);
            }
            if (type == PricebookEntryRecordType.TRANSACTIONS_PRICEBOOK_ENTRY) {
                return getInsertedTransactionsProduct(dataContainer);
            }
            if (type == PricebookEntryRecordType.DEPOSITS_PRICEBOOK_ENTRY) {
                return getInsertedDepositsProduct(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private PricebookEntry getDefaultProduct(ZZTEST_DataContainer dataContainer) {
        PricebookEntry pe = new PricebookEntry();
        pe.IsActive = true;
        pe.Pricebook2Id = Test.getStandardPricebookId();
        pe.UnitPrice = 10000;
        pe.UseStandardPrice = false;

        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        Product2 product = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);
        pe.Product2Id = product.Id;
        pe.Product2 = product;
        return pe;
    }
    
    private PricebookEntry getTransactionsProduct(ZZTEST_DataContainer dataContainer) {
        PricebookEntry pe = new PricebookEntry();
        pe.IsActive = true;
        pe.Pricebook2Id = Test.getStandardPricebookId();
        pe.UnitPrice = 10000;
        pe.UseStandardPrice = false;

        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        Product2 product = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.TRANSACTIONS_PRODUCT, dataContainer);
        pe.Product2Id = product.Id;
        pe.Product2 = product;
        return pe;
    }
    
    private PricebookEntry getDepositsProduct(ZZTEST_DataContainer dataContainer) {
        PricebookEntry pe = new PricebookEntry();
        pe.IsActive = true;
        pe.Pricebook2Id = Test.getStandardPricebookId();
        pe.UnitPrice = 10000;
        pe.UseStandardPrice = false;

        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        Product2 product = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEPOSITS_PRODUCT, dataContainer);
        pe.Product2Id = product.Id;
        pe.Product2 = product;
        return pe;
    }

    private PricebookEntry getInsertedDefaultProduct(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(PricebookEntry.getSObjectType()).isEmpty()) {
            PricebookEntry pe = this.getDefaultProduct(dataContainer);
            insert pe;
            dataContainer.put(pe);
            System.debug('############## new pricebook entry');
            return pe;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(PricebookEntry.getSobjectType(), null).values()) {
                System.debug('############## old pricebook entry');
                return (PricebookEntry) s;
            }
        }
        return null;
    }

    private PricebookEntry getInsertedTransactionsProduct(ZZTEST_DataContainer dataContainer) {
        PricebookEntry pe = this.getTransactionsProduct(dataContainer);
        insert pe;
        dataContainer.put(pe);
        System.debug('############## new pricebook entry');
        return pe;
    }
    
    private PricebookEntry getInsertedDepositsProduct(ZZTEST_DataContainer dataContainer) {
        PricebookEntry pe = this.getDepositsProduct(dataContainer);
        insert pe;
        dataContainer.put(pe);
        System.debug('############## new pricebook entry');
        return pe;
    }
}