/**
*** CHANGE LOG ***

29/11/2017 - TdB    - Created Class.

**/ 
public class Relationship_Parties_Bulk {
    
    public List<sObject_Scheduling_Occurences.RelationshipPartiesWrapper> relationshipParties_Wrapper { get; set; }
    public List<Relationship_Parties__c> existingRelationshipParties { get; set; }
    public List<sObject> existingParties { get; set; }
    public List<sObject> objectParentRecord { get; set; }
    public Set<Id> existingRelationshipSet { get; set; }
    public Map<Id, Id> partiesRelationshipParties { get; set; }
    public Boolean showError { get; set; }
    public Id currentObjectId;
    public String currentObjectName; 
   // public Id parentObjectId;
    
    public Relationship_Parties_Bulk()
    {
        relationshipParties_Wrapper = new List<sObject_Scheduling_Occurences.RelationshipPartiesWrapper> ();
        existingRelationshipParties = new List<Relationship_Parties__c> ();
        existingParties = new List<sObject>();
        objectParentRecord = new List<sObject>();
        existingRelationshipSet = new Set<Id> ();
        partiesRelationshipParties = new Map<Id, Id>();
        
        //Get Record Id from URL
        if(ApexPages.currentPage().getParameters().get('sObjectId') != null)
        {
            currentObjectId = Id.valueOf(ApexPages.currentPage().getParameters().get('sObjectId'));
        }
        
        //Get Object API Name based on Id
        currentObjectName = currentObjectId.getSObjectType().getDescribe().getName();
        
        //Margin Ratchet
        if(currentObjectName  == 'Margin_Ratchet__c')
        {
            //Get Margin Ratchet Record (sObject)
            objectParentRecord = [SELECT Id, Facility_Tranche__c, Facility__c, Agreement__c  FROM Margin_Ratchet__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification financialCovenants
            existingRelationshipParties = [SELECT Id, Agreement_Party__c, Facility_Party__c, Margin_Ratchet__c, Tranche_Party__c  FROM Relationship_Parties__c WHERE Margin_Ratchet__c = : currentObjectId];
            
                        
            if(objectParentRecord.size() > 0)
            {
                if((Id)objectParentRecord[0].get('Facility_Tranche__c') != null)
                {
                    sObject_Scheduling_Occurences.getRelationshipPartiesList((Id)objectParentRecord[0].get('Facility_Tranche__c'), 'Tranche');
                    existingParties = sObject_Scheduling_Occurences.tranchePartiesList;
                }
                else if ((Id)objectParentRecord[0].get('Facility__c') != null)
                {
                    sObject_Scheduling_Occurences.getRelationshipPartiesList((Id)objectParentRecord[0].get('Facility__c'), 'Facility');
                    existingParties = sObject_Scheduling_Occurences.facilityPartiesList;
                }
                else
                {
                    sObject_Scheduling_Occurences.getRelationshipPartiesList((Id)objectParentRecord[0].get('Agreement__c'), 'Agreement');
                    existingParties = sObject_Scheduling_Occurences.agreementPartiesList;
                }
            }
        }   
        
        if(!existingRelationshipParties.isEmpty())
        {
            //Build a set of existing Relationship Parties
            for(Relationship_Parties__c eachRelationshipParties : existingRelationshipParties)
            {
                if((Id)objectParentRecord[0].get('Facility_Tranche__c') != null)
                {
                    if(!existingRelationshipSet.contains(eachRelationshipParties.Tranche_Party__c))
                    {
                    	existingRelationshipSet.add(eachRelationshipParties.Tranche_Party__c);  
                    } 
                    partiesRelationshipParties.put(eachRelationshipParties.Tranche_Party__c, eachRelationshipParties.Id);
                }
                else if((Id)objectParentRecord[0].get('Facility__c') != null)
                {
                    if(!existingRelationshipSet.contains(eachRelationshipParties.Facility_Party__c))
                    {
                    	existingRelationshipSet.add(eachRelationshipParties.Facility_Party__c);  
                    } 
                    partiesRelationshipParties.put(eachRelationshipParties.Facility_Party__c, eachRelationshipParties.Id);
                }
                else if((Id)objectParentRecord[0].get('Agreement__c') != null)
                {
                    if(!existingRelationshipSet.contains(eachRelationshipParties.Agreement_Party__c))
                    {
                    	existingRelationshipSet.add(eachRelationshipParties.Agreement_Party__c);  
                    } 
                    partiesRelationshipParties.put(eachRelationshipParties.Agreement_Party__c, eachRelationshipParties.Id);
                } 
            } 
        }
        initialiseWrapperList();
    }
    
    public void initialiseWrapperList()
    {
        //Loop through financialCovenants Wrapper, check if financialCovenant already created as a Notification financialCovenant and flag as True
        for(sObject eachParty : existingParties)
        {
            sObject_Scheduling_Occurences.RelationshipPartiesWrapper wrapperItem = new sObject_Scheduling_Occurences.RelationshipPartiesWrapper();
            wrapperItem.partyName = (String)eachParty.get('Name');
            wrapperItem.partyType = (String)eachParty.get('Party_Type__c');
            wrapperItem.partyId = (Id)eachParty.get('Id');
            
            if(existingRelationshipSet.contains(eachParty.Id))
            {
                wrapperItem.selected = true;   
            }
            
            //Add to main wrapper list.
            relationshipParties_Wrapper.add(wrapperItem);
        }
    }
    
    public PageReference saveRecord() 
    {
        
        List<Relationship_Parties__c> relationshipPartiesInsert = new List<Relationship_Parties__c>();
        List<Relationship_Parties__c> relationshipPartiesDelete = new List<Relationship_Parties__c>();

        //Reset error message.
        showError = true;
        
        //Loop through wrapper list.
        for(sObject_Scheduling_Occurences.RelationshipPartiesWrapper eachWrapper : relationshipParties_Wrapper)
        {
            //If selected
            if(eachWrapper.selected)
            {
                //One is selected at least.
                showError = false;
                
                if(!existingRelationshipSet.contains(eachWrapper.PartyId))
                {
                    //New Notification financialCovenant
                    Relationship_Parties__c relationshipPartyItem = new Relationship_Parties__c();
                    relationshipPartyItem.Margin_Ratchet__c = currentObjectId;
					if((Id)objectParentRecord[0].get('Facility_Tranche__c') != null)
                    {
                        relationshipPartyItem.Tranche_Party__c = eachWrapper.PartyId;
                    }
                    else if((Id)objectParentRecord[0].get('Facility__c') != null)
                    {
                        relationshipPartyItem.Facility_Party__c = eachWrapper.PartyId;
                    }
                    else if((Id)objectParentRecord[0].get('Agreement__c') != null)
                    {
                        relationshipPartyItem.Agreement_Party__c = eachWrapper.PartyId;
                    }
                    
                    //Add to list.
                    relationshipPartiesInsert.add(relationshipPartyItem);
                }
            }
            //If deselected
            else
            {
                if(existingRelationshipSet.contains(eachWrapper.PartyId))
                {
                    //Id of financialCovenant to delete.
                    Id relationshipPartyToDeleteId = (Id)partiesRelationshipParties.get(eachWrapper.PartyId);
                    
                    //Notification financialCovenant to delete.
                    Relationship_Parties__c realtionshipPartyItemToDelete = new Relationship_Parties__c(Id = relationshipPartyToDeleteId); 
                    
                    //Add to delete list.
                    relationshipPartiesDelete.add(realtionshipPartyItemToDelete);
                }
            }
        }
        
        
        //Execute changes.
        try 
        {
            //Insert new records.
            if(!relationshipPartiesInsert.isEmpty())
            {
                insert relationshipPartiesInsert;
            }
            
            //Delete deselected records.
            if(!relationshipPartiesDelete.isEmpty())
            {
                delete relationshipPartiesDelete;
            }
            
            //New Page Setup
            PageReference standardPage = new PageReference('/'+ currentObjectId); 
            standardPage.setRedirect(true);

            //Redirect.
            return standardPage;
        }
        catch(Exception e)
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }
          return null;
    }
}