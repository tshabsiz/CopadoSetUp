<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Country</fullName>
        <field>Country__c</field>
        <formula>Name</formula>
        <name>Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Create unique coverage country</fullName>
        <actions>
            <name>Country</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Coverage_Country__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Copy Country name in the new country field in ensuring no duplicate countries are created</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
