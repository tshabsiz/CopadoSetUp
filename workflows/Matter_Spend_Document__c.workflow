<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LEAP_BAGL_Legal_Request_to_approve_spend</fullName>
        <description>LEAP - BAGL Legal – Request to approve spend</description>
        <protected>false</protected>
        <recipients>
            <field>Spend_Schedules_Owners_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Legal_Request_to_approve_spend_schedule</template>
    </alerts>
    <alerts>
        <fullName>LEAP_BAGL_Legal_Request_to_approve_spend1</fullName>
        <description>LEAP - BAGL Legal – Request to approve spend</description>
        <protected>false</protected>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_BAGL_Legal_Request_to_approve_spend</template>
    </alerts>
    <fieldUpdates>
        <fullName>LEAP_Matter_Spend_Document_Lock_Reco</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Matter_Spend_Document_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>LEAP - Matter Spend Document - Lock Reco</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LEAP_Matter_Spend_Document_Unlock</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Matter_Spend_Document</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>LEAP - Matter Spend Document - Unlock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LEAP_Matter_Spend_Document_Unlock_Re</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Matter_Spend_Document</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>LEAP - Matter Spend Document - Unlock Re</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LEAP_Spend_Doc_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Matter_Spend_Document_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>LEAP - Spend Doc Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LEAP_Spend_Document_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>LEAP - Spend Document - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LEAP_Spend_Document_Pending_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>LEAP - Spend Document - Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LEAP_Spend_Document_Queried</fullName>
        <field>Status__c</field>
        <literalValue>Queried</literalValue>
        <name>LEAP - Spend Document - Queried</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LEAP - BAGL Legal %E2%80%93 Request to approve spend</fullName>
        <actions>
            <name>LEAP_BAGL_Legal_Request_to_approve_spend1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT( ISBLANK(Matter_Spend_Schedule__c) )  &amp;&amp;   ISPICKVAL( Status__c   , &quot;Ready For Payment&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - BAGL Legal %E2%80%93 Request to approve spend schedule</fullName>
        <actions>
            <name>LEAP_BAGL_Legal_Request_to_approve_spend</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Spend_Schedules_Owners_Email__c )  &amp;&amp;  ISPICKVAL(Status__c, &quot;Approved&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
