<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_CR_owner_Manager_of_new_CR</fullName>
        <description>Notify Call Report owner   Manager of new CR</description>
        <protected>false</protected>
        <recipients>
            <field>Owner_Manager_s_email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/NotificationOwnerManagerNewCallReportVF</template>
    </alerts>
    <alerts>
        <fullName>Notify_Markets_Team_of_new_Call_Report_logged</fullName>
        <description>Notify Markets Team of new Call Report logged</description>
        <protected>false</protected>
        <recipients>
            <recipient>SA_Markets_Institutions</recipient>
            <type>roleSubordinatesInternal</type>
        </recipients>
        <recipients>
            <recipient>marshajean.dewet@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Notification_to_Owner_Manager_of_new_Call_Report</template>
    </alerts>
    <alerts>
        <fullName>Notify_RAISS_team_of_new_Call_Report</fullName>
        <description>Notify RAISS team  of new Call Report</description>
        <protected>false</protected>
        <recipients>
            <recipient>META_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Notification_to_Owner_Manager_of_new_Call_Report</template>
    </alerts>
    <alerts>
        <fullName>Notify_Raiss_Team_of_new_CR</fullName>
        <ccEmails>Ryan.sydow@absacapital.com</ccEmails>
        <ccEmails>Johann.Gunter@Barclays.com</ccEmails>
        <ccEmails>chris.edmeston@barclayscapital.com</ccEmails>
        <description>Notify META Team of new CR</description>
        <protected>false</protected>
        <recipients>
            <recipient>ZAF_CIB_Markets_RAISS</recipient>
            <type>roleSubordinatesInternal</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Call_Report_META_Notification_to_Team</template>
    </alerts>
    <fieldUpdates>
        <fullName>UpdateCR_Owner_manager_s_email</fullName>
        <field>Owner_Manager_s_email__c</field>
        <formula>Owner:User.Manager.Email</formula>
        <name>Update CR Owner manager&apos;s email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notify Call Report owner%27s manager when call report is logged</fullName>
        <actions>
            <name>Notify_CR_owner_Manager_of_new_CR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>YESTERDAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>META - Call Report</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>notContain</operation>
            <value>ZAF - CIB - Markets - Institutions</value>
        </criteriaItems>
        <description>Notify CR  Owner&apos;s manager when a new call report is logged.
META and Markets Teams excluded - team specific notification created for them.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify META Team of New Call Report</fullName>
        <actions>
            <name>Notify_Raiss_Team_of_new_CR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Call_Report__c.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>YESTERDAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>contains</operation>
            <value>META</value>
        </criteriaItems>
        <description>Notify RAISS Team of New Call Report</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Markets Research and Inst%2E team of Markets Call Report logged</fullName>
        <actions>
            <name>Notify_CR_owner_Manager_of_new_CR</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Markets_Team_of_new_Call_Report_logged</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND 3)  or  (1 AND 4 AND 5)</booleanFilter>
        <criteriaItems>
            <field>Call_Report__c.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>YESTERDAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Research Call Report</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>contains</operation>
            <value>ZAF - CIB - Markets - Research</value>
        </criteriaItems>
        <criteriaItems>
            <field>Call_Report__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Standard Call Report</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>contains</operation>
            <value>ZAF - CIB - Markets - Institutions</value>
        </criteriaItems>
        <description>Notify Markets Research and Institutional teams if anybody in the team logs a call report.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Owner Manager email on CR</fullName>
        <actions>
            <name>UpdateCR_Owner_manager_s_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Call_Report__c.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
