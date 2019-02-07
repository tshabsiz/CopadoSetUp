public class BxdCaseService {
    private static final String KM_RECORD_TYPE_NAME = 'Knowledge Request';
    
    /**
    * createBoxFolderTrigger - prepares a set of case records id, then pass it to createBoxFolderTrigger
	**/
    public static  void createBoxFolderTrigger(List<Case> caseList) {
        if(!caseList.isEmpty()){
            Case knowledge = caseList[0];
            Id knowledgeRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(KM_RECORD_TYPE_NAME).getRecordTypeId();
            if(knowledgeRecordTypeId == knowledge.RecordTypeId){
                System.debug('##Box Folder Creation Required##');
                Set<String> caseSet = new Set<String>(); 
                for(Case ca : caseList){
                    caseSet.Add(ca.id);             
                }
                
                createBoxFolderTrigger(caseSet);
            } else{
                System.debug('##Box Folder Creation Not Required##');
            }
        }
    }
    
    /**
    * createBoxFolderTrigger - this method executes asynchronously, pass the case records id set to createBoxFolderTrigger in BxdKnowledgeService
	**/
    @Future(callout = true)
    public static  void createBoxFolderTrigger(Set<String> caseSet) {
        BxdKnowledgeService.createBoxFolderTrigger(caseSet);
    }
}