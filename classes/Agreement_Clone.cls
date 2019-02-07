/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 21/06/2017 - PG    - Created Class.
 28/06/2017 - DF    - Creating Test Class
 28/09/2017 - PG    - Added "AGREEMENT_TYPES" map for easy reference.
 13/03/2018 - TdB 	- Add checkRecursion.stopRecursion(); to Stop Agreement Trigger from Firing

**/ 
public class Agreement_Clone 
{
    /**
    * Variables
    **/
    public String agreementId { get; set; }
    public Agreement__c agreement  { get; set; }
    public Agreement__c clonedAgreement { get; set; } 
    public Boolean showError { get; set; }
    public static final Map<String, RecordTypeInfo> AGREEMENT_TYPES = new Map<String, RecordTypeInfo>(Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName());
    
    /**
    * Constructor
    **/
    public Agreement_Clone()
    {
        //Default values.
        showError = false;
        agreement = null;
        
        //Get passed matter id.
        agreementId = ApexPages.currentPage().getParameters().get('agreementId');
        
        //Make sure ID is not blank.
        if(String.isBlank(agreementId))
        {
            //Set error.
            showError = true;
           
            //Show page error.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'Unfortunately there is a technical issue with the requested action. <br /><br /><b>Error:</b> Invalid agreement ID.'));
        }
        else
        {
            //Get all clonable fields.
            String soqlQuery = CloudSmiths_Utils.getCreatableFieldsSOQL('Agreement__c','id=\''+agreementId+'\''); 
            
            //Execute query.
            agreement = (Agreement__c)Database.query(soqlQuery);
            
            //If we got a matter.
            if(agreement != null)
            {
                //Clone it.
                clonedAgreement = agreement.clone(false, true);
                clonedAgreement.RecordTypeId = AGREEMENT_TYPES.get('Agreement').getRecordTypeId();
                clonedAgreement.Agreement_Status__c = '';
                clonedAgreement.Last_HotDocs_Answer_Set_ID__c = null;
            }
            else 
            {
                //Set error.
                showError = true;
               
                //Show page error.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'Unfortunately there is a technical issue with the requested action. <br /><br /><b>Error:</b> Invalid agreement.'));
            }
        }
    }
    
    /**
    * Action - cloneAgreement
    **/
    public PageReference cloneAgreement()
    {
        checkRecursion.stopRecursion();
        
        //Blank vars.
        List<Agreement_Party__c> agreementParties = new List<Agreement_Party__c>();
        List<Condition__c> conditions = new List<Condition__c>();
        List<Condition_Party__c> conditionParties = new List<Condition_Party__c>();
        //List<Margin_Ratchet__c> marginRatchetsList = new List<Margin_Ratchet__c>();
        List<Facility__c> facilitiesList = new List<Facility__c>();
        //List<Facility_Tranche__c> facilityTrancehesList = new List<Facility_Tranche__c>();
        //List<Trigger__c> triggerList = new List<Trigger__c>();
        
        //Wrapper
        List<ConditionWrapper> conditionWrappers = new List<ConditionWrapper>();
        List<FacilityWrapper> facilityWrappers = new List<FacilityWrapper>();
        
        //Cloned
        List<Condition__c> clonedConditions = new List<Condition__c>();
        Map<String, ConditionWrapper> wrapperMap = new Map<String, ConditionWrapper>();
        List<Condition_Party__c> clonedConditionParties = new List<Condition_Party__c>();
        List<Facility__c> clonedFacilities =  new List<Facility__c>();
        
        Map<String, FacilityWrapper> facility_wrapperMap = new Map<String, FacilityWrapper>();
        List<Facility_Party__c> clonedFacilityParties = new List<Facility_Party__c>();
        
        //Database savepoint
        Savepoint dbSavePoint = Database.setSavepoint();
        
        try
        {
            //Insert cloned agreement.
            insert clonedAgreement;
            
            /**
            * AGREEMENT PARTY
            **/
            //Get all clonable fields.
            String soqlQuery = CloudSmiths_Utils.getCreatableFieldsSOQL('Agreement_Party__c','Agreement__c=\''+agreementId+'\'');
            
            //Execute query.
            agreementParties = (List<Agreement_Party__c>)Database.query(soqlQuery);
            
            //Anything to process.
            if(!agreementParties.isEmpty())
            {
                //Clone list.
                List<Agreement_Party__c> clonedAgreementParties = agreementParties.deepClone(false);
                
                //Loop through records an update parent id.
                for(Agreement_Party__c clonedAgreementParty : clonedAgreementParties)
                {
                    clonedAgreementParty.Agreement__c = clonedAgreement.Id; 
                }
                
                //Insert records.
                insert clonedAgreementParties;
            }
            
            /**
            *  CONDITIONS
            **/
            conditions = [
                SELECT
                    Name,
                    Agreement__c,
                    Matter__c,
                    Clause__c,
                    RecordTypeId,
                    Activation_End__c,
                    Activation_Start__c,
                    Active__c,
                    Actual_Base__c,
                    Actual_Base_Percentage__c,
                    Actual_Base_Range_From__c,
                    Actual_Base_Range_To__c,
                    Actual_Base_Ratio__c,
                    Actual_Value__c,
                    Assigned_to_Group__c,
                    Multiples__c,
                    Base_Percentage__c,
                    Base_Threshold_Actual_Level__c,
                    Category__c,
                    Client__c,
                    Counter_Party__c,
                    Days__c,
                    Document_Expiry_Date__c,
                    Document_Name__c,
                    Document_Type__c,
                    Due_Date__c,
                    Expected_Value__c,
                    Recurrence__c,
                    Internal_Governance_Checks__c,
                    Manager__c,
                    Margin_Ratchet__c, 
                    Number_Of_Days__c,
                    Other_Relative_Date__c,
                    Date__c,
                    Required_Base__c,
                    Required_Base_Multiple__c,
                    Required_base_number_fold_from__c,
                    Required_Base_Percentage__c,
                    Required_Base_Range_Multiple_Range_From__c,
                    Required_Base_Range_Multiple_To__c,
                    Required_Base_Range_Percentage_From__c,
                    Required_Base_Range_Percentage_To__c,
                    Required_Base_Range_Ratio_From__c,
                    Required_Base_Range_Ratio_From_Two__c,
                    Required_Base_Range_Ratio_To__c,
                    Required_Base_Range_Ratio_To_Two__c,
                    Required_Base_Ratio__c,
                    Required_Base_Ratio_From__c,
                    Required_Base_Ratio_To__c,
                    Source__c,
                    Status__c,
                    Threshold_Category__c,
                    Threshold_Comparator__c,
                    Threshold_Type__c,
                    Type__c,
                    (
                        SELECT
                            Name,
                            Condition__c,
                            Agreement_Party__c,
                            Relationship__c,
                            Party_Type__c
                        FROM Condition_Parties__r
                    )
                FROM Condition__c
                WHERE
                    Agreement__c = :agreementId
            ];
            
            //Loop through original conditions and parties and build main wrapper.
            for(Condition__c condition : conditions)
            {
                //UUID
                String externalId = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(Crypto.getRandomLong().format())));
                
                //New wrappper.
                ConditionWrapper wrapperItem = new conditionWrapper();
                wrapperItem.condition = condition;
                wrapperItem.parties = condition.Condition_Parties__r;
                wrapperItem.uniqueId = externalId;
                
                //Add to wrapper list.
                conditionWrappers.add(wrapperItem);
            }
            
            //Loop through main wrapper list.
            for(ConditionWrapper wrapper  : conditionWrappers)
            {
                //Clone wrapper condition.
                Condition__c clonedCondition = wrapper.condition.clone();
                
                //Set guid.
                clonedCondition.External_ID__c = wrapper.uniqueId;
                clonedCondition.Agreement__c = clonedAgreement.Id;
                clonedCondition.Active__c = false;
                
                //Cloned
                clonedConditions.add(clonedCondition);
                
                //unique id to wrapper map.
                wrapperMap.put(wrapper.uniqueId, wrapper);
            }
            
            //insert cloned conditions.
            insert clonedConditions;     
            
            
            //Loop through inserted conditions
            for(Condition__c clonedCondition : clonedConditions)
            {
                //Get the wrapper item with this conditions external id.
                ConditionWrapper wrapperItem = wrapperMap.get(clonedCondition.External_ID__c);
                
                //Loop through condition parties
                for(Condition_Party__c conditionParty : wrapperItem.parties)
                {
                    //Clone condition party.
                    Condition_Party__c clonedConditionParty = conditionParty.clone();
                    clonedConditionParty.Condition__c = clonedCondition.Id;
                    
                    //Add to cloned list.
                    clonedConditionParties.add(clonedConditionParty);
                }
            }
            
            //insert cloned condition parties.
            insert clonedConditionParties;
            
            //Mark the previous agreements conditions as inactive.
            for(Condition__c condition : conditions)
            {
                condition.Active__c = false;
            }
            
            //Reset Condition Recursion Flag for Trigger
            checkRecursion.runOnce_Condition = true;
            
            //Update existing conditions and set "Inactive".
            update conditions;
            
            /**
            *  FACILITIES
            **/
            
            /*for(Facility__c eachFacility : [SELECT Agreement__c FROM Facility__c WHERE Agreement__c = :agreementId]){ 
                Facility__c clonedFacilityItem = eachFacility.clone(false,True,false,false); 
                clonedFacilityItem.Agreement__c = clonedAgreement.Id;
                clonedFacilities.add(clonedFacilityItem);
            }
            
            if(clonedFacilities.size() > 0)
            {
                insert clonedFacilities;
            }*/
            
             /**
            *  FACILITY PARTIES
            **/
            
            
            
            facilitiesList = [
                SELECT AcmFacility__c, 
                Agreement_Account__c, 
                Agreement__c, 
                Availability_End_Date__c, 
                Availability_Period__c, 
                Availability_Start_Date__c, 
                Availability__c, 
                CurrencyIsoCode, 
                Expiry_Date__c, 
                ExternalFacilityId__c, 
                FacilityLimitBalance__c, 
                Facility_Limit__c, 
                Facility_Type__c, 
                Financial_Year_End_Date__c, 
                Id, 
                Lender_Portion_Total_Amount__c, 
                Name, 
                Repayment_Profile_Type__c, 
                Signature_Date__c, 
                Source_System__c, 
                Source_User__c, 
                Start_Date__c, 
                Status__c, 
                Tenure_Period__c, 
                Tranche_Limit__c,
                    (SELECT Id, 
                     Name, 
                     CurrencyIsoCode, 
                     Agreement_Party__c, 
                     Facility__c, 
                     Party_Type__c, 
                     Facility_Amount_Formula__c, 
                     Facility_Percentage_Formula__c, 
                     Facility_Amount__c, 
                     Facility_Percentage__c, 
                     Agreement_Facility_Amount__c 
                     FROM Facility_Parties__r ) ,
                (SELECT Id
                 FROM Facility_Tranches__r
                )
                FROM Facility__c
                 WHERE
                    Agreement__c = :agreementId
            ];
            
            //Loop through original Fcaility and Parties and build main wrapper.
            for(Facility__c eachFacility : facilitiesList)
            {
                //UUID
                String externalId = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(Crypto.getRandomLong().format())));
                
                //New wrappper.
                FacilityWrapper facilityWrapperItem = new FacilityWrapper();
                facilityWrapperItem.facility = eachFacility;
                facilityWrapperItem.parties = eachFacility.facility_Parties__r;
                facilityWrapperItem.uniqueId = externalId;
                
                //Add to wrapper list.
                facilityWrappers.add(facilityWrapperItem);
            }
            
            //Loop through main wrapper list.
            for(FacilityWrapper eachFacilityWrapper  : facilityWrappers)
            {
                //Clone wrapper facility.
                Facility__c clonedFacility = eachFacilityWrapper.facility.clone();
                
                //Set guid.
                clonedFacility.External_ID__c = eachFacilityWrapper.uniqueId;
                clonedFacility.Agreement__c = clonedAgreement.Id;
                
                //Cloned
                clonedFacilities.add(clonedFacility);
                
                //unique id to wrapper map.
                facility_wrapperMap.put(eachFacilityWrapper.uniqueId, eachFacilityWrapper);
            }
            
            //insert cloned facility.
            insert clonedFacilities;     
            
            
            //Loop through inserted Facilities
            for(Facility__c eachClonedFacility : clonedFacilities)
            {
                //Get the wrapper item with this facilities external id.
                FacilityWrapper facilityWrapperItem = facility_wrapperMap.get(eachClonedFacility.External_ID__c);
                
                //Loop through facility parties
                for(Facility_Party__c eachFacilityParty : facilityWrapperItem.parties)
                {
                    //Clone facility party.
                    Facility_Party__c clonedFacilityParty = eachFacilityParty.clone();
                    clonedFacilityParty.Facility__c = eachClonedFacility.Id;
                    
                    //Add to cloned list.
                    clonedFacilityParties.add(clonedFacilityParty);
                }
            }
            
            //insert cloned facility parties.
            insert clonedFacilityParties;

            //Redirect to new record page.
            PageReference standardPage = new PageReference('/'+clonedAgreement.Id); 
            standardPage.setRedirect(true);
            
            //Redirect.
            return standardPage;
        }
        catch(Exception e)
        {
            System.debug('### EXCEPTION : '+e.getMessage());
            
            //Set error.
            showError = true;
            
            //Show page error.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,e.getLineNumber()+' : '+e.getMessage()));
                
            //Rollback db.
            Database.rollback(dbSavePoint);
        }
        
        //Return
        return null;
    }
    
    /**
    * Wrapper class.
    **/
    public class ConditionWrapper 
    {
        public Condition__c condition { get; set; }
        public List<Condition_Party__c> parties { get; set; }
        public String uniqueId { get; set; }
        
        public conditionWrapper() { }
    }
    
    public class FacilityWrapper 
    {
        public Facility__c facility { get; set; }
        public List<Facility_Party__c> parties { get; set; }
        public String uniqueId { get; set; }
        
        public FacilityWrapper() { }
    }
}