/*================================================
@Author : Mabhedle Tonga 
@Description : Helper class that holds generic functions that an be used across the salesforcs Org
@Created Date : 2017/12/14
@Test Class : AccountHelperController_Test
==================================================
@Modification Description : Changed account holder name from Africa RD Holder to Coverage Unmanaged
@Modification Date : 2018/02/19
@Modified By : Mabhedle Tonga 
==================================================*/
public with sharing class AccountHelperController 
{
	@AuraEnabled
    public static boolean isAFricaRDOwned(String accountId)
    {
        Account currentAccount = [Select Owner.Name,Segment__c from Account where ID=:accountID limit 1];
        
        if(currentAccount.Owner.Name.EqualsIgnoreCase(Label.lbl_Coverage_Unmanaged)&& !currentAccount.Segment__c.equalsIgnoreCase('Business Banking'))
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    @AuraEnabled
    public static string getNewName() {
        Set<String> newOppNames = new Set<String>();
        List<ProjectName__c> newProjectNames = [SELECT Id, Name FROM ProjectName__c WHERE Reserved__c = false AND Used__c = false ORDER BY CreatedDate LIMIT 20000];
        for(ProjectName__c projectname : newProjectNames)
        	newOppNames.add('Project ' + projectname.Name);

        List<AggregateResult> namecountslist = [SELECT Name, COUNT(Id) CountOpp 
                                                FROM Opportunity 
                                                WHERE RecordTypeId =: OpportunityTrigger_Helper.getOpportunityRT(OpportunityTrigger_Helper.OpportunityRT.PrivateOpp)
                                                AND Name =: newOppNames
                                                GROUP BY Name];
		Map<String, Integer> namecountsmap = new Map<String, Integer>();
        for(AggregateResult namecount : namecountslist) namecountsmap.put(((String)namecount.get('Name')).toLowerCase(), (Integer)namecount.get('CountOpp'));
        
        String NameFound = '';
        List<ProjectName__c> projectNamesToUpdate = new List<ProjectName__c>();
        //Run through the Project Names randomly until you find something not used or you have gone through the entire list
        while (newProjectNames.size() > 0 && NameFound == '') {
        	Integer randomIndex = (Math.random() * (newProjectNames.size() - 1)).intValue();
            if (!namecountsmap.containsKey('project ' + newProjectNames[randomIndex].Name.toLowerCase())) {
                projectNamesToUpdate.add(new ProjectName__c(Id = newProjectNames[randomIndex].Id, Reserved__c = true));
                NameFound = 'Project ' + newProjectNames[randomIndex].Name;
            } else {
                projectNamesToUpdate.add(new ProjectName__c(Id = newProjectNames[randomIndex].Id, Used__c = true));
                newProjectNames.remove(randomIndex);
            }
		}
        
        try {
            if (projectNamesToUpdate.size() > 0) update projectNamesToUpdate;
        } catch(Exception e) {
            System.debug('We were not able to update Project Names:' + e);
        }
        
        return NameFound;
    }
    
    @AuraEnabled
    public static String createClientPlan(String accountId)
    {
        Client_Plan__c clientPlan = new Client_Plan__c();
        
        clientPlan.Relationship__c = accountId;
        Database.SaveResult result = Database.insert(clientPlan, false);
        
        if(!result.isSuccess())
        {
            Database.Error error = result.getErrors().get(0);
            return 'false';
        }
        else
        {
            return  [Select ID from Client_Plan__c where Relationship__c =:accountId limit 1].ID;
        }
    }
    
    @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Call_Report__c.SObjectType.getDescribe().getRecordTypeInfos();    
        Map<String, String> recordtypemap = new Map<String, String>();
        if(!Test.isRunningTest())
        {
            recordtypemap.put('None','None');
        }
        
        for(RecordTypeInfo rt : recordtypes){
            if(rt.isAvailable()){
                if(rt.getName() != 'Master')
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }        
        return recordtypemap.values();
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }
    
    @AuraEnabled
    public static String updateAttendeePresent(String attendeeId){
        Meeting_Attendee__c ma = new Meeting_Attendee__c();
        ma.Id = attendeeId;
        ma.Present__c = true;
        
        Database.SaveResult result = Database.update(ma, false);
        if(!result.isSuccess())
            return 'There was an issue updating this record.';
        else
            return attendeeId;
    }
}