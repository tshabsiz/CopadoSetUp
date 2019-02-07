/*==================================================
 * @CreatedDate : 2018-02-27
 *@CreatedBy : Mabhedle Tonga 
 *@Description : Single instance for service Mapping 
====================================================*/
public class ServiceMappingHandler {

    public static List<Service_Mapping__c> sericeMappingInstance=null;
    
    public static List<Service_Mapping__c> getServiceMappingInstance()
    {
        if(sericeMappingInstance==null)
        {
            sericeMappingInstance = [Select Queue__c, Template_Name_Email_Receipt__c, Template_Name_Case_Creation__c, 
                                      Template_Name_Case_Close__c, Template_Name_Feedback_Email__c, Response_From_Email_Address__c    
                                      From Service_Mapping__c];
        }
        return sericeMappingInstance;
    }
}