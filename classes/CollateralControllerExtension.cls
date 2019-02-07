public class CollateralControllerExtension {
    private Collateral__c collateral;
    private Collateral__c oldCollateral = null;
    private ApexPages.StandardController sController;
    public boolean saveNewSelected = false;
    private String errorMessage {get ; set; }
    public String facilityMessage { get; set; }
    public boolean buttonDisable { get; set; }
    public String SaveStatus { get; set; }
    public String SaveStatusNew { get; set; }
    public boolean hasCededRights { get; set; }
    public boolean hasBondNumber { get; set; }
    public boolean hasPropertyDescription { get; set; }
    public boolean hasRank { get; set; }
    public boolean hasListedShares { get; set; }
    public boolean hasTitleDeedNo { get; set; }
    
    public boolean hasAircraftModelNo { get; set; }
    public boolean hasAircraftRegistrationMark { get; set; }
    public boolean hasAircraftSerialNo { get; set; }
    
    public CollateralControllerExtension(ApexPages.StandardController stdController) {
        buttonDisable = false;
        SaveStatus = 'Save';
        SaveStatusNew = 'Save & New'; 
        sController = stdController;
        if (!Test.isRunningTest()) stdController.addFields(new List<String>{'Collateral_No__c', 'Collateral_Group__c', 'Collateral_Type1__c', 'AcmFacility__c' });
        this.collateral = (Collateral__c)stdController.getRecord();
        if(collateral.Id != null) {
            oldCollateral = collateral.clone(true, true, false, false);
            System.debug('Cloned successfully : ' + oldCollateral);
        }
        
        if(collateral.Collateral_Type1__c != null) {
            SelectedCollateralType = collateral.Collateral_Type1__c;
        }
        
        if(collateral.Collateral_Group__c != null) {
            SelectedCollateralGroup = collateral.Collateral_Group__c;
        }
        OnCollateralTypeChange();
    }
    
    // Set Collateral Group Dropdown
    public String SelectedCollateralGroup { get; set; }
    
    // Set Collateral Type Dropdown
    public String SelectedCollateralType { get; set; }
    
    // Get all Collateral Groups
    public List<SelectOption> getCollateralGroups() {
        List<SelectOption> collateralGroupsOptionList = new List<SelectOption>();
        collateralGroupsOptionList.add(new SelectOption( '' ,'---Select---'));
        List<Collateral_Group__c> collateralGroups = [SELECT Id, Name FROM Collateral_Group__c WHERE deprecated__c = false];
        
        for(Collateral_Group__c collateralGroup : collateralGroups) {
            collateralGroupsOptionList.add(new SelectOption(collateralGroup.Id , collateralGroup.Name));
        }
        
        return collateralGroupsOptionList;
    }
    
    public PageReference disableButton(){
        buttonDisable = true;
        SaveStatus = 'Saving...';
        SaveStatusNew = 'Saving...';
        return null;
    }
    
    // Get collateral types for selected group
    public List<SelectOption> getCollateralTypes() {
        List<SelectOption> collateralTypesOptionList = new List<SelectOption>();
        collateralTypesOptionList.add(new SelectOption( '' ,'---Select---'));
        if(collateral.Collateral_Group__c != null || selectedCollateralGroup != null) {
            List<Collateral_Type__c> collateralTypes = [SELECT Id, Name FROM Collateral_Type__c WHERE Collateral_Group__c =:selectedCollateralGroup and deprecated__c = false];
            for(Collateral_Type__c collateralType : collateralTypes) {
                collateralTypesOptionList.add(new SelectOption(collateralType.Id , collateralType.Name));
            }
        }
        return collateralTypesOptionList;
    }
    
    public void OnCollateralTypeChange() {
        // Get all the has properties for this collateral
        
        List<Collateral_Type__c> collateralTypes = [SELECT has_Title_Deed_No__c,has_Bond_Number__c,has_Listed_Unlisted_Shares__c,has_Rank__c,has_Property_Description__c,has_Ceded_Rights__c,has_Aircraft_Model_No__c,has_Aircraft_Registration_Mark__c,has_Aircraft_Serial_No__c FROM Collateral_Type__c where Id =:SelectedCollateralType];
        // assign the has property
        if(collateralTypes.size() > 0){
            System.debug('running with it : ' + collateralTypes.get(0));
            Collateral_Type__c collateralType = collateralTypes.get(0);
            hasCededRights = collateralType.has_Ceded_Rights__c;
            hasBondNumber = collateralType.has_Bond_Number__c;
            hasPropertyDescription = collateralType.has_Property_Description__c;
            hasRank = collateralType.has_Rank__c;
            hasListedShares = collateralType.has_Listed_Unlisted_Shares__c;
            hasTitleDeedNo = collateralType.has_Title_Deed_No__c;
            hasAircraftModelNo = collateralType.has_Aircraft_Model_No__c;
   			hasAircraftRegistrationMark = collateralType.has_Aircraft_Registration_Mark__c;
    		hasAircraftSerialNo = collateralType.has_Aircraft_Serial_No__c;
        }
    }
    
    public PageReference GetAndCreateFacilities() {
        facilityMessage = AcmControllerLogic.ReadCreateCollateralAcmFacilities(collateral.Facility_Client__c);
        if(facilityMessage != ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, facilityMessage));   
        }
        return null; 
    } 
    public PageReference save() {
        buttonDisable = true;
        SaveStatus = 'Saving...';
        try {
            // Set Collateral Type and Group
            collateral.Collateral_Type1__c = SelectedCollateralType;
            collateral.Collateral_Group__c = SelectedCollateralGroup;
            
            errorMessage = '';
            
            // Only a single scope can be selected
            if(collateral.Scope__c == 'Beneficiary') {
                collateral.Facility_Client__c = null;
                collateral.AcmFacility__c = null;
            } else if(collateral.Scope__c == 'Facility'){
                collateral.Beneficiary__c = null;
            }
            
            List<Collateral_Type__c> cTypes = [SELECT Id, Name, deprecated__c, Collateral_Group__r.deprecated__c FROM Collateral_Type__c WHERE Id =: SelectedCollateralType LIMIT 1];
            if(cTypes.size() > 0) {
                Collateral_Type__c cType = cTypes.get(0);
                if((cType.deprecated__c || cType.Collateral_Group__r.deprecated__c)  && oldCollateral == null) {
                    errorMessage = 'Cannot create collateral of deprecated collateral type';	
                }
            }
            
            // Validate
            if(collateral.Beneficiary__c != null) {
                List<Account> accounts = [SELECT Id,Name, SDS__c, CIF__c FROM Account WHERE Id = :collateral.Beneficiary__c];
                if(accounts.size() > 0) {
                    Account account = accounts.get(0);
                    if((account.SDS__c == null || account.SDS__c == '') && (account.CIF__c == null || account.CIF__c == '') ){
                        errorMessage = 'Selected Beneficiary does not have an SDS Id \n';                       
                    }
                }
            } 
            
            if(collateral.Account__c != null) {
                List<Account> accounts = [SELECT Id,Name, SDS__c,CIF__c FROM Account WHERE Id = :collateral.Account__c];
                if(accounts.size() > 0) {
                    Account account = accounts.get(0);
                    if((account.SDS__c == null || account.SDS__c == '') && (account.CIF__c == null || account.CIF__c == '')) { 
                        errorMessage = 'Selected Provider does not have an SDS Id \n';	
                    }
                }
            }

            if(collateral.Beneficiary__c == null &&  collateral.Scope__c == 'Beneficiary') {
                errorMessage = 'Collateral must have at least 1 Beneficiary';
            } else if(collateral.AcmFacility__c == null && collateral.Facility_Client__c != null && collateral.Scope__c == 'Facility') {
                errorMessage = 'Please specify facility';
            } else if(collateral.AcmFacility__c == null && collateral.Facility_Client__c == null && collateral.Scope__c == 'Facility'){
                errorMessage = 'Please specify beneficiary and facility';
            } else if(errorMessage == '') {
                upsert(collateral);
                
                if(collateral.Scope__c == 'Facility') {
                    // Delete all Beneficiaries
                    AcmCollateralHelper.deleteAllBeneficariesForCollateral(collateral.Id);
                } else if(collateral.Scope__c == 'Beneficiary') {
                    // Delete all facilities
                    AcmCollateralHelper.deleteAllFacilitiesForCollateral(collateral.Id);
                }
                
                // Insert Or Update relationships
                if(oldCollateral == null) {
                    //Insert
                    CreateCollateralRelationships(collateral);
                    oldCollateral = collateral.clone(true, true, false, false);
                }  else {
                    // update
                    UpdateCollateralRelationships(collateral, oldCollateral);
                }
            }
        } catch(Exception e) {
            errorMessage = e.getMessage();
            System.debug('Exception thrown : ' + e);
        }
        return null;
    }
    
    public void CreateCollateralRelationships(Collateral__c collateral) {
        List<Collateral__c> collaterals = new List<Collateral__c>();
        collaterals.add(collateral);
        AcmCollateralHelper.createRelationshipForCollateral(collaterals);
        AcmCollateralHelper.createCollateralFacilities(collaterals);
    }
    
    public void UpdateCollateralRelationships(Collateral__c collateral, Collateral__c oldCollateral) {
        List<Collateral__c> collaterals = new List<Collateral__c>();
        collaterals.add(collateral);
        List<Collateral__c> oldCollaterals = new List<Collateral__c>();
        oldCollaterals.add(oldCollateral);
        AcmCollateralHelper.validateBeneficiaryAndFacility(collaterals, oldCollaterals);
        System.debug('Updating Relationships for Collateral :  ' + collaterals);
        AcmCollateralHelper.updateRelationshipForCollateral(collaterals, oldCollaterals);
        System.debug('Updating Facilities for Collateral : ' + oldCollateral);
        AcmCollateralHelper.updateCollateralFacilities(collaterals, oldCollaterals);
    }
    
    public PageReference saveNew() {
        save();
        saveNewSelected = true;
        return null;
    } 
    
    public PageReference Cancel() {
        PageReference redirectCancel = sController.cancel();
        return redirectCancel;
    }
    
    public PageReference callWebService() {
        //  Save to ACM after successful save
        PageReference redirectSuccess = null;
        PageReferenceMessage pageReferenceMessage = new PageReferenceMessage();
        if(errorMessage == '') {
            pageReferenceMessage = AcmControllerLogic.saveToACM(sController, collateral, saveNewSelected, errorMessage);
            if(pageReferenceMessage.message == 'Mitigant successfully created/update') {
                redirectSuccess = pageReferenceMessage.redirectSuccess;
            } else if(pageReferenceMessage.message == 'Not Saving to ACM') {
                redirectSuccess = pageReferenceMessage.redirectSuccess;
            } else {
                System.debug('Message from the service is : ' + pageReferenceMessage.message);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageReferenceMessage.message));
                redirectSuccess = null; 
            }
        } else {
            // If there is an error, show it on the save page
            boolean isError = false;
            String message = '';
            if(collateral.Beneficiary__c != null) {
                List<Account> accounts = [SELECT Id,Name, SDS__c,CIF__c FROM Account WHERE Id = :collateral.Beneficiary__c];
                if(accounts.size() > 0) {
                    Account account = accounts.get(0);
                    if((account.SDS__c == null || account.SDS__c == '') && (account.CIF__c == null || account.CIF__c == '')) { 
                        isError = true;
                        collateral.Beneficiary__c.adderror('Selected Beneficiary does not have an SDS Id \n');
                        
                    }
                }
            } else if(collateral.Beneficiary__c == null && collateral.Scope__c == 'Beneficiary') {
                isError = true;
                collateral.Beneficiary__c.adderror(errorMessage);	
            } else if(collateral.AcmFacility__c == null && collateral.Facility_Client__c != null && collateral.Scope__c == 'Facility'){
                isError = true;
                collateral.AcmFacility__c.adderror(errorMessage);	                
            } else if(collateral.AcmFacility__c == null && collateral.Facility_Client__c == null && collateral.Scope__c == 'Facility'){
                isError = true;
                collateral.Facility_Client__c.adderror(errorMessage);	
                collateral.AcmFacility__c.adderror(errorMessage);	
            } 
            
            if(collateral.Account__c != null) {
                List<Account> accounts = [SELECT Id,Name, SDS__c,CIF__c FROM Account WHERE Id = :collateral.Account__c];
                if(accounts.size() > 0) {
                    Account account = accounts.get(0);
                    if((account.SDS__c == null || account.SDS__c == '') && (account.CIF__c == null || account.CIF__c == '')) { 
                        isError = true;
                        collateral.Account__c.adderror('Selected Provider does not have an SDS or CIF Id \n');	
                    }
                }
            }
            
            System.debug('error Message : ' +errorMessage);
            // Get user friendly message
            if(errorMessage.contains('Collateral Group') && errorMessage.contains('REQUIRED_FIELD_MISSING')) {
                message = 'Collateral Group is required field \n';
            } else if(errorMessage.contains('Collateral Type') && errorMessage.contains('REQUIRED_FIELD_MISSING')) {
                message = 'Collateral Type is required field \n';
            } else if(errorMessage.contains('AcmFacility__c') && errorMessage.contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                message = 'Selected Facility does not belong to Facility Beneficiary \n';
            } else if(errorMessage.contains('Collateral_Type__c') && errorMessage.contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                message = 'Selected Collateral type does not belong to Selected Collateral Group \n';
            } else if(errorMessage.contains('Ensure that the Value is specified') && errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                collateral.Value__c.adderror('Ensure value is specfied when value type is set to Limited \n');
            } else if(errorMessage.contains('Please upload the relevant documentation') && errorMessage.contains('Supporting_Documentation_Uploaded__c')) {
                collateral.Supporting_Documentation_Uploaded__c.adderror('Please upload the relevant documentation');                
            } else if(errorMessage.contains('Comments__c') && errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                collateral.Comments__c.adderror('Please specify comment'); 
            } else if(!isError) {
                message = errorMessage;
            }
            
            if(message != '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message)); 
            }
        }
        buttonDisable = false;
        SaveStatus = 'Save';
        return redirectSuccess;
    }
}