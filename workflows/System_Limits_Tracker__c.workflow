<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>System_Limit_Notification</fullName>
        <ccEmails>rudolf@cloudsmiths.co.za</ccEmails>
        <description>System Limit Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Internal_Support_Team</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/System_Limits_Notification</template>
    </alerts>
    <alerts>
        <fullName>System_Limits_Workaround_Notification</fullName>
        <ccEmails>rudolf@cloudsmiths.co.za</ccEmails>
        <description>System Limits Workaround Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Internal_Support_Team</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/System_Limits_Workaround_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Flag_Warning_Sent</fullName>
        <field>Warning_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Flag Warning Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Flag_Workaround</fullName>
        <field>Use_WorkAround__c</field>
        <literalValue>1</literalValue>
        <name>Flag Workaround</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Waring Rule</fullName>
        <actions>
            <name>System_Limit_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Flag_Warning_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>RN - CloudSmiths
Rule fires when the warning threshold percentage was reached</description>
        <formula>Current_Threshold__c &gt;=  Warning_Percentage__c &amp;&amp;  Warning_Sent__c = false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Workaround Rule</fullName>
        <actions>
            <name>System_Limits_Workaround_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Flag_Workaround</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>RN - CloudSmiths
Rule fires when the woraround threshold percentage was reached</description>
        <formula>Current_Threshold__c &gt;=  Enforce_Workaround_Percentage__c &amp;&amp;  Use_WorkAround__c = false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
