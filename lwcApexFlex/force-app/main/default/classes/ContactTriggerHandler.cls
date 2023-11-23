public class ContactTriggerHandler {

    // Entry point for trigger handling
    public static void handleTrigger(List<Contact> newContacts, Map<Id, Contact> oldContactsMap, System.TriggerOperation operation) {
        if (operation == System.TriggerOperation.AFTER_INSERT) {
            afterInsert(newContacts);
        } else if (operation == System.TriggerOperation.AFTER_UPDATE) {
            afterUpdate(newContacts);
        } else if (operation == System.TriggerOperation.BEFORE_DELETE) {
            beforeDelete(oldContactsMap);
        }
    }

    // Handles logic after Contact records are inserted
    public static void afterInsert(List<Contact> newContacts) {
        List<Medical_Info__c> infosToUpdate = new List<Medical_Info__c>();
        List<Contact> contactUpdate = new List<Contact>();

        for (Contact contact : [SELECT Id, Name, lastName, Medical_Info__c FROM Contact WHERE Id IN :newContacts]) {
            if (contact.Medical_Info__c != null) {
                infosToUpdate.add(new Medical_Info__c(Id = contact.Medical_Info__c, Name = contact.Name));
            } else {
                Medical_Info__c existingMedInfo = getExistingMedicalInfo(contact.Name);
                if (existingMedInfo != null) {
                    contact.Medical_Info__c = existingMedInfo.Id;
                    contactUpdate.add(contact);
                }
            }
        }

        if (!infosToUpdate.isEmpty()) {
            update infosToUpdate;
        }

        if (!contactUpdate.isEmpty()) {
            update contactUpdate;
        }
    }

    // Handles logic after Contact records are updated
    public static void afterUpdate(List<Contact> updatedContacts) {
        List<Medical_Info__c> infosToUpdate = new List<Medical_Info__c>();
        List<Contact> contactUpdate = new List<Contact>();

        for (Contact contact : [SELECT Id, Name, lastName, Medical_Info__c FROM Contact WHERE Id IN :updatedContacts]) {
            if (contact.Medical_Info__c != null) {
                infosToUpdate.add(new Medical_Info__c(Id = contact.Medical_Info__c, Name = contact.Name));
            } else {
                Medical_Info__c existingMedInfo = getExistingMedicalInfo(contact.lastName);
                if (existingMedInfo != null) {
                    contact.Medical_Info__c = existingMedInfo.Id;
                    contactUpdate.add(contact);
                }
            }
        }

        if (!infosToUpdate.isEmpty()) {
            update infosToUpdate;
        }

        if (!contactUpdate.isEmpty()) {
            update contactUpdate;
        }
    }

    // Handles logic before Contact records are deleted
    public static void beforeDelete(Map<Id, Contact> oldContactsMap) {
        Set<Id> medInfoIds = new Set<Id>();

        for (Contact cont : [SELECT Id, Medical_Info__c FROM Contact WHERE Id IN :oldContactsMap.keySet()]) {
            if (String.isNotBlank(cont.Medical_Info__c)) {
                medInfoIds.add(cont.Medical_Info__c);
            }
        }

        if (!medInfoIds.isEmpty()) {
            List<Medical_Info__c> medicalInfoToDelete = [SELECT Id FROM Medical_Info__c WHERE Id IN :medInfoIds];
            if (!medicalInfoToDelete.isEmpty()) {
                delete medicalInfoToDelete;
            }
        }
    }

    // Helper method to retrieve existing or create new Medical Info record
    private static Medical_Info__c getExistingMedicalInfo(String contactNames) {
        Medical_Info__c[] existingMedicalInfo = [SELECT Id, Name FROM Medical_Info__c WHERE Name = :contactNames LIMIT 1];

        if (!existingMedicalInfo.isEmpty()) {
            return existingMedicalInfo[0];
        } else {
            Medical_Info__c newMedicalInfo = new Medical_Info__c();
            newMedicalInfo.Name = contactNames;
            insert newMedicalInfo;
            return newMedicalInfo;
        }
    }
}