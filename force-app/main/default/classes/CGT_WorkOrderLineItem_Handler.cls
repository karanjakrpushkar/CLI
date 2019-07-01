/********************************************************************************************************
* @Author         ext.chandan.singh@cargotec.com
* @Description    This is a handler class for CGT_wolirkOrderLineItemTriggger 
* @TestClass      <TBD>
* @CreatedDate    25-01-2018
* @Modified Date  

*********************************************************************************************************/
public with sharing class CGT_WorkOrderLineItem_Handler{
    
    /********************************************************************************************************
    * @Author         ext.chandan.singh@cargotec.com
    * @Method          calculateDuration
    * @Parameters      List<workOrderLineItem>,MAP<ID,workOrderLineItem>
    * @description     This method is used for updating the duration on wolirk Order
    * @CreatedDate    12-06-2018
    * Update :: // considered the update Scenario also in the method. So if update is needed in future on WOLI,
                    Please call this method only in update. No changes needed.
    *********************************************************************************************************/  
    public static Boolean notFirstWoli = true;
    public static set<Id> woIdSet= new set<Id>();
    public static void calculateDurationwoli(List<workOrderLineItem> woliList,MAP<ID,workOrderLineItem> oldMap,boolean isInsert, boolean isUpdate ){
        System.Debug('notFirstWoli>>>>'+notFirstWoli);
        if(notFirstWoli){
            for(workOrderLineItem woli:woliList){
                if(isInsert && woli.startDate == null){
                    woli.startDate = System.Today();  
                }
                if((isInsert && woli.startDate != null && woli.endDate!= null) || (isUpdate && woli.startDate != null && woli.endDate!= null 
                && (woli.StartDate != oldMap.get(woli.Id).StartDate || woli.endDate != oldMap.get(woli.Id).endDate || woli.Duration == null || 
                (woli.DurationType != oldMap.get(woli.Id).DurationType && woli.Duration == oldMap.get(woli.Id).Duration)))){
                    
                    woli.Duration = CGT_FSM_Utility.calculateDuration (woli.StartDate,woli.EndDate,woli.DurationType);
                
                }else if ((isInsert && woli.startDate != null && woli.Duration != null) || (isUpdate && woli.startDate != null && woli.Duration != null && 
                      ((woli.Duration != oldMap.get(woli.Id).Duration) || woli.EndDate == null))){
                        woli.endDate = CGT_FSM_Utility.calculateEndDate (woli.StartDate,woli.Duration,woli.DurationType);
                }
                woIdSet.add(woli.WorkOrderId);
                System.Debug('woIdSet>>>>'+woIdSet);
            }
        }
                
    }
    /********************************************************************************************************
    * @Author         ext.chandan.singh@cargotec.com
    * @Method          populatedefaultworkCenter
    * @Parameters      List<workOrderLineItem>
    * @description     This method is used to populate default service Territory on WOLI if service Territory is blank 
                       on WOLI,in case of manual creation of WOLI.
    * @CreatedDate    09-05-2019
   
    *********************************************************************************************************/  
    public static void populatedefaultworkCenter(List<workOrderLineItem> woliList){
        if (woIdSet != null && !woIdSet.isEmpty()){
            Map<String,String> territoryIdToWOIdMap=new Map<String,String>();
            Map<String,String> woToTerritoryIdMap =new Map<String,String>();
            Map<String,String> childstMap=new Map<String,String>();
            //Map<String,String> locationMap=new Map<String,String>();
            List<WorkOrder> workOrderList = new List <WorkOrder>([Select Id,ServiceTerritoryId from WorkOrder where Id IN :woIdset]);
            for (WorkOrder wo:workOrderList){
                territoryIdToWOIdMap.put(wo.ServiceTerritoryId,wo.Id);
                woToTerritoryIdMap.put(wo.Id,wo.ServiceTerritoryId);
            }
            List<ServiceTerritory> childSTList= [select ID,
                                               ParentTerritoryId 
                                               from 
                                               ServiceTerritory 
                                           where 
                                           ParentTerritoryId in: territoryIdToWOIdMap.keySet() 
                                           AND 
                                           IsActive =true 
                                           AND 
                                           RecordType.DeveloperName='CGT_Work_Center' 
                                           AND 
                                           CGT_Default_Work_Center__c = true ]; 
           
           for(ServiceTerritory st:childSTList)
           {
               childstMap.put(territoryIdToWOIdMap.get(st.ParentTerritoryId),st.id);
           }
           // query for the ServiceTerritoryLocation Records whose serviceTerritoryId in childstMap
           /* List<ServiceTerritoryLocation> locationList = [select ID,
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
           } */
            for(WorkOrderLineItem woli:woliList){  
                if(!childstMap.isEmpty() && childstMap.containskey(woli.workOrderId) && (woli.ServiceTerritoryId == null || 
                    (woToTerritoryIdMap.containskey(woli.workOrderId) && woli.ServiceTerritoryId == woToTerritoryIdMap.get(woli.workOrderId)))){
                        woli.ServiceTerritoryId = childstMap.get(woli.workOrderId);
                }
            }
        
        
        }
        
        
    }
}