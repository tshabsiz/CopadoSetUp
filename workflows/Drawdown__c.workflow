<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_to_CIB_Africa_PM_Client_once_a_request_and_its_associated_do</fullName>
        <description>Notification to CIB Africa PM Client once a request and its associated documents have been uploaded</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Draw_down_Request</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_CIB_Africa_Trading</fullName>
        <description>Notification to CIB Africa Trading</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/TMG_Draw_down_Utilization_request</template>
    </alerts>
    <fieldUpdates>
        <fullName>Record_Type_Drawdown_Cancelled</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Drawdown_Cancelled</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record Type Drawdown Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Drawdown_ReadOnly</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record Type Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Update</fullName>
        <field>Status__c</field>
        <literalValue>Governance and Documentation Check Complete</literalValue>
        <name>Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Update1</fullName>
        <field>Supporting_Documentation_Uploaded__c</field>
        <literalValue>0</literalValue>
        <name>Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_status</fullName>
        <field>Status__c</field>
        <literalValue>Governance and Documentation Check Complete</literalValue>
        <name>Update status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>TMG - Drawdown Cancelled</fullName>
        <actions>
            <name>Record_Type_Drawdown_Cancelled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Drawdown__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Drawdown Request Upload</fullName>
        <actions>
            <name>Notification_to_CIB_Africa_PM_Client_once_a_request_and_its_associated_do</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notification_to_CIB_Africa_Trading</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Drawdown__c.Supporting_Documentation_Uploaded__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Drawdown__c.Status__c</field>
            <operation>equals</operation>
            <value>Governance and Documentation Check Complete</value>
        </criteriaItems>
        <description>Send a notification to CIB Africa PM Client once a request and its associated documents have been uploaded so that they are informed and have all the required information to process</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Drawdown Status Update</fullName>
        <actions>
            <name>Record_Type_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Drawdown__c.Supporting_Documentation_Uploaded__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Drawdown__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Drawdown</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
