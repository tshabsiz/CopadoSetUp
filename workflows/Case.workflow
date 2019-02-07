<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CSC_Case_Closure</fullName>
        <description>CSC Case Closure</description>
        <protected>false</protected>
        <recipients>
            <field>Email_From_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CSC_Auto_Response_Templates/CSC_Case_Closure_General</template>
    </alerts>
    <alerts>
        <fullName>CSC_Case_Creation_Notification</fullName>
        <description>CSC Case Creation Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Email_From_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CSC_Auto_Response_Templates/CSC_Case_Creation_General</template>
    </alerts>
    <alerts>
        <fullName>CSC_Case_Escalation_Email_Alert</fullName>
        <description>CSC Case Escalation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Team Leader</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Team Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CSC_Auto_Response_Templates/Escalation_Notification</template>
    </alerts>
    <alerts>
        <fullName>CSC_Email_Receipt</fullName>
        <description>CSC Email Receipt</description>
        <protected>false</protected>
        <recipients>
            <field>Email_From_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CSC_Auto_Response_Templates/CSC_Email_Receipt_General</template>
    </alerts>
    <alerts>
        <fullName>CSC_Escalation_Notification</fullName>
        <description>CSC Escalation Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Team Leader</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Team Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CSC_Auto_Response_Templates/Escalation_Notification</template>
    </alerts>
    <alerts>
        <fullName>Case_Closure_Created_by</fullName>
        <description>Case Closure Created by</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Complaints_Email_Templates/Complaint_Case_Closure_Created_by</template>
    </alerts>
    <alerts>
        <fullName>Case_Closure_Owner</fullName>
        <description>Case Closure Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Complaints_Email_Templates/Complaint_Case_Closure_Owner</template>
    </alerts>
    <alerts>
        <fullName>Complaint_Case_Closure</fullName>
        <description>Complaint Case Closure</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Complaints_Email_Templates/Complaints_Case_Closure</template>
    </alerts>
    <alerts>
        <fullName>Complaints_Queue_Notifications</fullName>
        <description>Complaints Queue Notifications</description>
        <protected>false</protected>
        <recipients>
            <field>Complaint_Notification_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Complaints_Email_Templates/Complaints_Case_Creation_Internal2</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_CIB_Chief_of_Staff_Queue_members_notified_new_request_in_is_t</fullName>
        <description>Email Notification - CIB - Chief of Staff Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_CIB_Chief_of_Staff_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_CIB_Markets_Queue_members_notified_new_request_in_is_the_queu</fullName>
        <description>Email Notification - CIB - Markets Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_CIB_Chief_of_Staff_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_CIB_Regulatory_Knowledge_Queue_members_notified_new_request_i</fullName>
        <description>Email Notification - CIB - Regulatory &amp; Knowledge Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_CIB_Regulatory_Knowledge_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_CIB_Wholesale_Legal_Queue_members</fullName>
        <description>Email Notification - CIB - Wholesale Legal Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_CIB_Wholesale_Legal_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_Legal_Request_Queue_members_notified_new_request_in_is_the_qu</fullName>
        <description>Email Notification - CIB - Banking Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_CIB_Banking_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_RBB_ARBB_Queue_members_notified_new_request_in_is_the_queue</fullName>
        <description>Email Notification - RBB - ARBB Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_RBB_ARBB_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_Shared_Services_Commercial_Legal_Queue_members_notified_new_r</fullName>
        <description>Email Notification - Shared Services - Commercial Legal Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_Shared_Services_Commercial_Legal_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_Shared_Services_Group_Corporate_Queue_members_notified_new_re</fullName>
        <description>Email Notification - Shared Services - Group Corporate Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_Shared_Services_Group_Corporate_Leg_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_Shared_Services_HR_EIP_Queue_members_notified</fullName>
        <description>Email Notification - Shared Services - HR &amp; EIP Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_Shared_Services_HR_EIP_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_Shared_Services_IntellectualProp_Queue_members_notified_new_r</fullName>
        <description>Email Notification - Shared Services - IntellectualProp Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_Shared_Services_Intellectual_Prop_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_Shared_Services_Litigation_Queue_members_notified_new_request</fullName>
        <description>Email Notification - Shared Services - Litigation Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_Shared_Services_Litigation_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_Shared_Services_Regulatory_Legal_Queue_members_notified_new_r</fullName>
        <description>Email Notification - Shared Services - Regulatory Legal Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_Shared_Services_Regulatory_Legal_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_WIMI_Fiduciary_Queue_members_notified_new_request_in_is_the_q</fullName>
        <description>Email Notification - WIMI - Fiduciary Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_WIMI_Fiduciary_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_WIMI_Insurance_Queue_members_notified_new_request_in_is_the_q</fullName>
        <description>Email Notification - WIMI - Insurance Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_WIMI_Insurance_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_WIMI_Investment_Cluster_Queue_members_notified</fullName>
        <description>Email Notification - WIMI - Investment Cluster Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_WIMI_Investment_Cluster_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_WIMI_Investment_Cluster_Queue_members_notified_new_request_in</fullName>
        <description>Email Notification - WIMI - Investment Cluster Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_WIMI_Investment_Cluster_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_WIMI_Wealth_Management_Dist_Queue_members_notified_new_reques</fullName>
        <description>Email Notification - 	WIMI - Wealth Management &amp; Dist Queue members notified new request in is the queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Legal_Request_WIMI_Wealth_Managment_Dist_Auto_response_email</template>
    </alerts>
    <alerts>
        <fullName>Email_Submitter_to_notify_that_KM_requested_is_Rejected</fullName>
        <description>Email Submitter to notify that KM requested is Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Reject_KM_Submission_Reponse</template>
    </alerts>
    <alerts>
        <fullName>Email_notification1</fullName>
        <description>Email notification1</description>
        <protected>false</protected>
        <recipients>
            <recipient>Support Team</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CIBSupportCaseNewcaseassignmentnotification</template>
    </alerts>
    <alerts>
        <fullName>Feedback_Logger_Notification</fullName>
        <description>Feedback Logger Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Complaints_Email_Templates/Complaints_Case_Creation_Logger</template>
    </alerts>
    <alerts>
        <fullName>LEAP_Email_Notification_of_Allocation_of_Work</fullName>
        <description>LEAP - Email Notification of Allocation of Work</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Legal_Allocation_of_KM_Work</template>
    </alerts>
    <alerts>
        <fullName>LEAP_Notify_KM_that_Knowledge_Request_is_Approved</fullName>
        <description>LEAP - Notify KM that Knowledge Request is Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Request_to_Approve_Knowledge_Request</template>
    </alerts>
    <alerts>
        <fullName>LEAP_Notify_Reviewer_of_Artifact_Review</fullName>
        <description>LEAP - Notify Reviewer of Artifact Review</description>
        <protected>false</protected>
        <recipients>
            <field>Content_Reviewer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/BAGL_Legal_Artifact_ready_for_review</template>
    </alerts>
    <alerts>
        <fullName>Leap_BAGL_Legal_Artifact_Automation_ready_to_be_tested</fullName>
        <description>Leap - BAGL Legal – Artifact Automation ready to be tested</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Content_Reviewer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/BAGL_Legal_Artifact_Automation_ready_to_be_tested</template>
    </alerts>
    <alerts>
        <fullName>Leap_BAGL_Legal_Artifact_ready_for_automation</fullName>
        <description>Leap - BAGL Legal – Artifact ready for automation</description>
        <protected>false</protected>
        <recipients>
            <recipient>Leap - Document Automation Team</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/BAGL_Legal_Artifact_ready_for_automation</template>
    </alerts>
    <alerts>
        <fullName>Notification_received_by_new_owner_if_KM_work_owner_changed</fullName>
        <description>Notification received by new owner if KM work owner changed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Legal_Allocation_of_KM_Work</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Matter_Owner_on_Allocation_of_Matter</fullName>
        <description>Notification to Matter Owner on Allocation of Matter</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Notification_to_Matter_Owner_Matter_Allocated</template>
    </alerts>
    <alerts>
        <fullName>Notify_Complaints_Team</fullName>
        <description>Notify Complaints Team</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Complaints_Email_Templates/Complaints_Case_Creation_Internal2</template>
    </alerts>
    <alerts>
        <fullName>Notify_Requester_Matter_Query_Allocated</fullName>
        <description>Notify Requester - Matter/Query Allocated</description>
        <protected>false</protected>
        <recipients>
            <field>Email_From_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/Notification_to_Requestor_Matter_Allocated</template>
    </alerts>
    <alerts>
        <fullName>SLA_Date_1_Reached</fullName>
        <description>SLA Date 1 Reached</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Team_Manager_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Complaints_Email_Templates/Complaints_Case_Escalation</template>
    </alerts>
    <alerts>
        <fullName>SLA_Date_1_Warning</fullName>
        <description>SLA Date 1 Warning</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Team_Manager_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Complaints_Email_Templates/Complaints_Case_Reminder</template>
    </alerts>
    <alerts>
        <fullName>SLA_Date_2_Passed</fullName>
        <description>SLA Date 2 Passed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Department_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Team_Manager_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Complaints_Email_Templates/Complaints_Case_Escalation_2</template>
    </alerts>
    <alerts>
        <fullName>SLA_Date_2_Reached</fullName>
        <description>SLA Date 2 Reached</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Department_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Team_Manager_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Complaints_Email_Templates/Complaints_Case_Escalation_1</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Status_Updater</fullName>
        <field>Status</field>
        <literalValue>Closed Duplicate</literalValue>
        <name>Case Status Updater</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LEAP_Reassign_to_KM_Team</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Request_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>LEAP - Reassign to KM Team</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Assign_To_Document_Automation_Tea</fullName>
        <field>OwnerId</field>
        <lookupValue>Document_Automation_Team</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Leap - Assign To Document Automation Tea</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Reassign_to_KM_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Request_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Leap - Reassign to KM Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Case_Owner_To_KM</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Request_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Leap  - Update Case Owner To KM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Date_Field_Approved</fullName>
        <description>Update the date field &quot;Approved&quot; on update of the case status to &quot;Approved&quot;</description>
        <field>Approved__c</field>
        <formula>Today ()</formula>
        <name>Leap  - Update Date Field Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Date_Field_Pending_Approv</fullName>
        <field>Submitted_For_Approval__c</field>
        <formula>Today ()</formula>
        <name>Leap  - Update Date Field Pending Approv</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Date_Field_Previous_Rev</fullName>
        <field>Previous_Review_Date__c</field>
        <formula>Today()</formula>
        <name>Leap  - Update Date Field Previous Rev</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Date_Sign_Off_Field</fullName>
        <field>Signed_Off__c</field>
        <formula>Today()</formula>
        <name>Leap  - Update Date Sign Off Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Owner_To_KM_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Request_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Leap - Update Owner To KM Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Previous_Review_Date</fullName>
        <field>Previous_Review_Date__c</field>
        <formula>Submitted_For_Approval__c</formula>
        <name>Leap - Update Previous Review Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Ready_For_UAT_Date</fullName>
        <field>Ready_For_UAT__c</field>
        <formula>Today ()</formula>
        <name>Leap - Update Ready For UAT Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Status_To_Ready_For_Rev</fullName>
        <field>Status</field>
        <literalValue>Ready For Review</literalValue>
        <name>Leap  - Update Status To Ready For Rev</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Status_To_Rejected</fullName>
        <field>Status</field>
        <literalValue>UAT Rejected</literalValue>
        <name>Leap - Update Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Status_to_Ready_For_Use</fullName>
        <field>Status</field>
        <literalValue>UAT Approved</literalValue>
        <name>Leap  - Update Status to Ready For Use</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_Submit_For_Review_Date</fullName>
        <field>Submitted_For_Review__c</field>
        <formula>Today ()</formula>
        <name>Leap - Update Submit For Review Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leap_Update_To_KM_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Request_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Leap  - Update To KM Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QueueStatusinProgress</fullName>
        <description>Updating the Status of the case to In Progress once a</description>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>QueueStatusinProgress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Feedback_Flag</fullName>
        <field>Reset_Feedback_Alert__c</field>
        <literalValue>0</literalValue>
        <name>Reset Feedback Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_owner_for_Escalations</fullName>
        <description>The case owner field is updated once the stage is set to Escalated</description>
        <field>OwnerId</field>
        <lookupValue>LEVEL_1_ESCALATION_QUEUE</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Case owner for Escalations</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Client_Alert_Flag</fullName>
        <description>RN - CloudSmiths 
Update the checkbox that will indicate to the case trigger to fire of a client feedback alert</description>
        <field>Fire_Feedback_Alert__c</field>
        <literalValue>1</literalValue>
        <name>Update Client Alert Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Counter</fullName>
        <description>RN - CloudSmiths - Incriment the case ownership change field by 1</description>
        <field>Number_of_Ownership_Changes__c</field>
        <formula>(Number_of_Ownership_Changes__c + 1)</formula>
        <name>Update Counter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_KM_Team_Added</fullName>
        <field>Knowledge_Team_Added__c</field>
        <literalValue>1</literalValue>
        <name>Update KM Team Added</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Notification_Email</fullName>
        <description>RN - Update the email field based on team name for complaints</description>
        <field>Complaint_Notification_Address__c</field>
        <formula>CASE(Queue__c, &apos;Complaints - Banking&apos;,
&apos;abcapprivatesideadv@barclayscapital.com&apos;,
&apos;Complaints - Corporate&apos;,
&apos;panafricacorporatec@barclayscapital.com&apos;,
&apos;Complaints - Markets&apos;,
&apos;abcapcompliancemark@barclayscapital.com&apos;,
null)</formula>
        <name>Update Notification Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Original_Description</fullName>
        <description>RN - CloudSmiths - UPdate the read-only field with the original case description</description>
        <field>Description_Original__c</field>
        <formula>Description</formula>
        <name>Update Original Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Query_to_Matter_type</fullName>
        <field>Type</field>
        <literalValue>New/Existing Matter</literalValue>
        <name>LEAP - Update Query to Matter type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <field>Status</field>
        <literalValue>Escalated</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>All Complaints Case</fullName>
        <actions>
            <name>Update_Original_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint,MNPI Complaint</value>
        </criteriaItems>
        <description>RN - CloudSmiths - Rule fires for all complaint cases</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CSC Escalation Notifications</fullName>
        <actions>
            <name>CSC_Case_Escalation_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.hSendEscalationNotification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>CSC Default Support Cases</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Ownership Change</fullName>
        <actions>
            <name>Update_Counter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>RN - CloudSmiths - Rule fires when the case owner changes</description>
        <formula>ISCHANGED(OwnerId)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case escalation</fullName>
        <actions>
            <name>Update_Case_owner_for_Escalations</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <description>When users change the case status to &apos;Escalated&apos; manually, the case owner is updated to the &apos;escalation queue&apos;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Complaint Case Closure</fullName>
        <actions>
            <name>Case_Closure_Created_by</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Closure_Owner</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Complaint_Case_Closure</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint,MNPI Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Complaint Case Escalation</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint,MNPI Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SLA_Date_2_Passed</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.SLA_Date_2__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>SLA_Date_1_Warning</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.SLA_Date_1__c</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>SLA_Date_2_Reached</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.SLA_Date_2__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Complaint Full Team Change</fullName>
        <actions>
            <name>Complaints_Queue_Notifications</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Notification_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Email_Notification_Sent_to_New_Case_Owner</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>RN - CloudSmiths - Rule fires when the full team of a complaint changes or the first time the full team is one of the complaints sections</description>
        <formula>( ISNEW() || ISCHANGED( Resolving_Team__c ) ) &amp;&amp;  ( RecordType.DeveloperName = &apos;MNPI_Complaint&apos; ||  RecordType.DeveloperName = &apos;Complaint&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Daily Leavers Field Updater</fullName>
        <actions>
            <name>Case_Status_Updater</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>equals</operation>
            <value>Salesforce Daily Leavers Processing Error</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>equals</operation>
            <value>Africa Salesforce Daily Leavers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Out of Office</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Support Case,Client Support Case</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Feedback Logger Notification</fullName>
        <actions>
            <name>Feedback_Logger_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>MNPI Complaint,Complaint</value>
        </criteriaItems>
        <description>Feedback Logger Notification</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - BAGL Legal %E2%80%93 Allocation of KM Work %28New Owner%29</fullName>
        <actions>
            <name>Notification_received_by_new_owner_if_KM_work_owner_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Knowledge Request Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <description>Knowledge management or operations team member would like to be notified when made owner of a submitted knowledge piece.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - BAGL Legal %E2%80%93 Allocation of KM Work %28Queue%29</fullName>
        <actions>
            <name>LEAP_Email_Notification_of_Allocation_of_Work</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Knowledge Request Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <description>Knowledge management or operations team member would like to be notified when made owner of a submitted knowledge piece.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notification on Allocation of A Matter - Matter Owner %28AdvoLogix%29</fullName>
        <actions>
            <name>Notification_to_Matter_Owner_on_Allocation_of_Matter</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Matter owner notified that they have a Matter Allocated to them.</description>
        <formula>AND( ISCHANGED(OwnerId), PRIORVALUE(OwnerId) = &quot;00G9E000000ZRk3&quot;, NOT(BEGINS(OwnerId, &quot;00G&quot;)),  NOT(ISBLANK( Matter__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify %09WIMI - Wealth Management %26 Dist Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_WIMI_Investment_Cluster_Queue_members_notified_new_request_in</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>WIMI - Wealth Management &amp; Dist Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify CIB - Banking Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_Legal_Request_Queue_members_notified_new_request_in_is_the_qu</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>CIB - Banking Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify CIB - Chief of Staff Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_CIB_Chief_of_Staff_Queue_members_notified_new_request_in_is_t</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>CIB - Chief of Staff Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify CIB - Markets Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_CIB_Markets_Queue_members_notified_new_request_in_is_the_queu</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>CIB - Markets Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify CIB - Regulatory %26 Knowledge Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_CIB_Regulatory_Knowledge_Queue_members_notified_new_request_i</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>CIB - Regulatory &amp; Knowledge Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify CIB - Wholesale Legal Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_CIB_Wholesale_Legal_Queue_members</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>CIB - Wholesale Legal Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_Legal_Request_Queue_members_notified_new_request_in_is_the_qu</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.hOwnerQueueName__c</field>
            <operation>equals</operation>
            <value>Legal Request Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify RBB - ARBB Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_RBB_ARBB_Queue_members_notified_new_request_in_is_the_queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>RBB - ARBB Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify Requestor Assignment %28AdvoLogix%29</fullName>
        <actions>
            <name>Notify_Requester_Matter_Query_Allocated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Matter owner the Requestor of the legal work to be notified when a matter is allocated and when a Lead Lawyer is added</description>
        <formula>ISCHANGED( OwnerId ) &amp;&amp;   RecordType.Name = &quot;Query/Matter Request&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify Shared Services - Commercial Legal Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_Shared_Services_Commercial_Legal_Queue_members_notified_new_r</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Shared Services - Commercial Legal Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify Shared Services - Group Corporate Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_Shared_Services_Group_Corporate_Queue_members_notified_new_re</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Shared Services - Group Corporate Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify Shared Services - HR %26 EIP Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_Shared_Services_HR_EIP_Queue_members_notified</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Shared Services - HR &amp; EIP Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify Shared Services - IntellectualProp Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_Shared_Services_IntellectualProp_Queue_members_notified_new_r</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Shared Services - IntellectualProp Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify Shared Services - Litigation Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_Shared_Services_Litigation_Queue_members_notified_new_request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Shared Services - Litigation Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify Shared Services - Regulatory Legal Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_Shared_Services_Regulatory_Legal_Queue_members_notified_new_r</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Shared Services - Regulatory Legal Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify WIMI - Fiduciary Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_WIMI_Fiduciary_Queue_members_notified_new_request_in_is_the_q</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>WIMI - Fiduciary Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify WIMI - Insurance Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_WIMI_Insurance_Queue_members_notified_new_request_in_is_the_q</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>WIMI - Insurance Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Notify WIMI - Investment Cluster Queue Members when Cases are in the Queue</fullName>
        <actions>
            <name>Email_Notification_WIMI_Investment_Cluster_Queue_members_notified</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>WIMI - Investment Cluster Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Query/Matter Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Reject KM Submission Notification</fullName>
        <actions>
            <name>Email_Submitter_to_notify_that_KM_requested_is_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason_for_Rejection__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>KM or Operations team member I want to be able to select to reject a KM request that is deemed not-acceptable.
10/10/17 - MS: Update workflow to include Reason for Rejection not equal to blank/null.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Update Type to New%2FExisting Matter</fullName>
        <actions>
            <name>Update_Query_to_Matter_type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If a Query is converted to a Matter, the Case type equals New/Existing Matter.</description>
        <formula>NOT( ISBLANK( Matter__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Leap  - Update Date Field Approved</fullName>
        <actions>
            <name>Leap_Update_Date_Field_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Leap  - Update Date Field Pending Approval</fullName>
        <actions>
            <name>Leap_Update_Date_Field_Pending_Approv</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending Approval</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Leap  - Update Date Field Ready For UAT</fullName>
        <actions>
            <name>Leap_Update_Ready_For_UAT_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Ready For UAT</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Leap  - Update Date Field Submit For Review</fullName>
        <actions>
            <name>Leap_Update_Case_Owner_To_KM</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Leap_Update_Submit_For_Review_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Ready For Review</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Leap  - Update Sign Off Date</fullName>
        <actions>
            <name>Leap_Update_Date_Field_Previous_Rev</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Leap_Update_Date_Sign_Off_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Ready For Use</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Leap - Assign To Document Automation Team</fullName>
        <actions>
            <name>Leap_BAGL_Legal_Artifact_ready_for_automation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Automation in progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Leap - Assignment Of Case To KM Queue</fullName>
        <actions>
            <name>Leap_Update_Owner_To_KM_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_KM_Team_Added</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Knowledge Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Ready For Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Knowledge_Team_Added__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Complaints Case</fullName>
        <actions>
            <name>Notify_Complaints_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint,MNPI Complaint</value>
        </criteriaItems>
        <description>RN - CloudSmiths - Rule fires for all new complaint cases</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Case_Created_Email_Sent_to_the_Client</fullName>
        <assignedTo>adminsupport@barclaysafrica.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Case Created Email Sent to the Client</subject>
    </tasks>
    <tasks>
        <fullName>Case_Resolved_Email_Sent_to_the_Client</fullName>
        <assignedTo>adminsupport@barclaysafrica.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Case Resolved Email Sent to the Client</subject>
    </tasks>
    <tasks>
        <fullName>Email_Notification_Sent_to_New_Case_Owner</fullName>
        <assignedTo>salesforce@system.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Email Notification Sent to New Case Owner</subject>
    </tasks>
    <tasks>
        <fullName>Receipt_Email_Sent_to_the_Client</fullName>
        <assignedTo>adminsupport@barclaysafrica.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Receipt Email Sent to the Client</subject>
    </tasks>
</Workflow>
