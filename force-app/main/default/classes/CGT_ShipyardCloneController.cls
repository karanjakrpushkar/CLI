public class CGT_ShipyardCloneController {

@AuraEnabled
public static object queryAllFieldsForClone(String recordId)
{
    String allFields = '';
    
    //Get set of fields
    Set<String> objectFields = Schema.getGlobalDescribe().get('CGT_Shipyard_Project__c').getDescribe().fields.getMap().keySet();
    for(String fieldName:objectFields)
        allFields = allFields + fieldName + ','; 
    
    allFields = allFields.substring(0, allFields.length()-1);
    
    CGT_Shipyard_Project__c obj = Database.query('SELECT '+allFields+ ' FROM CGT_Shipyard_Project__c WHERE Id=\''+recordId+'\'');
    
    //String jsonString = JSON.serialize(obj, true);
    Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj, true));
    jsonMap.remove('attributes');
    jsonMap.remove('Id');
    jsonMap.remove('CGT_Sales_Tool_ID__c');
    jsonMap.remove('CGT_Option_Shipyard_Project__c');
    jsonMap.remove('CGT_Original_Shipyard_Project__c');
    jsonMap.put('CGT_Cloned_From__c',recordId);
    System.debug('**'+JSON.serialize(jsonMap, true));
    
    return JSON.serialize(jsonMap, true);

}    
}