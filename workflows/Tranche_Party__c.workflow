<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TMG_Tranche_Party_Default_Amount</fullName>
        <field>Facility_Amount__c</field>
        <formula>0</formula>
        <name>TMG - Tranche Party Default Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TMG - Tranche Party Lender Amount Default Value</fullName>
        <actions>
            <name>TMG_Tranche_Party_Default_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Tranche_Party__c.Party_Type__c</field>
            <operation>contains</operation>
            <value>Lender</value>
        </criteriaItems>
        <criteriaItems>
            <field>Tranche_Party__c.Facility_Amount_Formula__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
