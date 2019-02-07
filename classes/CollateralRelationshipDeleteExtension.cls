public class CollateralRelationshipDeleteExtension {
    private Collateral_Relationship__c collateralRelationship;
    private ApexPages.StandardController sController;
    private String errorMessage {get ; set; }
    private Collateral__c collateral;
    private boolean providerError = false;
    
    public CollateralRelationshipDeleteExtension(ApexPages.StandardController stdController) {
        sController = stdController;
        if (!Test.isRunningTest()) stdController.addFields(new List<String>{'IsDeleted', 'isPrimaryRelationship__c'});
        this.collateralRelationship = (Collateral_Relationship__c)stdController.getRecord();
        if(collateralRelationship.IsDeleted){
            undelete collateralRelationship;
        }
        collateral = AcmMitigantCRUDService.getCollateralFromId(collateralRelationship.Collateral__c);
    }
    
    public PageReference deleteAction() {
        PageReference redirectSuccess = null;
        try {
            errorMessage = '';
            if(collateralRelationship.isPrimaryRelationship__c) {
                errorMessage = 'Cannot delete primary Facility on this page, Please delete on collateral';
                providerError = true;
            } else {
                if(!collateralRelationship.IsDeleted) {
                    delete collateralRelationship;           
                }
            }
        } catch(Exception e) {
            errorMessage = e.getMessage();
            redirectSuccess = null;
        }
        return redirectSuccess;
    }
    
    public PageReference cancel() {
        Collateral__c collateral = AcmMitigantCRUDService.getCollateralFromId(collateralRelationship.Collateral__c);
        PageReference redirectSuccess = null;
        try {
            errorMessage = '';
            undelete collateralRelationship;
            redirectSuccess = new ApexPages.StandardController(collateral).view();
        } catch(Exception e) {
            errorMessage = e.getMessage();
            redirectSuccess = new ApexPages.StandardController(collateral).view();
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
                undelete collateralRelationship;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageReferenceMessage.message));
                return null; 
            }
        } else {
            String message = '';
            if(errorMessage.contains('Please ensure that the Relationship has an SDS ID.') && errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                message = 'Selected Relationship does not have SDS ID';
                collateralRelationship.Relationship__c.adderror('Selected Relationship does not have SDS ID');
            } else if(providerError) {
                message = errorMessage;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));  
            return null;
        }
        redirectSuccess = new ApexPages.StandardController(collateral).view();
        return redirectSuccess;
    }
}