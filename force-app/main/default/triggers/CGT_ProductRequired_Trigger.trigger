/********************************************************************************************************
* @author         ext.chandan.singh@cargotec.com
* @description    This is a trigger on ProductRequired object
* @date           06/05/2019
* 
* Modification Log:
* -------------------------------------------------------------------------------------------------------
* Developer                                          Date           Modification ID      Description
* -------------------------------------------------------------------------------------------------------
*********************************************************************************************************/

trigger CGT_ProductRequired_Trigger on ProductRequired (Before Insert,Before Update,After Insert,After Update,Before Delete) {
    
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {   
            CGT_ProductRequired_Handler.populateWOLI(Trigger.new);
            CGT_ProductRequired_Handler.verifyPlantExtension(Trigger.new);
        }
        if(trigger.isUpdate)
        {
            CGT_ProductRequired_Handler.verifyPlantExtension(Trigger.new);
        }
        if(trigger.isDelete){
            //CGT_ProductRequired_Handler.VerifyDeletion_PR(Trigger.old);
        }
    }else if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            CGT_ProductRequired_Handler.verifyPRFieldsAndCreateIntegrationMessages(Trigger.newMap,Trigger.oldMap,true,false);
            
        }
        else if(trigger.isUpdate)
        {
            CGT_ProductRequired_Handler.verifyPRFieldsAndCreateIntegrationMessages(Trigger.newMap,Trigger.oldMap,false,true);
            //SFF-56: Check if the product is marked for deletion and delete the product
           // CGT_ProductRequired_Handler.Delete_PR(trigger.new);
        }
    }
}