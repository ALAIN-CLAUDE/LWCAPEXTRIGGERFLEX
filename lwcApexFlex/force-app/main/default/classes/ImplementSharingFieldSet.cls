/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-23-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ImplementSharingFieldSet {
    @AuraEnabled(cacheable=True)
    public static List<sobject> getRecordList(String ParentObject,String recordId,String ChildObjectName,String fieldSetName ){
         return AlainClaudeDynamicLwcApex.getRecordData(ParentObject,recordId,ChildObjectName,fieldSetName);
    }

}