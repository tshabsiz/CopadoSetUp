<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ProjectNameAvailableAgain</fullName>
        <description>A field update which reavails a Project Name after being reserved by a user</description>
        <field>Reserved__c</field>
        <literalValue>0</literalValue>
        <name>Project Name Available Again</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Project Name Available Again</fullName>
        <active>true</active>
        <criteriaItems>
            <field>ProjectName__c.Reserved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ProjectName__c.Used__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>A workflow rule that makes a project name available again a day from being reserved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ProjectNameAvailableAgain</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
