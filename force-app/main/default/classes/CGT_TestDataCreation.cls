/*
* Class Name   : CGT_TestDataCreation
* Description  : Test Class for creating all the required test data
* Created By   : Deloitte
* Created On   : 11/20/2017
createServiceTerritory_TestData4-------------------------------------------------------------
* Developer                Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Deloitte               11/20/2017                                  Initial version
*/

@isTest(seealldata=false)
public class CGT_TestDataCreation {

  
/********************************************************************************************************
* @author        ext.chandrakanth.reddy@cargotec.com
* @description   Method to Create User object test data 
* @Paramters     Boolean doInsert
* @return        User
*********************************************************************************************************/
    
    public static User create_User(Boolean doInsert){    
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'abc000@def.com',
            Username = 'abc000@def.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
       if(doInsert)
            insert u;        
       return u;                
    }

/********************************************************************************************************
* @author        ext.suthesh.Manoharan@cargotec.com
* @description   Method to Create Asset object test data 
* @Paramters     Boolean doInsert
* @return        Asset
*********************************************************************************************************/
    
    public static Asset create_Equipment(Boolean doInsert){ 
    RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Asset' and DeveloperName = 'CGT_Equipment'];
    Account acc=  create_Account(true); 
        Asset ast = new Asset(
         name='test' ,
         accountId=acc.id,
         RecordTypeID=RecType.id  
        );
       if(doInsert)
            insert ast;        
       return ast;                
    }/********************************************************************************************************
* @author        ext.suthesh.Manoharan@cargotec.com
* @description   Method to Create Asset object test data 
* @Paramters     Boolean doInsert
* @return        Asset
*********************************************************************************************************/
    
    public static Asset create_Asset(Boolean doInsert){ 
    RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Asset' and DeveloperName = 'CGT_Functional_Location'];
    Account acc=  create_Account(true); 
        Asset ast = new Asset(
         name='test' ,
         accountId=acc.id,
         RecordTypeID=RecType.id  
        );
       if(doInsert)
            insert ast;        
       return ast;                
    }
     
     /********************************************************************************************************
* @author        ext.suthesh.Manoharan@cargotec.com
* @description   Method to Create Entitlement object test data 
* @Paramters     Boolean doInsert
* @return        Entitlement
*********************************************************************************************************/
    
    public static Entitlement create_Entitlement(Boolean doInsert){ 
     
    Account acc=  create_Account(true); 
        Entitlement ent = new Entitlement(
         name='test' ,
         accountId=acc.id,
         StartDate=system.today()
       //  RootAsset=astr.id  
        );
       if(doInsert)
            insert ent;        
       return ent;                
    }
     
   
/********************************************************************************************************
* @author        ext.suthesh.Manoharan@cargotec.com
* @description   Method to Create Account object test data 
* @Paramters     Boolean doInsert
* @return        Account
*********************************************************************************************************/
    
    public static Account create_Account(Boolean doInsert){    
        Account acc = new Account(
         name='test',CGT_Account_Group__c = 'C006'   
        );
       if(doInsert)
            insert acc;        
       return acc;                
    }
        
   
/********************************************************************************************************
* @author        ext.Chandrakanth.Reddy@cargotec.com
* @description   Method to Create Case object test data 
* @Paramters     Boolean doInsert
* @return        Account
*********************************************************************************************************/
    
    Public static Case createCase_TestData(Boolean doInsert){
        CGT_Organizational_Data__c salesoffice = salesoffice_TestData(true);
        CGT_Organizational_Data__c salesorg = salesorganization_TestData(true);
        Case cse = new Case();
        Asset ast = create_Asset(true);
        Asset ast1 = create_Equipment(true);
        Entitlement ent = create_Entitlement(true);
        cse.CGT_Sales_Office__c = salesoffice.Id;
        cse.CGT_Sales_Organization__c = salesorg.Id;
        cse.AssetId = ast1.Id;
        cse.EntitlementId=ent.id;
        cse.CGT_Vessel__c=ast.Id;
        cse.Status='New';
        cse.CGT_Purchase_Order_Number__c='12345';
        cse.Origin='notEmail';
        cse.CGT_Short_Description__c='Test';
        cse.Type='Service';
        cse.CGT_Service_Package__c='MI';
        if(doInsert)
            insert cse;
        
        return cse;
    }
    
/********************************************************************************************************
* @author        ext.Chandrakanth.Reddy@cargotec.com
* @description   Method to Create Workorder object test data 
* @Paramters     Boolean doInsert
* @return        Account
*********************************************************************************************************/
    
    Public static WorkOrder createWorkOrder_TestData(Boolean doInsert){
        Case c = createCase_TestData(true);
        //RecordType RecType = [Select Id,Name From RecordType  Where SobjectType = 'WorkOrder' and DeveloperName = 'CGT_ZC01'];
        Id RecTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('CGT_ZC01').getRecordTypeId();
        ServiceTerritory st=createServiceTerritory_TestData(true);
        WorkOrder wo= new WorkOrder(status='Open',  RecordTypeId = RecTypeId , CaseId = c.Id,CGT_Service_Report_Status__c='Approved', CGT_Initial_Service_Territory__c = st.id,ServiceTerritoryId = st.Id );     
         wo.StartDate = System.today();
         wo.EndDate = System.today().addDays(10);
         wo.CGT_Work_scope_executed_by_subcontractor__c = true;
        if(doInsert)
            insert wo;
        
        return wo;
    }
    
    /********************************************************************************************************
* @author        ext.chandan.singh@cargotec.com
* @description   Method to Create Workorder object test data for SM02 WOLI
* @Paramters     Boolean doInsert
* @return        Account
*********************************************************************************************************/
    
    Public static WorkOrder createWorkOrder_TestData2(Boolean doInsert){
        Case c = createCase_TestData(true);
        // Account acc=  create_Account(true);
        CGT_Planner_Group__c pg = createOrdeResposiblePerson_TestData(true);
        //RecordType RecType = [Select Id,Name From RecordType  Where SobjectType = 'WorkOrder' and DeveloperName = 'CGT_ZC01'];
        Id RecTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('CGT_ZC01').getRecordTypeId();
        ServiceTerritory st=createServiceTerritory_TestData(true);
        system.debug('st>>>>>>'+st);
        WorkOrder wo= new WorkOrder(status='Created',  RecordTypeId = RecTypeId , CaseId = c.Id,CGT_Service_Report_Status__c='Approved',  CGT_Initial_Service_Territory__c = st.id,ServiceTerritoryId = st.Id);  
         wo.StartDate = System.today();
         wo.EndDate = System.today().addDays(10);
         wo.CGT_Work_Country__c = 'IN';
         wo.CGT_Activity_Type__c = 'A00';
        // wo.CGT_External_Id__c = '12345';
         wo.CGT_Synchronize__c = true;
         wo.CGT_Order_Responsible_Person__c = pg.Id;
         
        if(doInsert)
            insert wo;
        
        return wo;
    } 
    
/********************************************************************************************************
* @author        ext.Chandrakanth.Reddy@cargotec.com
* @description   Method to Create OperatingHours object test data 
* @Paramters     Boolean doInsert
* @return        Account
*********************************************************************************************************/
    
    public static OperatingHours createOperatingHours_TestData(Boolean doInsert){
        OperatingHours opH= new OperatingHours();
        opH.Name='Basic US Calender';
        if(doInsert)
            insert opH;
        
        return opH;
        
    }
    
    /********************************************************************************************************
    * @author        ext.chandan.singh@cargotec.com
    * @description   Method to Create Workorder object test data for SM02 WOLI
    * @Paramters     Boolean doInsert
    * @return        Account
    *********************************************************************************************************/
     public static CGT_Planner_Group__c createOrdeResposiblePerson_TestData(Boolean doInsert){
        ServiceTerritory st = createServiceTerritory_TestData(true);
        CGT_Planner_Group__c pg = new CGT_Planner_Group__c();
        pg.Name='USPlanner';
        pg.CGT_Plant__c = st.Id;
        pg.CGT_External_ID__c = 'ukplanner';
        if(doInsert)
            insert pg;
        
        return pg;
        
    }
    /********************************************************************************************************
    * @author        ext.chandan.singh@cargotec.com
    * @description   Method to Create Workorder object test data for SM02 WOLI
    * @Paramters     Boolean doInsert
    * @return        Account
    *********************************************************************************************************/
     public static CGT_Organizational_Data__c salesoffice_TestData(Boolean doInsert){
         Id RecTypeId = Schema.SObjectType.CGT_Organizational_Data__c.getRecordTypeInfosByDeveloperName().get('CGT_Sales_Office').getRecordTypeId();
         Account acc=  create_Account(true);
        CGT_Organizational_Data__c so = new CGT_Organizational_Data__c();
        so.Name='USsalesoffice';
        so.CGT_Account__c = acc.Id;
        so.recordtypeId = RecTypeId;
        so.CGT_External_ID__c = 'ukoffice';
        if(doInsert)
            insert so;
        
        return so;
        
    }
    /********************************************************************************************************
    * @author        ext.chandan.singh@cargotec.com
    * @description   Method to Create Workorder object test data for SM02 WOLI
    * @Paramters     Boolean doInsert
    * @return        Account
    *********************************************************************************************************/
     public static CGT_Organizational_Data__c salesorganization_TestData(Boolean doInsert){
        Id RecTypeId = Schema.SObjectType.CGT_Organizational_Data__c.getRecordTypeInfosByDeveloperName().get('CGT_Sales_Organization').getRecordTypeId();
        Account acc=  create_Account(true);
        CGT_Organizational_Data__c orgdata = new CGT_Organizational_Data__c();
        orgdata.Name='USsalesOrganization';
        orgdata.CGT_Account__c = acc.Id;
        orgdata.recordtypeId = RecTypeId;
        orgdata.CGT_External_ID__c = 'ukorg';
        if(doInsert)
            insert orgdata;
        
        return orgdata;
        
    }
    /********************************************************************************************************
    * @author        ext.Chandrakanth.Reddy@cargotec.com
    * @description   Method to Create ServiceTerritory object test data 
    * @Paramters     Boolean doInsert
    * @return        ServiceTerritory
    *********************************************************************************************************/
    Public static ServiceTerritory createServiceTerritory_TestData(Boolean doInsert){
        Id RecTypeId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByDeveloperName().get('CGT_Plant').getRecordTypeId();
        List<ServiceTerritory> stlist = new List <ServiceTerritory>([Select Id,Name from ServiceTerritory where Name = 'UK1' Limit 1]);
        if(stlist != null && !stlist.isEmpty()){
            return stlist[0];
        }else{
            ServiceTerritory sTData= new ServiceTerritory();
            sTData.Name='UK1';
            sTData.OperatingHoursId= createOperatingHours_TestData(true).Id;
            sTData.IsActive=true;
            sTData.CGT_External_ID__c = 'US22';
            sTData.RecordTypeId = RecTypeId;
            if(doInsert) insert sTData;
            return sTData;
        } 
    }

         /********************************************************************************************************
    * @author        ext.chandan.Singh@cargotec.com
    * @description   Method to Create ServiceTerritory object test data at for Work Center 
    * @Paramters     Boolean doInsert
    * @return        ServiceTerritory
    *********************************************************************************************************/
    Public static ServiceTerritory createServiceTerritory_TestData1(Boolean doInsert,String ServiceTerritoryId){
        Id RecTypeId = Schema.SObjectType.ServiceTerritory.getRecordTypeInfosByDeveloperName().get('CGT_Work_Center').getRecordTypeId();
        List<ServiceTerritory> stlist = new List <ServiceTerritory>([Select Id,Name from ServiceTerritory where Name = 'UK1_WS001' Limit 1]);
        if(stlist != null && !stlist.isEmpty()){
            return stlist[0];
        }else{
            ServiceTerritory sTData= new ServiceTerritory();
            sTData.Name='UK1_WS001';
            sTData.OperatingHoursId= createOperatingHours_TestData(true).Id;
            sTData.IsActive=true;
            sTData.CGT_External_ID__c = 'UK1child1';
            sTData.RecordTypeId = RecTypeId;
            sTData.CGT_Default_Work_Center__c = true;
            sTData.ParentTerritoryId = ServiceTerritoryId;
            if(doInsert) insert sTData;
            return sTData;
        }
    }
    
    /********************************************************************************************************
* @author        ext.chandan.Singh@cargotec.com
* @description   Method to Create WorkOrderLineItem object test data 
* @Paramters     ServiceTerritory record 
* @return        WorkOrderLineItem
*********************************************************************************************************/
    
    Public static WorkOrderLineItem createWorkOrderLineItem_TestData2(ServiceTerritory serviceT,WorkOrder wo){
        Id externalRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('CGT_External').getRecordTypeId();
        //WorkOrder wo=createWorkOrder_TestData(true);
        WorkOrderLineItem WOLI= new WorkOrderLineItem();
        WOLI.WorkOrderId=wo.Id;
        WOLI.StartDate=DateTime.Now();
        WOLI.EndDate=Date.Today().addDays(5);
        WOLI.ServiceTerritoryId =serviceT.Id;
        WOLI.recordtypeId = externalRecordTypeId;
        insert WOLI;
        return WOLI;
    }

/********************************************************************************************************
* @author        ext.Chandrakanth.Reddy@cargotec.com
* @description   Method to Create ServiceAppointment object test data 
* @Paramters     WOrkOrderLineItem record 
* @return        ServiceAppointment
*********************************************************************************************************/
    
    
    Public static ServiceAppointment createServiceAppointment_TestData(ServiceTerritory serviceT, workorder wo){

        WorkOrderLineItem woli= createWorkOrderLineItem_TestData2(serviceT,wo);
        ServiceAppointment sa= new ServiceAppointment();
        sa.ParentRecordId=woli.Id;
        sa.EarliestStartTime=DateTime.Now();
        sa.DueDate=Date.Today().addDays(5);
        sa.Status='Scheduled';
        //sa.serviceTerritoryID=serviceT.ParentTerritoryId;
        sa.SchedStartTime=DateTime.Now();
        sa.SchedEndTime=Date.Today().addDays(5);
         insert sa;
        return sa;
    }


    Public static ServiceResource createServiceResource_TestData(){
        ServiceResource sr= new ServiceResource();
        sr.Name='Sample Name';
        sr.IsActive=true;
        //sr.ResourceType='Dispatcher';
        sr.RelatedRecordId=create_User(true).Id;

        insert sr;
        return sr;
    }

    public static ServiceTerritoryMember createServiceTerritoryMember_Testdata(ServiceResource sr,ServiceTerritory serviceT){
        ServiceTerritoryMember stm= new ServiceTerritoryMember();
        stm.ServiceResourceId=sr.Id;
        stm.TerritoryType='P';
        stm.ServiceTerritoryId=serviceT.id;
        stm.EffectiveStartDate=Datetime.newInstance(2018, 2, 17);
        insert stm;
        return stm;

    }

    public static AssignedResource createAssignedresource_TestData(ServiceAppointment sa, ServiceResource sr){
        AssignedResource ar= new AssignedResource();
        ar.ServiceResourceId=sr.Id;
        ar.ServiceAppointmentId =sa.id;

        return ar;

    }

    Public static CGT_Job_Briefing__c createJobBriefing_TestData (){
         CGT_Job_Briefing__c jb= new CGT_Job_Briefing__c();
        jb.CGT_Job_Briefing_Status__c='Post-job briefing approved';

        insert jb;
        
         return jb;

    }
    
        /********************************************************************************************************
    * @author        ext.chandan.singh@cargotec.com
    * @description   Method to Create product object test data 
    * @Paramters     Boolean doInsert
    * @return        List<Product2>
    *********************************************************************************************************/
    Public static List<Product2> createProduct_TestData(Boolean doInsert){
        List<Product2> list_prod=new List<Product2>();
        for(Integer i=0;i<10;i++){
            Product2 prod=new Product2();
            prod.CurrencyIsoCode='EUR';
            prod.CGT_External_ID__c='12345'+i;
            prod.Name='Product '+i;
            prod.CGT_Plant_Extension__c = 'US22';
            list_prod.add(prod);
        }
        if(doInsert)
            insert list_prod;
        
        return list_prod;
        
    }
    
    /********************************************************************************************************
* @author        ext.chandan.singh@cargotec.com
* @description   Method to Create ProductRequired object test data 
* @Paramters     List<Product2>,ServiceTerritory
* @return         List<ProductRequired>
*********************************************************************************************************/
    
    
    public static List<ProductRequired> createProductRequired_TestData(List<Product2> prodList,ServiceTerritory serviceT, WorkOrder wo){
        List<ProductRequired> prodReqList = new List<ProductRequired>();
        WorkOrderLineItem woli=createWorkOrderLineItem_TestData2(serviceT,wo);
        
        for(Integer i=0;i<prodList.size();i++){
            ProductRequired pr=new ProductRequired();
            pr.Product2Id=prodList.get(i).Id;
            pr.ParentRecordId=wo.Id;
            pr.CGT_Work_Order__c = wo.Id;
            pr.CGT_TECH_Work_Order_Line_Item__c = woli.Id;
            pr.QuantityRequired=14;
            prodReqList.add(pr);
            
        }
        
        return prodReqList;
        
    }

    /********************************************************************************************************
* @author        ext.chandan.singh@cargotec.com
* @description   Method to Create local Vendor Purchase object test data 
* @Paramters     List<Product2>,ServiceTerritory
* @return         List<ProductRequired>
*********************************************************************************************************/

    public static List<CGT_Local_Vendor_Product_Consumed__c> localvendorPurchase_testData(List<Product2> prodList, WorkOrder wo){
         Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CGT_Vendor').getRecordTypeId();
         Account vendor =  create_Account(false); 
         vendor.recordtypeId = recordtypeId;
         vendor.CGT_Vendor_Group__c = 'V001';
         insert vendor;
        List<CGT_Local_Vendor_Product_Consumed__c> localvendorPurchaseList = new List<CGT_Local_Vendor_Product_Consumed__c>();
        for(Integer i=0;i<prodList.size();i++){
            CGT_Local_Vendor_Product_Consumed__c pr=new CGT_Local_Vendor_Product_Consumed__c();
            pr.CGT_Material__c = prodList.get(i).Id;
            pr.CGT_Quantity__c=14;
            pr.CGT_Item_Category__c = 'N';
            pr.CGT_Price__c = 100;
            pr.CGT_Work_Order__c = wo.Id;
            pr.CGT_Vendor__c = vendor.Id;
            pr.CGT_Currency__c = 'EUR';
            localvendorPurchaseList.add(pr);
        }
        
        return localvendorPurchaseList; 
    } 
    
      /********************************************************************************************************
* @author        ext.chandan.singh@cargotec.com
* @description   Method to Create ProductRequired object test data 
* @Paramters     List<Product2>,ServiceTerritory
* @return         List<ProductRequired>
*********************************************************************************************************/

    public static List<ProductRequired> getTestProductRequiredInstances(List<Product2> prodList,WorkOrderLineItem woli, WorkOrder wo){
         Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CGT_Vendor').getRecordTypeId();
         Account vendor =  create_Account(false); 
         vendor.recordtypeId = recordtypeId;
         vendor.CGT_Vendor_Group__c = 'V001';
         insert vendor;
        List<ProductRequired> prodReqList = new List<ProductRequired>();
        for(Integer i=0;i<prodList.size();i++){
            ProductRequired pr=new ProductRequired();
            pr.Product2Id=prodList.get(i).Id;
            pr.CGT_TECH_Work_Order_Line_Item__c=woli.Id;
            pr.QuantityRequired=14;
            pr.CGT_Item_Category__c = 'N';
            pr.CGT_Price__c = 100;
            pr.CGT_Work_Order__c = wo.Id;
            pr.ParentRecordId= wo.Id;
            pr.CGT_Vendor__c = vendor.Id;
            prodReqList.add(pr);
        }
        
        return prodReqList; 
    }
   

    
    
}