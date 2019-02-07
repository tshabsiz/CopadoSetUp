<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LEAP_Missing_Weekly_Time_Quota</fullName>
        <description>LEAP - Missing Weekly Time Quota</description>
        <protected>false</protected>
        <recipients>
            <field>Line_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>advpm__Staff__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Missing_Weekly_Time_Quota</template>
    </alerts>
    <rules>
        <fullName>LEAP - Missing Weekly Time Quota</fullName>
        <actions>
            <name>LEAP_Missing_Weekly_Time_Quota</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(Quota_Last_Updated__c),  Last_Weeks_Quota_Hours__c &lt; $Setup.TimeManagementSetttings__c.Weekly_Quota_Hours__c, NOT(ISBLANK((TEXT(Quota_Last_Updated__c)))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
