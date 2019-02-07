<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Information_Undertaking_Overdue_Status</fullName>
        <field>Status__c</field>
        <name>Information Undertaking Overdue Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TMG_Make_Activate_Later_Unchecked</fullName>
        <field>Activate_Later__c</field>
        <literalValue>0</literalValue>
        <name>TMG - Make Activate Later Unchecked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TMG_Make_Condition_Active</fullName>
        <field>Active__c</field>
        <literalValue>1</literalValue>
        <name>TMG - Make Condition Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TMG - Activate Later Enable</fullName>
        <actions>
            <name>TMG_Make_Activate_Later_Unchecked</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TMG_Make_Condition_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Condition__c.Activate_Later__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Condition__c.Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
