/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Schedulable class for Box External Collaboration that executes a batch to remove folder collaborators
* @Date:        2018
*/
global class BxdExternalCollaborationSchedule implements System.Schedulable {
    /**
	* Run every day at midnight.
	* This is Scheduled in the User’s timezone who schedules the job
	**/
    private static final String CRON_EXPR = '0 00 00 * * ?';  
    
    /**
	* scheduleTheBatch - call this from Anonymous Apex to schedule at specified cron or default CRON_EXPR regularity
	**/
    global static String scheduleTheBatch(String cronOverride) {
        BxdExternalCollaborationSchedule job = new BxdExternalCollaborationSchedule();
        return System.schedule('Bxd External Collaboration BatchJob', String.isBlank(cronOverride) ? CRON_EXPR : cronOverride, job);
    }
    
    /**
	* execute - execute the batch with specified scope size
	**/
    global void execute(SchedulableContext SC) {
        //call batch class to be scheduled
        BxdExternalCollaborationScheduleBatch b = new BxdExternalCollaborationScheduleBatch();
        
        //if we are doing N callouts, the batch size will be 100/N. There could be at least 10 collaborators in a folder 100/10=10
        Database.executeBatch(b, 10);
    }
}