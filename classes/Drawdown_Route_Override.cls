/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 06/08/2017 - PG    - Created Class. 

**/   
public with sharing class Drawdown_Route_Override {
	
	/**
    * Variables
    **/
    public Drawdown__c drawdownObject { get; set; }
    public static Map <String, Schema.RecordTypeInfo> recordTypes = Drawdown__c.sObjectType.getDescribe().getRecordTypeInfosByName();

	public Drawdown_Route_Override(ApexPages.StandardController stdController) 
	{
		//Get the page record.
    	this.drawdownObject = (Drawdown__c)stdController.getRecord(); 

    	//Make sure we change from Read Only.
    	if(drawdownObject.RecordTypeId == recordTypes.get('Drawdown ReadOnly').getRecordTypeId())
    	{
    		//Clone as the relevant record type based on availablity to the profile.
    		if(recordTypes.get('Drawdown').isAvailable())
    		{
    			drawdownObject.RecordTypeId = recordTypes.get('Drawdown').getRecordTypeId();
    		}

    		if(recordTypes.get('Drawdown - Agency').isAvailable())
    		{
    			drawdownObject.RecordTypeId = recordTypes.get('Drawdown - Agency').getRecordTypeId();
    		}
    	}
	}

	public PageReference actionRouteRecordType()
	{
		//Get current page parameters
        Map<String, String> currentParams = ApexPages.CurrentPage().getParameters();

		if(drawdownObject.RecordTypeId == recordTypes.get('Drawdown').getRecordTypeId())
		{
			//Override Page
        	PageReference overridePage = new PageReference('/apex/Drawdown_Override'); 
            overridePage.getParameters().putAll(currentParams);
            overridePage.getParameters().remove('save_new');
            overridePage.getParameters().remove('save');
            overridePage.getParameters().put('nooverride','1');  
        	overridePage.setRedirect(true);
        	return overridePage;
		}
		else if(drawdownObject.RecordTypeId == recordTypes.get('Drawdown - Agency').getRecordTypeId()) 
		{
			//Override Page
        	PageReference overridePage = new PageReference('/apex/Drawdown_Override_Agency'); 
            overridePage.getParameters().putAll(currentParams);
            overridePage.getParameters().remove('save_new');
            overridePage.getParameters().remove('save');
            overridePage.getParameters().put('nooverride','1'); 
        	overridePage.setRedirect(true);
        	return overridePage;
		}
		else
		{
			return null;
		}
	}
}