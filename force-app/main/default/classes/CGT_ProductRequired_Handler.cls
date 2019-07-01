/**********************************************************************************************************
* Class Name   : CGT_ProductRequired_Handler 
* Description  : ProductRequired Trigger Helper Class .
* Created By   : ext.chandan.Singh@cargotec.com
* Created Date : 05/02/2019

* Modification Log:
* --------------------------------------------------------------------------------------------------------
* Developer                                     Date          Modification ID                Description
* --------------------------------------------------------------------------------------------------------
* ext.chandan.Singh@cargotec.com               05/02/2019                                 Initial version
*********************************************************************************************************/
public with sharing class CGT_ProductRequired_Handler 
{
    //Defines trigger context 
    public static String PR_CREATE ='create';
    public static String PR_UPDATE ='update';
    public static String PR_DELETE ='delete';
    
    
    //Defines integration message event type
    private static final String PR_CREATE_EVENT_TYPE= 'PRCREATE';
    private static final String PR_UPDATE_EVENT_TYPE='PRUPDATE';
    private static final String PR_DELETE_EVENT_TYPE='PRDELETE';

/********************************************************************************************************
* @author           chandan.singh@cargotec.com
* @date             04-25-2019
* @description      This method is used to populate WorkOrderLineItem on Local Vendor Purchase Object.
* @Params           List<CGT_Local_Vendor_Product_Consumed__c> localVendorPurchaseList
* @return           void
*********************************************************************************************************/
    public static void populateWOLI(List<ProductRequired> productrequiredList){
        Map<Id,Id> prIdtoWorkOrderIdMap = new Map<Id,Id>();
        for (ProductRequired pr : productrequiredList){
                 pr.CGT_Work_Order__c = pr.ParentRecordId;
                 prIdtoWorkOrderIdMap.put(pr.Id,pr.CGT_Work_Order__c);
        }
             Map<Id,Id> woIdwoliIdMap = CGT_FSM_Utility.firstWOLIofWO(prIdtoWorkOrderIdMap.values());
        for(ProductRequired productRequired : productrequiredList){
            if(woIdwoliIdMap != null && woIdwoliIdMap.containsKey(productRequired.CGT_Work_Order__c)){
                productRequired.CGT_TECH_Work_Order_Line_Item__c = woIdwoliIdMap.get(prIdtoWorkOrderIdMap.get(productRequired.Id));
                productRequired.CGT_TECH_Work_Order_Line_Item__c = woIdwoliIdMap.get(prIdtoWorkOrderIdMap.get(productRequired.Id));
            }
        }
    }

    /*******************************************************************************************************
* @author          Tieto
* @date             2019-05-06
* @description      Performs validation whether the selected Product2 on the ProductRequired is 
*                   extended towards the Service Territory of the related Work Order
* @Paramters        List<PrductRequired> lstProdRequired (Trigger.new) 
* @return           void
*********************************************************************************************************/
    public static void verifyPlantExtension(List<ProductRequired> lstProdRequired) 
    {
        try
        {
            // Set representing all Product2 Ids in Scope
            Set<Id> productIdSet = new Set<Id> ();
            
            // Set representing all WOLI Ids in Scope
            set<Id> woliIdSet = new set<Id> ();
            
            // Retrieve all Product2 and WOLI Ids in scope and store them in the correct sets
            // Assumption: Product Required records are only created as childs of WOLI records
            for(ProductRequired pr : lstProdRequired)
            {
                productIdSet.add(pr.Product2Id);
                woliIdSet.add(pr.CGT_TECH_Work_Order_Line_Item__c);
            }
            
            // Retrieve the relevant data, a direct PR query is not possible to retrieve both sets of data
            // given the polymorfic nature of the CGT_TECH_Work_Order_Line_Item__c field
            
            // Retrieve Plant Extension information for the Products in scope
            Map<Id, Product2> productMap = new Map<Id, Product2>([
                SELECT
                Id,
                CGT_Plant_Extension__c,
                CGT_Unit_Of_Measure__c
                //CGT_Alternative_Unit_Of_Measure__c
                FROM
                Product2
                WHERE
                Id IN :productIdSet 
            ]);
            
            // Retrieve the Service Territory Plant Codes for each WOLI in scope
            Map<Id, WorkOrderLineItem> woliMap = new Map<Id, WorkOrderLineItem>([
                SELECT
                Id,
                WorkOrderId,
                workOrder.ServiceTerritory.CGT_External_ID__c,
                ServiceTerritory.CGT_External_ID__c
                FROM
                WorkOrderLineItem
                WHERE
                Id IN :woliIdSet                                            
            ]);
            
            // Carry out the Plant Extension validation operation and complete technical fields on Product Required
            if(!productMap.isEmpty() && !woliMap.isEmpty())
            {
                for(ProductRequired pr : lstProdRequired)
                {
                    if(productMap.containsKey(pr.Product2Id) && woliMap.containsKey(pr.CGT_TECH_Work_Order_Line_Item__c))
                    {
                        if(productMap.get(pr.Product2Id).CGT_Plant_Extension__c != null && woliMap.get(pr.CGT_TECH_Work_Order_Line_Item__c).workOrder.ServiceTerritory.CGT_External_ID__c != null)
                        {
                            if(!productMap.get(pr.Product2Id).CGT_Plant_Extension__c.contains(woliMap.get(pr.CGT_TECH_Work_Order_Line_Item__c).workOrder.ServiceTerritory.CGT_External_ID__c))
                            {   
                                // The selected material has not been extended to the Work Order Plant
                                pr.addError(System.Label.CGT_Error_Material_Plant_Extension + ' ('+woliMap.get(pr.CGT_TECH_Work_Order_Line_Item__c).workOrder.ServiceTerritory.CGT_External_ID__c+')');
                            }
                            else
                            {   
                                // Assign technical field values to the PR
                                pr.CGT_TECH_Work_Order_Line_Item__c = woliMap.get(pr.CGT_TECH_Work_Order_Line_Item__c).Id;
                                pr.CGT_Work_Order__c = woliMap.get(pr.CGT_TECH_Work_Order_Line_Item__c).WorkOrderId;
                                if(pr.CGT_Unit_of_Measure__c== null){
                                    pr.CGT_Unit_of_Measure__c=productMap.get(pr.Product2Id).CGT_Unit_of_Measure__c;
                                }
                            }
                        }
                        else if(productMap.get(pr.Product2Id).CGT_Plant_Extension__c == null)
                        {
                            // Missing Plant Extension Information
                            pr.addError(System.Label.CGT_Error_Material_No_Plant_Extension);
                        }
                        else if(woliMap.get(pr.CGT_TECH_Work_Order_Line_Item__c).workOrder.ServiceTerritory.CGT_External_ID__c ==  null)
                        {   
                            // Missing Work Order Plant information
                            pr.addError(System.Label.CGT_Error_Material_Plant_Extension_Missing_Plant_Code);
                        }
                    }  
                }  
            } 
            
            
        }
        catch(Exception errorMessage)
        {
            LOG_LogMessageUtility.logMessage(errorMessage,'CGT_ProductRequired_Handler','CGT_ProductRequired_VerifyServiceTerritoryProduct','Error',true);
        }
    }
    
    /************************************************************************************************************
* @author           ext.chandan.singh@cargotec.com 
* @date             2019-06-05
* @description      Create record in integration message object when product required is created under integrated WOLI.
* @Paramters        Map<Id,ProductRequired> prTriggerNewMap  Trigger.newMap
* @Paramters        Map<Id,ProductRequired> prTriggerOldMap  Trigger.OldMap
* @Paramters        Boolean isCreate  Trigger.IsCreate
* @Paramters        Boolean isUpdate  Trigger.IsUpdate
* @return           void
*************************************************************************************************************/    
    public static void verifyPRFieldsAndCreateIntegrationMessages(Map<Id,ProductRequired> prTriggerNewMap,
      Map<Id,ProductRequired> prTriggerOldMap,
      Boolean isCreate,Boolean isUpdate){
          //Form map of integration attributes store in PR_Integration_Attribute metadata.
          Map<String,List<String>> prIntegrationAttributes = CGT_ProductRequired_Handler.GetPRIntegrationAttributes();
          Set<Id> woliIDSet = new Set<Id>();
          Map<String,Map<String,ProductRequired>> woliToProdReqMap = new Map<String,Map<String,ProductRequired>>();
          Map<Id,WorkOrderLineItem> woliMap;
          Map<String,List<ProductRequired>> prToCreateIntegrationMessage = new Map<String,List<ProductRequired>>();
          
          //Form Id set of WOLI and map of WOLI to product required map
          for(ProductRequired prInst1 : prTriggerNewMap.values()){
              woliIDSet.add(prInst1.CGT_TECH_Work_Order_Line_Item__c);
              if(!woliToProdReqMap.containsKey(prInst1.CGT_TECH_Work_Order_Line_Item__c)){
                  woliToProdReqMap.put(prInst1.CGT_TECH_Work_Order_Line_Item__c,new Map<String,ProductRequired>());
              }
              woliToProdReqMap.get(prInst1.CGT_TECH_Work_Order_Line_Item__c).put(prInst1.Id,prInst1);
          }
          
          try{       
              //query all the workorderlineitems based on product required CGT_TECH_Work_Order_Line_Item__c
              woliMap = new Map<Id,WorkOrderLineItem>([SELECT Id,CGT_Synchronize__c,CGT_External_Id__c
                                                       FROM WorkOrderLineItem
                                                       WHERE Id IN:woliIDSet]);
                                                       
              //query all the workorderlineitems based on product required CGT_TECH_Work_Order_Line_Item__c
              for(ProductRequired prInst2: prTriggerNewMap.values()){
                  Boolean isIMRequiredForPR = true;
                  Boolean hasPRExternalId=false;
                  // check if WOLI is already integrated
                  if(String.isNotBlank(woliMap.get(prInst2.CGT_TECH_Work_Order_Line_Item__c).CGT_External_Id__c)){                
                      //check insert TriggerContext
                      if(isCreate){
                          //validate mandatory integration fields are not null 
                          for(String str1:prIntegrationAttributes.get(PR_CREATE)){
                              System.debug('---Product Required create instance---'+prInst2.get(str1));
                              String prFieldValue= String.ValueOf(prInst2.get(str1));
                              if(String.isBlank(prFieldValue)){
                                  isIMRequiredForPR=false;
                                  break;
                              }
                          }
                          // create map for all pr records which should have integration message event type PRCREATE.
                          if(isIMRequiredForPR){
                              if(!prToCreateIntegrationMessage.containsKey(PR_CREATE)){
                                  prToCreateIntegrationMessage.put(PR_CREATE,new List<ProductRequired>());
                              }
                              prToCreateIntegrationMessage.get(PR_CREATE).add(prInst2);
                          } 
                      }else if(isUpdate){
                          isIMRequiredForPR=false;
                          // Retry logic check initiated via quick action
                          if((prInst2.CGT_Integration_Message__c != prTriggerOldMap.get(prInst2.Id).CGT_Integration_Message__c) &&
                             String.isBlank(prInst2.CGT_Integration_Message__c) && (!prInst2.CGT_Synchronize__c)){
                                 isIMRequiredForPR=true;
                             }
                          // check if product required is already integrated
                          if(String.isNotBlank(prInst2.CGT_External_Id__c)){
                              hasPRExternalId=true;
                              if(String.isBlank(prInst2.CGT_Integration_Message__c)){
                                  for(String str2:prIntegrationAttributes.get(PR_UPDATE)){
                                      System.debug('---Product Required update instance---'+prInst2.get(str2));
                                      String prFieldValue= String.ValueOf(prInst2.get(str2));
                                      // Check mandatory integration fields are not null and atleast one field value is updated.
                                      if(String.isNotBlank(prFieldValue) && 
                                         prInst2.get(str2) != prTriggerOldMap.get(prInst2.Id).get(str2)){
                                             isIMRequiredForPR=true;
                                             break;
                                         }
                                  }
                              }
                          }   
                          
                          if(isIMRequiredForPR && hasPRExternalId && !prInst2.CGT_Is_Delete__c ){
                              if(!prToCreateIntegrationMessage.containsKey(PR_UPDATE)){
                                  prToCreateIntegrationMessage.put(PR_UPDATE,new List<ProductRequired>());
                              }
                              prToCreateIntegrationMessage.get(PR_UPDATE).add(prInst2);
                              //Else logic executed when PR integration to SAP is retried
                          }else if(isIMRequiredForPR && !hasPRExternalId){
                              if(!prToCreateIntegrationMessage.containsKey(PR_CREATE)){
                                  prToCreateIntegrationMessage.put(PR_CREATE,new List<ProductRequired>());
                              }
                              prToCreateIntegrationMessage.get(PR_CREATE).add(prInst2);
                          }
                      } 
                  }
              }
              //create integration message entry for eligible product required records.
              createIntegrationMessage(prToCreateIntegrationMessage);   
          }catch(Exception errorMessage){
              LOG_LogMessageUtility.logMessage(errorMessage,'CGT_Product_Required_Handler','CGT_ProductRequired_VerifyQuantityRequired','Unexpected error while updating Quantity',false);
          }
      }
    
    
    /************************************************************************************************************
* @author           ext.chandan.singh@cargotec.com 
* @date             2019-06-05
* @description      Create integration message records for eligible product requireds.
* @Paramters        Map<String,List<ProductRequired>> productRequiredMaP  product required map based on trigger context
* @return           void
*************************************************************************************************************/
    private static void createIntegrationMessage(Map<String,List<ProductRequired>> productRequiredMaP){
        List<EVT_Integration_Message__c> intMessageList = new List<EVT_Integration_Message__c>();
        EVT_Integration_Message__c message;
        //Validate if map contains product required related to insert trigger context and create integration message records.
        List<String> eventTypeWithRecordId= new List<String>();
        if(!productRequiredMaP.isEmpty() && productRequiredMaP.containsKey(PR_CREATE)){
            for(ProductRequired prInst : productRequiredMaP.get(PR_CREATE)){
                //new instance of integration message
                message = new EVT_Integration_Message__c();
                message.EVT_Event_Type__c=PR_CREATE_EVENT_TYPE;
                message.EVT_Record_To_Integrate__c=prInst.Id;
                intMessageList.add(message);
                eventTypeWithRecordId.add(PR_CREATE_EVENT_TYPE+':'+prInst.Id);
            }
        }
        //Validate if map contains product required related to update trigger context and create integration message records.
        if(!productRequiredMaP.isEmpty() && productRequiredMaP.containsKey(PR_UPDATE)){
            for(ProductRequired prInst : productRequiredMaP.get(PR_UPDATE)){
                //new instance of integration message
                message = new EVT_Integration_Message__c();
                message.EVT_Event_Type__c=PR_UPDATE_EVENT_TYPE;
                message.EVT_Record_To_Integrate__c=prInst.Id;
                intMessageList.add(message);
                eventTypeWithRecordId.add(PR_UPDATE_EVENT_TYPE+':'+prInst.Id);
            }
        }
        //Validate if map contains product required related to delete trigger context and create integration message records.
        if(!productRequiredMaP.isEmpty() && productRequiredMaP.containsKey(PR_DELETE)){
            for(ProductRequired prInst : productRequiredMaP.get(PR_DELETE)){
                //new instance of integration message
                message = new EVT_Integration_Message__c();
                message.EVT_Event_Type__c=PR_DELETE_EVENT_TYPE;
                message.EVT_Record_To_Integrate__c=prInst.Id;
                intMessageList.add(message);
                eventTypeWithRecordId.add(PR_DELETE_EVENT_TYPE+':'+prInst.Id);
            }
        }
        try{
            //insert intMessageList;
            if(!eventTypeWithRecordId.isEmpty()){
                CGT_JsonGeneratorHandler.createIntMessageWithJsonPayload(eventTypeWithRecordId);
            }
        }catch(dmlException ex){
            LOG_LogMessageUtility.logMessage(ex,'CGT_Product_Required_Handler','createIntegrationMessage','Integration Message creation for Product Required are failed.',true);
        } 
    }
    
    /************************************************************************************************************
* @description: Query custom metadata and returns integration fields required for product required create and update. 
* @return: Map<String,List<String> insertUpdatePRAttributeMap
*************************************************************************************************************/
    private static Map<String,List<String>> getPRIntegrationAttributes(){
        Map<String,List<String>> insertUpdatePRAttributeMap= new Map<String,List<String>>();
        //Query Product Required Custom fields API name from Metadata
        List<CGT_PR_Integration_Attributes__mdt> prIntAttributeList = new List<CGT_PR_Integration_Attributes__mdt>([SELECT DeveloperName,CGT_Create__c,CGT_Update__c,CGT_Delete__c 
                                                                                                                    FROM CGT_PR_Integration_Attributes__mdt]);
        //Form a map of custom fields required to validate to create Integration Message
        for(CGT_PR_Integration_Attributes__mdt prIntAtt :prIntAttributeList){
            //Checks if attribute is mandatory during create
            if(prIntAtt.CGT_Create__c){
                if(!insertUpdatePRAttributeMap.containsKey(PR_CREATE)){
                    insertUpdatePRAttributeMap.put(PR_CREATE,new List<String>());
                }
                //String fieldAPIName=(String)prIntAtt.DeveloperName
                insertUpdatePRAttributeMap.get(PR_CREATE).add(prIntAtt.DeveloperName.replace('_c','__c'));
            }
            //Checked if attribute is required during update
            if(prIntAtt.CGT_Update__c){
                if(!insertUpdatePRAttributeMap.containsKey(PR_UPDATE)){
                    insertUpdatePRAttributeMap.put(PR_UPDATE,new List<String>());
                }
                insertUpdatePRAttributeMap.get(PR_UPDATE).add(prIntAtt.DeveloperName.replace('_c','__c'));
            }
            //Checked if attribute is required during delete
            //Not needed i guess, as we can use the PR_UPDATE snippent written above
            if(prIntAtt.CGT_Delete__c){
                if(!insertUpdatePRAttributeMap.containsKey(PR_DELETE)){
                    insertUpdatePRAttributeMap.put(PR_DELETE,new List<String>());
                }
                insertUpdatePRAttributeMap.get(PR_DELETE).add(prIntAtt.DeveloperName.replace('_c','__c'));
            }
        }                                                                                                           
        return insertUpdatePRAttributeMap;
    }
    
}