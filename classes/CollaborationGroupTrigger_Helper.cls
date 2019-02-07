/**
* @Author      	Svata Sejkora
* Company:      Deloitte
* @Description: a Class with methods to prevent certain users to create groups for external users (customers)
* @Date:		08/2015
* @Inputs:      None
* @TestClass:   ZZTEST_CollaborationGroupTrigger_Helper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/

public class CollaborationGroupTrigger_Helper {

	private static final String ERROR_MESSAGE = 'You cannot create groups with customer access or edit groups to have customer access';
	private static final String PERM_SET_NAME = 'Key_Allow_Customer_Groups';
	private static final String ADMIN = 'System Administrator';
	private static final String BC_ADMIN = 'Barclays Administrator';
	private static final String DELOITTE_ADMIN = 'Deloitte Administrator';


	/**
	* @Author:        	Svata Sejkora
	* @Company:       	Deloitte
	* @Description:  	check whether user has rights to create chatter group with customer access, if user does not, an error message will be shown
	* @param 			List<CollaborationGroup> triggerNew
	* @param 			Map<Id, CollaborationGroup> triggerOldMap
	* @Returns:       	no return value
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	* 18.09.2015	Svata Sejkora	changing the logic of the trigger to align with the need to allow users to invite internal users to groups marked as customer groups
	*------------------------------------------------------------*/


	public static void checkIfUserCanCreateCustomerGroup(List<CollaborationGroup> triggerNew, Map<Id, CollaborationGroup> triggerOldMap) {
		Boolean canCreateCustGroup = false;
		Boolean isCustomerGroupCheckChanged = false;
		Id userId = UserInfo.getUserId();
		List<PermissionSetAssignment> userPerms = [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId];
		Id allowCustGroupPermId = [SELECT Id, Name FROM PermissionSet WHERE Name = :PERM_SET_NAME LIMIT 1].Id;

		if(!userPerms.isEmpty()) {
			for (PermissionSetAssignment permAss : userPerms) {
				if (permAss.PermissionSetId == allowCustGroupPermId) {
					canCreateCustGroup = true;
				}
			}
		}

		for (CollaborationGroup cg : triggerNew) {
			if(triggerOldMap != null) {
				if(cg.CanHaveGuests != triggerOldMap.get(cg.Id).CanHaveGuests) {
					isCustomerGroupCheckChanged = true;
				}				
				if(canCreateCustGroup == false && isCustomerGroupCheckChanged == true) {
					cg.addError(ERROR_MESSAGE);
				}
			} else if(canCreateCustGroup == false && cg.CanHaveGuests == true) {
				cg.addError(ERROR_MESSAGE);
			}
		}
	}
}