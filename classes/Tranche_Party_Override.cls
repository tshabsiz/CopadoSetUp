/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 13/09/2017 - PG    - Created Class. 

**/
public with sharing class Tranche_Party_Override 
{
	/**
	* Variables
	**/
	public Facility_Tranche__c objectRecord { get; set; }
	public List<Facility_Party__c> facilityParties { get; set; }
	public List<Tranche_Party__c> existingTrancheParties { get; set; }
	public List<PartyWrapper> partyWrappers { get; set; }
	public Set<Id> existingFacilityPartyIds { get; set; }
	public Map<Id, Id> facilityPartyToTrancheParty { get; set; } 
	public Boolean showError { get; set; }               

	/**
	* Constructor
	**/
	public Tranche_Party_Override(ApexPages.StandardController stdController) 
	{
		//Blank vars
		facilityParties = new List<Facility_Party__c>();
		partyWrappers = new List<PartyWrapper>();		
		existingFacilityPartyIds = new Set<Id>();
		showError = false;
		facilityPartyToTrancheParty = new Map<Id, Id>();

		//Query standard fields.
		List<String> fields = new List<String> {
			'Facility__c'
		};

		//Only do if test is not running.
		if(!Test.isRunningTest())
		{
			stdController.addFields(fields);
		}

		//Get the page context record.
        this.objectRecord = (Facility_Tranche__c)stdController.getRecord();

        //Get all facility parties on the facility
		facilityParties = [
			SELECT
				Id,
				Name,
				Party_Type__c
			FROM Facility_Party__c 
			WHERE
				Facility__c = :objectRecord.Facility__c
		];

        //Get all existing parties on the tranche.
        existingTrancheParties = [
        	SELECT 
        		Id,
        		Name,
        		Facility_Party__c,
        		Facility_Tranche__c
        	FROM Tranche_Party__c 
        	WHERE
        		Facility_Tranche__c = :objectRecord.Id
        ];

        //Got tranche parties back.
        if(!existingTrancheParties.isEmpty())
        {
        	for(Tranche_Party__c existingTrancheParty : existingTrancheParties)
        	{
        		//Add to set.
        		existingFacilityPartyIds.add(existingTrancheParty.Facility_Party__c);

        		//Add to list for later use.
        		facilityPartyToTrancheParty.put(existingTrancheParty.Facility_Party__c, existingTrancheParty.Id);
        	}
        }

        //Initialise the list.
        initialiseWrapperList();
	}

	/**
    * initialiseWrapperList
    **/
	public void initialiseWrapperList()
	{
		for(Facility_Party__c facilityParty : facilityParties)
		{	
			//New wrapper item.
			PartyWrapper wrapperItem = new PartyWrapper();
			wrapperItem.party = facilityParty;

			//Facility party is already part of the tranche parties.
			if(existingFacilityPartyIds.contains(facilityParty.Id))
			{
				wrapperItem.selected = true;
			}

			//Add to main wrapper.
			partyWrappers.add(wrapperItem);
		}
	}

	public PageReference saveRecord()
	{
		System.debug('### Facility_Party_Override : saveRecord');

		//Blank variables.
		List<Tranche_Party__c> insertList = new List<Tranche_Party__c>();
		List<Tranche_Party__c> deleteList = new List<Tranche_Party__c>();

		//Reset error message.
        showError = true;

		for(PartyWrapper partyWrapper : partyWrappers)
		{	
			//Handle selected.
			if(partyWrapper.selected == true)
			{
				//One is selected at least.
                showError = false;

				if(!existingFacilityPartyIds.contains(partyWrapper.party.Id))
				{
					//New facility party
					Tranche_Party__c trancheParty = new Tranche_Party__c();
					trancheParty.Facility_Tranche__c = objectRecord.Id;
					trancheParty.Facility_Party__c = partyWrapper.party.Id;
					trancheParty.Name = partyWrapper.party.Name;
					insertList.add(trancheParty);
				}
			}
			//Not selected.
			else
			{
				//If this party was previously selected.
				if(facilityPartyToTrancheParty.containsKey(partyWrapper.party.Id))
				{
					//Id of party to delete.
                    Id tranchePartyId = facilityPartyToTrancheParty.get(partyWrapper.party.Id);

                    //Facility party to delete.
                    Tranche_Party__c partyToDelete = new Tranche_Party__c(Id = tranchePartyId); 

                    //Add to delete list.
                    deleteList.add(partyToDelete);
				}
			}
		}

		//Return page error.
        if(showError == true)
        {
            //Page message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You must select at least one facility party.'));
                
            return null;
        }

        //Execute changes.
        try 
        {
            //Insert new records.
            if(!insertList.isEmpty())
            {
                insert insertList;
            }
            
            //Delete deselected records.
            if(!deleteList.isEmpty())
            {
                delete deleteList;
            }
            
            //New Page Setup
            PageReference standardPage = new PageReference('/'+objectRecord.Id); 
            standardPage.setRedirect(true);

            //Redirect.
            return standardPage;
        }
        catch(Exception e)
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }

		//Default return.
		return null;
	}

	/**
    * Wrapper Class
    **/
    public class PartyWrapper
    {
        public Facility_Party__c party { get; set; }
        public Boolean selected { get; set; }
        
        public PartyWrapper() 
        { 
            this.selected = false;
        } 
    }
}