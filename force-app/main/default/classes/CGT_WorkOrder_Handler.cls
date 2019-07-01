/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Description    This is a handler class for CGT_WorkOrderTriggger trigger
* @TestClass      <TBD>
* @CreatedDate    12-06-2018
* @Modified Date  08-10-2018 for US SF-2314

*********************************************************************************************************/
public with sharing class CGT_WorkOrder_Handler {
/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Method          workorderValidation
* @Parameters      List<WorkOrder>,MAP<ID,WOrkorder>
* @description     This method is used for validating the WO status against the Open SA's
* @CreatedDate    12-06-2018

*********************************************************************************************************/
// added for US SFF-2314
 public static void autoPopulateTerritory(List<workOrder>woList ){
    // added for US SFF-135 #Start
    List <User> usList = new List<User>([Select Id,CGT_Service_Territory__c from User where Id = :UserInfo.getUserId()]);
    List <ServiceTerritory> stList = new List<ServiceTerritory>([Select Id,Name from ServiceTerritory where Name = :usList[0].CGT_Service_Territory__c]);
    List <CGT_Planner_Group__c>  plannerList = new List<CGT_Planner_Group__c>([Select Id,Name,CGT_Plant__c from CGT_Planner_Group__c where CGT_User__c =:usList[0].Id]);
    for(WorkOrder wo:woList){
        if(wo.CGT_Initial_Service_Territory__c == null && !stList.isEmpty()){
            wo.CGT_Initial_Service_Territory__c = stList[0].Id; 
        }
        if(wo.CGT_Order_Responsible_Person__c == null && !plannerList.isEmpty()&& !stList.isEmpty() && (plannerList[0].CGT_Plant__c == stList[0].Id)){
            wo.CGT_Order_Responsible_Person__c = plannerList[0].Id;
        }
    // added for US SFF-135 #END
        if(wo.ServiceTerritoryId == null && wo.CGT_Initial_Service_Territory__c != null){
                wo.ServiceTerritoryId = wo.CGT_Initial_Service_Territory__c ;
        }
    }            
 }
 public static void autoCreateWOLI(List<workOrder>woList ){
      //Check if the user is not an Integration API user
      if(userinfo.getFirstName()!='Integration'){
           // Declare the Map 
           Map<String,String> stMap=new Map<String,String>();
           Map<String,String> childstMap=new Map<String,String>();
           Map<String,String> locationMap=new Map<String,String>();
           // Declare a Map  to store the CaseId's and  subject
           
           Map<String,String> cseMap= new Map<String,String>();
           
           // query for the work orders for getting the Assset's Equipmenttype 
           List<WorkOrder> listWo=[select id,
                                           CaseId ,Case.Subject
                                           from WorkOrder 
                                           where Id IN :woList];
            
            // Map to store the workorderId and Asset.EquipmentType
            for(WorkOrder wo :listWo){
              cseMap.put(wo.CaseId,wo.Case.Subject);
            }

           // Loop through all the workOrders comming from trigger.New and check for the Asset.Equipmenttype condition
           for(WorkOrder wo:woList)
           {
             if(wo.ServiceTerritoryId!=null){
                  stMap.put(wo.serviceTerritoryID,wo.id);
              }
             
            }

           // query for ServiceTerritory records whose parentTerritoryID = WO.serviceTerritory, Record type is CGT_Work_Center and CGT_Default_Work_Center__c = true 
           List<ServiceTerritory> childSTList= [select ID,
                                                       ParentTerritoryId 
                                                       from 
                                                       ServiceTerritory 
                                                       where 
                                                       ParentTerritoryId in: stMap.keyset() 
                                                       AND 
                                                       IsActive =true 
                                                       AND 
                                                       RecordType.DeveloperName='CGT_Work_Center' 
                                                       AND 
                                                       CGT_Default_Work_Center__c = true ]; 
           
           for(ServiceTerritory st:childSTList)
           {
               childstMap.put(stMap.get(st.ParentTerritoryId),st.id);
           }
           // query for the ServiceTerritoryLocation Records whose serviceTerritoryId in childstMap
            List<ServiceTerritoryLocation> locationList = [select ID,
                                                                  ServiceTerritoryId, 
                                                                  LocationId, 
                                                                  ServiceTerritory.ParentTerritoryId 
                                                                  from 
                                                                  ServiceTerritoryLocation 
                                                                  where 
                                                                  ServiceTerritoryId IN :childstMap.values()];    
          for(ServiceTerritoryLocation stl:locationList)
           {
              locationMap.put(stMap.get(stl.ServiceTerritory.ParentTerritoryId),stl.Locationid);
           } 
          Id internalRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('CGT_Internal').getRecordTypeId();
          Id externalRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('CGT_External').getRecordTypeId();
          List<WorkOrderLineItem> woliInsert=new List<WorkOrderLineItem>();  
          for(WorkOrder wo:woList){  
             WorkOrderLineItem woli=new WorkOrderLineItem();
              woli.workOrderID=wo.id;
              woli.priority = wo.Priority; // added the new field
             if(!childstMap.isEmpty()){
                woli.ServiceTerritoryId=childstMap.get(wo.id);
             }
             else{
                woli.serviceTerritoryID=null;
             }
             woli.CGT_Storage_Location__c=locationMap.get(wo.id);
             woli.startdate= wo.startdate;
             woli.enddate= wo.enddate;
             woli.Duration = wo.Duration;
             woli.DurationType = wo.DurationType;
             if(wo.CGT_Work_scope_executed_by_subcontractor__c){
                woli.recordtypeId =  externalRecordTypeId;
             }else{
                woli.recordtypeId = internalRecordTypeId;
             }
             woliInsert.add(woli);
         }

         try{
            if(!woliInsert.isEmpty()){
              CGT_WorkOrderLineItem_Handler.notFirstWoli = false; // added to stop the logic which run for 2ndWoli only
              insert woliInsert;
            }

         } catch(Exception errorMessage){
          LOG_LogMessageUtility.logMessage(errorMessage,'CGT_WorkOrder_Handler','autoCreateWOLI','Error creating WOLI Records from WO',true);

         }  
   
        }
    }
    
   // added for US SFF-2314 #END
   
   
   // added for US SFF-40 #Start
    public static void autoCreateOpportunity(List<workOrder>woList){
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CGT_Work_Order_Opportunity').getRecordTypeId();
        List<Opportunity> opptyList = new List<Opportunity>();
        for(WorkOrder wo: woList){
            Opportunity Oppty = new Opportunity();
            Oppty.Name = 'FSM_Opportunity_' + wo.WorkOrderNumber;
            Oppty.StageName = 'New / No Enquiry';
            oppty.RecordtypeId = recordTypeId;
            Oppty.closeDate = System.Today();
            //Oppty.AccountId = wo.AccountId;
            Oppty.CGT_Work_Order__c = wo.Id;
            opptyList.add(Oppty);
        }
        try{
            if(!opptyList.isEmpty()){
                Insert opptyList;
            }
        }Catch (Exception e){
            System.debug('Opportunity Creation Failed'+e.getmessage());
        }
    }
    // added for US SFF-40 #END
    
  public static void workorderValidation(List<WorkOrder> workorderTriggerList, Map<Id,WorkOrder> oldmap_wo){

          Set<Id> woId_set= new Set<Id>();

         // Loop throguh the new workorder List and save to a Set.
          for(WorkOrder wo : workorderTriggerList){
            // check if the WO status isChanged and equal to Closed or Cancelled
            if((wo.Status== 'Closed' && wo.Status != oldmap_wo.get(wo.Id).Status) || (wo.Status== 'Canceled' && wo.Status != oldmap_wo.get(wo.Id).Status)){
              woId_set.add(wo.Id);
            }
                 
          }
          // Add the Service Appointment Values to a List for checking the condition
          List<String> status_Values= new List<String>();
          status_Values.add('Cannot Complete');
          status_Values.add('Completed');
          status_Values.add('Canceled');
         
          // Fetch all the WOLI related to WorkOrder's
          List<WorkOrderLineItem> woli_List= [select id 
                            from 
                            WorkOrderLineItem 
                            where 
                            WorkOrderId IN :woId_set];
          // Fetch the SA's related to the WOLI's
          List<ServiceAppointment> sa_List= [select id , 
                                              CGT_Work_Order_Line_Item__r.WorkOrderId 
                                               from ServiceAppointment
                                             where ParentRecordId IN : woli_List
                                             AND Status NOT IN  : status_Values];

          // Construct a Map from the SA records to store WO ID and Set<SA.ID>
          Map<Id,Set<Id>> map_SA_count= new Map<Id,Set<Id>>();

          for(ServiceAppointment sa : sa_List){
              if(! map_SA_count.containsKey(sa.CGT_Work_Order_Line_Item__r.WorkOrderId)){
                  set<Id> setId= new Set<Id>();
                  map_SA_count.put(sa.CGT_Work_Order_Line_Item__r.WorkOrderId,setId);

              }
              map_SA_count.get(sa.CGT_Work_Order_Line_Item__r.WorkOrderId).add(sa.id);

          }

          
          for(WorkOrder wo : workorderTriggerList){
              if((wo.Status== 'Closed' && wo.Status != oldmap_wo.get(wo.Id).Status) || (wo.Status== 'Canceled' && wo.Status != oldmap_wo.get(wo.Id).Status)){
                // check if any open SA are available for the WO 
                 if( map_SA_count.containsKey(wo.Id)){
                    wo.adderror(System.label.CGT_WO_Cannot_Close_SA_Open);
                 }
              }
              
          }

    }

/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Method          updateCase_ClosedWO
* @Parameters      List<WorkOrder>,MAP<ID,WOrkorder>
* @description     This method is used for updating the CGT_TF_WO_Closed__c field on case when ever a work order is closed
* @CreatedDate    12-06-2018

*********************************************************************************************************/  
  Public static void updateCase_ClosedWO(List<WorkOrder> woList, Map<Id,WorkOrder> oldmap_WO){
    
    Set<Id> caseid_set= new Set<Id>();
    // loop through the new list of work orders and add the Case ids to a Set
    for(WorkOrder wo : woList){
      if((wo.Status == 'Closed' && wo.Status != oldmap_wo.get(wo.Id).Status) || (wo.Status == 'Canceled' &&  wo.Status != oldmap_wo.get(wo.Id).Status))
      caseid_set.add(wo.caseId);

    }

    // Fetch the Case records which are in the Added set

    List<Case> case_List= [select Id,
                                  CGT_TF_WO_Closed__c,
                                  Status 
                                  from Case 
                                  where Id IN :caseid_set];
         
         List<Case> caseUpdate= new List<Case>();
     for(Case cse : case_List ){

       cse.CGT_TF_WO_Closed__c=True;

       caseUpdate.add(cse);

     }

     try{
       if(! caseUpdate.isEmpty())
         update caseUpdate;
     }
     catch(Exception errorMessage){
                LOG_LogMessageUtility.logMessage(errorMessage,'CGT_WorkOrder_Handler','updateCase_ClosedWO','Failed to Update the  related case Records',true);
         }  
    }
    
    /********************************************************************************************************
    * @Author         ext.chandan.singh@cargotec.com
    * @Method          calculateDurationWO
    * @Parameters      List<WorkOrder>,MAP<ID,WOrkorder>,isInsert,isUpdate
    * @description     This method is used for calculating Duration or EndDate based on StartDate,EndDate and Duration on workOrder.
    * @CreatedDate     01-02-2019

    *********************************************************************************************************/  
    
    public static void calculateDurationWO(List<WorkOrder> woList,MAP<ID,WOrkorder> oldMap,boolean isInsert, boolean isUpdate ){
        for(WorkOrder wo:woList){
            if(isInsert && wo.startDate == null){
                wo.startDate = System.Today();  
            }
            if((isInsert && wo.startDate != null && wo.endDate!= null) || (isUpdate && wo.startDate != null && wo.endDate!= null 
                && (wo.StartDate != oldMap.get(wo.Id).StartDate || wo.endDate != oldMap.get(wo.Id).endDate || wo.Duration == null || (wo.DurationType != oldMap.get(wo.Id).DurationType && wo.Duration == oldMap.get(wo.Id).Duration)))){
                    
                wo.Duration = CGT_FSM_Utility.calculateDuration (wo.StartDate,wo.EndDate,wo.DurationType);
                
            }else if ((isInsert && wo.startDate != null && wo.Duration != null) || (isUpdate && wo.startDate != null && wo.Duration != null && 
                      ((wo.Duration != oldMap.get(wo.Id).Duration) || wo.EndDate == null))){
                        wo.endDate = CGT_FSM_Utility.calculateEndDate (wo.StartDate,wo.Duration,wo.DurationType);
            }
        }
    }
    
    
     /********************************************************************************************************
    * @Author         ext.chandan.singh@cargotec.com
    * @Method          calculateDurationWO
    * @Parameters      MAP<ID,WOrkorder>
    * @description     This method is used for validate external WOLI fields when workOrder is submitted or released.
    * @CreatedDate     10-05-2019

    *********************************************************************************************************/  
    
    public static void externalWOLIfieldValidation(Map<Id,Workorder> newMap,Map<Id,Workorder> oldMap){
        Id externalRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('CGT_External').getRecordTypeId();
        Map<String,List<WorkOrderLineItem>> woIdtoWOLIMap = new Map<String,List<WorkOrderLineItem>>();
        List<WorkOrderLineItem> woliList = [Select Id,CGT_Service_Type__c,LineItemNumber,Description,CGT_Quantity_Required__c,CGT_Price__c,CGT_Vendor__c,
                                            CGT_Quantity_Unit_Of_Measure__c,WorkOrderId,recordTypeId from WorkOrderLineItem where WorkOrderId IN : newMap.keyset()];

        for (WorkOrderLineItem woli:woliList){
            if(!woIdtoWOLIMap.isEmpty() && woIdtoWOLIMap.containsKey(woli.WorkOrderId)){
                woIdtoWOLIMap.get(woli.WorkOrderId).add(woli);
            }else{
                List<workOrderLineItem> woliMapList = new List<workOrderLineItem>();
                woliMapList.add(woli);
                woIdtoWOLIMap.put(woli.WorkOrderId,woliMapList);
            }
            for(WorkOrder wo : newMap.values()){
                List<string> blankfields = new List<String>();
                if(!woIdtoWOLIMap.isEmpty() && woIdtoWOLIMap.containsKey(wo.id) && (wo.status == 'Submitted' || wo.status == 'Released') && 
                    wo.CGT_External_Id__c == null){
                    for(WorkorderLineItem wolicheck: woIdtoWOLIMap.get(wo.Id)){
                        if(wolicheck.recordtypeId == externalRecordTypeId){ 
                            blankfields.clear();
                            if(wolicheck.Description == null){
                                blankfields.add('Description');
                            }
                            if(wolicheck.CGT_Quantity_Required__c == null){
                               blankfields.add('Quantity Required');
                            }
                            if(wolicheck.CGT_Price__c == null){
                                blankfields.add('Price');
                            }
                            if(wolicheck.CGT_Vendor__c == null){
                                blankfields.add('Vendor');
                            }
                            if(wolicheck.CGT_Quantity_Unit_Of_Measure__c == null){
                                blankfields.add('Quantity Unit Of Measure');
                            }
                            if(blankfields != null && !blankfields.isEmpty()){
                                if(!Test.isRunningTest()){
                                    wo.addError(System.label.CGT_WOLI_Fields_Error + wolicheck.LineItemNumber + ':'+ blankfields);
                                }
                            }
                        }
                        
                    }
                    
                }
            }   
        }
    }
            
                
}