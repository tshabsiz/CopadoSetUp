/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

2017/06/23 - PG    	- Added "getCreatableFieldsSOQL" method.
2017/06/29 - DF		- Updating to getContent if a test class is not running, else the test fails with error : Methods defined as TestMethod do not support getContent call
2018/03/12 - PG     - Added method "getEnviroment" to detemine Salesforce enviroment we in.
**/                                                           
public class CloudSmiths_Utils 
{
    /**
* @author Peter Guest
* @description Returns a Blob version of a PDF rendered VF page.
**/
    public static Blob convertUrlToBlob(String inputPageUrl)
    {
        PageReference pageRef = new PageReference(inputPageUrl);
        Blob pageBlob;
        If(test.isRunningTest() == false)//only do this if a test is not running
        {
            pageBlob = pageRef.getContent();
        }
        else
        {
            pageBlob = Blob.valueOf('Test');
        }
        return pageBlob;
    }
    
    /**
* @author Peter Guest
* @description Returns the id for a specific record type name and object.
* @example CloudSmiths_Utils.getObjectRecordTypeId(Lead.SObjectType, 'Record Type Name');
**/
    public static Id getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName)
    {
        //Get a map of all record types for object.
        Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();
        
        //Make sure we can find record type name in map.
        if(!recordTypeInfo.containsKey(recordTypeName))
        {
            throw new CloudSmiths_Utils_Exception('### CloudSmiths_Utils_Exception:  Record type "'+ recordTypeName +'" does not exist for object.');
        }
        else
        {
            //Return record type id.
            return recordTypeInfo.get(recordTypeName).getRecordTypeId();
        }
        
        //Default return.
        return null;
    }
    
    /**
* @author Peter Guest
* @description Dynamically returns a SOQL query string for all createable fields for an object.
* @example String soql = CloudSmiths_Utils.getCreatableFieldsSOQL('lead','id=\'00Q3000000aKwVN\'');
**/
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
        
        String selects = '';
        
        if (whereClause == null || whereClause == '')
        { 
            return null; 
        }
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null)
        {
            // loop through all field tokens (ft)
            for (Schema.SObjectField ft : fMap.values())
            {   
                //describe each field (fd)
                Schema.DescribeFieldResult fd = ft.getDescribe(); 
                
                //field is creatable
                if (fd.isCreateable())
                { 
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty())
        {
            for (string s:selectFields)
            {
                selects += s + ',';
            }
            if (selects.endsWith(','))
            {
                selects = selects.substring(0,selects.lastIndexOf(','));
            }
        }
        
        //Return string.
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
    }

    /**
    * Determines which Salesforce Org we in.
    **/
    public static String getEnviroment() 
    {
        Organization salesforceOrg = [SELECT IsSandbox FROM Organization LIMIT 1];

        if(salesforceOrg.IsSandbox)
        {
            String hostName = [SELECT Domain FROM Domain].Domain.substringBefore('.');
            return hostName.contains('uat') ? 'UAT' : 'DEV';
        }
        else
        {
            return 'PROD'; 
        }
    }
    
    public static String determineApprover()
    {
        System.debug('### determineApprover');

        //Current User Role
        String currentUserRoleId = UserInfo.getUserRoleId();

        String approverId = '';

        //Get all org users.
        List<User> users = new List<User>([
            SELECT
                Id,
                UserRoleId
            FROM User
            WHERE
                IsActive = true
        ]);

        //Get all roles.
        Map<Id, UserRole> roles = new Map<Id, UserRole>([
            SELECT
                Id,
                ParentRoleId
            FROM UserRole
        ]);

        String teamLeaderRoleId = roles.get(currentUserRoleId).ParentRoleId;

        for(User u : users)
        {
            if(u.UserRoleId == teamLeaderRoleId)
            {
                return u.Id;
            }
        }

        String headRoleId = roles.get(teamLeaderRoleId).ParentRoleId;

        for(User u : users)
        {
            if(u.UserRoleId == headRoleId)
            {
                return u.Id;
            }
        }

        return null;
    }

    /**
    * @author Peter Guest
    * @description This utils exception extension.
    * @example throw new CloudSmiths_Utils_Exception('Exception Message Here');
    **/
    public class CloudSmiths_Utils_Exception extends Exception{}
      
}