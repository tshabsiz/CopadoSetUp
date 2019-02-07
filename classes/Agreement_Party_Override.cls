/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 26/06/2017 - PG    - Created Class. 
 19/08/2017 - PG    - Change to use the "Agreement__c" standard controller.
                    - Needed for custom button needed, instead of standard "New" overrride.

**/ 
public class Agreement_Party_Override  
{
    /**
    * Variables
    **/
    public Agreement__c objectRecord { get; set; } 
    public List<Deal_Party__c> dealParties { get; set; }
    public List<Agreement_Party__c> agreementParties { get; set; }
    public Set<Id> existingDealParties { get; set; }
    public List<PartyWrapper> partyWrappers { get; set; }
    Map<Id, Id> dealPartyAgreementParties { get; set; }
    public Boolean showError { get; set; }
    
    /**
     * CONSTRUCTOR
    **/
    public Agreement_Party_Override(ApexPages.StandardController stdController)
    {
        //Blank vars.
        dealParties = new List<Deal_Party__c>();
        agreementParties = new List<Agreement_Party__c>();
        partyWrappers = new List<PartyWrapper>();
        existingDealParties = new Set<Id>();
        dealPartyAgreementParties = new Map<Id, Id>();
        showError = false;
        
        //Get the page context record.
        this.objectRecord = (Agreement__c)stdController.getRecord();
        
        //Get the ID of the associated agreement deal.
        Id dealId =  [
            SELECT
                Id,
                Matter_Deal__c
            FROM Agreement__c
            WHERE
                Id = :objectRecord.Id
        ].Matter_Deal__c;
        
        //Get all the deal parties for the deal.
        dealParties = [
            SELECT 
                Id,
                Name,
                Deal__c,
                Relationship__c,
                Party_Type__c,
                Conditions_Monitored_By__c
            FROM Deal_Party__c
            WHERE
                Deal__c = :dealId
        ];
        System.debug('### Agreement_Party_Override : dealParties : '+dealParties);
        
        //There are no deal parties defined.
        if(dealParties.isEmpty())
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'There are no parties specified on the associated deal.'));
        }
        
        //Get all the agreement parties for the agreement
        agreementParties = [
         SELECT 
                Id,
                Name,
                Agreement__c,
                Deal_Party__c
            FROM Agreement_Party__c
            WHERE
                Agreement__c = :objectRecord.Id   
        ];
        System.debug('### Agreement_Party_Override : agreementParties : '+agreementParties);
        
        if(!agreementParties.isEmpty())
        {
           //Build a set of existing agreement deal parties.
            for(Agreement_Party__c agreementParty : agreementParties)
            {
                if(!existingDealParties.contains(agreementParty.Deal_Party__c))
                {
                    existingDealParties.add(agreementParty.Deal_Party__c);  
                } 
                
                //Add to map for use later to track deselected.
                dealPartyAgreementParties.put(agreementParty.Deal_Party__c, agreementParty.Id);
            } 
        }
        
        //Build Initial Wrapper List.
        initialiseWrapperList();
    }
    
    /**
     * action - initialiseWrapperList - Builds the initial wrapper list.
    **/
    public void initialiseWrapperList()
    {
        System.debug('### Agreement_Party_Override : initialiseWrapperList');
        System.debug('### Agreement_Party_Override : initialiseWrapperList : dealParties : '+dealParties);
        
        for(Deal_Party__c dealParty : dealParties)
        {
            PartyWrapper wrapperItem = new PartyWrapper();
            wrapperItem.party = dealParty;
            
            if(existingDealParties.contains(dealParty.Id))
            {
                wrapperItem.selected = true;   
            }
            
            //Add to main wrapper list.
            partyWrappers.add(wrapperItem);
        }
        System.debug('### Agreement_Party_Override : initialiseWrapperList : partyWrappers : '+partyWrappers);
    }
    
    /**
     * action - saveRecord.
    **/
    public PageReference saveRecord() 
    {
        System.debug('### Agreement_Party_Override : saveRecord');

        //Blank variables.
        List<Agreement_Party__c> agreementPartiesInsert = new List<Agreement_Party__c>();
        List<Agreement_Party__c> agreementPartiesDelete = new List<Agreement_Party__c>();
        
        //Reset error message.
        showError = true;
        
        //Loop through wrapper list.
        for(PartyWrapper partyWrapper : partyWrappers)
        {
            //If selected
            if(partyWrapper.selected)
            {
                //One is selected at least.
                showError = false;
                
                if(!existingDealParties.contains(partyWrapper.party.Id))
                {
                    //New Agreement Party
                    Agreement_Party__c agreementParty = new Agreement_Party__c();
                    agreementParty.Agreement__c = objectRecord.Id;
                    agreementParty.Deal_Party__c = partyWrapper.party.Id;
                    
                    //Add to list.
                    agreementPartiesInsert.add(agreementParty);
                }
            }
            //If deselected
            else
            {
                if(existingDealParties.contains(partyWrapper.party.Id))
                {
                    //Id of party to delete.
                    Id agreementPartyId = dealPartyAgreementParties.get(partyWrapper.party.Id);
                    
                    //Agreemnet party to delete.
                    Agreement_Party__c agreementPartyToDelete = new Agreement_Party__c(Id = agreementPartyId); 
                    
                    //Add to delete list.
                    agreementPartiesDelete.add(agreementPartyToDelete);
                }
            }
        }
        
        //Return page error.
        if(showError == true)
        {
            //Page message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You must select at least one agreement party.'));
                
            return null;
        }
        
        //Execute changes.
        try 
        {
            //Insert new records.
            if(!agreementPartiesInsert.isEmpty())
            {
                insert agreementPartiesInsert;
            }
            
            //Delete deselected records.
            if(!agreementPartiesDelete.isEmpty())
            {
                delete agreementPartiesDelete;
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
        
        //Default.
        return null;
    }
    
    /**
     * Wrapper Class
    **/
    public class PartyWrapper
    {
        public Deal_Party__c party { get; set; }
        public Boolean selected { get; set; }
        
        public PartyWrapper() 
        { 
            this.selected = false;
        } 
    }
}