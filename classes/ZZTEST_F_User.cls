/**
* @Author:        Svata Sejkora
* @Company:       Deloitte
*
* @group Unit Tests
*
* @description Unit Tests Helper - User
*      
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 30.03.2016	Caro Reinecke	OWD on Account changed to Private from Read Only. Added Role to User Facade 
* 02.06.2017 Mabhedle Tonga Included a method that you get a user with a CIB Role.
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_F_User {

    private static ZZTEST_F_User instance;

    private Map<String,Id> nameToProfileMap {get; set;}
    private Map<Id,User> profileToUserMap {get; set;}

    private Integer productCounter {get;set;}

    private ZZTEST_F_User() {
        this.productCounter = 0;
        nameToProfileMap = fillNameToProfileMap();
        profileToUserMap = new Map<Id,User>();
    }

    public static ZZTEST_F_User getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_User();
        }
        return instance;
    }

    public String getProfileIdByName(String profileName)
    {
        if(nameToProfileMap.containsKey(profileName))
            return nameToProfileMap.get(profileName);

        return null;
    }

    public User getBarclaysStandardUser()
    {
        if(profileToUserMap.containsKey(nameToProfileMap.get('Barclays Standard User')))
            return profileToUserMap.get(nameToProfileMap.get('Barclays Standard User'));
        
        String BarclaysAfricaRoleId = fillRoleNameToIdMap().get('Barclays Africa');

        User u = new User(Alias = 'barclays', Email='barclays@testorg.com', FirstName='Barclays', LastName='TestUser',
             EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', UserRoleId=BarclaysAfricaRoleId,
             LocaleSidKey='en_ZA', ProfileId = nameToProfileMap.get('Barclays Standard User'), 
            TimeZoneSidKey='Africa/Johannesburg', UserName='barclays@testorg.com', BRID__c='FAKEBRID');
        try {
            insert u;
        }
        catch (Exception e)
        {
            System.debug('XXXXXXXXXXXX failed to create test user' + e);
            return null;
        }
        nameToProfileMap.put(u.UserName, u.ProfileId);
        profileToUserMap.put(u.profileId,u);
        return u;
    }

    public User getBarclaysStandardUserWithCIBRole()
    {
        if(profileToUserMap.containsKey(nameToProfileMap.get('Barclays Standard User')))
            return profileToUserMap.get(nameToProfileMap.get('Barclays Standard User'));
        
        String BarclaysAfricaRoleId = fillRoleNameToIdMap().get('ZAF - CIB - Coverage - Inland LLC Midcorp - Midcorp Sandton - TM');

        User u = new User(Alias = 'barclays', Email='barclays@testorg.com', FirstName='Barclays', LastName='TestUser',
             EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', UserRoleId=BarclaysAfricaRoleId,
             LocaleSidKey='en_ZA', ProfileId = nameToProfileMap.get('Barclays Standard User'), 
            TimeZoneSidKey='Africa/Johannesburg', UserName='barclays@testorg.com', BRID__c='FAKEBRID');
        try {
            insert u;
        }
        catch (Exception e)
        {
            System.debug('XXXXXXXXXXXX failed to create test user' + e);
            return null;
        }
        nameToProfileMap.put(u.UserName, u.ProfileId);
        profileToUserMap.put(u.profileId,u);
        return u;
    }

    public User getBarclaysWealthUser()
    {
        if(profileToUserMap.containsKey(nameToProfileMap.get('Barclays Wealth Advisor')))
            return profileToUserMap.get(nameToProfileMap.get('Barclays Wealth Advisor'));

        User u = new User(Alias = 'barclays', Email='barclays1@testorg.com', FirstName='Barclays', LastName='TestUser',
             EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
             LocaleSidKey='en_ZA', ProfileId = nameToProfileMap.get('Barclays Wealth Advisor'), 
            TimeZoneSidKey='Africa/Johannesburg', UserName='barclays1@testorg.com', BRID__c='FAKEBRID1');
        try {
            insert u;
        }
        catch (Exception e)
        {
            System.debug('XXXXXXXXXXXX failed to create test user' + e);
            return null;
        }
        nameToProfileMap.put(u.UserName, u.ProfileId);
        profileToUserMap.put(u.profileId,u);
        return u;
    }
    
    
    public User getExistingUserByProfile(String profileName)
    {
        if(nameToProfileMap.containsKey(profileName))
            return getUserByProfileId(nameToProfileMap.get(profileName));
        
        return null;
    }

    public User getUserByProfileId(Id profileId)
    {
        if(profileToUserMap.containsKey(profileId))
            return profileToUserMap.get(profileId);

        else
        {
            List<User> tempUserList = [SELECT Id, Name, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, TimeZoneSidKey, UserName 
                FROM User WHERE ProfileId =: profileId and isActive = True];
            if(tempUserList.size() > 0)
            {
                profileToUserMap.put(profileId,tempUserList[0]);
                return tempUserList[0];
            }
        }
        return null;
    }

    private Map<String, Id> fillNameToProfileMap()
    {
        Map<Id,Profile> tempMap = new Map<Id,Profile>([SELECT Id, Name FROM Profile]);
        Map<String, Id> retMap = new Map<String,Id>();
        for(Id pId : tempMap.keySet())
        {
            retMap.put(tempMap.get(pId).Name,pId);
        }
        return retMap;
    }
    
     private Map<String, Id> fillRoleNameToIdMap()
    {
        Map<Id,UserRole> tempMap = new Map<Id,UserRole>([SELECT Id, Name FROM UserRole]);
        Map<String, Id> retMap = new Map<String,Id>();
        for(Id pId : tempMap.keySet())
        {
            retMap.put(tempMap.get(pId).Name,pId);
        }
        return retMap;
    }
}