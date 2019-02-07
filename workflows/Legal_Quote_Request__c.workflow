<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LEAP_Notify_LegalAdmin_Users_to_add_Off_Panel</fullName>
        <description>LEAP - Notify LegalAdmin Users to add Off Panel</description>
        <protected>false</protected>
        <recipients>
            <recipient>LEAP_Admin_Users_to_add_Off_Panel</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Admin_informed_to_add_Off_Panel_Counsel</template>
    </alerts>
    <alerts>
        <fullName>Notify_LegalAdmin_Users_to_add_Off_Panel</fullName>
        <description>Notify LegalAdmin Users to add Off Panel</description>
        <protected>false</protected>
        <recipients>
            <recipient>LEAP_Admin_Users_to_add_Off_Panel</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Admin_informed_to_add_Off_Panel_Counsel</template>
    </alerts>
    <alerts>
        <fullName>Notify_Litigation_Admin_Users_to_add_Off_Panel</fullName>
        <description>Notify Litigation Admin Users to add Off Panel</description>
        <protected>false</protected>
        <recipients>
            <recipient>LEAP_Admin_Users_to_add_Off_Panel</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AdvoLogix/LEAP_Admin_informed_to_add_Off_Panel_Counsel</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_To_Off_Panel_Lit</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Litigation_Off_Panel</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change To Off Panel Lit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_record_type_to_Legal_Off_Panel</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Legal_Off_Panel</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change record type to Legal (Off Panel)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_record_type_to_Legal_Request</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Legal_Request</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change record type to Legal Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lit_Off_to_Lit</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Litigation_Request</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Lit Off to Lit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LEAP - Legal Quote Request - Off Panel is checked</fullName>
        <actions>
            <name>LEAP_Notify_LegalAdmin_Users_to_add_Off_Panel</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_LegalAdmin_Users_to_add_Off_Panel</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_record_type_to_Legal_Off_Panel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Legal_Quote_Request__c.Request_Off_Panel__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Legal_Quote_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Legal Request</value>
        </criteriaItems>
        <description>Legal Quote Request - Off Panel is checked, change record type to Legal (Off Panel)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Legal Quote Request - Off Panel is unchecked</fullName>
        <actions>
            <name>Change_record_type_to_Legal_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Legal_Quote_Request__c.Request_Off_Panel__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Legal_Quote_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Legal (Off Panel)</value>
        </criteriaItems>
        <description>Legal Quote Request - Off Panel is unchecked, change record type to Legal Request</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Litigation Quote Request - Off Panel is checked</fullName>
        <actions>
            <name>Notify_Litigation_Admin_Users_to_add_Off_Panel</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_To_Off_Panel_Lit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Legal_Quote_Request__c.Request_Off_Panel__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Legal_Quote_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Litigation Request</value>
        </criteriaItems>
        <description>Litigation Quote Request - Off Panel is checked, change record type to Litigation (Off Panel)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LEAP - Litigation Quote Request - Off Panel is unchecked</fullName>
        <actions>
            <name>Lit_Off_to_Lit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Legal_Quote_Request__c.Request_Off_Panel__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Legal_Quote_Request__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Litigation (Off Panel)</value>
        </criteriaItems>
        <description>Litigation Quote Request - Off Panel is unchecked, change record type to Litigation (Off Panel)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
