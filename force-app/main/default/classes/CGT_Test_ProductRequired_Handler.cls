/* 
* Class Name   : CGT_Test_CGT_ProductRequired_Handler
* Description  : Test class for ProductRequired Handler Class.
* Created By   : Tieto
* Created On   : 22/05/2017

* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                                         Date                   Modification ID      Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Tieto                                          22/05/2017                                    Initial version
* ext.chandan.singh@cargotec.com                                              
*/
@isTest(seeAllData = false)
public class CGT_Test_ProductRequired_Handler{
    
    /********************************************************************************************************
    * @author        Tieto
    * @description   used to test the CGT_ProductRequired_VerifyServiceTerritoryProduct Class by inserting the ProductRequired
    Record. 
    * @Paramters     none
    * @return        none
    *********************************************************************************************************/ 
    
    /********************************************************************************************************
* @author        Tieto
* @description   used to test the Trigger logic for Invoking the error message
* @Paramters     none
* @return        none
*********************************************************************************************************/ 
    
    static testMethod void testVerifyPlantExtension_Error() {
        WorkOrder wo = CGT_TestDataCreation.createWorkOrder_TestData(true);
        ServiceTerritory str = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo.serviceTerritoryId);
        //WorkOrderlineItem woli1 = CGT_TestDataCreation.createWorkOrderLineItem_TestData2(str,wo);
        List<Product2> prodList=CGT_TestDataCreation.createProduct_TestData(false);
        insert prodList;
                
       try{
            List<ProductRequired> listProductRequired=CGT_TestDataCreation.createProductRequired_TestData(prodList,str,wo);
            insert listProductRequired;
       }catch(Exception e){
           System.assert(e.getMessage().contains('WorkCenter should be the child of the Plant ServiceTerritory related to WorkOrder'));
        }
        

        
    } 

/********************************************************************************************************
* @author        Tieto
* @description   Create product requireds under WOLI which is not integrated and verify integration message entry
*********************************************************************************************************/ 
  
    static testMethod void testCreatePRforWOLIandVerifyIM() {
        List<ProductRequired> prList;
        List<EVT_Integration_Message__c> messageList;
        WorkOrder wo = CGT_TestDataCreation.createWorkOrder_TestData(true);
        ServiceTerritory str = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo.serviceTerritoryId);
        //WorkOrderlineItem woli1 = CGT_TestDataCreation.createWorkOrderLineItem_TestData2(str,wo);
        List<Product2> pdtList= CGT_TestDataCreation.createProduct_TestData(true);
       // system.debug('pdtList '+pdtList.size());
        Test.startTest();
        prList= CGT_TestDataCreation.createProductRequired_TestData(pdtList,str,wo);
        //system.debug('prList '+prList.size()); 
        Insert prList;
        messageList= [Select ID,EVT_Record_To_Integrate__c from EVT_Integration_Message__c];
        //WOLI is not integrated hence messageList should be empty
        System.assertEquals(true,messageList.isEmpty());
        Test.stopTest();
    }

/********************************************************************************************************
* @author        Tieto
* @description   Create product requireds under integrated WOLI and verify integration message entry
*********************************************************************************************************/
  
   /* static testMethod void testCreatePRforIntegratedWOLIandVerifyIM() {
        List<ProductRequired> prList;
        Set<Id> prIdSet;
        List<EVT_Integration_Message__c> messageList;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Product2> pdtList= CGT_TestDataCreation.createProduct_TestData(true);
        //system.debug('pdtList '+pdtList.size());
        
        WorkOrder wo = CGT_TestDataCreation.createWorkOrder_TestData(true);
        ServiceTerritory str = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo.serviceTerritoryId);
        WorkOrderlineItem woli1 = CGT_TestDataCreation.createWorkOrderLineItem_TestData2(str,wo);
        
        try{
            woli1.CGT_External_ID__c='trtrf64565';
            woli1.CGT_Integration_Message__c = 'TestError';
            update woli1;
        }catch(Exception e){
            system.debug('WOLI update is failed with following error: '+e.getMessage());
        }
        Test.startTest();
        prlist= new List<ProductRequired>();
        prlist=CGT_TestDataCreation.getTestProductRequiredInstances(pdtList,woli1,wo);
        Insert prList;
        prIdSet= new Set<Id>();
        for(ProductRequired prinst:prlist){
            prIdSet.add(prinst.Id);
        }

        messageList= new List<EVT_Integration_Message__c>();
        messageList= [Select ID,EVT_Record_To_Integrate__c from EVT_Integration_Message__c where EVT_Record_To_Integrate__c IN: prIdSet];
        //WOLI is  integrated hence integration messageList should not be empty
       
        //System.debug(messageList.isEmpty());
        
        prIdSet= new Set<Id>();
        for(ProductRequired prinst:prlist){
            prIdSet.add(prinst.Id);
        }
        //Delete [Select Id from EVT_Integration_Message__c];
        prlist= new List<ProductRequired>();
        prList=[Select Id,QuantityRequired,CGT_External_ID__c from ProductRequired where Id In:prIdSet];
        Integer i=0;
        for(ProductRequired prinst:prlist){
            prinst.QuantityRequired=4.0;
            i+=i+1;
            prinst.CGT_External_Id__c='5434567'+String.ValueOf(i);
        }
        try{
            update prList;
        }catch(Exception e){
            system.debug('PR update is failed with following error: '+e.getMessage());
        }

        messageList=new List<EVT_Integration_Message__c>();
        messageList= [Select ID,EVT_Record_To_Integrate__c from EVT_Integration_Message__c where EVT_Record_To_Integrate__c IN: prIdSet];
        //Product required detail is updated hence integration message list should not be empty.
        
        Test.stopTest();
    } */
    
        
    /********************************************************************************************************
* @author        Tieto
* @description   used to test the Local Vendor Purchase Trigger logic for populating WorkOrderLineItem
* @Paramters     none
* @return        none
*********************************************************************************************************/ 
    
    static testMethod void populatelocalVendorPurchaseWoli() {
        WorkOrder wo = CGT_TestDataCreation.createWorkOrder_TestData(true);
        ServiceTerritory str = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo.serviceTerritoryId);
        WorkOrderlineItem woli = CGT_TestDataCreation.createWorkOrderLineItem_TestData2(str,wo);
        List<Product2> prodList=CGT_TestDataCreation.createProduct_TestData(false);
        insert prodList;
                
       try{
            List<CGT_Local_Vendor_Product_Consumed__c> listVendorPurchase =CGT_TestDataCreation.localvendorPurchase_testData(prodList,wo);
            insert listVendorPurchase;
       }catch(Exception e){
           System.debug(e.getMessage());
        }
        

        
    } 

}