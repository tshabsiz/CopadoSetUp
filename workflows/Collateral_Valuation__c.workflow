<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>TMG - Schedule Collateral  Valuation</fullName>
        <actions>
            <name>Collateral_Valuation</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Collateral_Valuation__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Collateral_Valuation</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Collateral_Valuation__c.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Collateral Valuation</subject>
    </tasks>
</Workflow>
