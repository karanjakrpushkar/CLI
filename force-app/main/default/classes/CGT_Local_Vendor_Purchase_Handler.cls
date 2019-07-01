/********************************************************************************************************
* @Author         ext.chandan.singh@cargotec.com
* @Description    This is a handler class for CGT_Local_Vendor_Purchase_Trigger
* @TestClass      <TBD>
* @CreatedDate    04-25-2019

*********************************************************************************************************/
public class CGT_Local_Vendor_Purchase_Handler{

/********************************************************************************************************
* @author           chandan.singh@cargotec.com
* @date             04-25-2019
* @description      This method is used to populate WorkOrderLineItem on Local Vendor Purchase Object.
* @Params           List<CGT_Local_Vendor_Product_Consumed__c> localVendorPurchaseList
* @return           void
*********************************************************************************************************/
    public static void populateWOLI(List<CGT_Local_Vendor_Product_Consumed__c> localVendorPurchaseList){
        Map<Id,Id> lcvpIdtoWorkOrderIdMap = new Map<Id,Id>();
        for (CGT_Local_Vendor_Product_Consumed__c lcvp : localVendorPurchaseList){
                 lcvpIdtoWorkOrderIdMap.put(lcvp.Id,lcvp.CGT_Work_Order__c);
        }
             Map<Id,Id> woIdwoliIdMap = CGT_FSM_Utility.firstWOLIofWO(lcvpIdtoWorkOrderIdMap.values());
        for(CGT_Local_Vendor_Product_Consumed__c lvp : localVendorPurchaseList){
            if(woIdwoliIdMap != null && woIdwoliIdMap.containsKey(lvp.CGT_Work_Order__c)){
                lvp.CGT_Work_Order_Line_Item__c = woIdwoliIdMap.get(lcvpIdtoWorkOrderIdMap.get(lvp.Id));
                lvp.CGT_Item_Category__c = 'N';
            }
        }
    }
}