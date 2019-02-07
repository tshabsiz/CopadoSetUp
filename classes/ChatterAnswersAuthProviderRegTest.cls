/**
* 
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 
* 10-Dec-2015 Mohsin Wadee 		US-1063 - Modified validateCreateUpdateUser() method to include a phone number when creating the
*											contact.
* 
* 09-May-2016 Mohsin Wadee		US-1089 - In validateCreateUpdateUser() method use Standard Platform User profile instead,
*											also added BRID. Also create the test Account, Contact and User in one transaction.
* ------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class ChatterAnswersAuthProviderRegTest {
  static testMethod void validateCreateUpdateUser() {
     
      Test.startTest();
      
      Account a = new Account(Name='Test Account Name');
      
      Contact con = new Contact(FirstName = 'Contact First Name', LastName = 'Contact Last Name', AccountId = a.id, Phone = '1127 000 0000');
	    
      User user = new User();
      user.ProfileID = [Select Id From Profile Where Name='Standard Platform User'].Id;
      User.UserRoleId = [Select Id From UserRole Where Name = 'Other'].Id;
      user.EmailEncodingKey = 'ISO-8859-1';
      user.LanguageLocaleKey = 'en_US';
      user.TimeZoneSidKey = 'America/New_York';
      user.LocaleSidKey = 'en_US';
      user.FirstName = 'first';
      user.LastName = 'last';
      user.Username = 'test@appirio.com.oiteoiteoweproiweporie';   
      user.CommunityNickname = 'testUser123';
      user.Alias = 't1';
      user.Email = 'no@email.com';
      user.IsActive = true;
      User.BRID__c = 'FakeBrid1';
      user.ContactId = con.Id;
     
      insert user;
      
      Test.stopTest();
     

    /*System.runAs ( user ) {
      Auth.UserData userData = new Auth.UserData('testId', 'testFirst', 'testLast',
      'testFirst testLast', 'no-reply@salesforce.com', null, 'testuserlong', 'en_US', 'facebook',
      null, new Map<String, String>{'language' => 'en_US'});
      ChatterAnswersAuthProviderRegistration reg = new ChatterAnswersAuthProviderRegistration();
      Profile[] p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
      User[] adminUser = [SELECT Id, Firstname, Lastname FROM User WHERE IsActive = true and ProfileId =: p[0].Id LIMIT 1];
      reg.setSiteAdminUserId(adminUser[0].Id);
      User newUser = reg.createUser(null, userData);
      System.assert(newUser != null, 'A new user should have been created');
      System.assertEquals(newUser.Firstname, 'testFirst', 'First name should have been same');
      System.assertEquals(newUser.Lastname, 'testLast', 'Last name should have been same');
      System.assertEquals(newUser.Email, 'no-reply@salesforce.com', 'Email should have been same');
      
      Contact c = new Contact();
      c.AccountId = (newUser.Username.split('@'))[0];
      c.LastName = 'contactLast';
      insert(c);
      
      newUser.Alias = 'firstusr';
      newUser.TimeZoneSidKey = 'America/Los_Angeles';
      newUser.LocaleSidKey = 'en_US';
      newUser.EmailEncodingKey = 'UTF-8';
      newUser.LanguageLocaleKey = 'en_US';
      newUser.ContactId = c.Id;
      newUser.ProfileID = '00e24000000odzr'; //00e24000000odzr
      newUser.UserRoleID = '00E24000000l66REAQ'; //00E24000000l65Y
      //newUser.UserPermissionsChatterAnswersUser = True;

      
      insert(newUser);
      
      
      Auth.UserData updateUserData = new Auth.UserData('testId', 'updatedFirst', 'updatedLast',
      'updatedFirst updatedLast', 'no-reply@new.salesforce.com', null, 'testuserlong', 'en_US', 'facebook',
      null, new Map<String, String>{'language' => 'en_US'});
      reg.updateUser(newUser.Id, null, updateUserData);
      
      User dbUser =  [SELECT Id, Firstname, Lastname, Email FROM User WHERE Id = :newUser.Id];
      System.assertEquals(dbUser.Firstname, 'updatedFirst', 'First name should have been updated');
      System.assertEquals(dbUser.Lastname, 'updatedLast', 'Last name should have been updated');
      System.assertEquals(dbUser.Email, 'no-reply@new.salesforce.com', 'Email should have been updated');
    }*/
  }
}