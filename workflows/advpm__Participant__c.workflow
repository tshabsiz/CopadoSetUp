<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_to_new_Participant</fullName>
        <description>Notification To Participant (User)</description>
        <protected>false</protected>
        <recipients>
            <field>advpm__Staff__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/Matter_Participant_Notification</template>
    </alerts>
    <rules>
        <fullName>TMG - Matter Participant</fullName>
        <actions>
            <name>Notification_to_new_Participant</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL(advpm__Staff__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
