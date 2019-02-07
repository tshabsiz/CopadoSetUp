/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 21/08/2017 - PG   - Created Class. 
 18/09/2017 - PG   - Removed "detemineProductId" methods.    Rather query associated matter for product.
 19/09/2017 - PG   - Added relationship from matter as well.
 17/01/2018 - TdB  - Add Review Status
 05/02/2018 - TdB  - Change Product functionality to use 3 the 3 new TMG Product Objects
 22/02/2018 - TdB  - Add functionality to set Agreement added from Library to False
 12/03/2018 - TdB   - Agreement Limit optional (prevent Users from creating Drawdown and Agency with no Agreement Limit) 
 01/08/2018 - TdB  - Removed debug for objectRecord.TMG_Product_Level_3__c

**/
public class Agreement_Override {
    /**
    * Variables
    **/
    public Agreement__c objectRecord { get; set; }
    public String objectPrefix { get; set; }
    public static final Map<String, RecordTypeInfo> agreementTypes = new Map<String, RecordTypeInfo>(Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName());
    public String productId { get; set; }
    public List<SelectOption> productAgreementTypes { get; set; }

    /**
    * Constructor
    **/
    public Agreement_Override(ApexPages.StandardController stdController) {
        System.debug('### Agreement_Override');

        //Blank vars.
        productAgreementTypes = new List<SelectOption>();

        //Get the object prefix.
        objectPrefix = Agreement__c.sObjectType.getDescribe().getKeyPrefix();

        //Fields for sObject.
        Map<String, Schema.SObjectField> agreementFieldMap = Schema.getGlobalDescribe().get('Agreement__c').getDescribe().fields.getMap();
        List<String> fields = new List<String>();
        for(Schema.SObjectField eachField :agreementFieldMap.values())
        {
            schema.describeFieldResult dfield = eachField.getDescribe();
            fields.add(string.valueOf(dfield.getName())); 
        }
        
        //Test not running.
        if (!Test.isRunningTest()) {
            //Add fields
            stdController.addFields(fields);
        }

        //Get the page context record.
        this.objectRecord = (Agreement__c) stdController.getRecord();

        //This is a new record or edit.
        if (objectRecord.Id == null) {
            //Set default fields.
            //Detemine the record type to use.
            if (ApexPages.currentPage().getParameters().get('RecordType') != null) {
                //Record type via the URL.
                objectRecord.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');

                List<RecordType> records = new List<RecordType>();
                records = [select id, name from RecordType where id = :objectRecord.RecordTypeId limit 1];
                if (records.get(0).name == 'Agreement Legal') {
                    List<TMG_Product_Level_3__c> products = new List<TMG_Product_Level_3__c>();
                    products = [select id, name from TMG_Product_Level_3__c where name = 'Legal Agreement Product' limit 1];
                    if (products.size() > 0) {
                        objectRecord.TMG_Product_Level_3__c = products.get(0).id;
                    }
                }
            } else {
                objectRecord.RecordTypeId = agreementTypes.get('Agreement').getRecordTypeId();
            }

            //Get somefields from the associate Matter_Deal__c
            if (objectRecord.Matter_Deal__c != null) {
                advpm__Matter__c matter = [
                        SELECT
                                Id,
                                TMG_Product_Level_3__c,
                                advpm__Primary_Account__c
                        FROM advpm__Matter__c
                        WHERE
                                Id = :objectRecord.Matter_Deal__c
                        LIMIT 1
                ];

                System.debug('### Agreement_Override : matter : ' + matter);

                //We got a matter back.
                if (matter != null) {
                    //Set product.
                    objectRecord.TMG_Product_Level_3__c = matter.TMG_Product_Level_3__c;
                    objectRecord.Client_Name__c = matter.advpm__Primary_Account__c;
                }
            }
        }
    }

    /**
    * actionHandleEntry
    **/
    public PageReference actionHandleEntry() {
        System.debug('### Agreement_Override : actionHandleEntry');

        //Get current page parameters
        Map<String, String> currentParams = ApexPages.CurrentPage().getParameters();

        //Set
        productId = objectRecord.TMG_Product_Level_3__c;

        if(agreementTypes.get('GMRA Agreement').getRecordTypeId() == objectRecord.RecordTypeId || agreementTypes.get('GMSLA Agreement').getRecordTypeId() == objectRecord.RecordTypeId || agreementTypes.get('ISDA Agreement').getRecordTypeId() == objectRecord.RecordTypeId || agreementTypes.get('Prime Services Agreement').getRecordTypeId() == objectRecord.RecordTypeId){
            if(objectRecord.id != null){
                PageReference masterAgreementEdit = new PageReference('/apex/MasterAgreementEdit?id=' + objectRecord.id);
                masterAgreementEdit.setRedirect(true);
                return masterAgreementEdit;
            }
        }

            //Matches a standard agreement.
        if ((agreementTypes.get('Agreement').getRecordTypeId() == objectRecord.RecordTypeId || agreementTypes.get('Agreement Legal').getRecordTypeId() == objectRecord.RecordTypeId) && objectRecord.Id == null) {
            //Get the product id from the URL params.
            if (productId != null) {
                //Initialise the select list.
                populateProductAgreementTypes();
            } else {
                //Add none.
                productAgreementTypes.add(new SelectOption('', '--None--'));
            }

            //Stay put.
            return null;
        } else if (objectRecord.Id != null && (objectRecord.RecordTypeId == agreementTypes.get('Agreement').getRecordTypeId() || objectRecord.RecordTypeId == agreementTypes.get('Agreement Legal').getRecordTypeId())) {
            //Get the product id from the URL params.
            if (productId != null) {
                //Initialise the select list.
                populateProductAgreementTypes();
            } else {
                //Add none.
                productAgreementTypes.add(new SelectOption('', '--None--'));
            }

            //Stay put.
            return null;
        }
        //Redirect to standard page.
        else {
            //New Page Setup
            PageReference standardPage = new PageReference('/' + objectPrefix + '/e?');
            standardPage.setRedirect(true);

            //Add passed params.
            standardPage.getParameters().putAll(currentParams);

            //Remove some unwanted params.
            standardPage.getParameters().remove('save_new');
            standardPage.getParameters().remove('save');

            //Prevent infinite loop. Force override.
            standardPage.getParameters().put('nooverride', '1');

            //Redirect.
            return standardPage;
        }
    }

    /**
    * populateProductAgreementTypes
    **/
    public void populateProductAgreementTypes() {
        System.debug('### Agreement_Override : populateProductAgreementTypes');

        //Blank vars.
        List<Product_Agreement__c> productAgreements = new List<Product_Agreement__c>();

        //Make sure we have a product id.
        if (productId != null) {
            //Get records.
            productAgreements = [
                    SELECT
                            Id,
                            Name,
                            TMG_Product_Level_3__c
                    FROM Product_Agreement__c
                    WHERE
                            TMG_Product_Level_3__c = :productId
            ];

            System.debug('productAgreements' + productAgreements);

            //Any records to process?
            if (!productAgreements.isEmpty()) {
                //Loop through records.
                for (Product_Agreement__c productAgreement : productAgreements) {
                    productAgreementTypes.add(new SelectOption(productAgreement.Id, productAgreement.Name));
                }
            }
        }
    }

    /**
    * updateSelectedProduct
    **/
    public PageReference updateSelectedProduct() {
        productId = objectRecord.TMG_Product_Level_3__c;
        productAgreementTypes.clear();
        populateProductAgreementTypes();
        return null;
    }

    /**
    * getAgreementTypesList
    **/
    public List<SelectOption> getAgreementTypesList() {
        return productAgreementTypes;
    }

    /**
    * actionSave
    **/
    public PageReference actionSave() {
        try {
            List<Product_Agreement__c> agreementproductList = new List<Product_Agreement__c>();
            //Get Agreement Template base on Agreemet Type selected
            if (objectRecord.Agreement_Type__c != null) {
                agreementproductList = [SELECT Id, Agreement_Template__c, Name from Product_Agreement__c where Id = :objectRecord.Agreement_Type__c];

            }

            if (agreementproductList.size() > 0) {
                objectRecord.Agreement_Template__c = agreementproductList[0].Agreement_Template__c;
                objectRecord.Agreement_Added_From_Libary__c = False;
            }

            //Insert new object.
            if (objectRecord.Id == null) {
                insert objectRecord;
            } else {
                update objectRecord;
            }
        } catch (Exception e) {
            //Error Message
            if (e.getMessage().contains('schedule') && e.getMessage().contains('Effective Date')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'You are not allowed to change the Effective Date. Agreement related to a Schedule'));
            } else if (e.getMessage().contains('schedule') && e.getMessage().contains('Signature Date')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'You are not allowed to change the Signature Date. Agreement related to a Schedule'));
            } else {
                ApexPages.addMessages(e);
            }

            return null;
        }

        //Send the user to the detail page for the new Deal.
        PageReference agreementPage = new ApexPages.StandardController(objectRecord).view();
        agreementPage.setRedirect(true);

        //Default return.
        return agreementPage;
    }
}