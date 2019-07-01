/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Description    Trigger on EVT_Integration_Message__c Object
* @TriggerHandler CGT_IntegrationMessage_Handler 
* @TestClass      <TBC>
* @CreatedDate    07-20-2018

*********************************************************************************************************/
trigger CGT_IntegrationMessage_Trigger on EVT_Integration_Message__c (after insert, after update) {
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            List<String> intList= new List<String>();
            for(EVT_Integration_Message__c intMsg: Trigger.new){
                intList.add(intMsg.id);
            }
            CGT_IntegrationMessage_Handler.sendIntegrationMessageOnCreate(intList);
        }
        if(trigger.isUpdate){
            String retry='CGT_Retry_Value';
            Map<String,String> retryMap=CGT_IntegrationMessage_Handler.getOrganizationMetadataRecords();
            Integer retryValue=Integer.valueof(retryMap.get(retry));
            List<EVT_Integration_Message__c> intList= new List<EVT_Integration_Message__c>();
            for(EVT_Integration_Message__c intMsg: Trigger.new){
                if(intMsg.CGT_Retry_Value__c < retryValue && 
                    intMsg.CGT_Retry__c &&  
                    String.isBlank(intMsg.CGT_Transaction_ID__c)){
                   
                   intList.add(intMsg);
                }
    
            }
            if(!intList.isEmpty()){
                CGT_IntegrationMessage_Handler.retryIntegrationMessageOnUpdate(intList);
            }
            
        }
    }

}