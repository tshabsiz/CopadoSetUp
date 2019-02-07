<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Engaged</fullName>
        <field>Engaged__c</field>
        <literalValue>Primary Bank</literalValue>
        <name>Update Engaged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Primary_Bank</fullName>
        <field>Primary_Bank__c</field>
        <literalValue>Barclays</literalValue>
        <name>Update Primary Bank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate Primary Bank on Country Presence</fullName>
        <actions>
            <name>Update_Engaged</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Primary_Bank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Country_Presence__c.Engaged__c</field>
            <operation>equals</operation>
            <value>Primary Bank</value>
        </criteriaItems>
        <criteriaItems>
            <field>Country_Presence__c.Primary_Bank__c</field>
            <operation>equals</operation>
            <value>Barclays</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
