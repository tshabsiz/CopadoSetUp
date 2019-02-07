public class evEmailBatchRunner_Controller 
{
    public integer SimgleEmailsSent {get; set;}
    public integer SingleEmailsLimit {get; set;}
    private Id inputID;
    private String action;
    
    public evEmailBatchRunner_Controller()
    {
        inputID =  ApexPages.currentPage().getParameters().get('id');
        action = ApexPages.currentPage().getParameters().get('action');
        
        SimgleEmailsSent = Limits.getEmailInvocations();
        SingleEmailsLimit = Limits.getLimitEmailInvocations();
    }
    
    public void ScheduleEmailBatchJob()
    {
        
        String sch = '0 0 * * * ?'; //every hour
        try 
        {
            System.Type t = System.Type.forName('evEventEmail_Batch');
            Schedulable s = (Schedulable) JSON.deserialize('{}',t);
            System.schedule('Automated Hourly Jobs',sch,s);
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.INFO,'Hourly Job Scheduled '));
        } 
        catch (Exception ex) 
        {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR,'Job not Scheduled - '+ex.GetMessage()));
        }
    }
    
    public pagereference runEventEmails()
    {
        system.debug('runEventEmails: action='+action+' id='+inputID);
        if (action  == 'runEventEmails')
        {
            database.executebatch(new evEventEmail_Batch(inputID),1);   // database.executebatch(new EM_Event_Email_Scheduled(),1);
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.INFO,'Event emails/smses queued for delivery.'));
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.INFO,'You will receive an email with the results when sending is complete.'));
            return null;
        }
        return null;
    }		 
        
    public pagereference doBackToEvent()
    {
        PageReference prEvent =  new PageReference('/'+ inputID);
        prEvent.setRedirect(true);
        return prEvent;
    }		 
}