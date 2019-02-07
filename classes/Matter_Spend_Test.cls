/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

 10/08/2017 - PG    - Created class.
 17/08/2017 - PG    - Updated for new Approval process via Line Manager, then only add to Spend Schedule.
 11/10/2017 - PG    - Moved startTest, after Data Factory call to reset governor limits.

**/  
@isTest
public class Matter_Spend_Test {

    public static testMethod void spendOverridePageandTriggers()   
    { 
        //Test data
        Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

        Test.startTest();

        //Blank variables.
        List<Matter_Spend_Document__c> spendDocuments = new List<Matter_Spend_Document__c>();
        List<Matter_Spend_Schedule__c> spendSchedules = new List<Matter_Spend_Schedule__c>();        

        //Submit for approval.
        testData.TestSpendDocument.Approver__c = UserInfo.getUserId(); 
        testData.TestSpendDocument.Status__c = 'Pending Approval';
        update testData.TestSpendDocument;

        //Set Approver and mark as Approved.
        testData.TestSpendDocument.Status__c = 'Approved';
        update testData.TestSpendDocument;

        //Set the spend schedule on the document.
        testData.TestSpendDocument.Matter_Spend_Schedule__c = testData.TestSpendSchedule.Id; 
        update testData.TestSpendDocument;
    
        //Get record after update.
        spendDocuments = [
            SELECT
                Id,
                Matter_Spend_Schedule__c,
                Status__c
            FROM Matter_Spend_Document__c
            WHERE
                Id = :testData.TestSpendDocument.Id
        ];

        //Make sure we got spend document 
        System.assert(spendDocuments.size() == 1, 'Unable to retrieve spend document');
        System.assert(spendDocuments[0].Matter_Spend_Schedule__c != null, 'Spend document not allocated to a spend schedule.');

        //Get scehdule record.
        spendSchedules = [
            SELECT
                Id,
                Status__c,
                Law_Firm__c
            FROM Matter_Spend_Schedule__c
            WHERE
                Id = :spendDocuments[0].Matter_Spend_Schedule__c 
        ];

        //Make sure we got spend schedule
        System.assert(spendSchedules.size() == 1, 'Unable to retrieve spend schedule');

        //Set working VF page.
        PageReference pageRef = Page.Matter_Spend_Schedule_Override_View;
        pageRef.getParameters().put('rowId', testData.TestSpendDocument.Id);
        Test.setCurrentPage(pageRef);

        //Load Spend Schedule Class.
        ApexPages.StandardController stdController = new ApexPages.standardController(spendSchedules[0]);
        Matter_Spend_Schedule_Override_View extController = new Matter_Spend_Schedule_Override_View(stdController);

        //Initilise documents.
        extController.initialiseDocuments();

        //Make sure we have documetn for loaded schedule.
        System.assert(extController.scheduleDocuments.size() == 1, 'There are no spend documents associated with this schedule.');

        //Approve row
        extController.actionApproveRow();

        //Make sure the docuemtn was updated.
        System.assert(extController.scheduleDocuments[0].Status__c == 'Approved For Payment', 'Document not updated to "Approved For Payment"');

        //Change GL Account Code.
        extController.scheduleDocuments[0].GL_Account__c = 'NEWGLCODE';

        //Update row.
        extController.actionUpdateRow();

        //Get record after update.
        spendDocuments = [
            SELECT
                Id,
                Matter_Spend_Schedule__c,
                Status__c,
                GL_Account__c
            FROM Matter_Spend_Document__c
            WHERE
                Id = :testData.TestSpendDocument.Id
        ];

        //Make sure the document was updated.
        System.assert(spendDocuments[0].GL_Account__c == 'NEWGLCODE', 'GL Code Not Updated.');

        //lock Schedule
        extController.actionLockSchedule();

        //Paid schedule
        extController.actionSubmitPayment();

        //Update row.
        extController.actionPaidRow();

        //Query row.
        extController.actionQueryRow();
        
        /*
        Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();   
        testData.TestMatter.RecordTypeId=mapMatterRecordTypes.get('Legal').getRecordTypeId();
        Update  testData.TestMatter;
        */
        
        Test.stopTest();   
    }
}