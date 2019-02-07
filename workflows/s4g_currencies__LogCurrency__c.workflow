<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>s4g_currencies__CallCurrencyUpdater</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>http://currencyupdater2.appspot.com/currency_updater_2_0</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>sizwe.tshabalala@absa1.com</integrationUser>
        <name>CallCurrencyUpdater</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>s4g_currencies__RunCurrencyUpdater</fullName>
        <active>false</active>
        <criteriaItems>
            <field>User.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
