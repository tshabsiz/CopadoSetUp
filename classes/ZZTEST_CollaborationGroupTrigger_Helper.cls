/**
* @Author:        Svata Sejkora
* @Company:       Deloitte
* @Description:	  Unit Tests for CollaborationGroupTrigger_Helper
*               	Tests executed:
*               	1 - testCreateCustomerAndStandardGroupWithoutPerm()
*               		Test that user without right permissions can not create Customer Group
*               	2 - testCreateCustomerAndStandardGroupWithPerm()
*               		Test that user with right permission can create Customer Group
*               	3 - testCreateCustomerAndStandardGroupWithUserWithoutAnyPermSet()
*               		testing if in the class, when there is no permission set assigned to the user
*               	4 - testUpdateCustomerAndStandardGroupWithUserWithoutAnyPermSet()
*               		Checks if user without permission can edit group
*               	5 - testUpdateCustomerAndStandardGroupWithUserWithoutAnyPermSetNoChangeFalse()
*               		Checks that user can update group without perm not changing customer tag (set to false), but changing a name (basically testing if user can add users)
*               	6 - testUpdateCustomerAndStandardGroupWithUserWithoutAnyPermSetNoChangeTrue()
*               		Checks that user can update group without perm not changing customer tag (set to true), but changing a name (basically testing if user can add users)
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/

@isTest
public class ZZTEST_CollaborationGroupTrigger_Helper {
    
    private static final String PERM_SET_NAME = 'Key_Allow_Customer_Groups';
    private static final String PRIVATE_ATTRIBUTE = 'Private';
    private static final String GROUP_NAME_CUST = 'Test Name Of Chatter Group Customer';
    private static final String GROUP_NAME = 'Test Name Of Chatter Group';
    private static final String RANDOM_PERM_SET_NAME = 'Test_Perm_Set_Name';
    
    //custom exception class
    private class ZZTEST_CollaborationGroupTrigger_HelperException extends Exception {
    }
    
    public static testMethod void testCreateCustomerAndStandardGroupWithoutPerm(){
        //create standard user with permissions
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u = userFactory.getBarclaysStandardUser();
        
        PermissionSet ps = new PermissionSet(Name = RANDOM_PERM_SET_NAME, Label = RANDOM_PERM_SET_NAME);
        insert ps;
        
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = u.Id);
        insert psa;
        
        System.runAs(u) {
            Test.startTest();
            CollaborationGroup cgExt = new CollaborationGroup(CanHaveGuests = true, CollaborationType = PRIVATE_ATTRIBUTE, Name = GROUP_NAME_CUST);
            CollaborationGroup cg = new CollaborationGroup(CanHaveGuests = false, CollaborationType = PRIVATE_ATTRIBUTE, Name = GROUP_NAME);
            try {
                insert cgExt;
                throw new ZZTEST_CollaborationGroupTrigger_HelperException();
            }	
            catch(Exception e) {
                System.assertEquals(true, e instanceof DmlException);
            }
            
            try {
                insert cg;
                throw new ZZTEST_CollaborationGroupTrigger_HelperException();
            }	
            catch(Exception e) {
                System.assertEquals(true, e instanceof ZZTEST_CollaborationGroupTrigger_HelperException);
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testCreateCustomerAndStandardGroupWithPerm(){
        //create standard user with specific permission
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u = userFactory.getBarclaysStandardUser();
        
        Id allowCustGroupPermSetId = [SELECT Id FROM PermissionSet WHERE Name = :PERM_SET_NAME LIMIT 1].Id;
        
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = allowCustGroupPermSetId, AssigneeId = u.Id);
        insert psa;
        
        System.runAs(u) {
            Test.startTest();
            CollaborationGroup cgExt = new CollaborationGroup(CanHaveGuests = true, CollaborationType = PRIVATE_ATTRIBUTE, Name = GROUP_NAME_CUST);
            CollaborationGroup cg = new CollaborationGroup(CanHaveGuests = false, CollaborationType = PRIVATE_ATTRIBUTE, Name = GROUP_NAME);
            try {
                insert cgExt;
                throw new ZZTEST_CollaborationGroupTrigger_HelperException();
            }	
            catch(Exception e) {
                System.assertEquals(true, e instanceof ZZTEST_CollaborationGroupTrigger_HelperException);
            }
            
            try {
                insert cg;
                throw new ZZTEST_CollaborationGroupTrigger_HelperException();
            }	
            catch(Exception e) {
                System.assertEquals(true, e instanceof ZZTEST_CollaborationGroupTrigger_HelperException);
            }
            Test.stopTest();
        }		
    }
    
    public static testMethod void testCreateCustomerAndStandardGroupWithUserWithoutAnyPermSet(){
        //create standard user without permissions
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u = userFactory.getBarclaysStandardUser();
        
        System.runAs(u) {
            Test.startTest();
            CollaborationGroup cgExt = new CollaborationGroup(CanHaveGuests = true, CollaborationType = PRIVATE_ATTRIBUTE, Name = GROUP_NAME_CUST);
            CollaborationGroup cg = new CollaborationGroup(CanHaveGuests = false, CollaborationType = PRIVATE_ATTRIBUTE, Name = GROUP_NAME);
            try {
                insert cgExt;
                throw new ZZTEST_CollaborationGroupTrigger_HelperException();
            }	
            catch(Exception e) {
                System.assertEquals(true, e instanceof DmlException);
            }
            
            try {
                insert cg;
                throw new ZZTEST_CollaborationGroupTrigger_HelperException();
            }	
            catch(Exception e) {
                System.assertEquals(true, e instanceof ZZTEST_CollaborationGroupTrigger_HelperException);
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testUpdateCustomerAndStandardGroupWithUserWithoutAnyPermSet(){
        //create standard user without permissions
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u = userFactory.getBarclaysStandardUser();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
         CollaborationGroup cg;
        System.runAs(user1)
        {
            cg = new CollaborationGroup(CanHaveGuests = false, CollaborationType = PRIVATE_ATTRIBUTE, Name = GROUP_NAME);
            insert cg;
        }
        
        
        System.runAs(u) {
            Test.startTest();
            cg.CanHaveGuests = true;
            try {
                update cg;
                throw new ZZTEST_CollaborationGroupTrigger_HelperException();
            } catch(Exception e) {
                System.assertEquals(true, e instanceof DmlException);
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testUpdateCustomerAndStandardGroupWithUserWithoutAnyPermSetNoChangeFalse(){
        //create standard user without permissions
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u = userFactory.getBarclaysStandardUser();
        
        System.runAs(u) {
            CollaborationGroup cg = new CollaborationGroup(CanHaveGuests = false, CollaborationType = PRIVATE_ATTRIBUTE, Name = GROUP_NAME);
            insert cg;
            
            Test.startTest();
            cg.Name = GROUP_NAME_CUST;
            try {
                update cg;
                throw new ZZTEST_CollaborationGroupTrigger_HelperException();
            } catch(Exception e) {
                System.assertEquals(true, e instanceof ZZTEST_CollaborationGroupTrigger_HelperException);
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testUpdateCustomerAndStandardGroupWithUserWithoutAnyPermSetNoChangeTrue(){
        //create standard user without permissions
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u = userFactory.getBarclaysStandardUser();
        
        System.runAs(u) {
            Test.startTest();
            
            CollaborationGroup cg = new CollaborationGroup(CanHaveGuests = false, CollaborationType = PRIVATE_ATTRIBUTE, Name = GROUP_NAME);
            insert cg;
            cg.CanHaveGuests = true;
            try {
                update cg;
            } catch(Exception e) {
                System.assertEquals(true, e instanceof DmlException);
            }
            Test.stopTest();
        }
    }
    
    
}