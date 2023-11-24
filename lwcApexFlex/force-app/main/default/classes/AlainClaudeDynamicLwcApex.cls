/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class AlainClaudeDynamicLwcApex {

    @AuraEnabled(Cacheable = true)
    public static List<Account> getRecordData(String parentObject, String recordId, String childObjectName, String fieldSetName) {
        try {
            String queryString = 'select id';
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(childObjectName);

            if (sObjectType == null) {
                throw new AuraHandledException('Object API name is invalid: ' + childObjectName);
            }

            Schema.FieldSet fieldSet;

            // Get field set, throw error if not found
            if (!sObjectType.getDescribe().fieldSets.getMap().containsKey(fieldSetName)) {
                throw new AuraHandledException('Field set ' + fieldSetName + ' not found!');
            } else {
                fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(fieldSetName);
            }

            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                queryString += ',' + field.getFieldPath();
            }
            queryString += ' FROM ' + childObjectName;

            // Just in case criteria field not specified then it will return all records
            if (!(String.isEmpty(parentObject) && String.isEmpty(recordId))) {
                queryString += ' WHERE ' + parentObject + '=\'' + recordId + '\'';
            }
            return Database.query(queryString);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getFieldLabelAndFieldAPI(String recordId, String childObjectName, String fieldSetName) {

        System.debug('ChildObjectName==> ' + childObjectName);

        List<Map<String, String>> listOfFieldSet = new List<Map<String, String>>();

        if (String.isNotBlank(recordId)) {
            // Schema.SObjectType sObjectType = Id.valueOf(recordId).getSobjectType();
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(childObjectName);

            if (sObjectType == null) {
                throw new AuraHandledException('Object API name is invalid: ' + childObjectName);
            }

            Schema.FieldSet fieldSet;

            // Get field set, throw error if not found
            if (!sObjectType.getDescribe().fieldSets.getMap().containsKey(fieldSetName)) {
                throw new AuraHandledException('Field set ' + fieldSetName + ' not found!');
            } else {
                fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(fieldSetName);
            }

            for (Schema.FieldSetMember field : fieldSet.getFields()) {

                Map<String, String> labelAPIMap = new Map<String, String>();
                labelAPIMap.put(field.getLabel(), field.getFieldPath());
                listOfFieldSet.add(labelAPIMap);

            }

        } else {
            throw new AuraHandledException('RecordId cannot be null or empty.');
        }
        System.debug('JSON.serialize(listOfFieldSet)==> ' + JSON.serialize(listOfFieldSet));
        return JSON.serialize(listOfFieldSet);
    }

}
