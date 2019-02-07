<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Claim_Against_Barclays_Probable_for_Approval_amount_needs_to_be_Approved</fullName>
        <description>Claim Against Barclays - Probable for Approval amount needs to be Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>steven.palmer@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Litigation_Matter_Claim_against_Barclays</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_Claim_Against_Barclays_probable_for_approval_amount_rejected</fullName>
        <description>Email Notification - Claim Against Barclays probable for approval amount rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Owner_of_Rejected_Litigation_Matter_notified</template>
    </alerts>
    <alerts>
        <fullName>LEAP_Email_Notification_to_Litigation_Matter_Owner_Probable_Approved</fullName>
        <description>LEAP - Email Notification to Litigation Matter Owner (Probable Approved)</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Owner_of_Approved_Litigation_Matter_notified</template>
    </alerts>
    <alerts>
        <fullName>LEAP_Escalate_Approval_to_GC_if_not_approved_within_30_days_by_Head_of_Litigatio</fullName>
        <description>LEAP - Escalate Approval to GC if not approved within 30 days by Head of Litigation</description>
        <protected>false</protected>
        <recipients>
            <recipient>steven.palmer@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Litigation_Matter_Claim_against_Barclays_Escalated_to_GC</template>
    </alerts>
    <alerts>
        <fullName>TMG_Agreement_Review_Complete</fullName>
        <description>TMG - Agreement Review Complete</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AdvoLogix/TMG_Agreement_Reviewed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Approved_to_No</fullName>
        <field>Litigation_Matter_Approved__c</field>
        <literalValue>No</literalValue>
        <name>Set Approved to No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approved_to_Yes</fullName>
        <field>Litigation_Matter_Approved__c</field>
        <literalValue>Yes</literalValue>
        <name>Set Approved to Yes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Completed_Date</fullName>
        <field>Review_Completed_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Completed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update  Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update  Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Review_Completed</fullName>
        <field>Status__c</field>
        <literalValue>Review Completed</literalValue>
        <name>Update Status Review Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Review_in_Progress</fullName>
        <field>Status__c</field>
        <literalValue>Review in Progress</literalValue>
        <name>Update Status Review in Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Update Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_as_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Status as Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_as_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status as Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LEAP - Probable for Approval not Approved within 30 days</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Approval__c.Litigation_Matter_Approved__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Approval__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Litigation Matter</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>LEAP_Escalate_Approval_to_GC_if_not_approved_within_30_days_by_Head_of_Litigatio</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Approval__c.CreatedDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
