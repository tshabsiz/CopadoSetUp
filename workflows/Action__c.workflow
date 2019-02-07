<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Action_Prior_Status_Update</fullName>
        <field>Action_Prior_Status__c</field>
        <formula>(PRIORVALUE (Action_Current_Status__c))</formula>
        <name>Action Prior Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Action_Status_III_Update</fullName>
        <description>Update with Action Prior Status when this is changed</description>
        <field>Action_Status_Before_Prior__c</field>
        <formula>(PRIORVALUE (Action_Prior_Status__c))</formula>
        <name>Action Status III Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_Date_to_Action_Current_Status</fullName>
        <field>Action_Current_Status__c</field>
        <formula>TEXT(TODAY()) + &quot; : &quot; + Action_Current_Status__c</formula>
        <name>Add Date to Action Current Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Action Prior Status Update</fullName>
        <actions>
            <name>Action_Prior_Status_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Action_Current_Status__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Action Status III  Update</fullName>
        <actions>
            <name>Action_Status_III_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Action_Prior_Status__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Add Datestamp to Action Status</fullName>
        <actions>
            <name>Add_Date_to_Action_Current_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(Action_Current_Status__c),  NOT(ISBLANK(Action_Current_Status__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
