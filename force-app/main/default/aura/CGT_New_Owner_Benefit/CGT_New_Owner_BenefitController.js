({
    doInit : function(component, event, helper) {
        
        
        var action = component.get("c.createRec");
        var tecId = component.get("v.recordId");
        action.setParams({
            "id" : tecId,
        });
        action.setCallback(this, function(Data){
            var state = Data.getState();
            if(state == "SUCCESS"){
                
                var val = Data.getReturnValue();
               // alert('val>>'+val.CGT_Account_Ship_owner__c);
                if(val!=null && val!='undefined'){
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                   // alert('val>>1'+val);
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": "CGT_Owner_s_Benefit__c",
                        "defaultFieldValues": {
                            'Name' : val.Name,
                            'CGT_Account_Ship_owner__c' : val.CGT_Account_Ship_owner__c,
                            'CGT_Owner__c' : val.CGT_Owner__c,
                            'CGT_Opportunity__c' : tecId
                        },"navigationLocation" : 'LOOKUP'
                    });
                    createRecordEvent.fire();                  
                }
                
            }else{
                alert('Error : Please contact your System Admin');
            }
            
            
        });
        $A.enqueueAction(action);
        
    }
})