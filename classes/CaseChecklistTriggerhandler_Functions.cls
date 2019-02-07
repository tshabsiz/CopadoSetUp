/*====================================================
@CreatedDate : 2018-06-13
@CreatedBy : Mabhedle Tonga 
@Description : 
=====================================================*/
public class CaseChecklistTriggerhandler_Functions {
    
    public static void addToQuestionAnswer(List<Case_Checklist__c> ccList)
    {
        List<Case_QA_Answer__c> caseQAAnswerList = new List<Case_QA_Answer__c>();
        map<ID,Case_Checklist_Question__c> questionMap = getQuestions();
        Set<ID> TemplateIDSet = new Set<ID>();
        Set<ID> caseIDSet = new Set<ID>();
        
        for(Case_Checklist__c case_CheckList : ccList)
        {
            caseIDSet.add(case_CheckList.RelatedCase__c);
            TemplateIDSet.add(case_CheckList.ChecklistTemplate__c);
            if(String.isNotBlank(case_CheckList.SavedResults__c))
            {
                List<String> questionAnswerlist = case_CheckList.SavedResults__c.split(';');
                for(String questionAnswer : questionAnswerlist)
                {
                    List<String> questionAnswerArray = questionAnswer.split('\\|');
                    if(questionMap.containskey((ID)questionAnswerArray[0].trim()))
                    {
                        if(questionAnswerArray.size()==2)
                        {
                            caseQAAnswerList.add(new Case_QA_Answer__c(Case__c=case_CheckList.RelatedCase__c,Question__c = questionMap.get(questionAnswerArray[0]).Question__c,
                                                                       Answer__c = questionAnswerArray[1],TemplateID__c = questionMap.get(questionAnswerArray[0]).Checklist_Template__c));                            
                        }
                        if(questionAnswerArray.size()==3)
                        {
                            caseQAAnswerList.add(new Case_QA_Answer__c(Case__c=case_CheckList.RelatedCase__c,Question__c = questionMap.get(questionAnswerArray[0]).Question__c,
                                                                       Answer__c = questionAnswerArray[1],TemplateID__c = questionMap.get(questionAnswerArray[0]).Checklist_Template__c,
                                                                      Action_Date__c = Date.valueOf(questionAnswerArray[2])));
                        }
                    }
                }
                
                
            }
        }
        
        if(TemplateIDSet.size()>0)
        {
            delete [Select ID from Case_QA_Answer__c where TemplateID__c IN: TemplateIDSet AND Case__c IN:caseIDSet];
        }
        if(caseQAAnswerList.size()>0)
            insert caseQAAnswerList;
    }
    private static map<ID,Case_Checklist_Question__c> getQuestions()
    {
        return  new Map<ID,Case_Checklist_Question__c>([Select ID,Heading__c,Name,Question__c,Checklist_Template__c From Case_Checklist_Question__c limit 50000]);
    }
    public static User getUserById(ID userId)
    {
        return [Select ID,Hub__c from User Where ID=:userId];
    }
    
    public static Set<String> getValidHubs()
    {
        
        List<CSC_Migration_Team__mdt> CSCMigrationTeams = [Select MasterLabel from CSC_Migration_Team__mdt];
        Set<String> teamName = new Set<String>();
        
        for(CSC_Migration_Team__mdt cscMT : CSCMigrationTeams)
        {
            teamName.add(cscMT.MasterLabel);
        }
        
        return teamName;
    }
    
}