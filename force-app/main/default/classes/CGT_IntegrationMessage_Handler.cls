/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Description    This is a handler class for CGT_IntegrationMessage_Trigger 
* @TestClass      <TBD>
* @CreatedDate    07-23-2018

*********************************************************************************************************/
public class CGT_IntegrationMessage_Handler {
    
    private static String retry='CGT_Retry_Value';
    private static Map<String,String> orgSettingMetadataMap=getOrganizationMetadataRecords();
    private static String client_id='CGT_client_id';
    private static String client_secret='CGT_client_secret';
    private static String status_Processing='Processing';
    
/********************************************************************************************************
* @author           chandrakanth.reddy@cargotec.com
* @date             07-23-2018
* @description      This method will invoke the Queuable class CGT_Async_Queuable if the criteria is meet
* @Params           List<String> integrationMsg
* @return           void
*********************************************************************************************************/
    
    public static void retryIntegrationMessageOnUpdate(List<EVT_Integration_Message__c> integrationMsgList){
        Map<String,String> retryIntmessageToJsonMap=new Map<String,String>();
        Map<String,Integer> retryValueMap= new Map<String,Integer>();
        
        String retryValueString=orgSettingMetadataMap.get(retry);
        Integer retryValue=Integer.valueof(retryValueString);
        

        // Loop through the queried records and check the Criteira 
        for(EVT_Integration_Message__c messageInst :integrationMsgList){
            if(messageInst.CGT_Retry_Value__c < retryValue && 
               messageInst.CGT_Retry__c && messageInst.EVT_Status__c ==status_Processing && 
               String.isBlank(messageInst.CGT_Transaction_ID__c)){
                // Id and Retry value of the record is added to the map which will be used for udating the Retry value with +1
                 retryValueMap.put(messageInst.Id, Integer.valueOf(messageInst.CGT_Retry_Value__c));
                // Construct a Map with Id and the Json String 
                retryIntmessageToJsonMap.putAll(getIntMessageToJsonMap(messageInst));
            }
        }
        // Check if the Callout value is less than 100 and greater than 0 to invoke the Queuable class
        if(!retryIntmessageToJsonMap.isEmpty() && 
            retryIntmessageToJsonMap.size()<100 ){
            // Invoke the Queuable class by passing jsonbody and retry value map as parameters
            CGT_Async_Queuable asycQueueJobInst= new CGT_Async_Queuable(retryIntmessageToJsonMap,retryValueMap);
            System.enqueueJob(asycQueueJobInst);
            System.debug('---asycQueueJobInst--'+asycQueueJobInst);
        }
         
    }

 /********************************************************************************************************
* @author           chandrakanth.reddy@cargotec.com
* @date             07-23-2018
* @description      This method will be invoked from the CGT_IntegrationMessage_Trigger on AfterInsert.
* @Params           List<String> integrationmsgL
* @return           void
*********************************************************************************************************/
       @future (Callout= true)
    public static void sendIntegrationMessageOnCreate(List<String> integrationmsgL){
        MAP<String,HttpRequest> reqMap=new MAP<String,HttpRequest>();
        MAP<String,HttpResponse> resMap = new MAP<String,HttpResponse>();
        Map<String,String> intmessageToJsonMap=new Map<String,String>();
        Map<String,Integer> retryValueMap=new Map<String,Integer>();
        // Query for the Integration message record whose Id is in  integrationmsgL 
        List<EVT_Integration_Message__c> integrationmsgList=[SELECT
                                                            Id,CGT_Retry__c,
                                                            CGT_Retry_Value__c,
                                                            CGT_Transaction_ID__c,
                                                            CGT_Json_String__c
                                                            FROM EVT_Integration_Message__c 
                                                            WHERE
                                                            Id  IN: integrationmsgL];
        // Loop thorugh the queried records
        for(EVT_Integration_Message__c integrationmsg : integrationmsgList){
            retryValueMap.put(integrationmsg.Id, Integer.valueOf(integrationmsg.CGT_Retry_Value__c));
            intmessageToJsonMap.putAll(getIntMessageToJsonMap(IntegrationMsg));
        }
        // Create the Map with Id and Requests
        reqMap=createHttpRequest(intmessageToJsonMap);
        // Getting the response map
        resMap=getHttpResponse(reqMap);
        // Updating the Records
        updateIntegrationMessageResponse(resMap,retryValueMap);
    }

/********************************************************************************************************
* @author           chandrakanth.reddy@cargotec.com
* @date             07-23-2018
* @description      This method will update the Integration Message Record based on the Response returned from the Http Callout
* @Params           MAP<String,HttpResponse> resMap,Map<String,Integer>retryValueMap
* @return           void
*********************************************************************************************************/

    public static void updateIntegrationMessageResponse(MAP<String,HttpResponse> resMap,Map<String,Integer>retryValueMap ){
        List<EVT_Integration_Message__c> integrationMsgToUpdate= new List<EVT_Integration_Message__c>();
        EVT_Integration_Message__c intMsgInstance;
        

        List<LOG_LogMessage__c> logListInsert=new List<LOG_LogMessage__c>();
        
            //Loop Through the resMap key values
        for(String str: resMap.keyset()){
            Integer retryException=retryValueMap.get(str)+1;
            try{
                intMsgInstance = new EVT_Integration_Message__c(Id=str);
                System.debug('res:'+resMap.get(str));
                   // Check if the  statuscode is <200 or >203
                    if(resMap.get(str).getStatusCode() < 200 || resMap.get(str).getStatusCode() >203){
                        // Update the Integration Message Record values
                        intMsgInstance.CGT_Retry__c=true;
                        intMsgInstance.CGT_Retry_Value__c=retryValueMap.get(str)+1;
                        integrationMsgToUpdate.add(intMsgInstance);
                    }
                    else{
                        if(String.isNotBlank(resMap.get(str).getbody())){
                            String jsonString=resMap.get(str).getbody().trim();
                            system.debug('jsonString :'+jsonString);
                            // Parse the Json Response and assign the values to the Integration message fields
                            CGT_JsonGeneratorUtilities.ResponseParser responseJsonWrapper =(CGT_JsonGeneratorUtilities.ResponseParser) JSON.deserialize(jsonString,CGT_JsonGeneratorUtilities.ResponseParser.class);
                            if(responseJsonWrapper!=null){
                                CGT_JsonGeneratorUtilities.StandardHeader stdHeader= responseJsonWrapper.responseHeader;
                                if(String.isNotBlank(stdHeader.messageID)){
                                    intMsgInstance.CGT_Transaction_ID__c=stdHeader.messageID;
                                    system.debug('stdHeader.messageID :'+stdHeader.messageID);
                                    intMsgInstance.CGT_Retry__c=false;
                                }else{
                                    intMsgInstance.CGT_Retry__c=true;
                                    intMsgInstance.CGT_Retry_Value__c=retryValueMap.get(str)+1;
                                }
                            }
                            integrationMsgToUpdate.add(intMsgInstance);
                        }
                    }
            }catch(Exception errorMessage){
                System.debug('expection:'+errorMessage.getMessage());
                if(retryException==3){
                    List<LOG_LogMessage__c> logList=LOG_LogMessageUtility.logMessage(errorMessage,'CGT_IntegrationMessage_Handler','updateIntegrationMessageResponse','Record Id :'+ str +',Failed to connect to Server ',false);
                    logListInsert.addAll(logList);
                    
                }
        }

            }

            if(! logListInsert.isEmpty()){
                insert logListInsert;
            }
            
                
        
        if(!integrationMsgToUpdate.isEmpty()){
            update integrationMsgToUpdate;
        }

        
    }

/********************************************************************************************************
* @author           chandrakanth.reddy@cargotec.com
* @date             07-23-2018
* @description      This method will create the Http Request by setting the parameters 
* @Params           Map<String,String>intIdToJsonMap
* @return           MAP<String,HttpRequest>
*********************************************************************************************************/
    
    public static MAP<String,HttpRequest> createHttpRequest(Map<String,String>intIdToJsonMap){
        MAP<String,HttpRequest> httpRequestMap= new MAP<String,HttpRequest>();
        for(String str :intIdToJsonMap.keyset()){
        if(intIdToJsonMap.get(str)!= null ){
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            System.debug('createHttpRequest'+str);
            System.debug('createHttpRequest'+intIdToJsonMap);
            req.setMethod('POST');
            req.setEndpoint('callout:CGT_Mule_EndPoint');
            req.setBody(intIdToJsonMap.get(str));
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('client_id', orgSettingMetadataMap.get(client_id));
            req.setHeader('client_secret',orgSettingMetadataMap.get(client_secret));
            
            httpRequestMap.put(str,req);
            }
        }
        System.debug('------httpRequestMap:'+httpRequestMap);
        return httpRequestMap;
    }

/********************************************************************************************************
* @author           chandrakanth.reddy@cargotec.com
* @date             07-23-2018
* @description      This Method will get the Response from Http by the request we pass
* @Params           MAP<String,HttpRequest> requestList
* @return           MAP<String,HTTPResponse>
*********************************************************************************************************/

    public static MAP<String,HTTPResponse> getHttpResponse(MAP<String,HttpRequest> requestList){
        MAP<String,HTTPResponse> resMap= new MAP<String,HTTPResponse>();
        System.debug('getHttpResponse:'+requestList);
        if(requestList.size()<100){
            for(String str:requestList.keyset() ){
                HTTPResponse res = new HTTPResponse();
                Http http = new Http();
               try{
                    res = http.send(requestList.get(str));
                    //resMap.put(str,res);
                    System.debug('-----res----'+res);
                }
                catch(System.CalloutException e ){
                    //resMap.put(str,null);
                    
                }
                
              resMap.put(str,res);  
            }
        }
        return resMap;
    }

/********************************************************************************************************
* @author           chandrakanth.reddy@cargotec.com
* @date             07-23-2018
* @description      This method construct the Map with Id and json String
* @Params           EVT_Integration_Message__c IntegrationMsg
* @return           Map<String,String>
*********************************************************************************************************/

    private static Map<String,String> getIntMessageToJsonMap(EVT_Integration_Message__c IntegrationMsg){
        Map<String,String> intmessageToJsonMap=new Map<String,String>(); 
        intmessageToJsonMap.put(integrationmsg.Id,integrationmsg.CGT_Json_String__c);

        return intmessageToJsonMap;
    }

/********************************************************************************************************
* @author           chandrakanth.reddy@cargotec.com
* @date             07-23-2018
* @description      This method will return the custom metadata types data from CGT_Organization_setting__mdt
* @Params           None
* @return           Map<String,String>
*********************************************************************************************************/

    public static Map<String,String> getOrganizationMetadataRecords(){
        Map<String,String> orgSettingMetadataMap= new Map<String,String>();
        // Query the Custom Meta Data Type and fetch the DeveloperName and retry value
        List<CGT_Organization_setting__mdt> orgmetadataList = [
                                                                SELECT
                                                                    DeveloperName,CGT_Value__c 
                                                                FROM 
                                                                    CGT_Organization_setting__mdt
                                                                ]; 
        for(CGT_Organization_setting__mdt orgdata:orgmetadataList){
            if(String.isNotBlank(orgdata.CGT_Value__c)){
                orgSettingMetadataMap.put(orgdata.DeveloperName,orgdata.CGT_Value__c);
            }
        }
        
        return orgSettingMetadataMap;
    }


}