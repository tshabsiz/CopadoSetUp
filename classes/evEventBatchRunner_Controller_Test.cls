@istest
Private class evEventBatchRunner_Controller_Test {
    
    
    static testmethod void evEventBatchRunner_Controller_Test()
    {
        evEmailBatchRunner_Controller s = new evEmailBatchRunner_Controller();
        
        s.ScheduleEmailBatchJob();
        PageReference pageRef1 = Page.evEmailBatchRunner;	
        Test.setCurrentPageReference(pageRef1);
        pageRef1.getParameters().put('action','runEventEmails');
        s.runEventEmails();
        s.doBackToEvent();

    } 
}