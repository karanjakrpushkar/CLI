/********************************************************************************************************
* @author         Deloitte
* @date           2017-07-21
* @description    Data factory class used by the test classes of the Integration Messages package
* @group          Common Libraries
*********************************************************************************************************/
@isTest
public class EVT_TestDataUtility
{
    /*********************************************************************************************************
    * @author        Deloitte
    * @date          2017-07-21
    * @description   The method returns an Integration Message.
    * @param         fieldnameValueMap (Map<String,Object>): Map with the name of the fields and its value
    * @param         executeInsert (Boolean): True if the record must be inserted, otherwise false
    * @return        EVT_Integration_Message__c: The integration message record
    *********************************************************************************************************/
    public static EVT_Integration_Message__c generateIntegrationMessage(Map<String,Object> fieldnameValueMap, Boolean executeInsert)
    {
        EVT_Integration_Message__c message = new EVT_Integration_Message__c();
        
        if(fieldnameValueMap!=null)
        {
            for(String fieldName : fieldnameValueMap.keySet()) 
            {
                message.put(fieldName,fieldnameValueMap.get(fieldName));
            }   
        }
        
        if(executeInsert) insert message;
        return message;
    }
}