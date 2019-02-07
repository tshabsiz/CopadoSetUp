/**
* @Author       Dino Scarcella
* @Company:     Absa Capital
* @Description: Class used for Javascript calls to generate a new opportunity Name
* @Date:        2017
* @TestClass:   ZZTEST_ProjectName
* History
* <Date>      <Authors Name>     <Brief Description of Change>
===============================================================*/
global without sharing class ProjectName {
	webservice static string getNewName() {
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
}