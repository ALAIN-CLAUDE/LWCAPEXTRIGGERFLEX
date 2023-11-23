trigger ContactTrigger on Contact (after insert, after update,before Delete) {
   /*
    if(Trigger.isAfter && Trigger.isInsert) {
        ContactTriggerHandler.afterInsert(Trigger.new);
    } else if(Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerHandler.afterUpdate(Trigger.new); 
    } else if(Trigger.isBefore && Trigger.isDelete){
        ContactTriggerHandler.handleBeforeDelete(Trigger.oldMap); 
    }
    */
    ContactTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
    
}