/**
* @Author:        Dino Scarcella
* @Company:       Absa Capital
*
* @group Unit Tests
*
* @description Unit Tests for the class which exposes custom REST API for User Operations
*                   Tests executed:
*                   1 - testUserDisable()
*                       Performs a test REST API call to disable a user
*					2 - testUpsertUser()
*						Performs a number of user upserts to test validations and successful insert
*						and update of Salesforce user.
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class ZZTEST_UserRequest {
	static testMethod void testUserDisable() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		
		req.requestURI = '/services/apexrest/Users/v1/FAKEBRID';
		req.httpMethod = 'DELETE';
		RestContext.request = req;
		RestContext.response = res;
		
		Test.startTest();
		System.AssertEquals(UserRequest.disableUser(), 'Invalid User');
		
		ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();
		
		System.AssertEquals(UserRequest.disableUser(), 'User successfully disabled');
		Test.stopTest();
	}
	
	static testMethod void testUpsertUser() {
		ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getExistingUserByProfile('System Administrator');
        User standard_user = userFactory.getBarclaysStandardUser();
        
        System.runAs(u) {
			RestRequest req = new RestRequest();
			RestResponse res = new RestResponse();
			
			req.requestURI = '/services/apexrest/Users/v1';
			req.httpMethod = 'POST';
			RestContext.request = req;
			RestContext.response = res;
			
			Test.startTest();
			
			System.AssertEquals('Invalid Country', UserRequest.upsertUser('Imaginary','User','','','South Africa','','','','','','','','',''));
			
			Request_Country__c rcntry = new Request_Country__c();
			rcntry.Name = 'South Africa';
			rcntry.SFCountry__c = 'South Africa';
			rcntry.TimeZoneSidKey__c = 'Africa/Johannesburg';
			rcntry.LocaleSidKey__c = 'en_ZA';
			insert rcntry;
			
			System.AssertEquals('Invalid FirstName', UserRequest.upsertUser('','User','','','South Africa','','','','','','','','',''));
			System.AssertEquals('Invalid LastName', UserRequest.upsertUser('Imaginary','','','','South Africa','','','','','','','','',''));
			System.AssertEquals('Invalid Email', UserRequest.upsertUser('Imaginary','User','invalidemail','','South Africa','','','','','','','','',''));
			System.AssertEquals('Invalid License Type', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','','','','','','','','','invalid licence'));
			System.AssertEquals('Invalid Division', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','','','','','','','','','Complete CRM Functionality'));
			System.AssertEquals('Invalid Business Area', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','','Division','','','','','','','Complete CRM Functionality'));
			System.AssertEquals('Invalid Hub', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','Business Area','Division','','','','','','','Complete CRM Functionality'));
			System.AssertEquals('Invalid Region', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','Business Area','Division','Hub','','','','','','Complete CRM Functionality'));
			System.AssertEquals('Invalid Team', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','Business Area','Division','Hub','Region','','','','','Complete CRM Functionality'));
			System.AssertEquals('Invalid Team Role', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','Business Area','Division','Hub','Region','Team','','','','Complete CRM Functionality'));
			System.AssertEquals('Invalid Manager Federation Identifier', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','Business Area','Division','Hub','Region','Team','Team Role','','WRONG_MANAGER_BRID','Complete CRM Functionality'));
			System.AssertEquals('No Profile and Role found for this combination', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','Business Area','Division','Hub','Region','Team','Team Role','','FAKEBRID','Complete CRM Functionality'));
			System.AssertEquals('Invalid Federation Identifier', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','','South Africa','Business Area','Division','Hub','Region','Team','Team Role','','FAKEBRID','Collaboration'));
			
			RequestChoice__c rchoice = new RequestChoice__c();
			rchoice.Business_Area__c = 'Business Enablers';
			rchoice.Country__c = 'South Africa';
			rchoice.Division__c = 'CIB';
			rchoice.Hub__c = 'Business Enablers';
			rchoice.Profile_ID__c = [SELECT id FROM Profile where name = 'Barclays Standard User'].get(0).id;
			rchoice.Region__c = 'Business Enablers Africa';
			rchoice.Team__c = 'Business Enablers';
			rchoice.Team_Role__c = 'Analyst';
			rchoice.UserPermissionsKnowledgeUser__c = false;
			rchoice.UserPermissionsSupportUser__c = false;
			insert rchoice;
			
			System.AssertEquals('User successfully inserted', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','FAKEBRIDS','South Africa','Business Area','Division','Hub','Region','Team','Team Role','0724567892','FAKEBRID','Collaboration'));
			System.AssertEquals('User successfully updated', UserRequest.upsertUser('Imaginary','User','dino.scarcella@barclays.com','FAKEBRIDS','South Africa','Business Enablers','CIB','Business Enablers','Business Enablers Africa','Business Enablers','Analyst','0724567891','FAKEBRID',	'Complete CRM Functionality'));
			Test.stopTest();
        }
	}
}