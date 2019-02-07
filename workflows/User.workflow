<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Deactivate_User</fullName>
        <description>Deactivate User</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Deactivation_Notification3</template>
    </alerts>
    <alerts>
        <fullName>Email_Chatter_External_User_External_Chatter_Welcome</fullName>
        <description>Email Chatter External User - External Chatter Welcome</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/External_Chatter_Welcome</template>
    </alerts>
    <alerts>
        <fullName>Email_Chatter_User_Chatter_Welcome</fullName>
        <description>Email Chatter User - Chatter Welcome</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Chatter_Welcome</template>
    </alerts>
    <alerts>
        <fullName>Email_Standard_User_Standard_Welcome</fullName>
        <description>Email Standard User - Standard Welcome</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Standard_Welcome</template>
    </alerts>
    <alerts>
        <fullName>User_Notification_30</fullName>
        <description>User_Notification_30</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Deactivation_Notification1</template>
    </alerts>
    <alerts>
        <fullName>User_Notification_60</fullName>
        <description>User Notification 60</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Deactivation_Notification2</template>
    </alerts>
    <fieldUpdates>
        <fullName>Deactivate</fullName>
        <field>IsActive</field>
        <literalValue>0</literalValue>
        <name>Deactivate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_BRID_with_Alias</fullName>
        <description>US-0719 Chatter External Customer Access - The BRID is a required field for users that login to salesforce via SSO. This information is not available or applicable to external users / customers. Set the BRID to the unique field Alias on the user record</description>
        <field>BRID__c</field>
        <formula>Alias</formula>
        <name>Update BRID with Alias</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Chatter External BRID Update</fullName>
        <actions>
            <name>Update_BRID_with_Alias</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Chatter External User</value>
        </criteriaItems>
        <description>This copies the username of only Chatter External profiles to the BRID</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Chatter External User Onboarded</fullName>
        <actions>
            <name>Email_Chatter_External_User_External_Chatter_Welcome</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Chatter External User</value>
        </criteriaItems>
        <description>Sends an email to the Chatter External User Welcoming him/her to Chatter Collaboration and giving him/her instructions on how to install Salesforce1 app and user guide to help Collaborating.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Chatter User Onboarded</fullName>
        <actions>
            <name>Email_Chatter_User_Chatter_Welcome</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Barclays Chatter Only User</value>
        </criteriaItems>
        <description>Sends an email to the Barclays Chatter Only User Welcoming him/her to Chatter Collaboration and giving him/her instructions on how to install Salesforce1 app and user guide to help Collaborating.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send Deactivation Email2</fullName>
        <active>false</active>
        <description>Users who have not logged on for 30 - 60 days will be notified that they will be deactivated at 90 days should they not login to Salesforce</description>
        <formula>TODAY() - DATEVALUE(Last_Login_Date__c )   &gt;=  30</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>User_Notification_30</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>User.Last_Login_Date__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>User_Notification_60</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>User.Last_Login_Date__c</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Deactivate_User</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Deactivate</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>User.Last_Login_Date__c</offsetFromField>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Standard User Onboarded</fullName>
        <actions>
            <name>Email_Standard_User_Standard_Welcome</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Barclays Standard User</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Standard User ( Lightning )</value>
        </criteriaItems>
        <description>Sends an email to the Standard User Welcoming him/her to Chatter Collaboration and giving him/her instructions on how to install Salesforce1 app and user guide to help Collaborating.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
