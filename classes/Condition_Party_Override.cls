/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 26/06/2017 - PG    - Created Class. 
 04/07/2017 - PG    - Modify class to handle GC's creates at Deal level.  Provisions a container Agreement and Agreement Parties.
                    - Moved most logic away from Constructor to initialiseData methods.  Needed DML.
 15/09/2017 - PG    - Ported overall class to use "Condition__c" instead of "Condition_Party__c" instead.
 29/09/2017 - PG    - Added "CONDITION_TYPES" and updated code to use it instead.  
 02/11/2017 - PG    - Removed Standard controller logic and use param instead.
                    - Added actionCancel method. 

**/ 
public class Condition_Party_Override
{
    /**
    * Variables
    **/
    public static final Map<String, RecordTypeInfo> CONDITION_TYPES = new Map<String, RecordTypeInfo>(Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName());
    public List<Agreement_Party__c> agreementParties { get; set; }
    public List<Condition_Party__c> conditionParties { get; set; }
    public Set<Id> existingAgreementParties { get; set; }
    public Map<Id, Id> agreementPartyMap { get; set; }
    public List<PartyWrapper> partyWrappers { get; set; }
    public Condition__c conditionRecord { get; set; }
    public Agreement__c agreementRecord { get; set; }
    public Id agreementId { get; set; }
    public String param1 { get; set; }
    
    /**
     * CONSTRUCTOR
    **/
    public Condition_Party_Override()
    {
        System.debug('## Condition_Party_Override');
        
        //Blank vars.
        agreementParties = new List<Agreement_Party__c>();
        conditionParties = new List<Condition_Party__c>();
        existingAgreementParties = new Set<Id>();
        agreementPartyMap = new Map<Id, Id>();
        partyWrappers = new List<PartyWrapper>();
        param1 = ApexPages.currentPage().getParameters().get('id');
    }
    
    /**
     * action - initialiseData - The main page logic on how to handle the Condition Party.
    **/
    public PageReference initialiseData()
    {
        //Get condition
        conditionRecord = [
            SELECT
                Id,
                RecordTypeId,
                Agreement__c,
                Matter__c
            FROM Condition__c
            WHERE
                Id = :param1
            LIMIT 1
        ];

        //Get all the existing conditions parties for the condition.
        conditionParties = [
            SELECT
                Id,
                Agreement_Party__c,
                Condition__c
            FROM Condition_Party__c
            WHERE
                Condition__c = :conditionRecord.Id
        ];
        
        //If this is a governance check, that is linked to the Deal and not linked to an Agreement i.e. Directly on Deal.
        if(conditionRecord.RecordTypeId == CONDITION_TYPES.get('Governance Check').getRecordTypeId() && conditionRecord.Matter__c != null && conditionRecord.Agreement__c == null)
        {
            System.debug('## Condition_Party_Override : GC IF ');
            
            //Blank list.
            List<Agreement__c> agreements = new List<Agreement__c>();
            
            //See if there is an existing system generated agreemnet on the Deal for Governance Checks.
            agreements = [
                SELECT
                    Id,
                    Name,
                    Matter_Deal__c
                FROM Agreement__c
                WHERE 
                    Name = 'Internal Deal Governance Checks'
                    AND Matter_Deal__c = :conditionRecord.Matter__c
                LIMIT 1
            ];
            
            //Agreement exists.
            if(agreements.size() > 0)
            {
                //Assign Id.
                agreementId = agreements[0].Id;  
                
            }
            //Agreement does not exist.
            else
            {
                //Create a new agreement.
                agreementRecord = new Agreement__c();
                agreementRecord.Name = 'Internal Deal Governance Checks';
                agreementRecord.Matter_Deal__c = conditionRecord.Matter__c; 
                agreementRecord.Agreement_Description__c = 'System Generated - Purpose: Deal Level Govenance Checks.';
                
                //insert agreement.
                insert agreementRecord;
                
                //Update id to be inserted agreement record.
                agreementId = agreementRecord.Id;
                
                //Get all deal parties and insert them by default.
                List<Deal_Party__c> dealParties = [
                    SELECT
                        Id,
                        Deal__c,
                        Conditions_Monitored_By__c,
                        Relationship__c,
                        Party_Type__c
                    FROM Deal_Party__c
                    WHERE
                        Deal__c = :conditionRecord.Matter__c
                ]; 
                
                //Anything to process
                if(dealParties.size() > 0)
                {
                    //Empty list.
                    List<Agreement_Party__c> agreementParties = new List<Agreement_Party__c>();
                    
                    //Loop through deal parties and build agreement parties.
                    for(Deal_Party__c dealParty : dealParties)
                    {
                        //New agreement party object.
                        Agreement_Party__c agreementParty = new Agreement_Party__c();
                        agreementParty.Deal_Party__c = dealParty.Id;
                        agreementParty.Agreement__c = agreementId;
                        
                        //Add to list.
                        agreementParties.add(agreementParty);
                    }
                    
                    //Anything to process.
                    if(!agreementParties.isEmpty())
                    {
                        //Insert parties.
                        insert agreementParties;
                    }
                }
            }
            
        }
        else
        {
            //Get this id of the associated conditions agreement. 
            agreementId = conditionRecord.Agreement__c;
        }
        
        //Get all the agreement parties for the conditions agreement.
        agreementParties = [
            SELECT
                Id,
                Name,
                Agreement__c,
                Relationship__c,
                Party_Type__c,
                Conditions_Monitored_By__c
            FROM Agreement_Party__c
            WHERE 
                Agreement__c = :agreementId
        ];
        
        //There are no deal parties defined.
        if(agreementParties.isEmpty())
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'There are no parties specified on the associated agreement.'));
        }
        
        //Any existing condition parties?
        if(!conditionParties.isEmpty()) 
        {            
            for(Condition_Party__c conditionParty : conditionParties)
            {                
                if(!existingAgreementParties.contains(conditionParty.Agreement_Party__c))
                {
                    existingAgreementParties.add(conditionParty.Agreement_Party__c);
                }
                
                //Add to map for use later to track deselected.
                agreementPartyMap.put(conditionParty.Agreement_Party__c, conditionParty.Id); 
            }
        }
        
        //Build Initial Wrapper List.
        initialiseWrapperList(); 
        
        return null;
    }
    
    /**
     * action - initialiseWrapperList - Builds the initial wrapper list.
    **/
    public void initialiseWrapperList()
    {
        System.debug('## initialiseWrapperList');
        System.debug('## initialiseWrapperList : agreementParties : '+agreementParties);
        
        //Loop through agreement parties.
        for(Agreement_Party__c agreementParty : agreementParties)
        {
            PartyWrapper wrapperItem = new PartyWrapper();
            wrapperItem.party = agreementParty;
            
            if(existingAgreementParties.contains(agreementParty.Id))
            {
                wrapperItem.selected = true;   
            }
            
            //Add to main wrapper list.
            partyWrappers.add(wrapperItem);
        }
    }
    
    /**
     * action - initialiseWrapperList - Builds the initial wrapper list. 
    **/
    public PageReference saveRecord() 
    {
        System.debug('### Condition_Party_Override : saveRecord');

        //Blank variables.
        List<Condition_Party__c> conditionPartiesInsert = new List<Condition_Party__c>();
        List<Condition_Party__c> conditionPartiesDelete = new List<Condition_Party__c>();
        
        //Loop through wrapper list.
        for(PartyWrapper partyWrapper : partyWrappers)
        {
            //If selected
            if(partyWrapper.selected == true)
            {
                if(!existingAgreementParties.contains(partyWrapper.party.Id))
                {
                    //New Agreement Party
                    Condition_Party__c conditionParty = new Condition_Party__c();
                    conditionParty.Condition__c = conditionRecord.Id;
                    conditionParty.Agreement_Party__c = partyWrapper.party.Id;
                    
                    //Add to list.
                    conditionPartiesInsert.add(conditionParty);
                }
            }
            //If deselected
            else
            {
                if(existingAgreementParties.contains(partyWrapper.party.Id))
                {
                    //Id of party to delete.
                    Id conditionPartyId = agreementPartyMap.get(partyWrapper.party.Id);
                    
                    //Agreemnet party to delete.
                    Condition_Party__c conditionPartyToDelete = new Condition_Party__c(Id = conditionPartyId); 
                    
                    //Add to delete list.
                    conditionPartiesDelete.add(conditionPartyToDelete);
                }
            }
        }
        
        //Execute changes.
        try 
        {
            //Insert new records.
            if(!conditionPartiesInsert.isEmpty())
            {
                insert conditionPartiesInsert;
            }

            //Delete deselected records.
            if(!conditionPartiesDelete.isEmpty())
            {
                delete conditionPartiesDelete;
            }
            
            //New Page Setup
            PageReference standardPage = new PageReference('/'+conditionRecord.Id); 
            standardPage.setRedirect(true);

            //Redirect.
            return standardPage;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }
        
        //Default.
        return null;
    }

    /**
    * actionCancel
    **/
    public PageReference actionCancel() 
    { 
        PageReference page = new PageReference('/'+param1);
        page.setRedirect(true);
        return page;
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