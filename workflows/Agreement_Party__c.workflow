<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TMG_Agreement_Party_Default_Amount</fullName>
        <field>Lender_Amount__c</field>
        <formula>0</formula>
        <name>TMG - Agreement Party Default Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TMG - Lender Amount Default Value</fullName>
        <actions>
            <name>TMG_Agreement_Party_Default_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Agreement_Party__c.Party_Type__c</field>
            <operation>contains</operation>
            <value>Lender</value>
        </criteriaItems>
        <criteriaItems>
            <field>Agreement_Party__c.Lender_Amount__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Default Lender Amount for Party Type = Lender to 0</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
