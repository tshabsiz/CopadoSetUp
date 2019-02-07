/**
* @Author       Liam Logan
* @Company:     Deloitte
* @Description: Sends reminder emails to account owners who have not logged a call in 90 Days
* @Date:        12.12.2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_RelationshipInactivityReminder
* History
* <Date>      <Authors Name>     <Brief Description of Change>

*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

global class RelationshipInactivityReminder {

global RelationshipInactivityReminder() {

//Returns todays date minus 90 days and puts it into the 'Date' format
dateTime dt = system.today().addDays(-90);
date myDate = dt.date();


//retrieves the visualforce email template to be sent 
EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE name = 'No Call report Logged'];

//Generates a list of Relationship Owners which have not logged a call in the past 90 Days 
List<Account> relationshipOwners = [SELECT Id, Owner.Email, Name, Owner.FirstName FROM Account WHERE Formatted_Call_Report_Last_Logged_Date__c = :myDate];



//Cycle through results and send a mail to each relationship owner
 List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
 
for (Account ro : relationshipOwners) {
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   
     mail.setSaveAsActivity(false);
     mail.setTemplateId(et.Id);  
     mail.setTargetObjectId(ro.OwnerId);
     mail.setWhatId(ro.Id);
     
      mailList.add(mail);
          
    }
  

Messaging.sendEmail(mailList);

}
    
}