<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Deal_Status_Update</fullName>
        <field>advpm__Status__c</field>
        <literalValue>Current</literalValue>
        <name>Deal Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Deal__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fit_to_Lend_Reviewed_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Fit_To_Lend_Checklist_Reviewed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Fit to Lend Reviewed Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TMG - Fit to Lend Approval</fullName>
        <actions>
            <name>Deal_Status_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Fit_To_Lend_Checklist__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Fit to Lend- Reviewed</fullName>
        <actions>
            <name>Fit_to_Lend_Reviewed_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Fit_To_Lend_Checklist__c.Review_Checklist_Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update Fit to Len Record Type to Reviewed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
