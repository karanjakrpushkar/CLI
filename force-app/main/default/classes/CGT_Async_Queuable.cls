public class CGT_Async_Queuable implements Queueable, Database.AllowsCallouts  {
    Map<String,String> messageIdToJsonMap=new Map<String,String>();
    Map<String,Integer> retryValueMap= new Map<String,Integer> ();
    public CGT_Async_Queuable(Map<String,String> messageIdToJsonMap,Map<String,Integer> retryValueMap){
          this.messageIdToJsonMap=messageIdToJsonMap;
          this.retryValueMap=retryValueMap;
    }

    public void execute(QueueableContext context){
        MAP<String,HttpRequest> reqMap =CGT_IntegrationMessage_Handler.createHttpRequest(messageIdToJsonMap);
        MAP<String,HttpResponse> resMap=CGT_IntegrationMessage_Handler.getHttpResponse(reqMap);
        CGT_IntegrationMessage_Handler.updateIntegrationMessageResponse(resMap,retryValueMap);
    }
}