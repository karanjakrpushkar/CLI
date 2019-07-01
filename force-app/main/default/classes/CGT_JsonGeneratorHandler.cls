/********************************************************************************************************
* @Author         ext.Manoj.Gupta@cargotec.com
* @Description    Handler Class to generate JSON string whenever UPDATE,CREATE,CLOSED events happen and create the Integration Message Record
* @CreatedDate    06-20-2018

*********************************************************************************************************/
public without sharing class CGT_JsonGeneratorHandler {


    public static String CGT_IntegrationMessage_Status ='Processing';
/********************************************************************************************************
* @author        ext.Manoj.Gupta@cargotec.com
* @description   This method will be invoked from process builder which creates integration message entry with JSON Payload
* @Paramters     List<String>
* @return        none
*********************************************************************************************************/
    @InvocableMethod(label='CGT_CreateIntMessageWithJsonPayload' description='Create integration message entry with json Payload')
    public static void createIntMessageWithJsonPayload(List<string> eventTypeWithRecordId){
      
        Set<String> eventTypes= new Set<String>();
        Set<String> recordIds= new Set<String>();
        //This Map is to store the eventtype as the Key and the Record Ids Set Related to the EventType as Value
        Map<String,Set<String>> eventTypeToRecordIds = new Map<String,Set<String>>();
        //This for loop will iterate through the method parameter to split the Event and RecordID
        for(String str: eventTypeWithRecordId)
        {
        List<String> recordIdEventypeSplit=str.split(':');
        eventTypes.add(recordIdEventypeSplit[0]);
            if(!eventTypeToRecordIds.containsKey(recordIdEventypeSplit[0]))
            {
            eventTypeToRecordIds.put(recordIdEventypeSplit[0], new Set<String>());
            }   
        eventTypeToRecordIds.get(recordIdEventypeSplit[0]).add(recordIdEventypeSplit[1]);
        }
        //This Map is used to store the metadata based on the event and the object
        Map<String,Map<String,CGT_MS_Integration_Framework__mdt>> eventTypeToObjectToMetadata=CGT_JsonGeneratorHandler.getCustomMetadataAttributes(eventTypes);
        //This Map is to store the Fields used in Query in Metadata with respect to EventType
        Map<String,Map<String,List<String>>> eventTypeToIntegrationAttributes=CGT_JsonGeneratorHandler.getEventToIntegrationAttributes(eventTypeToObjectToMetadata);
        //This Map is to store the record ids based on the object and the event
        Map<String,Map<String,Map<String,sObject>>> eventTypeToObjectToRecords= CGT_JsonGeneratorHandler.getObjectRecords(eventTypeToObjectToMetadata,eventTypeToRecordIds);
        //This Map is to store the Messagebody and Standard Header in the JSON String.
        Map<String,Object> jsonObjectMap;
        CGT_JsonGeneratorUtilities.StandardHeader stdHeader;
        CGT_JsonGeneratorUtilities.ObjectName objectWrapper;
        List<CGT_JsonGeneratorUtilities.ObjectName>objectWrapperList;
        //Map to store the object and related fieldvalue list
        Map<String,List<CGT_JsonGeneratorUtilities.ObjectName>> objectWrapperMap = new Map<String,List<CGT_JsonGeneratorUtilities.ObjectName>>();
        //Map to store JSONString List based on the Event type
        Map<String,String> eventTypeToJsonStringList= new Map<String,String>();
        //This will iterate based on the list of Events recieved in the parameter.
        for(String eventType:eventTypeToObjectToRecords.keySet())
        {
            stdHeader=CGT_JsonGeneratorHandler.getStandardHeader(eventType);
        
            for(String objectName:eventTypeToObjectToRecords.get(eventType).keySet())
            {
                List<String> attributesList=eventTypeToIntegrationAttributes.get(eventType).get(objectName);
                objectWrapperList = new List<CGT_JsonGeneratorUtilities.ObjectName>();
                for(sObject objInst:eventTypeToObjectToRecords.get(eventType).get(objectName).Values())
                {
                    List<CGT_JsonGeneratorUtilities.Field> fieldValueList= CGT_JsonGeneratorHandler.getfieldValueList(objInst,attributesList);
                    objectWrapper= new CGT_JsonGeneratorUtilities.ObjectName(fieldValueList);
                    objectWrapperList.add(objectWrapper);
                }
                String objectArrayHeader=eventTypeToObjectToMetadata.get(eventType).get(objectName).CGT_Object_Header__c;
                objectWrapperMap.put(objectArrayHeader,objectWrapperList);
                jsonObjectMap= new Map<String,Object>();
                jsonObjectMap.put('messageBody',objectWrapperMap);
                jsonObjectMap.put('StandardHeader', stdHeader);
            }
            String jsonString=JSON.serialize(jsonObjectMap);
            if(!eventTypeToJsonStringList.containsKey(eventType)){
            eventTypeToJsonStringList.put(eventType,jsonString);
            }
        }
        createIntegrationMessage(eventTypeToJsonStringList,eventTypeToRecordIds); 
      
    }
/********************************************************************************************************
* @author        ext.Manoj.Gupta@cargotec.com
* @description   This method is to create Integration Message Record based on the Event type and JSON string
* @Paramters     Map<String,String>,Map<String,Set<String>>
* @return        none
*********************************************************************************************************/
    private static void createIntegrationMessage(Map<String,String> eventTypeToJsonStringList,Map<String,Set<String>> eventTypeToRecordIds){
        Set<String> eventtype= eventTypeToJsonStringList.keySet();
        List<EVT_Integration_Message__c> integrationMSG_List=new List<EVT_Integration_Message__c>();
        //Iterates based on the event type so that the Integration message record is created based on that 
        for(String event : eventtype)
        {
        
            String jsonList=eventTypeToJsonStringList.get(event);
            EVT_Integration_Message__c recIntegration=new EVT_Integration_Message__c();
            recIntegration.EVT_Event_Type__c=event;
            recIntegration.EVT_Status__c=CGT_IntegrationMessage_Status;
            recIntegration.CGT_Json_String__c=jsonList;
            integrationMSG_List.add(recIntegration);    
          
            
        }
         try{
            if(!integrationMSG_List.isEmpty()){
            insert integrationMSG_List;
            }
        }
         catch(Exception errorMessage){
            LOG_LogMessageUtility.logMessage(errorMessage,'CGT_JsonGeneratorHandler','CGT_CreateIntMessageWithJsonPayload','Error encountered during creation of Integration Message  Records',true);

        }       
        
    } 
/********************************************************************************************************
* @author        ext.Manoj.Gupta@cargotec.com
* @description   This method is to get the list of field value from CGT_JsonGeneratorUtilities
* @Paramters     sObject,List<String>
* @return        List<CGT_JsonGeneratorUtilities.Field>
*********************************************************************************************************/    
    private static List<CGT_JsonGeneratorUtilities.Field> getfieldValueList(
                                        sObject objectInstance,
                                        List<String> attributesList){
      
        CGT_JsonGeneratorUtilities.Field fieldInst;
        List<CGT_JsonGeneratorUtilities.Field> fieldValueList= new List<CGT_JsonGeneratorUtilities.Field>();
        //Iterates over the Fields used in the MetaData query so that fieldname and fieldvalue is fetched
        for(String fieldName:attributesList)
        {
        Object fieldValue=null;
        List<String> relationshipList=fieldName.split('\\.');
        String firstRelation,secondRelation,thirdRelation;
            if(!relationshipList.isEmpty()){
                if(relationshipList.size()==4){
                    firstRelation= relationshipList[0];
                    secondRelation=relationshipList[1];
                    thirdRelation=relationshipList[2];
                        if(objectInstance.getSObject(firstRelation)!=null &&
                        objectInstance.getSObject(firstRelation).getSObject(secondRelation)!=null &&
                        objectInstance.getSObject(firstRelation).getSObject(secondRelation).getSObject(thirdRelation)!=null ){
                            fieldValue=objectInstance.getSObject(firstRelation).getSObject(secondRelation).getSObject(thirdRelation).get(relationshipList[3]);
                        }
                }else if(relationshipList.size()==3){
                    firstRelation= relationshipList[0];
                    secondRelation=relationshipList[1];
                        if(objectInstance.getSObject(firstRelation)!=null &&
                        objectInstance.getSObject(firstRelation).getSObject(secondRelation)!=null){
                            fieldValue=objectInstance.getSObject(firstRelation).getSObject(secondRelation).get(relationshipList[2]);
                        }
            
            
                }else if(relationshipList.size()==2){
                    firstRelation= relationshipList[0];
                        if(objectInstance.getSObject(firstRelation)!=null){
                            fieldValue=objectInstance.getSObject(firstRelation).get(relationshipList[1]);
                        }
                }else if(relationshipList.size()==1){
                    fieldValue=objectInstance.get(fieldName);
                
                }
            }
        
        fieldInst= new CGT_JsonGeneratorUtilities.Field(fieldName,fieldValue);
        fieldValueList.add(fieldInst);
        }
      return fieldValueList;
    }
/********************************************************************************************************
* @author        ext.Manoj.Gupta@cargotec.com
* @description   This method is to get the StandardHeader from CGT_JsonGeneratorUtilities
* @Paramters     String
* @return        CGT_JsonGeneratorUtilities.StandardHeader
*********************************************************************************************************/    
    private static CGT_JsonGeneratorUtilities.StandardHeader getStandardHeader(String eventType){
      CGT_JsonGeneratorUtilities.StandardHeader stdHeader= new CGT_JsonGeneratorUtilities.StandardHeader
                                  (
                                  UserInfo.getUserId(),
                                  null,
                                  eventType,
                                  String.valueOf(System.now()),
                                  null,
                                  null,
                                  null,
                                  UserInfo.getOrganizationName()                                  
                                );
    return stdHeader;
    }
/********************************************************************************************************
* @author        ext.Manoj.Gupta@cargotec.com
* @description   This method is to get the records based on the Event type for the the changes are made
* @Paramters     Map<String,Map<String,CGT_MS_Integration_Framework__mdt>>,Map<String,Set<String>>
* @return        Map<String,Map<String,Map<String,sObject>>>
*********************************************************************************************************/          
    private static Map<String,Map<String,Map<String,sObject>>> getObjectRecords(
                              Map<String,Map<String,CGT_MS_Integration_Framework__mdt>> eventTypeToObjectToMetadata,
                              Map<String,Set<String>> eventTypeToRecordIds
                            ){
                            
        Map<String,Map<String,Map<String,sObject>>> eventTypeToObjectToRecords= new Map<String,Map<String,Map<String,sObject>>>();
        Map<String,Map<String,Set<String>>> eventTypeToObjectToRecordIds= new Map<String,Map<String,Set<String>>>();
        //This Map is to fetch the query from the metadata which is based on the event and the object.  
        Map<String,Map<String,String>> eventTypeToObjectToQueryString = CGT_JsonGeneratorHandler.getEventTypeToObjectToQueryString(eventTypeToObjectToMetadata);
        //Iterates over the event type
        for(String eventType:eventTypeToObjectToMetadata.keySet())
        {
        //Iterates over the object Name
        for(String objectName:eventTypeToObjectToMetadata.get(eventType).keySet())
        {
          if(eventTypeToObjectToQueryString.containsKey(eventType) &&
                eventTypeToObjectToQueryString.get(eventType).containsKey(objectName)){

                if(!eventTypeToObjectToRecordIds.containsKey(eventType) && eventTypeToRecordIds.containsKey(eventType)){
                    eventTypeToObjectToRecordIds.put(eventType,new Map<String,Set<String>>{objectName =>eventTypeToRecordIds.get(eventType)});
                }
            
                Set<String> recordIds=eventTypeToRecordIds.get(eventType);
                if(eventTypeToObjectToRecordIds.containsKey(eventType) && 
                eventTypeToObjectToRecordIds.get(eventType).containsKey(objectName)){
                recordIds=new Set<String>();
                recordIds=eventTypeToObjectToRecordIds.get(eventType).get(objectName);
                }
                 //QueryString based on the eventtype and Object
                String queryString=eventTypeToObjectToQueryString.get(eventType).get(objectName);
                String recordId='';
                String db_query = queryString;
                if(!recordIds.isEmpty()){
                 //Replacing the recordIds in the Query 
                queryString = db_query.replace('REC_ID','recordIds');
                List<sObject> sObjectList= Database.query(queryString);
                if(!sObjectList.isEmpty()){
                    for(sObject obj:sObjectList)
                    {
                    Map<String,sObject> recordMap= new Map<String,sObject>{(String)obj.get('Id') =>obj};
                        if(!eventTypeToObjectToRecords.containsKey(eventType)){
                            eventTypeToObjectToRecords.put(eventType,new Map<String,Map<String,sObject>>{objectName =>recordMap});
                        }else{
                            if(eventTypeToObjectToRecords.containsKey(eventType) &&
                            !eventTypeToObjectToRecords.get(eventType).containsKey(objectName)){
                                eventTypeToObjectToRecords.get(eventType).put(objectName,recordMap);
                            }else{
                                if(eventTypeToObjectToRecords.containsKey(eventType) &&
                                eventTypeToObjectToRecords.get(eventType).containsKey(objectName)&&
                                !eventTypeToObjectToRecords.get(eventType).get(objectName).containsKey((String)obj.get('Id'))
                                ){
                                    eventTypeToObjectToRecords.get(eventType).get(objectName).putAll(recordMap);
                                }

                            }
                        }
                  
                    }
                }
            }
          }
        }  
      }
      return eventTypeToObjectToRecords;
    }
/********************************************************************************************************
* @author        ext.Manoj.Gupta@cargotec.com
* @description   This method is to get the CustomMetadata Attribute
* @Paramters     Set<String>
* @return        Map<String,Map<String,CGT_MS_Integration_Framework__mdt>>
*********************************************************************************************************/         
    private static Map<String,Map<String,CGT_MS_Integration_Framework__mdt>> getCustomMetadataAttributes(Set<String> eventTypeList){
        Map<String,Map<String,CGT_MS_Integration_Framework__mdt>> eventTypeToMetadataMap= new Map<String,Map<String,CGT_MS_Integration_Framework__mdt>>();
        List<CGT_MS_Integration_Framework__mdt> metaDataRecords= [
                                  SELECT 
                                     CGT_Event_Type__c,CGT_Object__c,CGT_Object_Header__c,CGT_Query__c,CGT_Filter_Criteria__c
                                   FROM 
                                     CGT_MS_Integration_Framework__mdt 
                                                               WHERE 
                                                                 CGT_Event_Type__c
                                                               IN: eventTypeList                                                               
                                                             ];

        for(CGT_MS_Integration_Framework__mdt metadata:metaDataRecords){
            if(!eventTypeToMetadataMap.containsKey(metadata.CGT_Event_Type__c)){
                eventTypeToMetadataMap.put(metadata.CGT_Event_Type__c, new Map<String,CGT_MS_Integration_Framework__mdt>());
            }
            eventTypeToMetadataMap.get(metadata.CGT_Event_Type__c).put(metadata.CGT_Object__c,metadata);
        }
        return eventTypeToMetadataMap;
    }
/********************************************************************************************************
* @author        ext.Manoj.Gupta@cargotec.com
* @description   This method is to get the list of Event to get the related integration attributes
* @Paramters     Map<String,Map<String,CGT_MS_Integration_Framework__mdt>>
* @return        Map<String,Map<String,List<String>>>
*********************************************************************************************************/  
    private static Map<String,Map<String,List<String>>> getEventToIntegrationAttributes(Map<String,Map<String,CGT_MS_Integration_Framework__mdt>> eventTypeToMetadataMap){
        Map<String,Map<String,List<String>>> eventToIntegrationAttributes= new Map<String,Map<String,List<String>>>();
        for(String eventype:eventTypeToMetadataMap.keySet()){
            for(CGT_MS_Integration_Framework__mdt metadata:eventTypeToMetadataMap.get(eventype).Values()){
            List<String> integrationAttributes= metadata.CGT_Query__c.split(',');
            String objectName=metadata.CGT_Object__c;
            if(!eventToIntegrationAttributes.containsKey(eventype)){
                eventToIntegrationAttributes.put(eventype,new Map<String,List<String>>{objectName => new List<String>(integrationAttributes)});
            }else{
                if(eventToIntegrationAttributes.containsKey(eventype) &&
                (!eventToIntegrationAttributes.get(eventype).containsKey(objectName))
                ){
                    eventToIntegrationAttributes.get(eventype).put(objectName,new List<String>(integrationAttributes));
                }else{
                    eventToIntegrationAttributes.get(eventype).get(objectName).addAll(integrationAttributes);
                }
            }
            }
        }
       return eventToIntegrationAttributes;
    }
/********************************************************************************************************
* @author        ext.Manoj.Gupta@cargotec.com
* @description   This method is to get the query based on the Event and the Object.
* @Paramters     Map<String,Map<String,CGT_MS_Integration_Framework__mdt>>
* @return        Map<String,Map<String,String>>
*********************************************************************************************************/  
    private static Map<String,Map<String,String>> getEventTypeToObjectToQueryString(
                                       Map<String,Map<String,CGT_MS_Integration_Framework__mdt>> eventTypeToObjectToMetadata
                                      ){
        Map<String,Map<String,String>> eventypeToObjectToQueryString = new Map<String,Map<String,String>>();
        for(String eventType:eventTypeToObjectToMetadata.keySet()){
            for(String objectName:eventTypeToObjectToMetadata.get(eventType).keySet()){
                CGT_MS_Integration_Framework__mdt metadata= eventTypeToObjectToMetadata.get(eventType).get(objectName);
                String query='SELECT ';
                query+= metadata.CGT_Query__c +' FROM '+ 
                metadata.CGT_Object__c + ' WHERE ' + 
                metadata.CGT_Filter_Criteria__c ;
                Map<String,String> objectToQueryString= new Map<String,String>{objectName =>query};
           
                if(!eventypeToObjectToQueryString.containsKey(eventType)){
                    eventypeToObjectToQueryString.put(eventType,objectToQueryString);
                }else{
                    if(eventypeToObjectToQueryString.containsKey(eventType) &&
                    !eventypeToObjectToQueryString.get(eventType).containsKey(objectName)){
                        eventypeToObjectToQueryString.get(eventType).putAll(objectToQueryString);
                    }
                }
            }
       }
       return eventypeToObjectToQueryString;
     }
}