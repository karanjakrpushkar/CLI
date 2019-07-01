({
	resetQuoteIntegrationMessageValue : function(cmp) {		
		// reset integration message
		var sRecordId=cmp.get("v.recordId");
		// Invoke controller method
		var action = cmp.get("c.resetQuoteIntegrationMessageFields");
		action.setParams({'recordId': sRecordId});
		action.setCallback(this, function(response) {
		var state = response.getState();
		if (state === "SUCCESS") {
			// refresh the recordpage view
			var hitRefresh =$A.get('e.force:refreshView');
			hitRefresh.fire();
			console.log('----Success Message--- ' + response.getReturnValue());
            var toastEvent = $A.get("e.force:showToast");
			var result=response.getReturnValue();
            console.log("test");
            console.log("test"+result);
			if(result == "Work Estimate Creation Started"){
			toastEvent.setParams({
				"title": "Success!",
				"message": result
				});
                toastEvent.fire();
			}else {
				toastEvent.setParams({
				"title": "Error!",
				"message": result
				});
                toastEvent.fire();
			}
		
		}
		
		// Close the action panel
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();

		});
		$A.enqueueAction(action);
	}
})