<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Attendee_of_being_added_to_Call_Report</fullName>
        <description>Notify Attendee of being added to Call Report</description>
        <protected>false</protected>
        <recipients>
            <field>Barclays_Attendee__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/NotifyAttendeeOfCallReport</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_team_role_field_on_Call_Report</fullName>
        <field>Team_Role_v2__c</field>
        <formula>IF(LEN(Call_Report__r.Team_Role_v2__c) = 0,  TEXT(Barclays_Attendee__r.Team_Role__c), 
IF(
CONTAINS(Call_Report__r.Team_Role_v2__c, TEXT(Barclays_Attendee__r.Team_Role__c)),
Call_Report__r.Team_Role_v2__c, Call_Report__r.Team_Role_v2__c &amp; &quot;, &quot; &amp; TEXT(Barclays_Attendee__r.Team_Role__c)))</formula>
        <name>Populate team role field on Call Report</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Call_Report__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Notify Attendee When Added to Call Report</fullName>
        <actions>
            <name>Notify_Attendee_of_being_added_to_Call_Report</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow rule notifying Wealth Attendee when being added to a call report</description>
        <formula>AND( TEXT($User.Division__c) = &apos;WIM&apos;, NOT(ISNULL(Barclays_Attendee__c)), Call_Report__r.OwnerId !=  Barclays_Attendee__c  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Team Role on Call Report</fullName>
        <actions>
            <name>Populate_team_role_field_on_Call_Report</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
