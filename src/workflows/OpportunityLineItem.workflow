<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Single_Unit_Price_update</fullName>
        <field>Single_Unit_Price__c</field>
        <formula>Total_Price__c  / Quantity</formula>
        <name>Single Unit Price update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Single Unit Price update</fullName>
        <actions>
            <name>Single_Unit_Price_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Single_Unit_Price__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
