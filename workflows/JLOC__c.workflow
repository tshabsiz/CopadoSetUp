<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_JLOC_Notification</fullName>
        <ccEmails>AbCapPrivateSideAdv@barclayscapital.com</ccEmails>
        <description>Send JLOC Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Wealth_Email_Templates/JLOC_Email_Notification_on_creation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_JLOC_Status_Draft</fullName>
        <field>JLOC_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Set JLOC Status: Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_JLOC_Status_Sent_to_Committee</fullName>
        <field>JLOC_Status__c</field>
        <literalValue>Sent to Committee</literalValue>
        <name>Set JLOC Status: Sent to Committee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_JLOC_Status_Submitted_to_Secretary</fullName>
        <field>JLOC_Status__c</field>
        <literalValue>Submitted to Secretary</literalValue>
        <name>Set JLOC Status: Submitted to Secretary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>JLOC_Creation_Notification</fullName>
        <actions>
            <name>Send_JLOC_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notification that gets sent out on creation of a JLOC</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
