<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Banker_Matrix_Lead_21_Days_period_passed</fullName>
        <description>Banker - Matrix Lead 21 Days period passed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_21_Days_period_passed</template>
    </alerts>
    <alerts>
        <fullName>Banker_Matrix_Lead_51_Days_period_passed</fullName>
        <description>Banker - Matrix Lead 51 Days period passed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_41_Days_period_passed</template>
    </alerts>
    <alerts>
        <fullName>Banker_Matrix_Lead_60_Days_Notification_Extension_Request_Approved</fullName>
        <description>Banker - Matrix Lead 60 Days Notification Extension Request Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_60_Days_Notification_Extension_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Banker_Matrix_Lead_60_Days_Notification_Extension_Request_Declined</fullName>
        <description>Banker - Matrix Lead 60 Days Notification Extension Request Declined</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_60_Days_Notification_Extension_Request_Declined</template>
    </alerts>
    <alerts>
        <fullName>Banker_Matrix_Lead_60_days_notification_lead_sent_to_queue</fullName>
        <description>Banker - Matrix Lead 60 days notification lead sent to queue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_60_days_notification_to_send_lead_to_the_queue</template>
    </alerts>
    <alerts>
        <fullName>Banker_Matrix_Lead_Assignment_Request_Approved</fullName>
        <description>Banker - Matrix Lead Assignment Request Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_Assignment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Banker_Matrix_Lead_Assignment_Request_Declined</fullName>
        <description>Banker - Matrix Lead Assignment Request Declined</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_Assignment_Request_Declined</template>
    </alerts>
    <alerts>
        <fullName>Banker_and_Sector_Head_Matrix_Lead_21_Days_Notification</fullName>
        <description>Banker and Sector Head - Matrix Lead 21 Days Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_21_Days_Notification</template>
    </alerts>
    <alerts>
        <fullName>Banker_and_Sector_Head_Matrix_Lead_30_Days_Notification</fullName>
        <description>Banker and Sector Head - Matrix Lead 30 Days Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Sector_Head_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_30_Days_Notification</template>
    </alerts>
    <alerts>
        <fullName>Banker_and_Sector_Head_Matrix_Lead_51_Days_Notification</fullName>
        <description>Banker and Sector Head - Matrix Lead 51 Days Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_51_Days_Notification</template>
    </alerts>
    <alerts>
        <fullName>Banker_and_Sector_Head_Matrix_Lead_81_Days_Notification</fullName>
        <description>Banker and Sector Head - Matrix Lead 81 Days Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_81_Days_Notification</template>
    </alerts>
    <alerts>
        <fullName>Banker_and_Sector_Head_Matrix_Lead_90_Days_Notification</fullName>
        <description>Banker and Sector Head - Matrix Lead 90 Days Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Sector_Head_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport@absa.africa</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_90_Days_Notification</template>
    </alerts>
    <alerts>
        <fullName>Sector_Head_Matrix_Lead_Assignment_Request_Escalated</fullName>
        <description>Sector Head - Matrix Lead Assignment Request Escalated</description>
        <protected>false</protected>
        <recipients>
            <field>Sector_Head_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>mervyn.pillay@absa1.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Worklfow_Email_Templates/Matrix_Lead_Assignment_Request_Escalated</template>
    </alerts>
    <fieldUpdates>
        <fullName>Empty_Assignment_Date</fullName>
        <field>Assignment_Date__c</field>
        <name>Empty Assignment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Empty_Assignment_Request_Date</fullName>
        <field>Assignment_Request_Date__c</field>
        <name>Empty Assignment Request Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Empty_Contacted_Date</fullName>
        <field>Contacted_Date__c</field>
        <name>Empty Contacted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Empty_Conversion_Deadline</fullName>
        <field>Conversion_Deadline__c</field>
        <name>Empty Conversion Deadline</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Extend_Conversion_Deadline</fullName>
        <field>Conversion_Deadline__c</field>
        <formula>Conversion_Deadline__c + 30</formula>
        <name>Extend Conversion Deadline</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Requested_Extension</fullName>
        <field>Requested_Extension_30_days__c</field>
        <literalValue>0</literalValue>
        <name>Reset Requested Extension</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Assignment_Date</fullName>
        <field>Assignment_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Assignment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Assignment_Request_Date</fullName>
        <field>Assignment_Request_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Assignment Request Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_Status_Assigned</fullName>
        <field>Lead_Status__c</field>
        <literalValue>Assigned</literalValue>
        <name>Set Lead Status: Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_Status_Open</fullName>
        <field>Lead_Status__c</field>
        <literalValue>Open</literalValue>
        <name>Set Lead Status: Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_Status_Pending_Assignment</fullName>
        <field>Lead_Status__c</field>
        <literalValue>Pending Assignment</literalValue>
        <name>Set Lead Status: Pending Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Matrix Lead Assignment Deadline Notifications</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Matrix_Lead__c.Lead_Status__c</field>
            <operation>equals</operation>
            <value>Pending Assignment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Matrix_Lead__c.Assignment_Request_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Empty_Assignment_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_Lead_Status_Open</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Matrix_Lead__c.Assignment_Request_Date__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Sector_Head_Matrix_Lead_Assignment_Request_Escalated</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Matrix_Lead__c.Assignment_Request_Date__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Matrix Lead Contact Deadline Notifications</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Matrix_Lead__c.Lead_Status__c</field>
            <operation>equals</operation>
            <value>Assigned</value>
        </criteriaItems>
        <criteriaItems>
            <field>Matrix_Lead__c.Assignment_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Banker_and_Sector_Head_Matrix_Lead_51_Days_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Matrix_Lead__c.Assignment_Date__c</offsetFromField>
            <timeLength>51</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Banker_and_Sector_Head_Matrix_Lead_90_Days_Notification</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Empty_Assignment_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_Lead_Status_Open</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Matrix_Lead__c.Assignment_Date__c</offsetFromField>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Banker_and_Sector_Head_Matrix_Lead_81_Days_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Matrix_Lead__c.Assignment_Date__c</offsetFromField>
            <timeLength>81</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Banker_and_Sector_Head_Matrix_Lead_21_Days_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Matrix_Lead__c.Assignment_Date__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Matrix Lead Conversion Deadline Notifications</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Matrix_Lead__c.Lead_Status__c</field>
            <operation>equals</operation>
            <value>Contacted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Matrix_Lead__c.Contacted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Matrix_Lead__c.Conversion_Deadline__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Matrix_Lead__c.Requested_Extension_30_days__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Banker_Matrix_Lead_21_Days_period_passed</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Matrix_Lead__c.Contacted_Date__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Banker_Matrix_Lead_60_days_notification_lead_sent_to_queue</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Empty_Assignment_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Empty_Contacted_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Empty_Conversion_Deadline</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Reset_Requested_Extension</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_Lead_Status_Open</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Matrix_Lead__c.Contacted_Date__c</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Banker_Matrix_Lead_51_Days_period_passed</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Matrix_Lead__c.Contacted_Date__c</offsetFromField>
            <timeLength>51</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
