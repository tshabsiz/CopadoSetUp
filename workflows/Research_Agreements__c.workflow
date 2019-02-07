<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MIFID_II_Client_updated_on_RA</fullName>
        <field>MIFID_II_Client__c</field>
        <literalValue>1</literalValue>
        <name>MIFID II Client? updated on RA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Research_Agr_Expiry_update</fullName>
        <field>Research_Agreement_Expiry__c</field>
        <formula>Research_Agreement_Effective__c + 90</formula>
        <name>Research Agr Expiry update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Research Agreement Expiry update</fullName>
        <actions>
            <name>Research_Agr_Expiry_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Research_Agreements__c.Research_Agreement_Type__c</field>
            <operation>contains</operation>
            <value>Trial</value>
        </criteriaItems>
        <criteriaItems>
            <field>Research_Agreements__c.Research_Agreement_Effective__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>For Trial Agreements</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Research_Agreement</fullName>
        <assignedTo>lusiazelda.anderson@absa1.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Please take requisite action prior to expiry of this research agreement.</description>
        <dueDateOffset>-30</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Research_Agreements__c.Research_Agreement_Expiry__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Research Agreement Expiring</subject>
    </tasks>
</Workflow>
