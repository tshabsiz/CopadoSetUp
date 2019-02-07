<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Big_Deal_Alert_For_Trade_Product</fullName>
        <description>Big Deal Alert For Trade Product</description>
        <protected>false</protected>
        <recipients>
            <recipient>deon.smith@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jo.setati@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>joy.trivangalo@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kuben.pillay@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lodewyk.riekert@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vanessa.naidoo@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Big_Deal_Alert</template>
    </alerts>
    <alerts>
        <fullName>Conflict_Clearing_Check</fullName>
        <ccEmails>AbCapPrivateSideAdv@barclayscapital.com</ccEmails>
        <description>Conflict Clearing Check</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Conflict_Clearance_and_Pre_screening</template>
    </alerts>
    <alerts>
        <fullName>Creator_Alert_Approved</fullName>
        <description>Creator Alert Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Creator_Alert_Approved</template>
    </alerts>
    <alerts>
        <fullName>Creator_Alert_Rejected</fullName>
        <description>Creator Alert Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Creator_Alert_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_to_Accountable_Banker_related_to_the_MM_Campaign</fullName>
        <description>Email Notification to Accountable Banker related to the MM Campaign</description>
        <protected>false</protected>
        <recipients>
            <field>Accountable_Banker__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/MMDC_Email_to_Accountable_Banker</template>
    </alerts>
    <alerts>
        <fullName>Email_Tender_Proposal_Team</fullName>
        <description>Email Tender/Proposal Team - New Tender/Proposal Support Requested</description>
        <protected>false</protected>
        <recipients>
            <recipient>marlize.schwar@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tumi.mokgara@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Tender_Proposal_Support_Requested</template>
    </alerts>
    <alerts>
        <fullName>Email_notification_to_Banker_notifying_of_Closed_Won_Opportunity</fullName>
        <description>Email notification to Banker notifying of Closed Won Opportunity</description>
        <protected>false</protected>
        <recipients>
            <field>Accountable_Banker__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/MMDC_Email_Deal_Closed_Won</template>
    </alerts>
    <alerts>
        <fullName>Liquidity_And_Working_Capital_Alert</fullName>
        <description>Liquidity And Working Capital Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Liquidity_And_Working_Capital_Team</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Liquidity_And_Working_Capital_Alert</template>
    </alerts>
    <alerts>
        <fullName>MailProductPartnerApprover</fullName>
        <description>Mail the Product Partner with an approval email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ProductPartner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Product_Partner_Approval_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Notification_Opportunity_Close_Date</fullName>
        <description>Notify - Opportunity past Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Owner_Manager_Id__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Opportunity_passed_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Notification_email_to_Accountable_Banker</fullName>
        <description>Notification email to Accountable Banker</description>
        <protected>false</protected>
        <recipients>
            <field>Accountable_Banker__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Accountable_Banker_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Banker_of_Closed_Lost_MM_Opportunities</fullName>
        <description>Notification to Banker of Closed Lost MM Opportunities</description>
        <protected>false</protected>
        <recipients>
            <field>Accountable_Banker__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/MMDC_Email_Deal_Closed_Lost</template>
    </alerts>
    <alerts>
        <fullName>Notify_Accountable_Banker_of_new_assignment_to_Opportunity</fullName>
        <description>Notify Accountable Banker of new assignment to Opportunity</description>
        <protected>false</protected>
        <recipients>
            <recipient>Accountable Banker</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Notify_Accountable_Banker_of_assignment_to_Opp</template>
    </alerts>
    <alerts>
        <fullName>Notify_Opp_Owner_of_Opp_flagged_as_Priority</fullName>
        <description>Notify Opp Owner of Opp flagged as Priority (SFA-271)</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Opportunity_flagged_as_Priority</template>
    </alerts>
    <alerts>
        <fullName>Notify_Opp_Owner_of_Opp_not_under_Review_SFA_271</fullName>
        <description>Notify Opp Owner  of Opp not under  Review (SFA-271)</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Opportunity_not_under_Review</template>
    </alerts>
    <alerts>
        <fullName>Notify_Opp_Owner_of_Opp_under_Review</fullName>
        <description>Notify Opp Owner  of Opp under Review (SFA-271)</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Opportunity_under_Review</template>
    </alerts>
    <alerts>
        <fullName>Notify_Opportunity_past_Close_Date_Private_Side</fullName>
        <description>Notify - Opportunity past Close Date (Private Side)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Accountable_Banker__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Overdue_Opportunity_Reminder_Private_Side</template>
    </alerts>
    <alerts>
        <fullName>Recall_Actions_Notification_for_Accountable_Banker</fullName>
        <description>Recall Actions Notification for Accountable Banker</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Accountable_Banker__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Recall_Actions_Notification_for_Accountable_Banker</template>
    </alerts>
    <alerts>
        <fullName>Rejection_notification_email_to_Opp_Owner</fullName>
        <description>Rejection notification email to Opp Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Accountable_Banker__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Rejection_notification_email_to_Opp_Owner</template>
    </alerts>
    <alerts>
        <fullName>SendEmailToNewOwnerOfMMCampaign</fullName>
        <description>SendEmailToNewOwnerOfMMCampaign</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Accountable_Banker__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/MMDC_Email_Opportunity_confirmation</template>
    </alerts>
    <alerts>
        <fullName>Send_To_Insuarance</fullName>
        <ccEmails>virtualshortterm@absa.co.za</ccEmails>
        <description>Send To Insurance For Private Clients</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Email_To_Insurance_For_Closed_CPF_Deals</template>
    </alerts>
    <alerts>
        <fullName>Send_To_Insurance_For_Public_Clients</fullName>
        <ccEmails>virtualshortterm@absa.co.za</ccEmails>
        <description>Send To Insurance For Public Clients</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Email_To_Insurance_For_Closed_CPF_Deals_For_Public_Opps</template>
    </alerts>
    <alerts>
        <fullName>Send_notification_email_to_Accountable_Banker</fullName>
        <description>Send notification email to Accountable Banker</description>
        <protected>false</protected>
        <recipients>
            <field>Accountable_Banker__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Accountable_Banker_Approval_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_notification_email_to_Relationship_and_opportunity_owner</fullName>
        <description>Send notification email to Relationship and opportunity owner</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Opportunity_Created</template>
    </alerts>
    <alerts>
        <fullName>Sends_email_to_on_boarding_team</fullName>
        <description>Sends email to on-boarding team</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Wealth_Email_Templates/Client_On_boarding_Wealth</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Asset_Hub_1_defaults_to_100</fullName>
        <field>Asset_Hub_1perc__c</field>
        <formula>1.00</formula>
        <name>Asset Hub 1 % defaults to 100</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Asset_Hub_1_update_from_Opp_Country</fullName>
        <field>Asset_Hub_1a__c</field>
        <formula>TEXT (Opportunity_Country__c)</formula>
        <name>Asset Hub 1 update from Opp Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Asset_Hub_1perc_reset_to_100</fullName>
        <description>If Asset Hub 2 and 3 are edited to 0%, reset Asset Hub 1 to 100%</description>
        <field>Asset_Hub_1perc__c</field>
        <formula>1</formula>
        <name>Asset Hub 1 % reset  to 100 %</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CheckPrivateOnOpportunity</fullName>
        <field>Private_Side__c</field>
        <literalValue>1</literalValue>
        <name>CheckPrivateOnOpportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Asset_Hub</fullName>
        <field>Asset_Hub_2perc__c</field>
        <formula>0</formula>
        <name>Clear Asset Hub %</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Asset_Hub_3perc</fullName>
        <field>Asset_Hub_3perc__c</field>
        <formula>0</formula>
        <name>Clear Asset  Hub 3 %</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Priority_Reason</fullName>
        <description>SFA-271 - clear field Piority Reason when Priority is unchecked</description>
        <field>Priority_Reason__c</field>
        <name>Clear Priority Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Review_Reason</fullName>
        <description>SFA-271 clear the reason selected for Opportunity under Review when Review is unchecked</description>
        <field>Review_Reason__c</field>
        <name>Clear Review Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_opportunity_name</fullName>
        <description>Copy opportunity name to unique opportunity name</description>
        <field>Unique_Opportunity_Name__c</field>
        <formula>Name</formula>
        <name>Copy opportunity name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increment_Push_Counter_Field</fullName>
        <description>Increment the Push Counter by 1</description>
        <field>Push_Counter__c</field>
        <formula>IF(ISNULL(Push_Counter__c)= TRUE ,1, Push_Counter__c + 1)</formula>
        <name>Increment Push Counter Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mandate_Won_date</fullName>
        <field>Mandate_Won_date__c</field>
        <formula>TODAY()</formula>
        <name>Mandate Won date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Overdue_Reminder_Sent_False</fullName>
        <description>Change Checkbox value to False one day after the workflow rule fired.</description>
        <field>Overdue_reminder_sent__c</field>
        <literalValue>0</literalValue>
        <name>Overdue Reminder Sent - False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_Private_if_Priv_Side_Check</fullName>
        <description>Opportunity Record type auto updated when Private Side Checkbox is checked</description>
        <field>RecordTypeId</field>
        <lookupValue>Private_opportunity_RT</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record Type Private if  Priv Side Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reject_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Reject Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approved</fullName>
        <field>ProductPartnerApprovalStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Set Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Private_Side_to_False</fullName>
        <description>Unchecks Private Side Checkbox when Opp Record type is changed to Public</description>
        <field>Private_Side__c</field>
        <literalValue>0</literalValue>
        <name>Set Private Side to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Private_Side_to_True</fullName>
        <field>Private_Side__c</field>
        <literalValue>1</literalValue>
        <name>Set Private Side to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Trigger_Date</fullName>
        <field>hSetOverdueReminderDate__c</field>
        <formula>NOW()</formula>
        <name>Set Trigger Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Pending_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Status Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateProductPartnerStatusApproved</fullName>
        <field>ProductPartnerApprovalStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>UpdateProductPartnerStatusApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateProductPartnerStatusNotSubmitted</fullName>
        <field>ProductPartnerApprovalStatus__c</field>
        <literalValue>Not Submitted</literalValue>
        <name>UpdateProductPartnerStatusNotSubmitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateProductPartnerStatusPending</fullName>
        <field>ProductPartnerApprovalStatus__c</field>
        <literalValue>Pending</literalValue>
        <name>UpdateProductPartnerStatusPending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateProductPartnerStatusRejected</fullName>
        <field>ProductPartnerApprovalStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>UpdateProductPartnerStatusRejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRecordTypeOfOPP</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Private_opportunity_RT</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdateRecordTypeOfOPP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Field_owner_role_BB</fullName>
        <description>If user is in Role containing BB, the field will be updated to BB User (Business Bank)</description>
        <field>BB_CIB_user__c</field>
        <literalValue>BB User</literalValue>
        <name>Update Field owner role BB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Stage_Change_Date</fullName>
        <description>Updates the Last Stage Change Date field with the current Date</description>
        <field>Last_Stage_Change_Date__c</field>
        <formula>Today()</formula>
        <name>Update Last Stage Change Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Overdue_Reminder_Set_to_True</fullName>
        <field>Overdue_reminder_sent__c</field>
        <literalValue>1</literalValue>
        <name>Update Overdue Reminder Set to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_the_Owner_Role_Field</fullName>
        <description>Update the Owner Role Field if the owner role contains the words CIB</description>
        <field>BB_CIB_user__c</field>
        <literalValue>CIB User</literalValue>
        <name>Update the Owner Role Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Asset Hub 1 %25 default to 100</fullName>
        <actions>
            <name>Asset_Hub_1_defaults_to_100</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Asset_Hub_1perc__c</field>
            <operation>lessThan</operation>
            <value>100</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Asset Hub 1 %25 reset to 100</fullName>
        <actions>
            <name>Asset_Hub_1perc_reset_to_100</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Asset Hub 2 and 3 are reset to 0, AH 1 to be reset to 100%</description>
        <formula>Asset_Hub_2perc__c  = 0 &amp;&amp;  Asset_Hub_3perc__c = 0 &amp;&amp; (PRIORVALUE (Asset_Hub_2perc__c )  &lt;&gt; 0 ||PRIORVALUE (Asset_Hub_3perc__c )  &lt;&gt; 0)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Asset Hub 1 updated from Opp Country</fullName>
        <actions>
            <name>Asset_Hub_1_update_from_Opp_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Asset_Hub_1a__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Big Deal Alert</fullName>
        <actions>
            <name>Big_Deal_Alert_For_Trade_Product</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify a group of users for big deals that are bigger that 1.5M</description>
        <formula>AND( Annualised_Income__c  &gt;= 1500000,  CONTAINS(ProductList__c  , &apos;Trade&apos;) , ISCHANGED( StageName ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ChangeRecordTypeOfOppToPrivate</fullName>
        <actions>
            <name>CheckPrivateOnOpportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateRecordTypeOfOPP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>if there is private product assigned to opportunity this workflow will change the record type of opportunity to private</description>
        <formula>AND( RecordType.Name = &apos;Public opportunity&apos; , OR( CONTAINS( ProductList__c ,  $Setup.PrivateProducts__c.PrivateProduct1__c ),  CONTAINS( ProductList__c ,  $Setup.PrivateProducts__c.PrivateProduct2__c ),  CONTAINS( ProductList__c ,  $Setup.PrivateProducts__c.PrivateProduct4__c ),  CONTAINS( ProductList__c ,  $Setup.PrivateProducts__c.PrivateProduct5__c ),  CONTAINS( ProductList__c ,  $Setup.PrivateProducts__c.PrivateProduct6__c ) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check Private Side if Record Type is Private opp</fullName>
        <actions>
            <name>Set_Private_Side_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Private opportunity</value>
        </criteriaItems>
        <description>If user loads Private Opp, the checbox Private Side is automatically checked.
This checkbox is not on the page layout but maintained in the event that any workflow fires based on the check</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear Asset Hub %25</fullName>
        <actions>
            <name>Clear_Asset_Hub</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Asset_Hub_3perc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2)or (3 AND 4)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Asset_Hub_2__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Asset_Hub_2perc__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Asset_Hub_3__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Asset_Hub_3perc__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear Priority Reason</fullName>
        <actions>
            <name>Clear_Priority_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Priority__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>SFA-271 - uses Field Update : Clear Priority Reason</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clear Review Reason</fullName>
        <actions>
            <name>Clear_Review_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Review__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>SFA-271 - uses Field Update : Clear Review Reason</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Notification to the Accountable Banker for MM Campaign</fullName>
        <actions>
            <name>Email_Notification_to_Accountable_Banker_related_to_the_MM_Campaign</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Inform the Accountable banker of a new MM Campaign opportunity</description>
        <formula>AND(
Campaign.Name =&apos;Money Market Deposit Campaign&apos;,  ISCHANGED(Accountable_Banker__c)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Liquidity And Working Capital Alert</fullName>
        <actions>
            <name>Liquidity_And_Working_Capital_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Opportunity_Country__c</field>
            <operation>equals</operation>
            <value>South Africa</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ProductLevel2List__c</field>
            <operation>equals</operation>
            <value>Collections,Payments</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ProductLevel2List__c</field>
            <operation>contains</operation>
            <value>Information</value>
        </criteriaItems>
        <description>This will send an email to the Liduidity and Working Capital when a Transactional Banking Product is added.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mandate won field update</fullName>
        <actions>
            <name>Mandate_Won_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Mandate Won</value>
        </criteriaItems>
        <description>Update with time when mandate is won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification to Banker of Closed Lost MM Opportunities</fullName>
        <actions>
            <name>Notification_to_Banker_of_Closed_Lost_MM_Opportunities</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email notification to the Banker of Closed Lost Opportunities</description>
        <formula>AND( Campaign.Name = &apos;Money Market Deposit Campaign&apos;, TEXT(StageName) = &apos;Closed Lost&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notification to Banker of Closed Won MM Opportunities</fullName>
        <actions>
            <name>Email_notification_to_Banker_notifying_of_Closed_Won_Opportunity</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email notification to the Banker of Closed Won Opportunities</description>
        <formula>AND( Campaign.Name = &apos;Money Market Deposit Campaign&apos;, TEXT(StageName) = &apos;Closed Won&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Acc Banker of assignment to Opp%2E</fullName>
        <actions>
            <name>Notification_email_to_Accountable_Banker</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Private opportunity</value>
        </criteriaItems>
        <description>Sends email when AB is added to Opportunity via lookup field</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Opportunity owner Opportunity under Review</fullName>
        <actions>
            <name>Notify_Opp_Owner_of_Opp_under_Review</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Review__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFA 271 - If checkbox Review  is checked, notify  Opp owner  via email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Opportunity owner Opportunityflagged as Priority</fullName>
        <actions>
            <name>Notify_Opp_Owner_of_Opp_flagged_as_Priority</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFA 271 - If checkbox Priority  is checked, notify  Opp owner, Manager and Account Owner  via email</description>
        <formula>Priority__c  = True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>On-boarding Email Trigger</fullName>
        <actions>
            <name>Sends_email_to_on_boarding_team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Credit and Banking,Investment</value>
        </criteriaItems>
        <description>Emails the opportunity to the opportunity owner to alert that relationship linked to opportunity is ready to be on-boarded</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Record Type must be Private</fullName>
        <actions>
            <name>Record_Type_Private_if_Priv_Side_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Private_Side__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Owner notification for MM Campaign</fullName>
        <actions>
            <name>SendEmailToNewOwnerOfMMCampaign</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Informing the opportunity owner linked to the MM Campaign</description>
        <formula>AND( Campaign.Name =&apos;Money Market Deposit Campaign&apos;, ISCHANGED(OwnerId) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Owner to perform conflict check</fullName>
        <actions>
            <name>Conflict_Clearing_Check</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Private_Side__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Opportunity owner to perform conflict check for private opportunities</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ProductPartnerApprovalStatusUpdater</fullName>
        <actions>
            <name>Set_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(Owner.Id == ProductPartner__c ,   ISPICKVAL(ProductPartnerApprovalStatus__c , &apos;Not Submitted&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Push Counter</fullName>
        <actions>
            <name>Increment_Push_Counter_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Increments the push counter by one each time the Close Date is changed</description>
        <formula>IF((CloseDate &lt;&gt; PRIORVALUE( CloseDate )),true,false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Overdue Reminder</fullName>
        <actions>
            <name>Notification_Opportunity_Close_Date</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Trigger_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Overdue_Reminder_Set_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 and 5</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Private_Side__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Days_since_expected_Close_date__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Closed Won,Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.BB_CIB_user__c</field>
            <operation>equals</operation>
            <value>CIB User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Overdue_reminder_sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>SFA-348 Workflow trigger.  Sends reminder to update overdue open Opportunity for CIB Public Opps</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Overdue Reminder - Private Side</fullName>
        <actions>
            <name>Notify_Opportunity_past_Close_Date_Private_Side</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Trigger_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Overdue_Reminder_Set_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 and 5</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Private_Side__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Days_since_expected_Close_date__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Closed Won,Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.BB_CIB_user__c</field>
            <operation>equals</operation>
            <value>CIB User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Overdue_reminder_sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>SFA-348 Workflow trigger.  Sends reminder to update overdue open Opportunity for CIB Private Opps</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Overdue Reminder to False</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.hSetOverdueReminderDate__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SFA-348 Workflow rule SEND OVERDUE REMINDER  trigger.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Overdue_Reminder_Sent_False</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Opportunity.hSetOverdueReminderDate__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Tender%2FProposal Support</fullName>
        <actions>
            <name>Email_Tender_Proposal_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Require_Proposal_Support__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>Sends out the Email to the Responsible Tender/Proposal Team Member, to update him/her that a Proposal support is need from a Banker.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Uncheck Private Side if Record Type is changed to Public</fullName>
        <actions>
            <name>Set_Private_Side_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Public opportunity</value>
        </criteriaItems>
        <description>Uncheck Private Side if Record Type is changed to Public</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Last Stage Change Date</fullName>
        <actions>
            <name>Update_Last_Stage_Change_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow used to update the last time the stage changed on an opportunity</description>
        <formula>NOT(ISBLANK(TEXT(StageName))) &amp;&amp; ISCHANGED(StageName)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Owner Role BB</fullName>
        <actions>
            <name>Update_Field_owner_role_BB</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>CONTAINS(Owner.UserRole.Name, &quot;BB&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Owner Role CIB</fullName>
        <actions>
            <name>Update_the_Owner_Role_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>CONTAINS(Owner.UserRole.Name, &quot;CIB&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Wealth Notification - Opportunity Close Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Closed Won,Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.BB_CIB_user__c</field>
            <operation>notEqual</operation>
            <value>CIB User</value>
        </criteriaItems>
        <description>Sends notification to opportunity owner when close date has passed</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notification_Opportunity_Close_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
