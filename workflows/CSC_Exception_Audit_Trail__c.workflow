<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CSC_Failure_Notification</fullName>
        <description>CSC Failure Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>nakedi.mashapa@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rudolf.niehaus@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CSC_Auto_Response_Templates/CSC_Failure_Exception</template>
    </alerts>
    <rules>
        <fullName>CSC Failure Exception</fullName>
        <actions>
            <name>CSC_Failure_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CSC_Exception_Audit_Trail__c.Severity__c</field>
            <operation>equals</operation>
            <value>Failure</value>
        </criteriaItems>
        <description>RN - CloudSmiths
Rule fires if there was an exception when creating a new Case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
