/**
@author : Mabhedle Tonga
@since: 2018-11-16
@description: The purpose of this controller is to retrieve data related to call report and pass it to the VF to render AS PDF
@testClass : BriefingNoteControllerTest
*/
public class BriefingNoteController {

    public Call_Report__c callReport{get;set;}
    public List<Client_Plan_Relationship__c> clientPlanStakeholders {get;set;}
    public BriefingNoteController(ApexPages.StandardController SC)
    {
        
        List<String> fieldNames = new List<String>();
        
        fieldNames.add('Relationship__r.Name');
        fieldNames.add('meeting_date__c');
        fieldNames.add('location__c');
        fieldNames.add('Relationship__r.Owner.name');
        fieldNames.add('Relationship__c');
        fieldNames.add('description__c');
        fieldNames.add('key_messages_to_discussion__c');
        fieldNames.add('topics_client_would_like_to_cover__c');
        fieldNames.add('Relationship__r.Owner.Manager.Name');
        
        
        If(!Test.isRunningTest())
            SC.addFields(fieldNames);
        
        callReport = (Call_Report__c)SC.getRecord();
        queryStakeHolders();
    }
    /*
     * @return A list of client Attendees related to the call report
	*/
    public List<Attendee__c> getClientAttendee()
    {
        return [Select Attendee_Name__c,Attendee_Email__c,Attendee_Mobile__c,
                Client_Attendee__r.Job_title__c,Client_Attendee__r.Job_Role__c,Client_Attendee__r.image__c,Client_Attendee__r.Biography__c
                From Attendee__c 
                Where Call_Report__c=:callReport.ID 
                And Barclays_Attendee__c = null ];
    }
    /*
     * @return A list of stuff Attendees related to the call report
	*/
    public List<Attendee__c> getStuffAttendee()
    {
        return [Select Attendee_Name__c,Attendee_Email__c,Attendee_Mobile__c 
                From Attendee__c 
                Where Call_Report__c=:callReport.ID 
                And Barclays_Attendee__c != null ];
    }
    /*
     * @return call report to be rendered as PDF 
	*/
    public Client_Plan__c getClientPlan()
    {
        List<Client_Plan__c> clientPlan = [Select ID,Relationship__c ,status__c,expansion_policy__c,dg__c,lgd__c,client_overview__c,
                sector_overview__c,Executive_Summary__c,Financial_Information_Image_ID__c,Org_Structure_Image_ID__c,Group_Structure_Image_ID__c
                from Client_Plan__c 
                where Relationship__c =:callReport.Relationship__c];
        if(clientPlan.size()>0)
        {
            return clientPlan[0];
        }
        return new Client_Plan__c();
        
    }
    /*
     * @return A list of Opportunities related the the relationship regarding the call report
	*/
    public List<Opportunity> getOpportunities()
    {
        return [Select ID,Name,Stagename,Annualised_Income__c,CloseDate 
                from opportunity 
               Where accountid=:callReport.Relationship__c AND StageName !='Closed Lost'
                AND Type !='Income Recovery'
                AND CloseDate =LAST_N_MONTHS:12
               Order by Annualised_Income__c DESC
               limit 3];
    }
    /*
     * @return A list of Client financials related the the clientplan regarding the call report
	*/
    public List<Financial_Information__c> getclientPlanFinancials()
    {
        return ClientFinancialsController.queryFinancialInformation(getClientPlan(),Date.today().AddYears(-5).Year(),1);
    }
    private void queryStakeHolders() {
        clientPlanStakeholders = [
            SELECT      Id, Contact__c, Reports_to__r.Name,Reports_to__c, Contact__r.Name,Contact__r.Biography__c,Contact__r.Image__c, Contact__r.Job_Role__c, Contact__r.Job_Title__c, Comment__c, Client_Strength__c, (
                            SELECT      Id, Barclays_Contact_User__r.Name, Strength_of_Relationship__c, Primary_Contact__c 
                            FROM        Client_Plan_Relationship_Items__r
                            WHERE       Primary_Contact__c = TRUE
                            ORDER BY    Primary_Contact__c DESC
                        )
            FROM        Client_Plan_Relationship__c
            WHERE       Client_Plan__c = :getClientPlan().Id
            ORDER BY    Contact__r.Name
        ];
    }
}