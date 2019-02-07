@istest
public class evEventEmailConfig_Controller_test 
{
    static testMethod void evEventEmailConfig_Controller_test() 
    {  
        Test.startTest();
        
        Event__c event  = new Event__c(); 
        event.Name = 'Test Event';
        event.Capacity__c = 2;
        event.Start_Date__c = Date.today();
        event.End_Date__c = Date.today()+3;
        event.Online_Processing__c = 'Do Not Create Opportunity';
        event.Registration_Process__c = 'Simple';
         event.I_have_read_Absa_Event_Governance__c = true;
        insert event;       
        
        EM_Event_Email_Configuration__c rbatch =  new EM_Event_Email_Configuration__c();
        rbatch.Event__c = event.Id;
        rbatch.SMS_Text__C = 'Test SMS';
        insert rbatch; 
        
        
        ApexPages.StandardController sc = new ApexPages.standardController(rbatch); 
        evEventEmailConfig_Controller myPageCon = new evEventEmailConfig_Controller(sc);
        //myPageCon.record.EMail_Template__c = template.Id;
        List<SelectOption> templates   = myPageCon.templates;
        List<SelectOption> addresses=  myPageCon.orgWideAddresses;
        myPageCon.doSave();
        
        rbatch.eMail_Template__c = 'Test SMS';
        rbatch.SMS_Text__C = 'Test SMS';
        update rbatch;
        sc = new ApexPages.standardController(rbatch); 
        myPageCon = new evEventEmailConfig_Controller(sc);
        myPageCon.doSave();
        
        rbatch.eMail_Template__c = null;
        rbatch.SMS_Text__C = null;
        update rbatch;
        sc = new ApexPages.standardController(rbatch); 
        myPageCon = new evEventEmailConfig_Controller(sc);
        
        myPageCon.doSave();
        
        rbatch.SMS_Text__C = 'test';
        rbatch.Send_From__c = 'LoggedInUser';
        update rbatch;
        
        sc = new ApexPages.standardController(rbatch); 
        myPageCon = new evEventEmailConfig_Controller(sc);
        myPageCon.doSave();
        
        rbatch.Send_From__c = 'dasdad';
        try
        {
        myPageCon.doSave();
        }
        Catch(exception e)
        {
            
        }
        
    }
}