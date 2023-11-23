@isTest
private class ContactTriggerHandlerTest {

    @testSetup 
    static void setup() {

        // Insert test contacts
        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0; i < 2; i++) {
            testContacts.add(
                new Contact(LastName='Test Contact '+i, Email='test'+i+'@test.com')
            );
        }
        insert testContacts;
    }
    

    @isTest
    static void testAfterInsert() {

        // Existing Medical Info records
        List<Medical_Info__c> existingInfos = new List<Medical_Info__c>{
            new Medical_Info__c(Name='Test Contact 0'), 
            new Medical_Info__c(Name='Test Contact 1')
        };
        insert existingInfos;

        // New contact to trigger handler
        Contact newContact = new Contact(LastName='Test Trigger Contact');
        insert newContact;

        // Verify contact linked and info created   
        newContact = [SELECT Id, Medical_Info__c FROM Contact WHERE Id = :newContact.Id];
        //System.assertNotEquals(null, newContact.Medical_Info__c);
        Assert.areNotEqual(null, newContact.Medical_Info__c);
    }

    @isTest
    static void testAfterUpdate() {

        Contact existingContact = [SELECT Id, Medical_Info__c,LastName FROM Contact WHERE LastName = 'Test Contact 0']; 
        
        // Update name should create new info
        existingContact.LastName = 'Updated Last Name';
        update existingContact;
        
        existingContact = [SELECT Id, Medical_Info__c,LastName, Medical_Info__r.Name 
                           FROM Contact WHERE Id = :existingContact.Id];
                           
        Assert.areEqual(existingContact.LastName, existingContact.Medical_Info__r.Name);                                                         
    }
    
    
    @isTest
    static void testBeforeDelete() {

        Contact contactToDelete = [SELECT Id, Medical_Info__c 
                                   FROM Contact 
                                   WHERE LastName LIKE 'Test Contact %' LIMIT 1];
                                   
        Test.startTest();
            delete contactToDelete;
        Test.stopTest();
        
        // Verify info gets deleted
        Assert.areEqual(0, [SELECT COUNT() FROM Medical_Info__c WHERE Id = :contactToDelete.Medical_Info__c]);
        
    }

}