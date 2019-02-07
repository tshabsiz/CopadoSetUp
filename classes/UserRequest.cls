/**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     Class which exposes custom API for User Operations to be called by external systems
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
@RestResource(urlMapping='/Users/v1/*')
global with sharing class UserRequest {
	public static String UsernameDomain;
	
	@HttpDelete
    global static String disableUser() {
        RestRequest request = RestContext.request;
        String BRID = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        List<User> UserToDisable = [SELECT Id FROM User WHERE BRID__c = :BRID LIMIT 1];
        if (UserToDisable != null && UserToDisable.size()>0) {
        	UserToDisable[0].isActive = false;
        	update UserToDisable[0];
        	return 'User successfully disabled';
        } else {
        	RestContext.response.statusCode = 400; return 'Invalid User';
        }
    }

	@HttpPost
    global static String upsertUser(String FirstName, String LastName, String EmailAddress, String FederationIdentifier, String Country, 
    								String BusinessArea, String Division, String Hub, String Region, String Team, String TeamRole, 
    								String Phone, String ManagerFederationIdentifier, String License) {
        User UserToUpsert = new User();
        Profile ChatterFreeProfile = [SELECT id, Name FROM Profile where name = 'Chatter Free User'].get(0);
        UserToUpsert.isActive = true;
        List<Request_Country__c> rcntry = [SELECT LocaleSidKey__c, SFCountry__c, TimeZoneSidKey__c, CurrencyIsoCode 
        						 FROM Request_Country__c WHERE Name =:Country LIMIT 1];
        if (rcntry != null && rcntry.size() > 0) {
        	UserToUpsert.Country = rcntry[0].SFCountry__c;
        	UserToUpsert.LocaleSidKey = rcntry[0].LocaleSidKey__c;
        	UserToUpsert.TimeZoneSidKey = rcntry[0].TimeZoneSidKey__c;
        	UserToUpsert.CurrencyIsoCode = rcntry[0].CurrencyIsoCode;
        	UserToUpsert.DefaultCurrencyIsoCode = rcntry[0].CurrencyIsoCode;
        } else {
        	RestContext.response.statusCode = 400; return 'Invalid Country';
        }
        
        if (FirstName != null && FirstName != '') {
        	UserToUpsert.FirstName = FirstName;
        } else {
        	RestContext.response.statusCode = 400; return 'Invalid FirstName';
        }
        
        if (LastName != null && LastName != '') {
        	UserToUpsert.LastName = LastName;
        } else {
        	RestContext.response.statusCode = 400; return 'Invalid LastName';
        }
        
        Integer LastNameEndIndex = 4;
        if (LastName.length() < 4) LastNameEndIndex = LastName.length();
        UserToUpsert.Alias = FirstName.substring(0,1).toLowerCase() + LastName.substring(0,LastNameEndIndex).toLowerCase();
        if ((FirstName.toLowerCase() + '.' + LastName.toLowerCase()).length() > 40)
        	UserToUpsert.CommunityNickname = (FirstName.toLowerCase() + '.' + LastName.toLowerCase()).substring(0,40);
        else
        	UserToUpsert.CommunityNickname = FirstName.toLowerCase() + '.' + LastName.toLowerCase();
        
        for(UserRequestSetting__mdt settings : [SELECT DeveloperName, Setting__c FROM UserRequestSetting__mdt WHERE DeveloperName IN('UsernameDomain')]){
        	if (settings.DeveloperName == 'UsernameDomain') UsernameDomain = settings.Setting__c;
        }
        if (UsernameDomain == null || UsernameDomain == '') { RestContext.response.statusCode = 400; return 'Invalid User Domain Setting'; }
        UserToUpsert.Username = UserToUpsert.CommunityNickname + UsernameDomain;
        
        if (EmailAddress != null && EmailAddress != '' && validateEmail(EmailAddress)) {
        	UserToUpsert.Email = EmailAddress;
        } else {
        	RestContext.response.statusCode = 400; return 'Invalid Email';
        }
        
        if (Phone != null && Phone != '') {
        	if (Phone.length() > 40) UserToUpsert.Phone = Phone.substring(0,40);
        	else UserToUpsert.Phone = Phone; 	
        }
        
        UserToUpsert.EmailEncodingKey = 'ISO-8859-1';
     	UserToUpsert.LanguageLocaleKey = 'en_US';
     	
     	if (License == null || (License != 'Collaboration' && License != 'Complete CRM Functionality')) {
			RestContext.response.statusCode = 400; return 'Invalid License Type';
     	}
     	
     	if (Division != null && Division != '') {
        	UserToUpsert.Division__c = Division;
        } else {
        	RestContext.response.statusCode = 400; return 'Invalid Division';
     	}
     	
     	if (License == 'Complete CRM Functionality') {
     		if (BusinessArea != null && BusinessArea != '') {
        		UserToUpsert.Business_Area__c = BusinessArea;
        	} else {
        		RestContext.response.statusCode = 400; return 'Invalid Business Area';
        	}
        	if (Hub != null && Hub != '') {
        		UserToUpsert.Hub__c = Hub;
        	} else {
        		RestContext.response.statusCode = 400; return 'Invalid Hub';
        	}
	        if (Region != null && Region != '') {
	        	UserToUpsert.Region__c = Region;
	        } else {
	        	RestContext.response.statusCode = 400; return 'Invalid Region';
	        }
	        if (Team != null && Team != '') {
	        	UserToUpsert.Team__c = Team;
	        } else {
	        	RestContext.response.statusCode = 400; return 'Invalid Team';
	        }
	        if (TeamRole != null && TeamRole != '') {
	        	UserToUpsert.Team_Role__c = TeamRole;
	        } else {
	        	RestContext.response.statusCode = 400; return 'Invalid Team Role';
	        }
	        if (ManagerFederationIdentifier != null && ManagerFederationIdentifier != '') {
				List<User> Manager = [SELECT Id FROM User WHERE BRID__c =:ManagerFederationIdentifier LIMIT 1];
				if (Manager != null && Manager.size()>0) {
					UserToUpsert.ManagerID = Manager[0].Id;					
				} else {
					RestContext.response.statusCode = 400; return 'Invalid Manager Federation Identifier';
				}       	
	        }
	     	List<RequestChoice__c> rchoice = [SELECT 	Profile_ID__c, UserRoleId__c, 
	     												UserPermissionsKnowledgeUser__c, UserPermissionsSupportUser__c
	        						 FROM RequestChoice__c WHERE Country__c =:Country AND Business_Area__c =:BusinessArea
	        						 							 AND Division__c =:Division AND Hub__c =:Hub AND Region__c =:Region
	        						 							 AND Team__c =:Team AND Team_Role__c =:TeamRole LIMIT 1];
	        if (rchoice != null && rchoice.size()>0) {
	 			UserToUpsert.ProfileId = rchoice[0].Profile_ID__c;
	 			UserToUpsert.UserRoleId = rchoice[0].UserRoleId__c;
	 			UserToUpsert.UserPermissionsKnowledgeUser = rchoice[0].UserPermissionsKnowledgeUser__c;
	 			UserToUpsert.UserPermissionsSupportUser = rchoice[0].UserPermissionsSupportUser__c;
	        } else {
	        	RestContext.response.statusCode = 400; return 'No Profile and Role found for this combination';
	        }	
     	} else {
			UserToUpsert.ProfileId = ChatterFreeProfile.Id;
     	}
        
        if (FederationIdentifier != null && FederationIdentifier != '') {
        	UserToUpsert.FederationIdentifier = FederationIdentifier;
        	Integer FederationIdentifierEndIndex = 9;
        	if (FederationIdentifier.length() < 9) FederationIdentifierEndIndex = FederationIdentifier.length();
        	UserToUpsert.BRID__c = FederationIdentifier.substring(0,FederationIdentifierEndIndex);
        } else {
        	RestContext.response.statusCode = 400; return 'Invalid Federation Identifier';
        }
        
        UserToUpsert.UserPreferencesHideChatterOnboardingSplash = true;
        UserToUpsert.UserPreferencesHideSecondChatterOnboardingSplash = true;
		
		// if we're updating Chatter Free User make sure notifications work
		Database.DMLOptions dlo;
     	if (License == 'Collaboration') {
     		dlo = new Database.DMLOptions();
     		dlo.EmailHeader.triggerUserEmail = true;
     		dlo.EmailHeader.triggerAutoResponseEmail = true;
     		UserToUpsert.setOptions(dlo);					
     	}
		
		try {
     		List<User> UsersToUpsert = [SELECT Id, ProfileId FROM User WHERE BRID__c =:UserToUpsert.BRID__c LIMIT 1];
     		if (UsersToUpsert != null && UsersToUpsert.size() > 0) {
     			UserToUpsert.Id = UsersToUpsert[0].Id;
     			// we're upgrading a user from chatter free to full profile, need to do an update of user role after update of profile
     			if (ChatterFreeProfile.Id == UsersToUpsert[0].ProfileId && License == 'Complete CRM Functionality') {
     				String UserRoleId = UserToUpsert.UserRoleId;
     				dlo = new Database.DMLOptions();
     				dlo.EmailHeader.triggerUserEmail = false;
     				dlo.EmailHeader.triggerAutoResponseEmail = false;
     				UserToUpsert.setOptions(dlo);
     				UserToUpsert.UserRoleId = null;
     				update UserToUpsert;
					UserToUpsert.UserRoleId = UserRoleId;
     			}
     			update UserToUpsert;
	        	return 'User successfully updated';
        	} else {
        		insert UserToUpsert;
        		return 'User successfully inserted';
        	}
     	} catch (Exception exc) {
     		RestContext.response.statusCode = 400; return 'User Upsert Failed: ' + exc.getMessage();
     	}
    }
    
    private static Boolean validateEmail(String Email) {
    	String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
    	Pattern MyPattern = Pattern.compile(emailRegex);
	    Matcher MyMatcher = MyPattern.matcher(Email);
    	if (!MyMatcher.matches()) return false;
    	return true;
	}
}