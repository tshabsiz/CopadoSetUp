<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Uncheck_Apex_Context</fullName>
        <field>Apex_Context__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck_Apex_Context</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Uncheck_Apex_Context</fullName>
        <actions>
            <name>Uncheck_Apex_Context</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Roles__c.Apex_Context__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
