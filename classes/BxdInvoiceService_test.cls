@isTest
public class BxdInvoiceService_test {
    
    private static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();    
    
    public static testMethod void testCreateFolder(){
        Legal_Quote__c quote = setUpFixture();
        
        Test.startTest();
        quote.Request_for_Service__c = true;
        update quote;
        
        Test.stopTest();
    }
    
    public static Legal_Quote__c setUpFixture(){
        BXDtesclassdata.setupFolder();
        
        Business_Unit__c BusinessUnit = New Business_Unit__c(Cluster_Function__c = 'Cluster_Function',Segment__c='Segment');
        Insert BusinessUnit;
        
        advpm__Matter__c Matter = new advpm__Matter__c(Name='Matter Test',Business_Unit_Cluster_Segment__c=BusinessUnit.id,	
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Type__c='Syndicated',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Deal').getRecordTypeId(),
                Division__c = 'CIB',
                Coverage_Area__c = 'Corporate Banking',
                Product_Area__c = 'Structured Trade Finance');
        Insert Matter;

        Contact c = CSC_TestDataFactory.getDefaultEmailSupportContact();
        Insert c;
        
        RecordType rt;
        rt = [SELECT id,Name,SobjectType FROM RecordType where name ='Legal Request' and SobjectType='Legal_Quote_Request__c' limit 1];
        Legal_Quote_Request__c 	quoteRequest = new Legal_Quote_Request__c(RecordTypeId =rt.id,Matter__c=Matter.id,	Matter_Difficulty__c='Low',Quote_Title__c='Title',Quote_Description__c='Description');
        Insert quoteRequest;
        
        
        Account acc= new Account(Name='Account',RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId(),Approved__c=True);
        
        rt = [Select id,Name from RecordType Where Name = 'On/Off Panel Law Firm' limit 1]; 
        Acc.RecordTypeId =rt.id;
        Insert Acc;
        
        Contact Con = new Contact(AccountId=Acc.id, FirstName='John',LastName='Doe');
        Insert Con;
        
        
        Legal_Quote__c LegalQuote = new Legal_Quote__c(Legal_Quote_Request__c=quoteRequest.id,Panel_Type__c='On Panel',Law_Firm__c=Acc.id,Contact__c = Con.id,Box_Webhook__c='53',Quote_Recieved__c = false, Status__c = 'Approved');
        Insert LegalQuote;

        return LegalQuote;
    }
}