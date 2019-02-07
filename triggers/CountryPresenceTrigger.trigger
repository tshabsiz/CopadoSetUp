trigger CountryPresenceTrigger on Country_Presence__c (before insert, before update) {

    // before insert
    if (trigger.isBefore && trigger.isInsert) {
        CountryPresenceTrigger_Helper.checkCountryUniqueness(trigger.new, trigger.newmap, true);
    }
    
    // before update
    if (trigger.isBefore && trigger.isUpdate) {
        CountryPresenceTrigger_Helper.checkCountryUniqueness(trigger.new, trigger.newmap, false);
    }

}