<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Notification_to_owner_when_a_month_before_Collateral_expiration_Date</fullName>
        <description>Send Notification to owner  a month before Collateral expiration Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Collateral_Expiration</template>
    </alerts>
    <rules>
        <fullName>TMG - Collateral Expiration</fullName>
        <actions>
            <name>Send_Notification_to_owner_when_a_month_before_Collateral_expiration_Date</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Collateral__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Collateral__c.Expiry_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
