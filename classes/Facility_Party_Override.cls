/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 12/09/2017 - PG    - Created Class. 

**/
public with sharing class Facility_Party_Override 
{
	/**
	* Variables
	**/
	public Facility__c objectRecord { get; set; }
	public List<Agreement_Party__c> agreementParties { get; set; }
	public List<Facility_Party__c> existingFacilityParties { get; set; }
	public List<PartyWrapper> partyWrappers { get; set; }
	public Set<Id> existingAgreementPartyIds { get; set; }
	public Map<Id, Id> agreementPartyToFacilityParty { get; set; } 
	public Boolean showError { get; set; }               

	/**
	* Constructor
	**/
	public Facility_Party_Override(ApexPages.StandardController stdController) 
	{
		//Blank vars
		agreementParties = new List<Agreement_Party__c>();
		partyWrappers = new List<PartyWrapper>();		
		existingAgreementPartyIds = new Set<Id>();
		showError = false;
		agreementPartyToFacilityParty = new Map<Id, Id>();

		//Query standard fields.
		List<String> fields = new List<String> {
			'Agreement__c'
		};

		//Only do if test is not running.
		if(!Test.isRunningTest())
		{
			stdController.addFields(fields);
		}

		//Get the page context record.
        this.objectRecord = (Facility__c)stdController.getRecord();

        //Get all agreement parties on the agreement
		agreementParties = [
			SELECT
				Id,
				Name,
				Party_Type__c
			FROM Agreement_Party__c 
			WHERE
				Agreement__c = :objectRecord.Agreement__c
		];

        //Get all existing parties on facility.
        existingFacilityParties = [
        	SELECT 
        		Id,
        		Name,
        		Agreement_Party__c,
        		Facility__c
        	FROM Facility_Party__c 
        	WHERE
        		Facility__c = :objectRecord.Id
        ];

        //Got facility parties back.
        if(!existingFacilityParties.isEmpty())
        {
        	for(Facility_Party__c existingFacilityParty : existingFacilityParties)
        	{
        		//Add to set.
        		existingAgreementPartyIds.add(existingFacilityParty.Agreement_Party__c);

        		//Add to list for later use.
        		agreementPartyToFacilityParty.put(existingFacilityParty.Agreement_Party__c, existingFacilityParty.Id);
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
		for(Agreement_Party__c agreementParty : agreementParties)
		{	
			//New wrapper item.
			PartyWrapper wrapperItem = new PartyWrapper();
			wrapperItem.party = agreementParty;

			//Agreement party is already part of the facility parties.
			if(existingAgreementPartyIds.contains(agreementParty.Id))
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
		List<Facility_Party__c> insertList = new List<Facility_Party__c>();
		List<Facility_Party__c> deleteList = new List<Facility_Party__c>();

		//Reset error message.
        showError = true;

		for(PartyWrapper partyWrapper : partyWrappers)
		{	
			//Handle selected.
			if(partyWrapper.selected == true)
			{
				//One is selected at least.
                showError = false;

				if(!existingAgreementPartyIds.contains(partyWrapper.party.Id))
				{
					//New facility party
					Facility_Party__c facilityParty = new Facility_Party__c();
					facilityParty.Facility__c = objectRecord.Id;
					facilityParty.Agreement_Party__c = partyWrapper.party.Id;
					facilityParty.Name = partyWrapper.party.Name;
					insertList.add(facilityParty);
				}
			}
			//Not selected.
			else
			{
				//If this party was previously selected.
				if(agreementPartyToFacilityParty.containsKey(partyWrapper.party.Id))
				{
					//Id of party to delete.
                    Id facilityPartyId = agreementPartyToFacilityParty.get(partyWrapper.party.Id);

                    //Facility party to delete.
                    Facility_Party__c partyToDelete = new Facility_Party__c(Id = facilityPartyId); 

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
        public Agreement_Party__c party { get; set; }
        public Boolean selected { get; set; }
        
        public PartyWrapper() 
        { 
            this.selected = false;
        } 
    }
}