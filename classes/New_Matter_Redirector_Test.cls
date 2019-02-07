/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***

18/07/2017 - DF     - Created Class.
08/08/2017 - PG     - Replace Flow with Standard 

**/
@isTest
public class  New_Matter_Redirector_Test 
{
                
        Public static void Setup(){
                
                Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
               
                advpm__Matter__c Matter_leg = new advpm__Matter__c(Name='Matter Test', 
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Type__c='Syndicated',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Legal').getRecordTypeId(),
                Division__c = 'Legal',
                Coverage_Area__c = 'Legal Support',
                Product_Area__c = 'Legal Standard Product'
             
             );
                Insert Matter_leg;
        
            advpm__Matter__c Matter_lit = new advpm__Matter__c(Name='Matter Test',  
                Standard__c = true,
                advpm__Status__c = 'Open',
                advpm__Type__c='Syndicated',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Litigation Matter').getRecordTypeId(),
                Division__c = 'Legal',
                Coverage_Area__c = 'Legal Support',
                Product_Area__c = 'Legal Standard Product'
              );
                Insert Matter_lit;
        
        advpm__Matter__c Matter_N = new advpm__Matter__c(Name='Matter Test',  
        
                advpm__Status__c = 'Open',
                advpm__Type__c='Syndicated',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Standard').getRecordTypeId()
             );
                Insert Matter_N;
        /*
        Account Relationship = new Account(Client_Country__c='Botswana',Type='Prospect',Segment__c='AIFA',Name='Rel' );
        Insert Relationship;
               
        advpm__Matter__c Matter_D = new advpm__Matter__c(Name='Matter Test',  
                 Name = 'Test',
                Standard__c = 'Yes',
                advpm__Status__c = 'Open',
                advpm__Type__c='Syndicated',
                Start_Date__c = date.today(),
                RecordTypeId = mapMatterRecordTypes.get('Deal').getRecordTypeId(),
                Division__c = 'CIB',
                Coverage_Area__c = 'Corporate Banking',
                Product_Area__c = 'Corporate Finance',
                Product2__c = TestProductLevel2.Id,
               
             );
        Insert Matter_D;
        */
     //    Coverage_Area__c = 'Corporate Banking',
     //          Product_Area__c = 'Corporate Finance'
        
        }

    public static testMethod void New_Matter_Redirector_Test1()
    {   
        //Test Data
        Test.StartTest();

        Limits.getQueries();
        
        Setup();
        advpm__Matter__c Matter_lit = [Select id from advpm__Matter__c Where RecordType.Name='Litigation Matter' limit 1];
       
         PageReference pageRef = Page.MatterToCaseConvert;
         pageRef .getParameters().put('id',Matter_lit.id);

         Test.setCurrentPageReference(pageRef);
         ApexPages.StandardController sc = new ApexPages.standardController(Matter_lit);
        New_Matter_Redirector testController = new New_Matter_Redirector(sc);  
        
        //Main method
        testController.redirect();  
        Test.StopTest();  
    }
    
    public static testMethod void New_Matter_Redirector_Test2()
    { 
        Cloudsmiths_TestDataClass TDClass = new Cloudsmiths_TestDataClass();

         Test.StartTest();
        
        Limits.getQueries();
         
        ApexPages.StandardController sc = new ApexPages.standardController(TDClass.TestMatter);
        New_Matter_Redirector testController = new New_Matter_Redirector(sc);  
        testController.redirect();    
        Test.StopTest(); 
    }
    
    public static testMethod void New_Matter_Redirector_Test3()
    { 
        Test.StartTest();

        Limits.getQueries();

            Setup();
         advpm__Matter__c Matter_lit = [Select id from advpm__Matter__c Where RecordType.Name ='Standard' limit 1];
       
         PageReference pageRef = Page.MatterToCaseConvert;
         pageRef .getParameters().put('id',Matter_lit.id);

         Test.setCurrentPageReference(pageRef);
         ApexPages.StandardController sc = new ApexPages.standardController(Matter_lit);
         New_Matter_Redirector testController = new New_Matter_Redirector(sc);  
        
        //Main method
        testController.redirect();    
        Test.StopTest(); 
    }
}