/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 28/07/2017 - PG    - Created class.
 01/08/2017 - PG    - Added Approve and Reject methods.
 04/08/2017 - PG    - Removed previous page action methods.
                    - Added 3 action methods for actionFunction change to associated VF page.
 10/08/2017 - PG    - Added "actionSubmitPayment" method.
 11/08/2017 - KK    - Added Box method.

**/ 
public class Matter_Spend_Schedule_Override_View 
{   
    /**
    * Variables
    **/
    public Matter_Spend_Schedule__c objectRecord { get; set; }
    public List<Matter_Spend_Document__c> scheduleDocuments { get; set; }
    
    //Buttons
    public Boolean showExport { get; set; }
    public Boolean showMessage { get; set; }
    public Boolean showExportPaid { get; set; }
    //Box
    public Boolean showBox {get;set;}
    public String boxEmbedURL {get;set;}

    /**
    * Constructor
    **/
    public Matter_Spend_Schedule_Override_View(ApexPages.StandardController stdController)  
    {
        System.debug('### Matter_Spend_Schedule_Override_View');
        //Blank vars.
        scheduleDocuments = new List<Matter_Spend_Document__c>();

        //Extra fields
        List<String> fields = new List<String> {
            'Name',
            'Status__c',
            'CreatedDate' 
        };

        //Add fields if not a test running.
        if(!Test.isRunningTest())
        {
            stdController.addFields(fields);
        }

        //Record
        this.objectRecord = (Matter_Spend_Schedule__c)stdController.getRecord(); 
        
        //Box
        getBoxEmbedLink();
    }

    /**
    * initialiseDocuments - Loads the documents for schedule on page load.
    **/
    public PageReference initialiseDocuments()
    {
        scheduleDocuments = [
            SELECT
                Id, 
                Name,
                Law_Firm__c,
                Total_Amount_Excl_VAT__c,
                Total_Amount_Non_VATable__c,
                Total_VAT__c,
                Grand_Total__c,
                Type__c,
                Status__c,
                Matter__c,
                Box_Folder_Link__c,
                GL_Account__c,
                BU_Corporate_Code__c,
                Cost_Centre2__c,
                Latest_Comment__c,
                Matter_Spend_Schedule__c,
                Vendor_Number__c,
                InvoiceNumber__c,
                InvoiceDate__c
            FROM Matter_Spend_Document__c
            WHERE
                Matter_Spend_Schedule__c = :objectRecord.Id
            ORDER BY
                Name
        ];
        
        //Update button logic.
        updateButtonStatuses();

        //Default return.
        return null;
    }

    /**
    * updateButtonStatuses
    **/
    public void updateButtonStatuses()
    {
        showExport = true;
        showExportPaid = true;
        showMessage = false;
        
        //Loop through line items
        for(Matter_Spend_Document__c scheduleDocument : scheduleDocuments)
        {
           if(scheduleDocument.Status__c != 'Approved For Payment' || (scheduleDocument.Status__c == 'Approved For Payment' && (scheduleDocument.GL_Account__c == null || scheduleDocument.BU_Corporate_Code__c == null) ) )
           {
               showExport = false;
           }
           
           if(scheduleDocument.GL_Account__c == null || scheduleDocument.BU_Corporate_Code__c == null)
           {
               showMessage = true; 
           }
           
           if(scheduleDocument.Status__c != 'Paid') 
           {
               showExportPaid = false;
           }
        }
    }

    /**
    * actionApproveRow
    **/
    public PageReference actionApproveRow()  
    {   
        //Param from actionFunction
        Id rowId = Apexpages.currentPage().getParameters().get('rowId');

        //Convert list to map.
        Map<Id, Matter_Spend_Document__c> documentMap = new Map<Id, Matter_Spend_Document__c>(scheduleDocuments);

        //Get document
        Matter_Spend_Document__c scheduleDocument = documentMap.get(rowId);

        //Update document with new values.
        scheduleDocument.Status__c = 'Approved For Payment';
        update scheduleDocument;

        //Default return.
        return null;
    }

    /**
    * actionQueryRow
    **/
    public PageReference actionQueryRow()  
    {   
        //Param from actionFunction
        Id rowId = Apexpages.currentPage().getParameters().get('rowId');

        //Convert list to map.
        Map<Id, Matter_Spend_Document__c> documentMap = new Map<Id, Matter_Spend_Document__c>(scheduleDocuments);

        //Get document
        Matter_Spend_Document__c scheduleDocument = documentMap.get(rowId);

        //Update document with new values.
        scheduleDocument.Status__c = 'Queried';
        scheduleDocument.Matter_Spend_Schedule__c = null;
        update scheduleDocument;

        //Refesh documents list.
        initialiseDocuments();

        //Default return.
        return null;
    }

    /**
    * actionUpdateRow
    **/
    public PageReference actionUpdateRow()  
    {   
        //Param from actionFunction
        Id rowId = Apexpages.currentPage().getParameters().get('rowId');

        //Convert list to map.
        Map<Id, Matter_Spend_Document__c> documentMap = new Map<Id, Matter_Spend_Document__c>(scheduleDocuments);

        //Get document
        Matter_Spend_Document__c scheduleDocument = documentMap.get(rowId);

        //Update document with new values.
        update scheduleDocument;

        //Refesh documents list.
        initialiseDocuments();

        //Default return.
        return null;
    }

    /**
    * actionUpdateRow
    **/
    public PageReference actionPaidRow()  
    {   
        //Param from actionFunction
        Id rowId = Apexpages.currentPage().getParameters().get('rowId');

        //Convert list to map.
        Map<Id, Matter_Spend_Document__c> documentMap = new Map<Id, Matter_Spend_Document__c>(scheduleDocuments);

        //Get document
        Matter_Spend_Document__c scheduleDocument = documentMap.get(rowId);

        //Update document with new values.
        scheduleDocument.Status__c = 'Paid';
        update scheduleDocument;

        //Refesh documents list.
        initialiseDocuments();

        //Default return.
        return null;
    }

    /**
    * actionLockSchedule
    **/
    public PageReference actionLockSchedule()  
    { 
        //Update schedule with new values.
        objectRecord.Status__c = 'Exported';

        //Update record
        update objectRecord;

        //Refesh documents list.
        initialiseDocuments();

        //Default return.
        return null;
    }
    
    /**
    * actionSubmitPayment
    **/
    public PageReference actionSubmitPayment()  
    { 
        //Update schedule with new values.
        objectRecord.Status__c = 'Pending Payment';

        //Update schedule record
        update objectRecord;
        
        for(Matter_Spend_Document__c scheduleDocument : scheduleDocuments)
        {
            scheduleDocument.Status__c = 'Pending Payment';
        }
        
        //Update documents.
        update scheduleDocuments;

        //Refesh documents list.
        initialiseDocuments();

        //Default return.
        return null;
    }
    
    public void getBoxEmbedLink() {
        boxEmbedURL = BxdMatterSpendScheduleService.getBoxFolderLink(objectRecord);
        if(!String.isBlank(boxEmbedURL)){
            showBox = true;
        }
    }
    
    public PageReference createBoxPermission(){
        BxdMatterSpendScheduleService.createViewerPermission(objectRecord);
        return null;
    }
}