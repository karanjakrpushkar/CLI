({
	doInit : function(component, event, helper) {
		
        var action = component.get("c.taskOwneridUpdate");
        var taskId = component.get("v.recordId");
       action.setParams({
            "idSTR" : taskId
        });
       action.setCallback(this, function(Data){
            var state = Data.getState();
             console.log('statessss>>>'+state);
            if(state == "SUCCESS"){
         $A.get("e.force:closeQuickAction").fire();
         $A.get('e.force:refreshView').fire();
            } else if(state == "ERROR"){
                alert('UNKNOWN ERROR');
            } 
        });
		$A.enqueueAction(action);
        

         
	}
})