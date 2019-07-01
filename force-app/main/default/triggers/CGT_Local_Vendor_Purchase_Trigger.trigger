/********************************************************************************************************
* @Author         ext.chandan.singh@cargotec.com
* @Description    Trigger for Local Vendor Purchase.
* @CreatedDate    04-25-2019

*********************************************************************************************************/

trigger CGT_Local_Vendor_Purchase_Trigger on CGT_Local_Vendor_Product_Consumed__c (before Insert) {
    if (Trigger.isBefore && Trigger.isInsert){
            CGT_Local_Vendor_Purchase_Handler.populateWOLI(Trigger.New);
    }
}