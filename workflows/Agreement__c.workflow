<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LIBRA_Update_Agreement_Name_Matter</fullName>
        <field>Name</field>
        <formula>Matter_Deal__r.Name  &amp; &quot; - &quot; &amp; RecordType.Name</formula>
        <name>LIBRA - Update Agreement Name: Matter +</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LIBRA_Update_Business_Unit_ISDA</fullName>
        <description>Update Business Unit to &quot;Prime Services&quot; for ISDA when agreement part of Prime Services</description>
        <field>Business_Unit__c</field>
        <literalValue>Prime Services</literalValue>
        <name>LIBRA - Update Business Unit - ISDA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Agreement_To_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Read_Only_Agreement</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Agreement To Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_To_None</fullName>
        <field>Agreement_Status__c</field>
        <literalValue>Extension</literalValue>
        <name>Update Status To Extension</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_The_Agreement_Record_Type</fullName>
        <description>Update the Agreement Record Type If Cloned</description>
        <field>RecordTypeId</field>
        <lookupValue>Read_Only_Agreement</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update The Agreement Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LIBRA - ISDA Agreement from Prime Services</fullName>
        <actions>
            <name>LIBRA_Update_Business_Unit_ISDA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Business Unit field to &quot;Prime Services&quot; when an ISDA is created from an original Prime Services Deal and Prime Services Client = Yes.</description>
        <formula>AND(ISPICKVAL(Matter_Deal__r.Prime_Services_Client__c ,&quot;Yes&quot;) &amp;&amp; RecordType.Name = &quot;ISDA Agreement&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LIBRA - Update Agreement Name%3A Matter %2B Agreement Type</fullName>
        <actions>
            <name>LIBRA_Update_Agreement_Name_Matter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Agreement__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ISDA Agreement,GMRA Agreement,GMSLA Agreement</value>
        </criteriaItems>
        <description>Workflow that concatenates Matter/Deal with Agreement Type as the Agreement Name</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Change Record Type Agreement</fullName>
        <actions>
            <name>Update_Status_To_None</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_The_Agreement_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Agreement__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Read Only Agreement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Agreement__c.Agreement_Status__c</field>
            <operation>equals</operation>
            <value>Extension</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TMG - Set Agreement To Read Only</fullName>
        <actions>
            <name>Set_Agreement_To_Read_Only</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Agreement__c.Agreement_Status__c</field>
            <operation>equals</operation>
            <value>Extension</value>
        </criteriaItems>
        <criteriaItems>
            <field>Agreement__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Read Only Agreement</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
