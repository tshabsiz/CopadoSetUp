@isTest
public class BxdFolderStructureHelper_test {
    private static FolderHandler folderHandler = new FolderHandler();
    private static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    public static testmethod void testFolderStructure(){   
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        BxdFolderStructureHelper helper = new BxdFolderStructureHelper();
        Box_Folder_Structure__c agreementStruct = helper.getFolderStructure(Agreement__c.SObjectType, testDataClass.TestAgreement.Id);
    }
    
    public static testmethod void testFolderStructureStatic(){
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        BxdFolderStructureHelper helper = new BxdFolderStructureHelper();        
        Box_Folder_Structure__c agreementStruct = helper.getFolderStructure(Agreement__c.SObjectType, testDataClass.TestAgreement.Id, true, true);
    }
    
    public static testmethod void testFolderStructureNonStatic(){
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        BxdFolderStructureHelper helper = new BxdFolderStructureHelper();
        Box_Folder_Structure__c agreementStruct = helper.getFolderStructure(Agreement__c.SObjectType, testDataClass.TestAgreement.Id, false, true);
    }
    
    public static testmethod void testFolderStructureList(){
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        BxdFolderStructureHelper helper = new BxdFolderStructureHelper();
        List<Box_Folder_Structure__c> agreementStructures = helper.getFolderStructures(Agreement__c.SObjectType, testDataClass.TestAgreement.Id, false);
    }
    
    public static testmethod void testFolderStructureStaticList(){
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        BxdFolderStructureHelper helper = new BxdFolderStructureHelper();
        List<Box_Folder_Structure__c> agreementStructures = helper.getFolderStructures(Agreement__c.SObjectType, testDataClass.TestAgreement.Id, true);
    }
    
    public static testmethod void testFolderStructureRecordTypeName(){
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        BxdFolderStructureHelper helper = new BxdFolderStructureHelper();
        String recordTypeName = helper.getRecordTypeName(testDataClass.TestAccount.Id);
    }
        
    public static testmethod void testFolderStructureRecordValue(){
        BxdFolderStructureHelper helper = new BxdFolderStructureHelper();
        Account TestAccount = new Account
            (
                Name ='test',
                Type = 'Client'
            );
        Insert TestAccount;
        
        Id accountId = TestAccount.Id;
        
        SObject record = Database.query('Select Id, Name FROM Account Where Id = :accountId');
        
        String name  = helper.getRecordValue(record, 'Name');
        System.assert(!String.isBlank(name));
    }
    
    public static testmethod void testCreateFolderForRecord(){        
        Date todaysDate = System.Today();
        DateTime todaysDate_nextMonth = System.now().addMonths(1);

        //Create account
        Account TestAccount = new Account
            (
                Name = 'Random With Timestamp',
                Type = 'Client',
                Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'), 
                SDS__c = 'test',
                RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId() //Added
            );
        
        insert TestAccount;
        
        test.startTest();
        String externalFolderId = folderHandler.createBoxFolderForRecord(TestAccount.Id);
        test.stopTest();
        System.debug('FOLDER1 '+externalFolderId);
    }
    
    public static testmethod void testCreateFolder(){                
        test.startTest();
        String externalFolderId = folderHandler.createBoxFolder('Folder on Box', '0');
        test.stopTest();
        System.debug('FOLDER2 '+externalFolderId);
    }
    
    public static testmethod void testCreateFolderWithTimestampIfExist(){        
        Date todaysDate = System.Today();
        DateTime todaysDate_nextMonth = System.now().addMonths(1);

        //Create account
        Account TestAccount = new Account
            (
                Name = 'Random With Timestamp',
                Type = 'Client',
                Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'), 
                SDS__c = 'test',
                RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId() //Added
            );
        
        insert TestAccount;
        
        test.startTest();
        String externalFolderId = folderHandler.createBoxFolder(TestAccount.Id, 'Folder Timestamp', '0');
        externalFolderId = folderHandler.createBoxFolder(TestAccount.Id, 'Folder Timestamp', '0');
        test.stopTest();
        System.debug('FOLDER3 '+externalFolderId);
    }
    
    public static testmethod void testCreateFolderwithSDK(){      
        String name = 'Deal Folder';
        String folderId = '0';
        
        folderHandler.createBoxFolderOrGetExistingFolder(name, folderId);
    }
    
    public static testmethod void testCreateExternalCollaboration(){        
        box.Toolkit.CollaborationType collaborationType = box.Toolkit.CollaborationType.VIEWERUPLOADER;
        
        List<BxdExternalCollaborationHelper.Collaborator> collaborations = new List<BxdExternalCollaborationHelper.Collaborator>();
        collaborations.add(new BxdExternalCollaborationHelper.Collaborator('kapeshikongolo@gmail.com', null));
        collaborations.add(new BxdExternalCollaborationHelper.Collaborator('kapeshiviewonly@gmail.com', null));
        
        BxdExternalCollaborationHelper externalHelper = new BxdExternalCollaborationHelper('kk@bsg.co.za', 'Folder Name Ex', '12345', '098765', collaborations, collaborationType);                        
        folderHandler.createExternalBoxFolder(externalHelper);
    }
    
    public static testmethod void testUpdateCollaboration(){    
        folderHandler.updateCollaboration('791291', folderHandler.parseRole('VIEWER'));
        folderHandler.updateCollaboration('791292', folderHandler.parseRole('VIEWER_UPLOADER'));
        folderHandler.updateCollaboration('791293', folderHandler.parseRole('PREVIEWER_UPLOADER'));
        folderHandler.updateCollaboration('791294', folderHandler.parseRole('PREVIEWER'));
        
        //
        folderHandler.parseToolkitRole('VIEWER_UPLOADER');
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() { 
            //the specific constructor in parent will be initialized with null to allow finding current user email
            super(true, 'kapeshi.kongolo@bsg.co.za');
        }
    }
}