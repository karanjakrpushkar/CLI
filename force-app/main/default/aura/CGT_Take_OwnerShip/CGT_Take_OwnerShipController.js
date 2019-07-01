({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.OwneridUpdate");
        var accId = component.get("v.recordId");
        action.setParams({
            "idSTR" : accId
        });
        action.setCallback(this, function(Data){
            var state = Data.getState();
            if(state == "SUCCESS"){
                
                var boolVal = Data.getReturnValue();
                if(boolVal.valueOf() == "true"){
                    component.set("v.messageType", 'success' );
                    component.set("v.message", 'Completed Successfully!');
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }else if(boolVal.valueOf() == "false"){
                    var toastEvent = $A.get("e.force:showToast");
                    var errorMessage = $A.get("$Label.c.CGT_Error_Message_AccountOwnership");
                    component.set("v.messageType", 'error' );
                    component.set("v.message", errorMessage);
                }else{
                    component.set("v.messageType", 'error' );
                    component.set("v.message", boolVal);
                }
                
            } else if(state == "ERROR"){
                alert('UNKNOWN ERROR');
            } 
        });
        $A.enqueueAction(action);
        
        
        
    }
})