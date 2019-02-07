<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>TMG_Notify_Asset_Manager_7_days_after_Due_Date</fullName>
        <description>TMG - Notify Asset Manager 7 days after Due Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AdvoLogix/TMG_Margin_Ratchet_7_Days_after_Due_Date</template>
    </alerts>
    <alerts>
        <fullName>TMG_Notify_Asset_Manager_7_days_before_Due_Date</fullName>
        <description>TMG - Notify Asset Manager 7 days before Due Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AdvoLogix/TMG_Margin_Ratchet_7_Days_before_Due_Date</template>
    </alerts>
    <alerts>
        <fullName>TMG_Notify_Asset_Managers_7_days_after_Due_Date</fullName>
        <description>TMG - Notify Asset Manager 7 days after Due Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AdvoLogix/TMG_Margin_Ratchet_7_Days_after_Due_Date</template>
    </alerts>
    <alerts>
        <fullName>TMG_Notify_Asset_Managers_7_days_before_Due_Date</fullName>
        <description>TMG - Notify Asset Manager 7 days before Due Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AdvoLogix/TMG_Margin_Ratchet_7_Days_before_Due_Date</template>
    </alerts>
    <fieldUpdates>
        <fullName>TMG_Margin_Ratchet_RecordType_Covenant</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Covenant</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>TMG - Margin Ratchet RecordType-Covenant</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TMG_Margin_Ratchet_Record_Type_Event</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Event</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>TMG - Margin Ratchet Record Type - Event</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TMG - Update Margin Ratchet Record Type to Covenant</fullName>
        <actions>
            <name>TMG_Margin_Ratchet_RecordType_Covenant</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Margin_Ratchet__c.Type__c</field>
            <operation>equals</operation>
            <value>Covenant</value>
        </criteriaItems>
        <criteriaItems>
            <field>Margin_Ratchet__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Covenant</value>
        </criteriaItems>
        <description>Update Margin Ratchet Record Type to Covenant if Type equals Covenant</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Update Margin Ratchet Record Type to Event</fullName>
        <actions>
            <name>TMG_Margin_Ratchet_Record_Type_Event</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Margin_Ratchet__c.Type__c</field>
            <operation>equals</operation>
            <value>Event</value>
        </criteriaItems>
        <criteriaItems>
            <field>Margin_Ratchet__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Event</value>
        </criteriaItems>
        <description>Update Margin Ratchet Record Type to Event if Type equals Event</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
