/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 @author Peter Guest
 
*** CHANGE LOG ***
 
13/06/2017 - PG     - Removed some commented code (historic) from when we switched back to standard "Product" objects.
                    - Add logic for nulitple borrowers, handle deal parties on generation screen.
20/06/2017 - PG     - Added Condition Monitored By to controller for view.
                    - Block added from library when one of the deal parties does not have a "Condition Monitored By" specified.
                    - Fix issue were "Relationship__c" not pupoluting on the Agreement from matter realtionship.
27/06/2017 - PG     - Added logic to override CP and GC schedule fields from the Condition Templates.  Set all fileds to blank and Recurrence to 'Once Off'
01/07/2017 - PG     - Changed controller to rather use "RecordTypeId" in the "getFilterOptions" methods.  Was previously using 'Record Type Name'. Bug: W-001417
21/08/2017 - PG     - Added logic to exclude "Superceded" agreements when fetching the agreements.
22/08/2017 - PG     - Removed the logic to check if all the "condition monitored by" are specified.
                    - Added logic to ensure a "TA" participant is added to the deal before using the template functionality.
                    - Removed the "All" type from filtering.
                    - Set "Condition Precedent" as the default record type filter.
28/08/2017 - PG     - Updated error logic for when all templates are used on the Deal.
15/09/2017 - PG     - Replace "Superceded" with "Extension" in Code.
19/09/2017 - PG     - Added logic to populate the "Condition Template" field on inserted condition from a Template. Need it to tie back to Document Templates.
07/12/2017 - PG     - Added CONDITION_TYPES constant.
                    - Removed dependancy on condition types from helper class.  Used above constant instead.
08/12/2017 - PG     - Removed reference to "Condition_Helper.recordTypes()".
09/01/2017 - PG     - Changed Condition Template Recrd Type name to be a static list, instead of executing each time.
                    - Added logic to only add GC's from a template if a HotDocs Template existings.
22/01/2018 - TdB    - Default Frequency for Condition Precedent and Governance Check to null 
23/01/2018 - TdB    - Validate that atleast 1 Participant with roles TA/TM/SPV/Agency is added to Deal before adding Agreements
05/02/2018 - TdB    - Change Product functionality to use 3 the 3 new TMG Product Objects
05/02/2018 - PG     - Added logic to check the "Clause Origin" field when look if we should insert conditions from Library.
05/02/2018 - TdB	- Fix default Frequency On bulk edit load page to set to None
22/02/2018 - TdB    - Add functionality to set Agreement added from Library to True
01/08/2018 - TdB    - Remove commenetd out code. Merge conditionsToInsert add if statements
**/      
public class Matter_AgreementTemplate
{     
    /**
     * VARIABLES
    **/
    public String paramId { get; set; }
    public String paramId2 { get; set; }
    public advpm__Matter__c matter { get; set; }
    public Boolean pageHasError { get; set; }
    public List<ProductAgreementWrapper> productAgreementsWrapper { get; set; }
    public List<Agreement__c> agreements { get; set; }
    public List<Condition__c> conditions { get; set; }
    public List<AgreementConditionWrapper> agreementConditionWrappers { get; set; } //The main wrapper list.
    public Condition__c bulkEditCondition  { get; set; } //Used just for the controls / field inputs on the bulk edit.
    public String selectedFilterRecordType { get; set; } //Used for condition filtering control.
    public Boolean saveHasError { get; set; }
    public List<ConditionSaveWrapper> conditionSaveWrappers { get; set; } 
    public List<DealPartyWrapper> dealPartiesWrapper { get; set; }
    public List<advpm__Participant__c> dealParticipants { get; set; }
    public Boolean showAdvancedControls { get; set; }
    public Boolean showNoControls { get; set; }
    public Boolean showOtherDate { get; set; }
    private List<Agreement__c> matterExistingAgreements { get; set; } //Used to store existign agreements to check which templates to exlude from create page.
    private static final Map<String, RecordTypeInfo> CONDITION_TYPES = new Map<String, RecordTypeInfo>(Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName()); 
    private static final Map<Id, RecordTypeInfo> TEMPLATE_TYPE_IDS = new Map<Id, RecordTypeInfo>(Condition_Template__c.sObjectType.getDescribe().getRecordTypeInfosById());

    
    /**
     * CONSTRUCTOR
    **/
    public Matter_AgreementTemplate() 
    {
        System.debug('### Matter_AgreementTemplate');

        //Default values.
        pageHasError = false;
        productAgreementsWrapper = new List<ProductAgreementWrapper>(); 
        agreementConditionWrappers = new List<AgreementConditionWrapper>();
        dealPartiesWrapper = new List<DealPartyWrapper>();
        selectedFilterRecordType = CONDITION_TYPES.get('Condition Precedent').getRecordTypeId();
        saveHasError = false;
        conditionSaveWrappers = new List<ConditionSaveWrapper>();
        dealParticipants = new List<advpm__Participant__c>();
        showAdvancedControls = false;
        showOtherDate = false;
        matterExistingAgreements = new List<Agreement__c>();
        
        //Get record type id for a "Information Undertaking", used in bulk edit control.  Shows all recurrences.
        Id bulkEditConditionRecordType = CONDITION_TYPES.get('Condition Precedent').getRecordTypeId();
        bulkEditCondition = new Condition__c(RecordTypeId = bulkEditConditionRecordType); 
       
        //Get passed matter id from URL.
        paramId = ApexPages.currentPage().getParameters().get('Id'); //Matter Id
        
        //Get passed agreement id from URL
        paramId2 = ApexPages.currentPage().getParameters().get('agreementId'); //Agreement Id
        
        //Make sure a valid id was passed.
        if(String.isBlank(paramId) && String.isBlank(paramId2))
        {
            //Set error variable.
            pageHasError = true;
            
            //Show page error.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'Requested page is not valid due to an BLANK "id" in the URL. (I)  Please contact your system administrator.'));
        }
        else
        {
            //Launched from deal, because Agreement Id is null.
            if(paramId2 == null)
            {
                //Get matter object we working with.
                List<advpm__Matter__c> matterList = [
                    SELECT 
                        Id,
                        Name,
                    	TMG_Product_Level_3__c,
                    	TMG_Product_Level_3__r.Name,
                        advpm__Primary_Account__c
                    FROM advpm__Matter__c
                    WHERE 
                        Id = :paramId
                ];
                
                //If we got records back.
                if(!matterList.isEmpty())
                {
                    //Set the matter in context.
                    matter = matterList[0]; 
                    
                    //Get a list of all the "Deal Parties" on the deal for type borrower.
                    List<Deal_Party__c> dealParties = [
                        SELECT 
                            Id,
                            Deal__c,
                            Relationship__c,
                            Party_Type__c,
                            Conditions_Monitored_By__c
                        FROM Deal_Party__c
                        WHERE  
                            Deal__c = :paramId 
                            AND Party_Type__c = 'Borrower' 
                    ];                 
                    
                    //Populate the party wrapper list.
                    if(dealParties.isEmpty())
                    {
                        //Set error variable.
                        pageHasError = true;
                        
                        //Show page error.
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'Please ensure there is a minimum of one "Borrower" specified on the Deal.'));
                    }
                    else
                    {
                        //Populate the deal parties wrapper.
                        for(Deal_Party__c dealParty : dealParties)
                        {
                            dealPartiesWrapper.add(new DealPartyWrapper(dealParty));
                        }
                    }

                    //Get a list of all the participants on the deal.
                    dealParticipants = [
                        SELECT
                            Id,
                            advpm__Role__c,
                            advpm__Matter__c
                        FROM advpm__Participant__c
                        WHERE
                            advpm__Matter__c = :paramId
                            AND advpm__Staff__c != null
                    ];

                    //Make sure the participants are correct, else show a page message. 
                    if(dealParticipants.isEmpty())
                    {
                        //Set error variable.
                        pageHasError = true;
                        
                        //Show page error.
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'Please ensure there is at least one Participant specified on the Deal.'));
                    }

                    //Get a list of existing agreement templates used on this matter.
                    List<Agreement__c> matterExistingAgreements = [
                        SELECT
                            Id,
                            Agreement_Template__c,
                            Matter_Deal__c
                        FROM Agreement__c
                        WHERE
                            Matter_Deal__c = :matter.Id
                            AND Agreement_Template__c != null
                    ];

                    Set<Id> agreementTemplateIds = new Set<Id>();

                    //Existing agreement to build existing templates check.
                    if(!matterExistingAgreements.isEmpty())
                    {
                        for(Agreement__c matterAgreement : matterExistingAgreements)
                        {
                            //Add to set.
                            agreementTemplateIds.add(matterAgreement.Agreement_Template__c);
                        }
                    }
                    
                    //Get a list of all agreement templates for the deal product on matter.
                    List<Product_Agreement__c> productAgreements = [
                        SELECT 
                            Id,
                            Name,
                            TMG_Product_Level_3__c,
                            Agreement_Template__c,
                            Agreement_Template__r.Name,
                            Agreement_Template__r.Description__c
                        FROM Product_Agreement__c 
                        WHERE 
                            TMG_Product_Level_3__c = :matter.TMG_Product_Level_3__c AND 
                            Agreement_Template__c NOT IN :agreementTemplateIds
                    ];
                    
                    //Did we get templates back?
                    if(!productAgreements.isEmpty())
                    {
                        //Loop through product agreement records.
                        for(Product_Agreement__c productAgreement : productAgreements)
                        {
                            //Add to wrapper list.
                            productAgreementsWrapper.add(new ProductAgreementWrapper(productAgreement));
                        }
                    }
                    else
                    {
                        if(agreementTemplateIds.isEmpty())
                        {
                            //Set error variable.
                            pageHasError = true;
                            
                            //Show page error.
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'There are no Agreement Templates defined for the Deal Product.')); 
                        }
                    }
                }
                else
                {
                    //Set error variable.
                    pageHasError = true;
                    
                    //Show page error.
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'Requested page is not valid due to an INVALID "id" in the URL. (M)  Please contact your system administrator.'));
                }
            }
        }
    }
    
    /**
     * Command  button action on step 1.
    **/
    public PageReference actionCreateAgreements()
    {
        //Blank sets and lists.
        List<Agreement__c> agreementsToInsert = new List<Agreement__c>();
        Set<Id> agreementTemplateIds = new Set<Id>();
        List<Agreement_Condition__c> agreementConditions = new List<Agreement_Condition__c>();
        List<Condition__c> conditionsToInsert = new List<Condition__c>();
        Set<Id> selectedDealPartyIds = new Set<Id>();
        List<Agreement_Party__c> agreementPartiesToInsert = new List<Agreement_Party__c>();
        List<Condition_Party__c> conditionPartiesToInsert = new List<Condition_Party__c>();
        
        //Loop through the selected deal parties
        for(DealPartyWrapper wrapperItem : dealPartiesWrapper)
        {
            //Is selected?
            if(wrapperItem.selected == true)
            {
                //Add to ID list.
                selectedDealPartyIds.add(wrapperItem.record.Id);
            }
        }
        
        //Make sure a "borrower" was selected.
        if(selectedDealPartyIds.isEmpty())
        {
            //Set error variable.
            pageHasError = true;
            
            //Show page error.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'Please select at least one Deal Party.'));
            
            //Show error.       
            return null;
        }
        
        //Loops through wrapper to get "selected" items.
        for(ProductAgreementWrapper wrapperRecord : productAgreementsWrapper)
        {            
            //Agreement selected.
            if(wrapperRecord.selected == true) 
            {
                //New agreement object.
                Agreement__c agreementRecord = new Agreement__c();
                agreementRecord.Name = wrapperRecord.record.Agreement_Template__r.Name;
                agreementRecord.Agreement_Description__c = wrapperRecord.record.Agreement_Template__r.Description__c;
                agreementRecord.Agreement_Template__c = wrapperRecord.record.Agreement_Template__c;
                agreementRecord.TMG_Product_Level_3__c = matter.TMG_Product_Level_3__c;
                agreementRecord.Matter_Deal__c = matter.Id;
                agreementRecord.Client_Name__c = matter.advpm__Primary_Account__c; //Relationship
                agreementRecord.Agreement_Type__c = wrapperRecord.record.Id;
                agreementRecord.Agreement_Added_From_Libary__c = True;
                
                //Add agreement object to insert list.
                agreementsToInsert.add(agreementRecord);
                
                //Add agreement template id to set.
                agreementTemplateIds.add(wrapperRecord.record.Agreement_Template__c);
            }
        }
        
        //Anything to insert?
        if(agreementsToInsert.size() > 0)
        {
            //Database savepoint
            Savepoint dbSavePoint = Database.setSavepoint();

            try
            {
                //Insert agreement records.
                insert agreementsToInsert; 
                
                //Build up the Agreement Parties for the agreements selected.
                for(Agreement__c agreementInserted : agreementsToInsert)
                {
                    for(Id dealPartyId : selectedDealPartyIds)
                    {
                        //Add to insert list.
                        agreementPartiesToInsert.add(new Agreement_Party__c(Deal_Party__c = dealPartyId, Agreement__c = agreementInserted.Id));
                    }
                }
                
                //Insert the agreement parties.
                insert agreementPartiesToInsert;
                
                //Clone the list for easy of use in next step.
                agreements = agreementsToInsert.deepClone(true, true, true);
                
                //Get a list of all condition templates for the agreements templates used.
                agreementConditions = [
                    SELECT
                        Id,
                        Name,
                        Agreement_Template__c,
                        Agreement_Template__r.HotDocs_Template_ID__c,
                        Agreement_Template__r.Clause_Origin__c,
                        Condition_Template__c,
                        Condition_Template__r.Name,
                        Condition_Template__r.Recurrence__c,
                        Condition_Template__r.Date__c,
                        Condition_Template__r.Number_of_Days__c,
                        Condition_Template__r.Days__c,
                        Condition_Template__r.Clause__c,
                        Condition_Template__r.RecordTypeId
                    FROM Agreement_Condition__c
                    WHERE 
                        Agreement_Template__c IN :agreementTemplateIds
                    ORDER BY 
                        Condition_Template__r.RecordType.Name
                ];
                
                //Loop through each agreement and determine which conditions belong to it.
                for(Agreement__c agreement : agreementsToInsert)
                {
                    //Loop through each agreement conditions  
                    for(Agreement_Condition__c agreementCondition : agreementConditions)
                    {                        
                        if(agreementCondition.Agreement_Template__c == agreement.Agreement_Template__c)
                        {
                            //New condition object.
                            Condition__c condition          = new Condition__c();
                            condition.Agreement__c          = agreement.Id;
                            condition.Matter__c             = matter.Id;
                            
                            //Detemine condition record type id based in condition template record type name
                            String conditionTemplateRecordTypeName = TEMPLATE_TYPE_IDS.get(agreementCondition.Condition_Template__r.RecordTypeId).getName();

                            condition.RecordTypeId          = CONDITION_TYPES.get(conditionTemplateRecordTypeName).getRecordTypeId();
                            
                            //Other template fields.
                            condition.Name                  = agreementCondition.Condition_Template__r.Name;
                            condition.Clause__c             = agreementCondition.Condition_Template__r.Clause__c;
                            condition.Condition_Template__c = agreementCondition.Condition_Template__c;
                            condition.Active__c             = false;
                            
                            //Override template schedule values incase data is bad in Templates.
                            if(conditionTemplateRecordTypeName == 'Condition Precedent' || conditionTemplateRecordTypeName == 'Governance Check')
                            {
                                condition.Recurrence__c         = null; 
                                condition.Date__c               = null;
                                condition.Number_of_Days__c     = null;
                                condition.Days__c               = null;
                            }
                            else
                            {
                                condition.Recurrence__c         = agreementCondition.Condition_Template__r.Recurrence__c;
                                condition.Date__c               = agreementCondition.Condition_Template__r.Date__c;
                                condition.Number_of_Days__c     = agreementCondition.Condition_Template__r.Number_of_Days__c;
                                condition.Days__c               = agreementCondition.Condition_Template__r.Days__c;
                            }

                            //Add all condition types if HotDocs Template is not specified on parent Template.
                            //If there is a HotDocs Template, only add GC's as rest will come from HotDocs Template.
                            if((agreementCondition.Agreement_Template__r.Clause_Origin__c == null || agreementCondition.Agreement_Template__r.Clause_Origin__c == 'Salesforce') || (agreementCondition.Agreement_Template__r.Clause_Origin__c == 'HotDocs' && condition.RecordTypeId == CONDITION_TYPES.get('Governance Check').getRecordTypeId() ))
                            {                        
                                //Add condition object to insert list.
                                conditionsToInsert.add(condition);
                            }
                        }
                    }
                }
                
                //Insert condition records.
                insert conditionsToInsert;
                
                //Logic to build up the condition parties to be inserted,
                for(Condition__c conditionToInsert : conditionsToInsert)
                {
                    //Loop throuhg agreement paries.
                    for(Agreement_Party__c agreementPartyToInsert : agreementPartiesToInsert)
                    {
                        if(conditionToInsert.Agreement__c == agreementPartyToInsert.Agreement__c)
                        {
                            //New Condition Party Object
                            Condition_Party__c conditionParty = new Condition_Party__c();
                            conditionParty.Agreement_Party__c = agreementPartyToInsert.Id;
                            conditionParty.Condition__c = conditionToInsert.Id;
                            
                            //Add to list
                            conditionPartiesToInsert.add(conditionParty);
                        }
                    }
                }
                
                //Make sure we have something to insert.
                if(!conditionPartiesToInsert.isEmpty())
                {
                    insert conditionPartiesToInsert;
                }
                
                //Clone the list for easy of use in next step.
                conditions = conditionsToInsert.deepClone(true, true, true);
                
                //Move to the bulk edit screen / page
                PageReference nextPage = Page.Matter_AgreementTemplateEdit;
                nextPage.getParameters().put('id', paramId);
                return nextPage; 

            }
            catch(Exception e)
            {
                //Roll back database DML.
                Database.rollback(dbSavePoint);
                
                //Set error variable.
                pageHasError = true;
                
                //Apex error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'The was an error processing the request. Error Message: '+e.getMessage()));
                 
                //Default return.
                return null;
            }
        }
        else
        {
            //Set error variable.
            pageHasError = true;
            
            //Show page error.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'You have not selected any agreement templates to use.'));
            
            //Default return.
            return null;
        }
        
        //Default return.
        return null;
    }
    
    /**
     * Step 2 action for detemining if we need to get records or just use existing.
    **/
    
    public PageReference actionEntryHandler()
    {
        //If these are null, then we need to fetch the records because they come in at Step 2. 
        if(agreements == null || conditions == null)
        {
            //Blank set.
            Set<Id> agreementIds = new Set<Id>();
            
            //Entered page via Deal.
            if(paramId2 == null && paramId != null)
            {
                //Agreements for Deal. 
                agreements = [
                    SELECT
                        Id,
                        Name,
                        Agreement_Description__c
                    FROM Agreement__c
                    WHERE 
                        Matter_Deal__c = :paramId
                        AND Agreement_Status__c != 'Extension'
                ];
            }
            
            //Entered page via Agreemnt.
            if(paramId2 != null && paramId == null)
            {
                //Agreements for Deal. 
                agreements = [
                    SELECT
                        Id,
                        Name,
                        Agreement_Description__c
                    FROM Agreement__c
                    WHERE 
                        Id = :paramId2
                        AND Agreement_Status__c != 'Extension' 
                ];
            }
            
            //Make sure we got agreements.
            if(agreements.size() > 0)
            {
                //Agreement ids set.
                agreementIds = (new Map<Id,Agreement__c>(agreements)).keySet();
                
                //Conditions for Agreements.
                conditions = [
                    SELECT
                        Id,
                        Name,
                        Active__c,
                        Recurrence__c,
                        Date__c,
                        Number_of_Days__c,
                        Days__c,
                        Clause__c,
                        RecordTypeId,
                        RecordType.Name,
                        Other_Relative_Date__c,
                        Due_Date__c,
                        Agreement__c
                    FROM Condition__c
                    WHERE 
                        Agreement__c IN :agreementIds
                    ORDER BY 
                        RecordType.Name
                ];                
                
                //Make sure we got conditions.
                if(conditions.isEmpty())
                {
                    //Set error variable.
                    pageHasError = true;
            
                    //Show page error.
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'There are no Conditions associated with any Agreements.'));
                    
                    //Default return.
                    return null;
                }
            }
            else
            {
                //Set error variable.
                pageHasError = true;
            
                //Show page error.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'There are no Agreements associated with this Deal.'));
                
                //Default return.
                return null;
            }
        }

        //Build the main wrapper list by looping through all agreements and conditions.
        for(Agreement__c agreement : agreements)
        {
            List<ConditionWrapper> conditionWrappers = new List<ConditionWrapper>();
            
            //Loop through conditions.
            for(Condition__c condition : conditions)
            {
                //Is for this agreement.
                if(condition.Agreement__c == agreement.Id)
                {                    
                    //Add to condition wrapper list.
                    conditionWrappers.add(new ConditionWrapper(condition));
                }
            }
            
            //Add to main / final wrapper
            agreementConditionWrappers.add(new AgreementConditionWrapper(agreement, conditionWrappers));
        }
        
        //Default return.
        return null;
    }
    
    /**
     * Page action to bulk update conditions. 
    **/
    public PageReference actionBulkUpdate()  
    { 
        //Loop through wrapper list.
        for(AgreementConditionWrapper agreementWrapper : agreementConditionWrappers)
        {
            //Loop through wrapped conditions.
            for(ConditionWrapper conditionWrapper : agreementWrapper.conditions)
            {
                //Is is selected?
                if(conditionWrapper.selected == true)
                {
                     //Handle "CP" and "GC" diferrently
                    if(conditionWrapper.condition.RecordType.Name == 'Governance Check' || conditionWrapper.condition.RecordType.Name == 'Condition Precedent')
                    {
                        //Update conditions with "bulk edit" values.
                        if(showNoControls == False)
                        {
                            conditionWrapper.condition.Recurrence__c = bulkEditCondition.Recurrence__c;
                            conditionWrapper.condition.Due_Date__c   = null;
                        }
                        else
                        {
                            conditionWrapper.condition.Recurrence__c = bulkEditCondition.Recurrence__c;
                            conditionWrapper.condition.Due_Date__c   = bulkEditCondition.Due_Date__c;
                        }
                        
                        
                        conditionWrapper.condition.Number_Of_Days__c        = null;
                        conditionWrapper.condition.Days__c                  = null;
                        conditionWrapper.condition.Date__c                  = null;
                        conditionWrapper.condition.Other_Relative_Date__c   = null;
                    }
                    else
                    {
                        //Update conditions with "bulk edit" values.
                        conditionWrapper.condition.Recurrence__c            = bulkEditCondition.Recurrence__c;
                        conditionWrapper.condition.Due_Date__c              = bulkEditCondition.Due_Date__c;
                        conditionWrapper.condition.Number_Of_Days__c        = bulkEditCondition.Number_Of_Days__c;
                        conditionWrapper.condition.Days__c                  = bulkEditCondition.Days__c;
                        conditionWrapper.condition.Date__c                  = bulkEditCondition.Date__c;
                        conditionWrapper.condition.Other_Relative_Date__c   = bulkEditCondition.Other_Relative_Date__c;
                    }
                    
                    //Clear selected flag.
                    conditionWrapper.selected = false;
                }
            }
        }
        
        //Default return.
        return null;
    }
    
    /**
     * actionSaveConditions - Saves the updated conditions.
    **/
    public PageReference actionSaveConditions() 
    { 
        System.debug('### Matter_AgreementTemplate : actionSaveConditions : agreementConditionWrappers : '+agreementConditionWrappers);
        
        //Blank List
        List<Condition__c> conditionsToUpdate = new List<Condition__c>();
        
        //Loop through wrapper list.
        for(AgreementConditionWrapper agreementWrapper : agreementConditionWrappers)
        {            
            //Loop through wrapped conditions.
            for(ConditionWrapper conditionWrapper : agreementWrapper.conditions)
            {
                conditionsToUpdate.add(conditionWrapper.condition);
            }
        }
        
        //If we have conditions to update.
        if(!conditionsToUpdate.isEmpty())
        {
            System.debug('### Matter_AgreementTemplate : actionSaveConditions : IF');
            
            //convert List to Map for future reference in error handling.
            Map<Id,Condition__c> conditionsToUpdateMap = new Map<Id, Condition__c>(conditionsToUpdate);
            
            //Update records an allow partial processing.
            Database.SaveResult[] saveResults = Database.update(conditionsToUpdate, false);
            
            //Loop through the save results.
            for(Integer i=0; i < saveResults.size(); i++) 
            {                
                //Was the result success for record?
                if(!saveResults.get(i).isSuccess())
                {                    
                    //There was a problem saving all records.   
                    saveHasError = true;
                    
                    //New ConditionSaveWrapper object.
                    ConditionSaveWrapper saveWrapper = new ConditionSaveWrapper(); 
                    
                    //Set condition in wrapper item.
                    saveWrapper.condition = conditionsToUpdateMap.get(conditionsToUpdate.get(i).Id);
                    
                    //List to hold error message for wrapepr item.
                    List<String> errorMessages = new List<String>();
                    
                    //Loop through errors.
                    for(Database.Error error : saveResults.get(i).getErrors())
                    {
                        //Add to error list.
                        errorMessages.add(error.getMessage());
                    }
                    
                    //Set errors in wrapper item.
                    saveWrapper.errors = errorMessages;
                    
                    //Add to wrapper list.
                    conditionSaveWrappers.add(saveWrapper);
                }
            }
            
            //Route user according to the database results.
            if(saveHasError == true)
            {
                //Move to "detailed" error page.
                return Page.Matter_AgreementTemplateResults;
            }
            else
            {
                //Redirect back to matter/deal record.
                return actionCancel();
            }
        }
        
        //Default return.
        return null;
    }
    
    /**
     * actionFilterConditions - Changes the Step 2 control inputs.
    **/
    public PageReference actionFilterConditions()
    {
        System.debug('### Matter_AgreementTemplate : filterPageConditions');
        
        //Create a fresh bulk condition input control.
        bulkEditCondition = new Condition__c();
        bulkEditCondition.RecordTypeId = selectedFilterRecordType;
        bulkEditCondition.Recurrence__c = 'Once Off';
        showOtherDate = false;

        //Detemine of if we need to hide some fields due to the record type.
        //if(selectedFilterRecordType == Condition_Helper.conditionTypes.get('Condition Precedent').getRecordTypeId() || selectedFilterRecordType == Condition_Helper.conditionTypes.get('Governance Check').getRecordTypeId())
        //{
            showAdvancedControls = false;
        //}
        
        //Default return.
        return null;
    }

    /**
     * actionFilterConditions - Changes the Step 2 control inputs.
    **/
    public PageReference actionFilterRecurrence()
    {
        System.debug('### Matter_AgreementTemplate : actionFilterRecurrence');  
        System.debug('bulkEditCondition.Recurrence__c : ' + bulkEditCondition.Recurrence__c);

        if(bulkEditCondition.Recurrence__c != 'Once Off' )
        {
            showAdvancedControls = true;
        }
        else
        {
            showAdvancedControls = false;
        } 
        
        System.debug('bulkEditCondition.Recurrence__c : ' + bulkEditCondition.Recurrence__c);
        
        if(bulkEditCondition.Recurrence__c == 'None' || bulkEditCondition.Recurrence__c == null)
        {
            showNoControls = False;
        }
        else
        {
            showNoControls = True;
        }
        
        
        //Default return.
        return null;
    }

    /**
     * actionFilterConditions - Changes the Step 2 control inputs.
    **/
    public PageReference actionFilterDate()
    {
        System.debug('### Matter_AgreementTemplate : actionFilterDate');  

        if(bulkEditCondition.Date__c == 'Other')
        {
            showOtherDate = true;
        }
        else
        {
            showOtherDate = false;
        }
        
        //Default return.
        return null;
    }
    
    /**
     * Page action to return to Deal.
    **/
    public PageReference actionCancel() 
    { 
        //Matter redirect.
        if(paramId != null && paramId2 == null)
        {
            PageReference page = new PageReference('/'+paramId);
            page.setRedirect(true);
            return page;
        }
        
        //Agreement redirect.
        if(paramId2 != null && paramId == null)
        {
            PageReference page = new PageReference('/'+paramId2);
            page.setRedirect(true);
            return page;
        }
        
        //Default return.
        return null;
    }
    
    /**
     * getFilterOptions - Builds a select list option based on record types.
    **/
    public List<SelectOption> getFilterOptions()  
    {
        System.debug('### Matter_AgreementTemplate : getFilterOptions');
        
        //Blank list.
        List<SelectOption> selectOptions = new List<SelectOption>();
        
        //Iterate the map.
        for(String key : CONDITION_TYPES.keySet())
        {
            if(key != 'Master')
            {
                //Add to optiosn list.
                selectOptions.add(new SelectOption(CONDITION_TYPES.get(key).getRecordTypeId(), key)); 
            }
        }
        
        //Return options.
        return selectOptions;
    }

    /**
     * actionLoadValidation - Checks the availble templates for the deal.
    **/
    public PageReference actionLoadValidation()
    {
        //Blank values.
        Set<Id> agreementTemplateIds = new Set<Id>();

        //Default value
        Boolean isValid = false;

        //Get a list of existing agreement templates used on this matter.
        List<Agreement__c> matterExistingAgreements = [
            SELECT
                Id,
                Agreement_Template__c,
                Matter_Deal__c
            FROM Agreement__c
            WHERE
                Matter_Deal__c = :matter.Id
                AND Agreement_Template__c != null
        ];

        //Existing agreement to build existing templates check.
        if(!matterExistingAgreements.isEmpty())
        {
            for(Agreement__c matterAgreement : matterExistingAgreements)
            {
                //Add to set.
                agreementTemplateIds.add(matterAgreement.Agreement_Template__c);
            }
        }

        //Loop through product agreements and make sure they not all used.
        for(ProductAgreementWrapper productAgreementWrapper : productAgreementsWrapper)
        {
            if(!agreementTemplateIds.contains(productAgreementWrapper.record.Agreement_Template__c))
            {
               isValid = true; 
            }
        }

        if(isValid == false)
        {
            //Set error variable.
            pageHasError = true;
            
            //Show page error.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'All agreements templates for this Deal product have been used.  Please <a href="/apex/Matter_AgreementTemplateEdit?id='+matter.Id+'">click here</a> or use the "Bulk Edit Conditions" button on the Deal.'));
        }

        //Default return.
        return null;
    }
    
 // SEARCH FOR KNOWLEDGE AGREEMENT   --- SEAN 1/10/2018
    
     Public String AgreementSearch {get;set;}   
     public List<ProductAgreementTemplateWrapper > productAgreementsWrapperSearch { get; set; }   
     
     public List<Agreement_Template__c> Lst_agreementRecord { get; set; } 
     
     Public List<Agreement__c> lst_Agreement {get;set;}
     
     Public void LoadAgreements(){
     
         lst_Agreement = [Select Name,TMG_Product_Level_3__c,Agreement_Type__c,Agreement_Template__c From Agreement__c Where Matter_Deal__c =:matter.Id];
                  
     }
     
     
     public pagereference Searchagreement(){
 
        
            String SearchTerm = '%'+ AgreementSearch+ '%';
            Set<String> Set_String;
            List<Product_Agreement__c> lst_ProductAgreement;
            
           if(SearchTerm.length()>1){
               
               lst_ProductAgreement = [Select Agreement_Template__c,TMG_Product_Level_3__c From Product_Agreement__c Where TMG_Product_Level_3__c =: matter.TMG_Product_Level_3__c];
               
               Set_String = new Set<String>();
               
               for(Product_Agreement__c p:lst_ProductAgreement){
                   Set_String.add(p.Agreement_Template__c);
               }
               
               Lst_agreementRecord = [Select Name,Description__c From Agreement_Template__c Where Name Like:SearchTerm AND id in:Set_String];
                
                system.debug('**Search*'+Lst_agreementRecord +'*****'+AgreementSearch);
            
                productAgreementsWrapperSearch = new List<ProductAgreementTemplateWrapper> ();
                
                for(Agreement_Template__c l: Lst_agreementRecord){                          
                    ProductAgreementTemplateWrapper ProductAgreement = new ProductAgreementTemplateWrapper();
                    ProductAgreement.record = l;
                    productAgreementsWrapperSearch.Add(ProductAgreement);
                }
            }
            
         return null;
         
     }     
  
  Public Pagereference GenerateSearchAgreements(){
            
            List<Agreement__c> agreementsToInsert = new List<Agreement__c>();
            
            
            List<Product_Agreement__c> lst_ProductAgreement;
            
            Set<String> Set_Prod = new Set<String>();
            Map<String,String> Map_Prod = new Map<String,String>();
            Map<String,String> Map_Type = new Map<String,String>();
            
            
            for(ProductAgreementTemplateWrapper wrapperRecord : productAgreementsWrapperSearch)
                {            
                    //Agreement selected.
                    if(wrapperRecord.selected == true) 
                    {
                        Set_Prod.Add(wrapperRecord.record.id);
                    }
                }    
            
            lst_ProductAgreement = [Select Agreement_Template__c,id,TMG_Product_Level_3__c from Product_Agreement__c Where Agreement_Template__c in: Set_Prod];
            
            for(Product_Agreement__c p:lst_ProductAgreement){ 
                Map_Prod.Put(p.Agreement_Template__c,p.TMG_Product_Level_3__c);
                Map_Type.Put(p.Agreement_Template__c,p.id);
            }        
              
            for(ProductAgreementTemplateWrapper wrapperRecord : productAgreementsWrapperSearch)
                {            
                    //Agreement selected.
                    if(wrapperRecord.selected == true) 
                    {
                        //New agreement object.
                        Agreement__c agreementRecord = new Agreement__c();
                        agreementRecord.Name = wrapperRecord.record.Name;
                        agreementRecord.Agreement_Description__c = wrapperRecord.record.Description__c;
                        agreementRecord.Agreement_Template__c = wrapperRecord.record.id;
                        agreementRecord.TMG_Product_Level_3__c = Map_Prod.get(wrapperRecord.record.Id);
                        agreementRecord.Matter_Deal__c = matter.Id;
                        agreementRecord.Client_Name__c = matter.advpm__Primary_Account__c; //Relationship
                        agreementRecord.Agreement_Type__c = Map_Type.get(wrapperRecord.record.Id);
                        
                        //Add agreement object to insert list.
                        agreementsToInsert.add(agreementRecord);
                    }
             }    
           try
            {
                //Insert agreement records.
                insert agreementsToInsert; 
                
            }
           catch(Exception e){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'The was an error processing the request. Error Message: '+e.getMessage()));
                 
                //Default return.
                return null;
           
           }    
  
      return new pagereference('/apex/Matter_AgreementTemplateSearch?Id='+matter.Id);
  }
  
  
   
   /**
     * Step 1 Wrapper Class
    **/
    
    public class ProductAgreementTemplateWrapper 
    { 
        public Agreement_Template__c record { get; set; }
        public Boolean selected { get; set; }
    }  
    
    /**
     * 
    **/
    public class ConditionSaveWrapper
    {
        public Condition__c condition { get; set; }
        public List<String> errors { get; set; }
        
        /**
        * CONSTRUCTOR
        **/
        public ConditionSaveWrapper()
        {
            //Blank
        }
    }
    
    /**
     * Step 2 - Agreement Wrapper Class
    **/
    public class AgreementConditionWrapper 
    {
         
         public Agreement__c agreement { get; set; }
         public List<ConditionWrapper> conditions { get; set; }
         
         /**
        * CONSTRUCTOR
        **/
        public AgreementConditionWrapper(Agreement__c inputObject1, List<ConditionWrapper> inputObjects2)
        {
            agreement = inputObject1;
            conditions = inputObjects2;
        }
     }
     
    /**
     * Step 2 - Condition Wrapper Class
    **/
    public class ConditionWrapper 
    {
        
        public Boolean selected { get; set; }
        public Condition__c condition { get; set; }
        
        public ConditionWrapper(Condition__c inputObject)
        {
            condition = inputObject;
            selected = false;
        }
    }
    
    /**
     * Step 1 Wrapper Class
    **/
    public class ProductAgreementWrapper 
    {
        
        public Product_Agreement__c record { get; set; }
        public Boolean selected { get; set; }
        
        /**
        * CONSTRUCTOR
        **/
        public ProductAgreementWrapper(Product_Agreement__c inputObject)
        {
            record = inputObject;
            selected = true;
        }
    }
    
    /**
     * Step 1 Wrapper Class
    **/
    public class DealPartyWrapper
    {
        public Boolean selected { get; set; }
        public Deal_Party__c record { get; set; }
        
        /**
        * CONSTRUCTOR
        **/
        public DealPartyWrapper(Deal_Party__c inputObject)
        {
            record = inputObject;
            selected = true;
        }
    }
}