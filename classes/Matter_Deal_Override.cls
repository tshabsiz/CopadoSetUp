/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

19/08/2017 - PG    - Created Class. 
08/11/2017 - PG    - Added 2 new fields.
09/11/2017 - PG    - Added CD/ Vault, Zippal etc fields.
25/01/2018 - TdB   - Add Try catch on update of Deal
02/02/2018 - TdB   - Change Product functionality to use 3 the 3 new TMG Product Objects
01/08/2018 - TdB   - Remove hard coded fields, use Describe and add the fields to the list

**/ 
public class Matter_Deal_Override 
{
    /**
* Variables
**/
    public advpm__Matter__c objectRecord { get; set; }
    public static final Map<String, RecordTypeInfo> matterType = new Map<String, RecordTypeInfo>(advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName()); 
    private List<SelectOption> productOptions = new List<SelectOption>();
    public Id selectedProduct { get; set; }
    public Boolean productDisabled { get; set; }
    
    public List<TMG_Product_Level_1__c> coverageAreaList = new List<TMG_Product_Level_1__c>();
    public List<TMG_Product_Level_2__c> productAreaList = new List<TMG_Product_Level_2__c>();
    public  List<TMG_Product_Level_3__c> products = new List<TMG_Product_Level_3__c>();
    
    private List<SelectOption> coverageAreaOptions = new List<SelectOption>();
    public Id coverageAreaSelected { get; set; }
    public String coverageAreaSelected_String { get; set; }
    public Boolean coverageAreaDisabled { get; set; }
    
    private List<SelectOption> productAreaOptions = new List<SelectOption>();
    public Id productAreaSelected { get; set; }
    public Boolean productAreaDisabled { get; set; }
    
    /**
* CONSTRUCTOR
**/
    public Matter_Deal_Override(ApexPages.StandardController stdController)
    {
        //Fields for sObject.
        Map<String, Schema.SObjectField> matterFieldMap = Schema.getGlobalDescribe().get('advpm__Matter__c').getDescribe().fields.getMap();
        List<String> fields = new List<String>();
        for(Schema.SObjectField eachField :matterFieldMap.values())
        {
            schema.describeFieldResult dfield = eachField.getDescribe();
            fields.add(string.valueOf(dfield.getName())); 
        }

        if(!Test.isRunningTest())
        {
            //Add fields
            stdController.addFields(fields);
        }
        
        //Get the page context record.
        this.objectRecord = (advpm__Matter__c)stdController.getRecord();
        
        //Is a new record?
        if(objectRecord.Id == null)
        {
            //Set default fields.
            objectRecord.OwnerId = UserInfo.getUserId();
            objectRecord.RecordTypeId = matterType.get('Deal').getRecordTypeId();
            
            //Add to product options list.
            productOptions.add(new SelectOption('','--None--'));
            productDisabled = true; 
            
            //Add to Coverage Area list.
            coverageAreaOptions.add(new SelectOption('','--None--'));
            coverageAreaDisabled = true; 
            
            //Add to Coverage Area list.
            productAreaOptions.add(new SelectOption('','--None--'));
            productAreaDisabled = true; 
            
            populateCoverageArea();
            populateProductArea();
            populateProducts();
        }
        else
        {
            if(objectRecord.TMG_Product_Level_1__c == null)
            {
                initialiseLists();
            }
            else
            {
                system.debug('###objectRecord.TMG_Product_Level_1__c :' + objectRecord.TMG_Product_Level_1__c);
                coverageAreaSelected = objectRecord.TMG_Product_Level_1__c;
                productAreaSelected = objectRecord.TMG_Product_Level_2__c;
                selectedProduct = objectRecord.TMG_Product_Level_3__c;
                
            }
            
            //Populate the initial list of products.
            System.debug('#####################objectRecord.Division__c: ' + objectRecord.Division__c);
            populateCoverageArea();
            populateProductArea();
            populateProducts();
            
        }
    }
    
    public void initialiseLists()
    {
        coverageAreaList = new List<TMG_Product_Level_1__c>();
        productAreaList = new List<TMG_Product_Level_2__c>();
        products = new List<TMG_Product_Level_3__c>();
        
        if(objectRecord.Division__c != null)
        {
            coverageAreaList = [
                SELECT
                Id,
                Name
                FROM TMG_Product_Level_1__c
                WHERE
                Division__c = :objectRecord.Division__c
                AND Active__c = true
            ];
            
            if(coverageAreaList.size() > 0)
            {
                coverageAreaSelected = coverageAreaList[0].id;
            }
        }
        
        if(coverageAreaSelected != null)
        {
            productAreaList = [
                SELECT
                Id,
                Name
                FROM TMG_Product_Level_2__c
                WHERE
                TMG_Product_Level_1__r.Id = :coverageAreaSelected
                AND Active__c = true
            ];
            
            if(productAreaList.size() > 0)
            {
                productAreaSelected = productAreaList[0].id;
            }
        }
        
        if(productAreaSelected != null)
        {
            products = [
                SELECT
                Id,
                Name
                FROM TMG_Product_Level_3__c
                WHERE
                TMG_Product_Level_2__r.Id= :productAreaSelected
                AND Active__c = true
            ];
            
            if(products.size() > 0 )
            {
                selectedProduct = products[0].id;
            }
        }
    } 
    
    
    public void populateProducts()
    {
        //Blank vars.
        
        productDisabled = true;  
        
        //Has a product area.
        if(productAreaSelected != null)
        {
            //Get product for the selected area.
            products = [
                SELECT
                Id,
                Name
                FROM TMG_Product_Level_3__c
                WHERE
                TMG_Product_Level_2__r.Id= :productAreaSelected
                AND Active__c = true
            ];
            
            //Anything to process.
            if(!products.isEmpty())
            {      
                productDisabled = false;
                if(selectedProduct == null)
                {
                    selectedProduct = products[0].Id;
                }
                
                for(TMG_Product_Level_3__c product : products)
                {
                    //Add to product options list.
                    productOptions.add(new SelectOption(product.Id,product.Name));
                }
            }
            else
            {
                //Add to product options list.
                productOptions.add(new SelectOption('','--None--'));
            }
        }
        else
        {
            //Add to product options list.
            productOptions.add(new SelectOption('','--None--'));
        }
    } 
    
    public PageReference actionClearProduct()
    {
        //Clear Product Area
        selectedProduct = null;
        
        //Clear product options.
        productOptions.clear();
        
        //Populate new products list.
        populateProducts();
        
        return null;
    }
    
    /**
* getProducts 
**/
    public List<SelectOption> getProducts()
    {
        return productOptions;
    }
    
    /****************************************
* 
* Coverage Area
* 
* *************************************/
    public void populateCoverageArea()
    {
        //Blank vars.
        
        productDisabled = true;  
        productAreaDisabled = true;  
        
        
        
        //Has a product area.
        if(objectRecord.Division__c != null) 
        {
            //Get product for the selected area.
            coverageAreaList = [
                SELECT
                Id,
                Name
                FROM TMG_Product_Level_1__c
                WHERE
                Division__c = :objectRecord.Division__c
                AND Active__c = true
            ];
            
            //Anything to process.
            if(!coverageAreaList.isEmpty())
            {      
                coverageAreaDisabled = false;  
                
                if(CoverageAreaSelected == null)
                {
                    CoverageAreaSelected = coverageAreaList[0].id;
                }
                
                for(TMG_Product_Level_1__c eachCoverage : coverageAreaList)
                {
                    //Add to product options list.
                    coverageAreaOptions.add(new SelectOption(eachCoverage.Id,eachCoverage.Name));
                }
            }
            else
            {
                //Add to product options list.
                coverageAreaOptions.add(new SelectOption('','--None--'));
            }
        }
        else
        {
            //Add to product options list.
            coverageAreaOptions.add(new SelectOption('','--None--'));
        }
        
        System.debug('coverageAreaSelected : ' + coverageAreaSelected);
    } 
    
    public PageReference actionClearCoverageArea()
    {
        //Clear Product Area
        coverageAreaSelected = null;
        ProductAreaSelected = null;
        selectedProduct = null;
        
        //Clear product options.
        coverageAreaOptions.clear();
        productAreaOptions.clear();
        productOptions.clear();
        
        //Populate new products list.
        populateCoverageArea();
        populateProductArea();
        populateProducts();
        
        return null;
    }
    
    public List<SelectOption> getCoverageArea()
    {
        return coverageAreaOptions;
    }
    
    /***************************************
* 
* Product Area
* 
* *************************************/
    
    public void populateProductArea()
    {
        //Blank vars.
        
        productDisabled = true;  
        
        System.debug('coverageAreaSelected_String : ' + coverageAreaSelected_String);   
        System.debug('coverageAreaSelected : ' + coverageAreaSelected); 
        system.debug('objectRecord.TMG_Product_Level_1__c : ' + objectRecord.TMG_Product_Level_1__c);
        system.debug('objectRecord.Division__c : ' + objectRecord.Division__c);
        
        //Has a product area.
        if(coverageAreaSelected != null )
        {
            //Get product for the selected area.
            productAreaList = [
                SELECT
                Id,
                Name
                FROM TMG_Product_Level_2__c
                WHERE
                TMG_Product_Level_1__r.Id = :coverageAreaSelected
                AND Active__c = true
            ];
            
            //Anything to process.
            if(!productAreaList.isEmpty())
            {      
                productAreaDisabled = false; 
                if(productAreaSelected == null)
                {
                    productAreaSelected = productAreaList[0].id;
                }
                
                for(TMG_Product_Level_2__c eachProductArea : productAreaList)
                {
                    //Add to product options list.
                    productAreaOptions.add(new SelectOption(eachProductArea.Id,eachProductArea.Name));
                }
            }
            else
            {
                //Add to product options list.
                productAreaOptions.add(new SelectOption('','--None--'));
            }
        }
        else
        {
            
            //Add to product options list.
            productAreaOptions.add(new SelectOption('','--None--'));
        }
        
        System.debug('productAreaList : ' + productAreaList);
    } 
    
    public PageReference actionClearProductArea()
    {
        //Clear Product Area
        ProductAreaSelected = null;
        selectedProduct = null;
        
        //Clear product options.
        productAreaOptions.clear();
        productOptions.clear();
        
        //Populate new products list.
        populateProductArea();
        populateProducts();
        
        return null;
    }
    
    public List<SelectOption> getProductArea()
    {
        return productAreaOptions;
    }
    
    /**
* actionSaves 
**/
    public pageReference actionSave() 
    {
        //Set product
        objectRecord.TMG_Product_Level_1__c = coverageAreaSelected;
        objectRecord.TMG_Product_Level_2__c = productAreaSelected;
        objectRecord.TMG_Product_Level_3__c = selectedProduct;
        
        
        //Insert new object.
        if(objectRecord.Id == null)
        {
            insert objectRecord;
        }
        else
        {   try{
            update objectRecord;
        }catch(Exception e)
        {
            //Error Message
            ApexPages.addMessages(e);
            
            return null;
        }
        }
        
        //Send the user to the detail page for the new Deal.
        PageReference dealPage = new ApexPages.StandardController(objectRecord).view();
        dealPage.setRedirect(true);
        
        //Default return.
        return dealPage;
    }
}