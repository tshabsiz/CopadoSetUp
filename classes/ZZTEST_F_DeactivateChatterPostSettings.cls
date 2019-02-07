/**
 * @Author			Mohsin Wadee
 * @Company:		Barclays Africa
 * @Description:	Helper test class to instantiate custom setting Deactivate Chatter Post Settings.
 * @Date:			10-Dec-2015
 * History:
 * 10-Dec-2015 - Mohsin Wadee - US-0775 - class created.
 *-------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_F_DeactivateChatterPostSettings {

    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which adds a record for custom setting Deactivate Chatter Post Settings.
     *
     * @params:         
     * 					deactivateInsertPost - If the settings should deactivate Chatter posts when inserting records into the specified object.
     * 					deactivateUpdatePost - If the settings should deactivate Chatter posts when updating records in the specified object.
     * 					deactivateDeletePost - If the settings should deactivate Chatter posts when deleting records from the specified object.
     * 					deactivateAdminPost - If the settings should deactivate all Chatter posts for admin users.
     * 
     * History:
     * 10-Dec-2015, Mohsin Wadee, US-0775, method created.
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static void InstantiateChatterSettingsForOpportunityLineItem(Boolean deactivateInsertPost, Boolean deactivateUpdatePost, 
        	Boolean deactivateDeletePost, Boolean deactivateAdminPost) {
            
        OpportunityLineItemTrigger_Helper.chatterSettings = new DeactivateChatterPostSettings__c();
        OpportunityLineItemTrigger_Helper.chatterSettings.Name = 'OpportunityLineItem';
        OpportunityLineItemTrigger_Helper.chatterSettings.Deactivate_non_Admin_Chatter_Insert_Post__c = deactivateInsertPost;
        OpportunityLineItemTrigger_Helper.chatterSettings.Deactivate_non_Admin_Chatter_Update_Post__c = deactivateUpdatePost;
        OpportunityLineItemTrigger_Helper.chatterSettings.Deactivate_non_Admin_Chatter_Delete_Post__c = deactivateDeletePost;
        OpportunityLineItemTrigger_Helper.chatterSettings.Deactivate_All_Admin_Chatter_Posts__c = deactivateAdminPost;
        insert OpportunityLineItemTrigger_Helper.chatterSettings;
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Test method which adds a record for custom setting Deactivate Chatter Post Settings,
     * 					and returns the custom setting object.
     *
     * @params:         
     * 					deactivateInsertPost - If the settings should deactivate Chatter posts when inserting records into the specified object.
     * 					deactivateUpdatePost - If the settings should deactivate Chatter posts when updating records in the specified object.
     * 					deactivateDeletePost - If the settings should deactivate Chatter posts when deleting records from the specified object.
     * 					deactivateAdminPost - If the settings should deactivate all Chatter posts for admin users.
     * 
     * History:
     * 10-Dec-2015, Mohsin Wadee, US-0775, method created.
     *-------------------------------------------------------------------------------------------------------------------------*/
    public static DeactivateChatterPostSettings__c ChatterSettingsForOpportunityLineItem(Boolean deactivateInsertPost, Boolean deactivateUpdatePost, 
        	Boolean deactivateDeletePost, Boolean deactivateAdminPost) {
            
        OpportunityLineItemTrigger_Helper.chatterSettings = new DeactivateChatterPostSettings__c();
        OpportunityLineItemTrigger_Helper.chatterSettings.Name = 'OpportunityLineItem';
        OpportunityLineItemTrigger_Helper.chatterSettings.Deactivate_non_Admin_Chatter_Insert_Post__c = deactivateInsertPost;
        OpportunityLineItemTrigger_Helper.chatterSettings.Deactivate_non_Admin_Chatter_Update_Post__c = deactivateUpdatePost;
        OpportunityLineItemTrigger_Helper.chatterSettings.Deactivate_non_Admin_Chatter_Delete_Post__c = deactivateDeletePost;
        OpportunityLineItemTrigger_Helper.chatterSettings.Deactivate_All_Admin_Chatter_Posts__c = deactivateAdminPost;
        insert OpportunityLineItemTrigger_Helper.chatterSettings;
                
        return OpportunityLineItemTrigger_Helper.chatterSettings;
    }
}