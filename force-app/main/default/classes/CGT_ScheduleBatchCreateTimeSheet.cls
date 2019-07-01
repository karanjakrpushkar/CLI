/*
 @Name : CGT_ScheduleBatchCreateTimeSheet
 @Description : This Schedulable class schedules the batch class "CGT_BatchCreateTimeSheet"
 @Developed by : ext.Leo.Johnson@cargotec.com
 @Created date : 20/11/2017

*/


public class CGT_ScheduleBatchCreateTimeSheet implements Schedulable{
    
  public void execute(SchedulableContext sc){
            CGT_BatchCreateTimeSheet batch = new CGT_BatchCreateTimeSheet();
            database.executebatch(batch, 10);
         
    }
    
    

}