<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Probability</fullName>
        <field>Probability__c</field>
        <formula>CASE(Stage__c,
&quot;Potential Opportunity Identified&quot;, 0.01,
&quot;Potential Opportunity Engaged&quot;, 0.03,
&quot;Potential Opportunity Convert&quot;, 0.05, 
0)</formula>
        <name>Update Probability</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Potential Opportunity Probability</fullName>
        <actions>
            <name>Update_Probability</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Stage__c )  ||  ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
