<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Birthday_Notification_email</fullName>
        <description>Birthday Notification email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Birthday_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Reset_Birthday_Email_System</fullName>
        <field>Reset_Birthday_email_system__c</field>
        <literalValue>0</literalValue>
        <name>Reset Birthday Email System</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Next_Birthday</fullName>
        <description>Used in automated birthday notification to ensure continuous sending every year</description>
        <field>Next_Birthday__c</field>
        <formula>IF(DATE(YEAR(TODAY()),MONTH(Birthday__c),DAY(Birthday__c)) &lt;= TODAY(), DATE(YEAR(TODAY())+1,MONTH(Birthday__c),DAY(Birthday__c)), DATE(YEAR(TODAY()),MONTH(Birthday__c),DAY(Birthday__c)))</formula>
        <name>Reset Next Birthday</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Birthday Change</fullName>
        <actions>
            <name>Reset_Birthday_Email_System</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>to update Next Birthday in the event of Birthday change</description>
        <formula>(MONTH(Birthday__c) &lt;&gt; MONTH(Next_Birthday__c) || DAY(Birthday__c) &lt;&gt; DAY(Next_Birthday__c)) &amp;&amp; Birthday_notification__c = True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset Birthday Email</fullName>
        <actions>
            <name>Reset_Next_Birthday</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Birthday_notification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Reset_Birthday_email_system__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reset_Birthday_Email_System</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Birthday Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Birthday_notification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Reset_Birthday_email_system__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Birthday__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Birthday Notification to Contact Owner 48 hours prior to Birthday</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Birthday_Notification_email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contact.Next_Birthday__c</offsetFromField>
            <timeLength>-48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Reset_Next_Birthday</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contact.Next_Birthday__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
