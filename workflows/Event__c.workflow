<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Record_Type_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Function</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record Type Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Event_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>alison@absa1.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Event Owner</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>evDeactivate_Event_Function</fullName>
        <field>Active__c</field>
        <literalValue>0</literalValue>
        <name>evDeactivate Event/Function</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>evDefault_Event_Calendar_OrganiserEmail</fullName>
        <field>Calendar_Organiser_Email__c</field>
        <formula>CreatedBy.Email</formula>
        <name>evDefault_Event_Calendar_OrganiserEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>evDefault_Event_Calendar_OrganiserName</fullName>
        <field>Calendar_Organiser_Name__c</field>
        <formula>CreatedBy.FirstName + &apos; &apos; + CreatedBy.LastName</formula>
        <name>evDefault_Event_Calendar_OrganiserName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>evDeactivate Event if Past Event End Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Event__c.End_Date__c</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event__c.Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Function</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>evDeactivate_Event_Function</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Event__c.End_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>evDefault_Event_Calendar_Organiser</fullName>
        <actions>
            <name>evDefault_Event_Calendar_OrganiserEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>evDefault_Event_Calendar_OrganiserName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event__c.Calendar_Organiser_Name__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Event__c.Calendar_Organiser_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set/default the event/function Calendar Organiser Name and Email to created by user on creation.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>