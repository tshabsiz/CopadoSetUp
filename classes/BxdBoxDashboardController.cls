public class BxdBoxDashboardController {
    
    public BxdBoxDashboardController(){        
    }
    
    public void clearData(){
        //Detemine which enviroment we are in for jwt selection.
        String salesforceEnviroment = CloudSmiths_Utils.getEnviroment();
        System.debug('***Current Environment: ' + salesforceEnviroment);
        
        if(!String.isBlank(salesforceEnviroment) && !salesforceEnviroment.containsIgnoreCase('PROD')){
            //Deletes all data if any in the Box Folder Details object
            List<box__Folder_Details__c> folderDetails = [SELECT Id, Name FROM box__Folder_Details__c];
            if(!folderDetails.isEmpty()){
                delete folderDetails;
                System.debug('Details size ' + folderDetails.size());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Box Sandbox Data successfully deleted.'));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Box Folder Details unsuccessful delete'));
            }
        } 
    }   
}