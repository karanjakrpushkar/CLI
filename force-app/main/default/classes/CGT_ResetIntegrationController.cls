/********************************************************************************************************
* @author         Prince Kumar
* @date           12-01-2018
* @description    Controller class for CGT_ResetIntegrationMessageFieldValue.
          Class has method which sets the Integration message field to null when quick action is executed.
*                 
*********************************************************************************************************/

global with sharing class CGT_ResetIntegrationController{
  /********************************************************************************************************
    * @author    Prince Kumar
    * @date      12-01-2018
    * @description  Quick action ligthning component helper invokes this method.
    * @param    objToIDString (String) : ObjectName and recordId value is seperated with ':'
    * @return    Boolean
    *********************************************************************************************************/
    public Static String estimate_Success = 'Work Estimate Creation Started';
    public Static String estimate_Already_Created = 'You can create only one Estimate/Quote for a Work Order';
    public Static String workOrder_NotIntegrated = 'You can not create an Estimate/Quote for a non-integrated Work Order';
    
  @AuraEnabled
  global static Boolean resetIntegrationMessageFields(String objToIDString){
    System.debug('---objToIDString--'+objToIDString);
    // Variable to indicate error
    Boolean hasError=True;
    String objName;
    String recordId;
    //List of String deducted from  objToIDString string split based on ':' 
    list<String> oNameAndRecordId=objToIDString.split(':');
    //sObject Name e.g. WorkOrder
    objName=oNameAndRecordId[0];
    //sObject Record Id
    recordId=oNameAndRecordId[1];
    System.debug('---objName--'+objName+'---recordId---'+recordId);
    // Query string to fetch Intergration message and Synchronization flag based on sObject Name and record Id.
    String queryString='SELECT '+
              ' ID,CGT_Integration_Message__c from '+ objName +
              ' WHERE ID = :recordId';
    System.debug('--queryString--'+queryString);
    //sObject records return via query String
    sObject[] sObjrecords=System.Database.query(queryString);
    System.debug('---records--'+sObjrecords);
    //Iterate the sObject Records
    for(sObject sobjInst:sObjrecords){
      if(sobjInst.get('CGT_Integration_Message__c') != null){
        sobjInst.put('CGT_Integration_Message__c',null);
        sobjInst.put('CGT_Synchronize__c',false);
      }
      System.debug('--CGT_Integration_Message__c--'+sobjInst);
    }
    try{
          update sObjrecords;
          hasError=False;
    }catch(Exception e){
      LOG_LogMessageUtility.logMessage(e,'Lightning component controller','CGT_ResetIntegrationController','Unexpected exception while resetting the null for ObjectName:'+objName+' ---RecordId'+recordId,true); 
    }
    return hasError;
  }
  
    /********************************************************************************************************
    * @author    Chandan Singh
    * @date      14-01-2019
    * @description  Quick action ligthning component helper invokes this method.
    * @param    Id (String) :Id and recordId value is seperated with ':'
    * @return    Boolean
    *********************************************************************************************************/
    @AuraEnabled
    global static String resetQuoteIntegrationMessageFields(String recordId){
        // Variable to indicate error
        string Message;
        List<WorkOrder> woRecords = [SELECT ID,CGT_Integration_Message__c,CGT_Synchronize__c,CGT_Estimate_Quote_External_Id__c,CGT_Quotation_Integration_Message__c,CGT_External_ID__c  from WorkOrder WHERE ID = :recordId limit 1];
        //Iterate the sObject Records
        for(WorkOrder wo:woRecords){
            if(wo.CGT_Integration_Message__c == null && wo.CGT_Synchronize__c == true && wo.CGT_External_ID__c != null ){
                if(wo.CGT_Estimate_Quote_External_Id__c == null){
                       // wo.CGT_Create_Estimate_Quote__c = true;
                        wo.CGT_CreateEstimate__c = true;
                        wo.CGT_Quotation_Integration_Message__c = null;
                        Message = estimate_Success ;
                }else if(wo.CGT_Estimate_Quote_External_Id__c != null){
                    wo.CGT_Quotation_Integration_Message__c = null;
                    Message = estimate_Already_Created;
                }
            }else {
                    Message = workOrder_NotIntegrated;
            }
                
        }
        try{
              update woRecords;
        }catch(Exception e){
          LOG_LogMessageUtility.logMessage(e,'Lightning component controller','CGT_ResetIntegrationController','Unexpected exception while resetting the null for ObjectName: WorkOrder  ---RecordId'+recordId,true); 
        }

        return Message;
    }
}