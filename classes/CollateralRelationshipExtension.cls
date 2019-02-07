public class CollateralRelationshipExtension {
    private Collateral_Relationship__c collateralRelationship;
    private ApexPages.StandardController sController;
    private String errorMessage {get ; set; }
    private Collateral__c collateral;
    private boolean providerError = false;
    
    public CollateralRelationshipExtension(ApexPages.StandardController stdController) {
        sController = stdController;
        if (!Test.isRunningTest())stdController.addFields(new List<String>{'isPrimaryRelationship__c'});
        this.collateralRelationship = (Collateral_Relationship__c)stdController.getRecord();
        collateral = AcmMitigantCRUDService.getCollateralFromId(collateralRelationship.Collateral__c);
    }
    
    public PageReference save() {
        PageReference redirectSuccess = null;
        try {
            providerError = false;
			errorMessage = '';
            List<Collateral_Relationship__c> collateralRelastionships = [SELECT Id 
                                                                         FROM Collateral_Relationship__c 
                                                                         WHERE Collateral__c = :collateralRelationship.Collateral__c AND
                                                                         Relationship_Type__c = :collateralRelationship.Relationship_Type__c AND
                                                                         Relationship__c = :collateralRelationship.Relationship__c];

            if(collateralRelastionships.size() >= 2) {
                if(collateralRelationship.Id != null) {
                    errorMessage = 'Collateral relationship already exists';
                    providerError = true;
                }
            } else if(collateralRelastionships.size() == 1) {
                if(collateralRelationship.Id == null) {
                    errorMessage = 'Collateral relationship already exists';
                    providerError = true;
                }
            }
            if(!providerError){
                if(collateral.Scope__c != 'Beneficiary' && collateralRelationship.Relationship_Type__c == 'Beneficiary') {
                    errorMessage = 'Cannot create/edit Beneficiary on Collateral with scope : ' + collateral.Scope__c;
                    providerError = true;
                } else if(collateralRelationship.isPrimaryRelationship__c) {
                    errorMessage = 'Cannot update primary relationship on this page, Please edit on collateral';
                    providerError = true;
                } else {
                    upsert(collateralRelationship);
                }
            }
        } catch(Exception e) {
            errorMessage = e.getMessage();
            redirectSuccess = null;
        }
        return redirectSuccess;
    }
    
    public PageReference CallWebService() {
        PageReference redirectSuccess = null;
        PageReferenceMessage pageReferenceMessage = new PageReferenceMessage();
        if(errorMessage == '') {
            pageReferenceMessage = AcmControllerLogic.saveToACM(sController, collateral, false, errorMessage);
            if(pageReferenceMessage.message == 'Mitigant successfully created/update') {
                redirectSuccess = pageReferenceMessage.redirectSuccess;
            } else if(pageReferenceMessage.message == 'Not Saving to ACM') {
                redirectSuccess = pageReferenceMessage.redirectSuccess;
            } else {
                System.debug('My messages are here : ' + pageReferenceMessage.message);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageReferenceMessage.message));
                return null; 
            }
        } else {
            System.debug('Text fillll error message : ' +errorMessage);
            String message = '';
            if(errorMessage.contains('Please ensure that the Relationship has an SDS ID.') && errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                message = 'Selected Relationship does not have SDS ID';
                collateralRelationship.Relationship__c.adderror('Selected Relationship does not have SDS ID');
            }  else if(providerError) {
                message = errorMessage;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));  
            return null;
        }
        redirectSuccess = new ApexPages.StandardController(collateralRelationship).view();
        return redirectSuccess;
    }
}