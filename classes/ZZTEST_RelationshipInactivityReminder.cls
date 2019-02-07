/**
* @Author       Liam Logan
* @Company:     Deloitte
* @Description: Test Class for RelationshipInactivityReminder
* @Date:        12.12.2015
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 10-Jun-2016	Mohsin Wadee	Commented out last line as we have currently de-activated email template 'No Call report Logged'.
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
private class  ZZTEST_RelationshipInactivityReminder {

   @isTest
   public static void testRelationshipInactivityReminder(){

   ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
     ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc = accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
           
  
   Account[] al = new List<Account>();
   for (Integer i=0;i<10;i++) {
   Account a = new Account(
   name = 'Account '+i,
   Call_Report_Last_Logged_Date__c = system.today().addDays(-90));
   
   al.add(a);
   
   
   }
   insert al; 
   //RelationshipInactivityReminder sb = new RelationshipInactivityReminder();
  
   
   
    
   }
   }