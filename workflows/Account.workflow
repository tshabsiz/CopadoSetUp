<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Legal_Entity_to_Client_Wealth</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Client_Legal_Entity</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Legal Entity to Client Wealth</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Individual_RT_to_Client</fullName>
        <description>Updates Individual record type to record type Individual Client</description>
        <field>RecordTypeId</field>
        <lookupValue>Client_Individual</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Individual RT to Client</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Original_Salesforce_ID</fullName>
        <field>OriginalSalesforceID__c</field>
        <formula>CASESAFEID(Id)</formula>
        <name>Update Original Salesforce ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Copy Original Salesforce ID</fullName>
        <actions>
            <name>Update_Original_Salesforce_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copy Original Salesforce ID</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prospect Individual to Individual Client Wealth</fullName>
        <actions>
            <name>Update_Individual_RT_to_Client</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Prospect - Individual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.CIF__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Changes the Prospect Individual to Client Individual record type when the CIF is entered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Prospect Legal Entity to Client Wealth</fullName>
        <actions>
            <name>Legal_Entity_to_Client_Wealth</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Prospect - Legal Entity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.CIF__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Changes the Prospect Legal Entity to Client record type on wealth record type when CIF is entered</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
