public class CollateralFacilityDeleteExtension {
    private Collateral_Facility__c CollateralFacility;
    private ApexPages.StandardController sController;
    private String errorMessage {get ; set; }
    private Collateral__c collateral;
    private boolean providerError = false;
    
    public CollateralFacilityDeleteExtension(ApexPages.StandardController stdController) {
        sController = stdController;
        if (!Test.isRunningTest()) stdController.addFields(new List<String>{'IsDeleted', 'isPrimaryRelationship__c'});
        this.CollateralFacility = (Collateral_Facility__c)stdController.getRecord();
        if(CollateralFacility.IsDeleted) {
            undelete CollateralFacility;
        }
        collateral = AcmMitigantCRUDService.getCollateralFromId(CollateralFacility.Collateral__c);
    }
    
    public PageReference deleteAction() {
        PageReference redirectSuccess = null;
        try {
            errorMessage = '';
            if(CollateralFacility.isPrimaryRelationship__c) {
                errorMessage = 'Cannot delete primary Collateral Facility on this page, Please delete on collateral';
                providerError = true;
            } else {
                if(!CollateralFacility.IsDeleted) {
                    delete CollateralFacility;           
                }
            }
        } catch(Exception e) {
            errorMessage = e.getMessage();
            redirectSuccess = null;
        }
        return redirectSuccess;
    }
    
    public PageReference cancel() {
        PageReference redirectSuccess = null;
        try {
            errorMessage = '';
            undelete CollateralFacility;
            redirectSuccess = new ApexPages.StandardController(collateral).view();
        } catch(Exception e) {
            errorMessage = e.getMessage();
            redirectSuccess = new ApexPages.StandardController(collateral).view();
        }
        return redirectSuccess;
    }
    
    public PageReference CallWebService() {
        PageReference redirectSuccess = null;
        pageReferenceMessage pageReferenceMessage = new pageReferenceMessage();
        if(errorMessage == '') {
            pageReferenceMessage = AcmControllerLogic.saveToACM(sController, collateral, false, errorMessage);
            if(pageReferenceMessage.message == 'Mitigant successfully created/update') {
                redirectSuccess = pageReferenceMessage.redirectSuccess;
            } else if(pageReferenceMessage.message == 'Not Saving to ACM') {
                redirectSuccess = pageReferenceMessage.redirectSuccess;
            } else {
                System.debug('My messages are here : ' + pageReferenceMessage.message);
                 undelete CollateralFacility;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageReferenceMessage.message));
                return null; 
            }
        } else {
            String message = '';
            if(providerError) {
                message = errorMessage;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));  
            return null;
        }
        redirectSuccess = new ApexPages.StandardController(collateral).view();
        return redirectSuccess;
    }
}