/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

 24/09/2017 - PG    - Created class.

**/ 
global class Condition_Scheduling_Schedule implements Schedulable {
	
	global void execute(SchedulableContext sc) {

		Condition_Scheduling_Batch batch = new Condition_Scheduling_Batch();
		database.executebatch(batch);
	} 
}