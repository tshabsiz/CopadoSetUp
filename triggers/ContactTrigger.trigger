trigger ContactTrigger on Contact (after insert) {   

    new ContactTriggerHandler().run();
}