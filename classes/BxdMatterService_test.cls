@isTest
public class BxdMatterService_test {
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    
    public static testmethod void testMatterCreationExisting(){
        String IMPORT_FOLDER = 'DataMigrations';
        String MATTER_IMPORT_FOLDER = 'Matters';
        String importCustomKey = IMPORT_FOLDER;
        String mattersCustomKey = importCustomKey + MATTER_IMPORT_FOLDER;
        Custom_FRUP__c migration = new Custom_FRUP__c 
            (
                CustomKey__c = importCustomKey,
                FolderId__c = '1',
                ParentFolderId__c = '0'
            );
        Insert migration;
        
        Custom_FRUP__c matterFolder = new Custom_FRUP__c 
            (
                CustomKey__c = mattersCustomKey,
                FolderId__c = '2',
                ParentFolderId__c = '1'
            );
        Insert matterFolder;
        
        test.startTest();
        advpm__Matter__c TestMatter = new advpm__Matter__c(
            Name='Matter Test Box',
            RecordTypeId = mapMatterRecordTypes.get('Legal').getRecordTypeId(),
            Imported_Data__c = true);
        Insert TestMatter;
        Test.stopTest();        
    }
    
    public static testmethod void testMatterCreationNonExisting(){       
        test.startTest();
        advpm__Matter__c TestMatter = new advpm__Matter__c(
            Name='Matter Test Non Box',
            RecordTypeId = mapMatterRecordTypes.get('Legal').getRecordTypeId(),
            Imported_Data__c = true);
        Insert TestMatter;
        Test.stopTest();        
    }
    
    public static testmethod void testMatterCreationLegalHold(){
        advpm__Matter__c TestMatter = new advpm__Matter__c(
            Name='Matter Test Legal',
            RecordTypeId = mapMatterRecordTypes.get('Read-Only Legal Hold (Legal RT)').getRecordTypeId());
        Insert TestMatter;
        
        advpm__Matter_Legal_Hold_Acknowledgement__c Ackow = new advpm__Matter_Legal_Hold_Acknowledgement__c(
            advpm__Matter__c = TestMatter.Id, Box_Assignment_Id__c = '1234');
        Insert Ackow;
        
        test.startTest();
        TestMatter.advpm__Legal_Hold__c = false;
        TestMatter.Box_Legal_Hold_Assignment_Id__c = '1234';
        Update TestMatter;
        Test.stopTest();        
    }
}