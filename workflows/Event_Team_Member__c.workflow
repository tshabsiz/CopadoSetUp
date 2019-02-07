<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>evNew_Event_Team_Member_Notification</fullName>
        <description>evNew Event Team Member Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Team_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Event_Email_Templates/evNew_Event_Team_Member_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Name</fullName>
        <field>Name</field>
        <formula>Team_Member__r.FirstName + &quot; &quot; + Team_Member__r.LastName + &quot; (&quot;+ TEXT(Event_Team_Member_Role__c) + &quot;)&quot;</formula>
        <name>Set Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Default Event Team Member Name</fullName>
        <actions>
            <name>Set_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Name of the event team member based on the user name and role</description>
        <formula>ISCHANGED( Name )  || ISCHANGED( Event_Team_Member_Role__c ) || ISCHANGED ( Team_Member__c ) || ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>evNew Event Team Member Notification</fullName>
        <actions>
            <name>evNew_Event_Team_Member_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event_Team_Member__c.Team_Member__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Email notification sent to Event Team Member User on creation.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
