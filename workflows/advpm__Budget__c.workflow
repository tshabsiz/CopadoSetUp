<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>advpm__Budget_Send_approved_email_to_requestor</fullName>
        <description>Budget: Send approved email to requestor</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>advpm__Budget_Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>advpm__Budget_Templates/advpm__Budget_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>advpm__Budget_Send_rejected_email_to_requestor</fullName>
        <description>Budget: Send rejected email to requestor</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>advpm__Budget_Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>advpm__Budget_Templates/advpm__Budget_Rejected_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>advpm__Budget_Set_Budget_Lock</fullName>
        <field>advpm__Lock__c</field>
        <literalValue>1</literalValue>
        <name>Budget: Set Budget Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>advpm__Budget_Set_Budget_UnLock</fullName>
        <field>advpm__Lock__c</field>
        <literalValue>0</literalValue>
        <name>Budget: Set Budget UnLock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>advpm__Budget_Set_Date_Approved</fullName>
        <field>advpm__Date_Approved__c</field>
        <formula>NOW()</formula>
        <name>Budget: Set Date Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>advpm__Budget_Set_Date_Submitted</fullName>
        <field>advpm__Date_Submitted__c</field>
        <formula>NOW()</formula>
        <name>Budget: Set Date Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>advpm__Budget_Set_Status_to_Approved</fullName>
        <field>advpm__Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Budget: Set Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>advpm__Budget_Set_Status_to_Rejected</fullName>
        <field>advpm__Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Budget: Set Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>advpm__Budget_Set_Status_to_Submitted</fullName>
        <field>advpm__Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Budget: Set Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
