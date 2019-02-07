/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 14/01/2017 - PG    - Created Class. 

**/ 
public class Notification_Group_Override
{
	private static final Map<String, RecordTypeInfo> RECORD_TYPES = new Map<String, RecordTypeInfo>(Notification_Group__c.sObjectType.getDescribe().getRecordTypeInfosByName());
	public Notification_Group__c objectRecord { get; set; }

	public Notification_Group_Override(ApexPages.StandardController stdController)
	{
		Id parentId = (Id)ApexPages.currentPage().getParameters().get('parentId');
		String sObjectType = parentId.getSObjectType().getDescribe().getName();

		//Get the page context record.
        this.objectRecord = (Notification_Group__c)stdController.getRecord();

        //Set owner id.
        objectRecord.OwnerId = UserInfo.getUserId();

        if(sObjectType == 'Fit_To_Lend_Checklist__c')
		{
			objectRecord.RecordTypeId = RECORD_TYPES.get('Fit To Lend Checklist').getRecordTypeId();
			objectRecord.Fit_To_Lend__c = parentId;
		}

		if(sObjectType == 'Drawdown__c')
		{
			objectRecord.RecordTypeId = RECORD_TYPES.get('Drawdown').getRecordTypeId();
			objectRecord.Drawdown__c = parentId;
		}
	}
}