/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
*** CHANGE LOG ***
 
 18/09/2017 - PG    - Created Class.
 26/09/2017 - PG 	- Defaulted some additional fields on the default when inserting Deal.
 19/01/2018 - PG 	- Added logic for parent opp.
 23/01/2018 - PG 	- Removed Primary Opp functionality.  Changed to selected only.
 27/01/2018 - PG 	- Added Related_Group_Client__c in SOQL.

**/ 
public with sharing class Matter_ConvertFromOpportunities   
{	
	/**
	* Vars.
	**/
	public Account objectRecord { get; set; }
	public List<Opportunity> opportunities { get; set; }
	public List<WrapperRecord> opportunityWrappers { get; set; }
	public Boolean hasError { get; set; }
	public Map<String, String> userMapping;
	public advpm__Matter__c deal { get; set; }
	private static final Map<String, RecordTypeInfo> MATTER_TYPES = new Map<String, RecordTypeInfo>(advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName()); 

	/**
	* Constructor.
	**/
	public Matter_ConvertFromOpportunities(ApexPages.StandardController stdController)  
	{
		//Blank vars.
		opportunities = new List<Opportunity>();
		opportunityWrappers = new List<WrapperRecord>();
		hasError = false;
		deal = null;

		//Fields
		List<String> fields = new List<String>{
			'Name'
		};

		if(!Test.isRunningTest())
		{
			stdController.addFields(fields);
		}

		//Get the page context record.
        this.objectRecord = (Account)stdController.getRecord();

        //Get all open opportunities for the relationship.
        opportunities = [
        	SELECT 
        		Id,
        		Name,
        		AccountId,
        		CurrencyISOCode,
        		RecordTypeId,
        		CloseDate,
        		Description,
        		Amount,
        		StageName,
        		Is_Parent_Opportunity__c,
        		Parent_Opportunity__c,
        		//Opp Team Members
        		(
        			SELECT
        				Id,
        				UserId,
        				TeamMemberRole,
        				User.Name
        			FROM OpportunityTeamMembers
        		),
        		//OpportunityLineItems
        		(
        			SELECT
        				Id,
        				Product2.Name
        			FROM OpportunityLineItems
        			LIMIT 1
        		)
        	FROM Opportunity
        	WHERE
        		(AccountId = :objectRecord.Id 
        		OR Related_Group_Client__c = :objectRecord.Id)
        		AND IsClosed = false 
        		AND (
        			Is_Parent_Opportunity__c = 'Yes' 
        			OR (
        				(Is_Parent_Opportunity__c = 'No' OR Is_Parent_Opportunity__c = null OR Is_Parent_Opportunity__c = '')
        				AND Parent_Opportunity__c = NULL
        			)
        		)
        ];

        //No opportunities.
        if(opportunities.isEmpty())
        {
        	hasError = true;

        	//Show message on page.
        	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'There are no open opportunities for this Relationship.');
        	ApexPages.addMessage(msg);
        }
        else
        {
        	//Build Wrapper items.
        	buildWrappers();
        }        
	}

	/**
	* Wrapper class.
	**/
	public void buildWrappers() 
	{
		//Have Opps
		if(!opportunities.isEmpty())
		{
			for(Opportunity opportunity : opportunities)
			{
				//Create wrapper item for list.
				WrapperRecord wrapperItem = new WrapperRecord(opportunity);
				opportunityWrappers.add(wrapperItem);
			}
		}

		userMapping = new Map<String, String>{
			'Credit Manager' => 'Credit',
			'Legal' => 'Legal Counsel',
			'PCG' => 'Product Control Group'
		};
	}

	/**
	* submitRecord
	**/
	public PageReference submitRecord()
	{
		//Some vars.
		List<advpm__Participant__c> participants = new List<advpm__Participant__c>();
		Set<Id> addedParticipants = new Set<Id>();

		//Loop through wrapper items.
		for(WrapperRecord wrapperItem : opportunityWrappers)
		{
			//Opportunity selected.
			if(wrapperItem.selected == true)
			{
				//New deal & set values.
				deal = new advpm__Matter__c();
				deal.advpm__Primary_Account__c = objectRecord.Id;
				deal.Name = wrapperItem.record.Name;
				deal.Deal_Description__c = wrapperItem.record.Description;
				deal.CurrencyIsoCode = wrapperItem.record.CurrencyIsoCode;
				deal.Start_Date__c = wrapperItem.record.CloseDate;
				deal.RecordTypeId = MATTER_TYPES.get('Deal').getRecordTypeId();
				deal.Division__c = null;
				deal.Coverage_Area__c = null;
				deal.Product_Area__c = null;
				deal.Product2__c = null;
				deal.advpm__Opportunity__c = wrapperItem.record.Id;

				//Loop to opp team members.
				for(OpportunityTeamMember member : wrapperItem.record.OpportunityTeamMembers) 
				{
					//Valid mapping and not already added as participant.
					if(userMapping.containsKey(member.TeamMemberRole) && !addedParticipants.contains(member.UserId))
					{
						//New participant
						advpm__Participant__c participant = new advpm__Participant__c(); 
						participant.advpm__Staff__c = member.UserId;
						participant.advpm__Role__c = userMapping.get(member.TeamMemberRole); 
						participant.Name = member.User.Name;

						//Add to unique list.
						addedParticipants.add(member.UserId);

						//Add to list.
						participants.add(participant);
					}
				}

				//Database SavePoint
				Savepoint dbSave = Database.setSavepoint();

				try 
				{
					//Insert deal.
					insert deal;

					//Loop through participants and set deal.
					if(!participants.isEmpty())
					{
						for(advpm__Participant__c participant : participants)
						{
							//Set to inserted deal id.
							participant.advpm__Matter__c = deal.Id;
						}

						//Inser participants.
						insert participants;
					}

					//Setup redirect.
					PageReference dealPage = new PageReference('/'+deal.Id);
					dealPage.setRedirect(true);
					return dealPage;
				}
				catch(DmlException e)
				{
					//Rollback.
					Database.rollback(dbSave);

					//Show message on page.
		    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
		    		ApexPages.addMessage(msg);
				}
			}
		}
		
		//Default return. 
		return null;		
	}

	/**
	* Wrapper class.
	**/
	public class WrapperRecord
	{
		public Boolean selected { get; set; }
		public Opportunity record { get; set; }
		public String productName { get; set; }
		
		public WrapperRecord(Opportunity inputObject) 
		{
			this.record = inputObject;
			this.selected = false;

			if(inputObject.OpportunityLineItems.size() == 1)
			{
				this.productName = inputObject.OpportunityLineItems.get(0).Product2.Name;
			}
		}
	}
}