({
    handleDeleteRecord : function(component, event, helper) {
        
        var action = component.get("c.deleteQuote");
        var quoteId = component.get("v.recordId");
        action.setParams({
            "id" : quoteId,
            "bool" : 'false'
        });
        action.setCallback(this, function(Data){
            var state = Data.getState();
            if(state == "SUCCESS"){
                
                var boolVal = Data.getReturnValue();
                if(boolVal.valueOf() == "true"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been deleted successfully."
                    });
                    toastEvent.fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/0Q0/o'
                    });
                    urlEvent.fire();                    
                }else if(boolVal.valueOf() == "false"){
                    // var toastEvent = $A.get("e.force:showToast");
                    // component.set("v.messageType", 'error' );
                    // component.set("v.message", errorMessage);
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
    , 
    doInit : function(component, event, helper) {
        var quoteId = component.get("v.recordId");
        var action = component.get("c.deleteQuote");
        var quoteId = component.get("v.recordId");
        action.setParams({
            "id" : quoteId,
            "bool" : 'true'
        });
        action.setCallback(this, function(Data){
            var state = Data.getState();
            if(state == "SUCCESS"){
                var boolVal = Data.getReturnValue();
                if(boolVal.valueOf() == "false"){
                    component.set("v.visible",false);
                    var errorMessage = $A.get("$Label.c.CGT_Delete_Draft_Quote_Only");
                    component.set("v.messageType", 'error' );
                    component.set("v.message", errorMessage);
                }else if(boolVal.valueOf() == "true"){
                    component.set("v.visible",true);
                    var errorMessage = $A.get("$Label.c.CGT_Message_Confirming_Quote_Deletion");
                    component.set("v.messageType", 'error' );
                    component.set("v.message", errorMessage);
                }
            }
        });
        
        
        $A.enqueueAction(action);
    },
    cancel : function(component, event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
})