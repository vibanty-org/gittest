@isTest
public class TestDataFactory {
    private final static Set<string> EXCLUDE_FIELD_NAME = new Set<String> {'LastModifiedById', 'LastModifiedId', 'CreatedById', 'SystemModstamp', 'LastModifiedDate', 'CreatedDate','ClosedDate','ListPrice', 'TotalPrice','RecurrenceType', 'RecurrenceTimeZoneSidKey', 'RecurrenceStartDateTime', 'RecurrenceMonthOfYear', 'RecurrenceInterval', 'RecurrenceInstance', 'RecurrenceEndDateOnly', 'RecurrenceDayOfWeekMask','RecurrenceDayOfMonth', 'IsRecurrence', 'DurationInMinutes', 'RecurrenceStartDateOnly'};
    private final static Set<String> EXCLUDE_PICKLIST_FIELD_NAME = new Set<String> {'BillingStateCode', 'ShippingStateCode', 'BillingCountryCode', 'ShippingCountryCode'}; 
    private final static Set<String> EXCLUDE_REFERENCE_FIELD_NAME = new Set<String> {'ForecastUserId', 'UserRoleId', 'CallCenterId'}; 
    private final static Set<String> DIGITS = new Set<String> {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};    
    private final static Set<String> EXCLUDE_COMPOUND_FIELD_NAME = new Set<String> {'contact_name'};                                                                                
    private final static Set<String> FIELD_TYPE_TEXT = new Set<String>      {'STRING', 'TEXTAREA','PHONE','URL','ENCRYPTEDSTRING'};
    private final static Set<String> FIELD_TYPE_PICKLIST = new Set<String>  {'MUTIPICKLIST','PICKLIST'};                                                                     
    private final static Set<String> FIELD_TYPE_EMAIL = new Set<String>     {'EMAIL'};
    private final static Set<String> FIELD_TYPE_NUMBER = new Set<String>    {'INTEGER', 'PERCENT', 'DECIMAL', 'DOUBLE', 'CURRENCY'};
    private final static Set<String> FIELD_TYPE_TIME = new Set<String>      {'TIME','DATETIME'};
    private final static Set<String> FIELD_TYPE_DATE = new Set<String>      {'DATE'};
    private final static Set<String> FIELD_TYPE_BOOLEAN = new Set<String>   {'BOOLEAN'};

    private static String emailValue = 'test@coba.com';
    private static String groupType = 'Queue';
    private static String profileName = 'CMS Publisher Commerzbank Marketing';
    private static String profileId;
    private static Integer numberValue = 90;
    private static Boolean booleanValue = false;
    private static Date dateValue = System.today();
    private static Datetime datetimeValue = System.now();
    private static Boolean insertSObjects = false;
    private static String picklistValue;
    private static Map<String, Schema.SObjectType> globalDescribe;
    private static Map<String, Schema.SObjectField> fieldNamesMap;
    private static SObjectType sobjTyp;
    private static String objName;
    private static Map<String, Schema.SObjectField> fieldNamesMapFormer;
    private static SObjectType sobjTypFormer;
    private static String objNameFormer;
    private static Map<String, Map<String, Id>> objNameReferenceNameIdPairs = new Map<String, Map<String, Id>>();    
    private static Map<String, String> fieldNameValuePairs = new Map<String, String>();
    private static Boolean createRelationships = false;
    private static Boolean createQueue = false;

    private static void init(String objectName){ 
        objName = objectName;
        globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
        sobjTyp = globalDescribe.get(objName);
        if(sobjTyp == null){
            throw new UnsupportedObjectTypeException('UnsupportedObjectTypeException' + ': ' + objName);
        }
        fieldNamesMap = sobjTyp.getDescribe().fields.getMap();
    }

    public static SObject createSObject(String objectName){
        init(objectName);
        SObject sobj = sobjTyp.newSObject();
        sobj = buildSObject(sobj);
        if(insertSObjects){
            insert sobj;
        }
        return sobj;
    }

    public static List<SObject> createSObjects(String objectName, Integer numberOfRecordsToCreate){
        init(objectName);
        List<SObject> createdSObjects = new List<SObject>();
        for(Integer i = 0; i < numberOfRecordsToCreate; i++){
            SObject sobj = sobjTyp.newSObject();
            createdSObjects.add(buildSObject(sobj));
        }
        if(insertSObjects){
            insert createdSObjects;
        }
        return createdSObjects;
    }

    private static SObject buildSObject(SObject sobj){
        for(Schema.SObjectField fName : fieldNamesMap.values()){
            Schema.DescribeFieldResult field = fName.getDescribe();
            String compoundField = objName.toLowerCase() + '_' + field.getName().toLowerCase();
            if(EXCLUDE_FIELD_NAME.contains(field.getName()) || EXCLUDE_COMPOUND_FIELD_NAME.contains(compoundField)){
                continue;
            }

            if(field.isCreateable()){
                if(field.isExternalId() && field.getType() != Schema.DisplayType.Reference){
                    sobj.put(field.getName(), getRandomString(7));
                    continue;
                }
            } else {
                continue;
            }
            
            if(FIELD_TYPE_TEXT.contains(field.getType().name())){
                if(field.isNillable() && !fieldNameValuePairs.containsKey(field.getName())){
                    continue;
                }

                if(field.getName().equals('Username') && objName.equals('User')){
                    sobj.put(field.getName(), getRandomString(7) + emailValue);
                } else {
                    String str = getRandomString(20);
                    Integer endIndex = str.length() >= field.getLength() ? field.getLength() : str.length();
                    sobj.put(field.getName(), str.substring(0, endIndex - 1));
                }
                if(fieldNameValuePairs.containsKey(field.getName()) && (field.isNillable() || String.isNotBlank(fieldNameValuePairs.get(field.getName())))){
                    sobj.put(field.getName(), fieldNameValuePairs.get(field.getName()));
                }
            } else if(FIELD_TYPE_EMAIL.contains(field.getType().name())){
                sobj.put(field.getName(), getRandomString(7) + emailValue);
                if(fieldNameValuePairs.containsKey(field.getName()) && String.isNotBlank(fieldNameValuePairs.get(field.getName()))){
                    sobj.put(field.getName(), fieldNameValuePairs.get(field.getName()));
                }
            } else if(FIELD_TYPE_BOOLEAN.contains(field.getType().name())){
                sobj.put(field.getName(), booleanValue);
                if(fieldNameValuePairs.containsKey(field.getName()) && String.isNotBlank(fieldNameValuePairs.get(field.getName()))){
                    sobj.put(field.getName(), Boolean.valueOf(fieldNameValuePairs.get(field.getName())));
                } else if(field.getName().equals('IsConverted')){
                    sobj.put(field.getName(), false);
                }
            } else if(FIELD_TYPE_NUMBER.contains(field.getType().name())){
                sobj.put(field.getName(), numberValue);
                if(fieldNameValuePairs.containsKey(field.getName()) && String.isNotBlank(fieldNameValuePairs.get(field.getName()))){
                    sobj.put(field.getName(), Integer.valueOf(fieldNameValuePairs.get(field.getName())));
                }
            } else if(FIELD_TYPE_TIME.contains(field.getType().name())){
                sobj.put(field.getName(), datetimeValue);
                if(fieldNameValuePairs.containsKey(field.getName()) && String.isNotBlank(fieldNameValuePairs.get(field.getName()))){
                    sobj.put(field.getName(), Datetime.valueOf(fieldNameValuePairs.get(field.getName())));
                }
            } else if(FIELD_TYPE_DATE.contains(field.getType().name())){
                sobj.put(field.getName(), dateValue);
                if(fieldNameValuePairs.containsKey(field.getName()) && String.isNotBlank(fieldNameValuePairs.get(field.getName()))){
                    sobj.put(field.getName(), Date.valueOf(fieldNameValuePairs.get(field.getName())));
                } 
            } else if(FIELD_TYPE_PICKLIST.contains(field.getType().name())){
                if(field.isNillable() && !fieldNameValuePairs.containsKey(field.getName())){
                    continue;
                }
                String plv = picklistValue != null ? picklistValue : field.getPicklistValues()[0].getValue();
                sobj.put(field.getName(), plv);
                if(fieldNameValuePairs.containsKey(field.getName()) && String.isNotBlank(fieldNameValuePairs.get(field.getName()))){
                    sobj.put(field.getName(), fieldNameValuePairs.get(field.getName()));
                }
            } else if(field.getType() == Schema.DisplayType.Reference){
                string referenceType = field.getReferenceTo()[0].getDescribe().getName();
                if(fieldNameValuePairs.containsKey(field.getName()) && String.isNotBlank(fieldNameValuePairs.get(field.getName()))){
                    if(referenceType.equals('RecordType')){
                        String recordTypeId = getRecordTypeIdByName(fieldNameValuePairs.get(field.getName()));
                        if(recordTypeId == null){
                            throw new UnavailableRecordTypeException('UnavailableRecordTypeException' + ': ' + fieldNameValuePairs.get(field.getName()));
                        } else {
                        	sobj.put(field.getName(), recordTypeId);
                        	setObjNameReferenceNameIdPairs(objName, field.getName(), recordTypeId);
                        }
                    } else{
                        sobj.put(field.getName(), fieldNameValuePairs.get(field.getName()));
                        setObjNameReferenceNameIdPairs(objName, field.getName(), fieldNameValuePairs.get(field.getName()));
                    }
                } else {
                    Map<String, Id> referenceNameIdPairs;
                    if(objNameReferenceNameIdPairs.containsKey(objName) && objNameReferenceNameIdPairs.get(objName).containsKey(field.getName())){
                        sobj.put(field.getName(), objNameReferenceNameIdPairs.get(objName).get(field.getName()));
                    } else {
                        if(EXCLUDE_REFERENCE_FIELD_NAME.contains(field.getName())){
                            continue;
                        }
                        if(field.getName().equals('ProfileId')){
                            sobj.put(field.getName(), getProfileId());
                            continue;
                        }
                        if(referenceType.equals('RecordType')){
                            if(field.isNillable()){
                                continue;
                            }
                            String recordTypeId = getDefaultRecordType();
                            sobj.put(field.getName(), recordTypeId);
                            setObjNameReferenceNameIdPairs(objName, field.getName(), recordTypeId);
                        } else if(referenceType.equals('User') || field.getName().equals('DelegatedApproverId')){
                            sobj.put(field.getName(), UserInfo.getUserId());
                            setObjNameReferenceNameIdPairs(objName, field.getName(), UserInfo.getUserId());
                        } else if(!referenceType.equals(objName) && (!field.isNillable() || createRelationships)){
                            String reference;
                            if(referenceType.equals('Group') && field.getName().equals('OwnerId') && !createQueue){
                                reference = UserInfo.getUserId();
                            } else {
                                switchObject('switch');
                                SObject referenceObj = createSObject(referenceType);
                                if(objName.equals('Group') && field.getName().equals('OwnerId')){
                                    referenceObj.put('Type', groupType);
                                }
                                switchObject('switchBack');
                                insert referenceObj;
                                reference = referenceObj.Id;
                                if(objName.equals('Group') && field.getName().equals('OwnerId')){
                                    QueueSobject mappingObject = new QueueSobject(QueueId = referenceObj.Id, SobjectType = 'Lead');
                                    insert mappingObject;
                                }
                            }
                            sobj.put(field.getName(), reference);
                            setObjNameReferenceNameIdPairs(objName, field.getName(), reference);
                        }
                    }
                }
            }
            
        }
        return sobj;
    }

    private static void switchObject(String flag){
        if(flag.equals('switch')){
            fieldNamesMapFormer = fieldNamesMap;
            sobjTypFormer = sobjTyp;
            objNameFormer = objName;
        } else {
            fieldNamesMap = fieldNamesMapFormer;
            sobjTyp = sobjTypFormer;
            objName = objNameFormer;
        }
    }

    private static String getDefaultRecordType(){
        String defaultRecordTypeId;
        Schema.SObjectType sst = sobjTyp != null ? sobjTyp : ((globalDescribe != null && objName != null) ? globalDescribe.get(objName) : null);
        if(sst != null){
            List<Schema.RecordTypeInfo> recordTypes = sst.getDescribe().getRecordTypeInfos();
            if(!recordTypes.isEmpty()){
                for(Schema.RecordTypeInfo recordTypeInfo : recordTypes){
                    if(recordTypeInfo.isAvailable() && recordTypeInfo.isDefaultRecordTypeMapping()){
                        defaultRecordTypeId = recordTypeInfo.getRecordTypeId();
                    }
                }
            }
        }
        return defaultRecordTypeId;
    }

    private static String getRecordTypeIdByName(String name){
        String recordTypeId;
        Schema.SObjectType sst = sobjTyp != null ? sobjTyp : ((globalDescribe != null && objName != null) ? globalDescribe.get(objName) : null);
        if(sst != null){
            Map<String, Schema.RecordTypeInfo> rtMapByName = sst.getDescribe().getRecordTypeInfosByName();
            Schema.RecordTypeInfo rtByName = rtMapByName.containsKey(name) ? rtMapByName.get(name) : null;
            recordTypeId = rtByName != null ? rtByName.getRecordTypeId() : null;
        }
        return recordTypeId;
    }

    private static String getProfileId(){
        if(profileId == null){
            Profile p = [SELECT Id, Name, UserType, UserLicenseId FROM Profile where name=:profileName limit 1];
            if(p == null){
                p = [SELECT Id, Name, UserType, UserLicenseId FROM Profile where name = 'Standard User' limit 1];
            }
            profileId = p.Id;
        }
        return profileId;
    }

    private static String getRandomString(Integer size) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        while (randomString.length() < size) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randomString += chars.substring(idx, idx+1);
        }
        String firstCharacter = randomString.substring(0,1);
        if(DIGITS.contains(firstCharacter)){
            getRandomString(size);
        }
        return randomString; 
    }

    public static void setEmail(String inputEmail){
        emailValue = inputEmail;
    }
    
    public static void setNumberValue(Integer inputNumberValue){
        numberValue = inputNumberValue;
    }
    
    public static void setBooleanValue(Boolean inputBooleanValue){
        booleanValue = inputBooleanValue;
    }
    
    public static void setDateValue(Date inputDateValue){
        dateValue = inputDateValue;
    }
    
    public static void setDatetimeValue(Datetime inputDatetimeValue){
        datetimeValue = inputDatetimeValue;
    }

    public static void setCreateRelationships(Boolean flag){
        createRelationships = flag;
    }

    public static void setGroupType(String typ){
        groupType = typ;
    }

    public static void setFieldNameValuePairs(String field, String value){
        fieldNameValuePairs.put(field, value);
    }

    public static void resetFieldNameValuePairs(){
        fieldNameValuePairs = new Map<String, String>();
    }

    public static void removeFieldNameValuePairs(String fieldName){
        if(fieldNameValuePairs.containsKey(fieldName)){
            fieldNameValuePairs.remove(fieldName);
        }
    }

    public static Map<String, Map<String, Id>> getObjNameReferenceNameIdPairs(){
        return objNameReferenceNameIdPairs;
    }

    public static void resetObjNameReferenceNameIdPairs(){
        objNameReferenceNameIdPairs = new Map<String, Map<String, Id>>();
    }

    public static void removeObjNameReferenceNameIdPair(String fieldName){
        if(objName != null && objNameReferenceNameIdPairs.containsKey(objName)){
            if(objNameReferenceNameIdPairs.get(objName).containsKey(fieldName)){
                objNameReferenceNameIdPairs.get(objName).remove(fieldName);
            }
        }
    }

    public static void setProfileName(String name){
        profileName = name;
    }

    private static void setObjNameReferenceNameIdPairs(String objectName, String name, String value){
        Map<String, Id> referenceNameIdPairs;
        if(objNameReferenceNameIdPairs.containsKey(objectName)){
            referenceNameIdPairs = objNameReferenceNameIdPairs.get(objectName);
            referenceNameIdPairs.put(name, Id.valueOf(value));
        } else {
            referenceNameIdPairs = new Map<String, Id>();
            referenceNameIdPairs.put(name, Id.valueOf(value));
        }
        objNameReferenceNameIdPairs.put(objectName, referenceNameIdPairs);
    }

    public static void setInsertOBjects(Boolean flag){
        insertSObjects = flag;
    }

    public static void setCreateQueue(Boolean flag){
        createQueue = flag;
    }

    private static void clean(){
        fieldNameValuePairs = new Map<String, String>();
        setInsertOBjects(false);
    }

    /******************************* HELPERS ********************************/
    public static User createActiveUser(){
        User testUser;
        TestDataFactory.setFieldNameValuePairs('IsActive', 'true');
        testUser = (User)TestDataFactory.createSObject('User');
        insert testUser;
        TestDataFactory.resetFieldNameValuePairs();
        return testUser;
    }


    public class UnsupportedObjectTypeException extends Exception{}
    public class UnavailableRecordTypeException extends Exception{}
    
}