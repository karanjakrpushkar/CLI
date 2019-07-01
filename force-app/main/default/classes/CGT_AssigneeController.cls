public class CGT_AssigneeController {
   @AuraEnabled 
    public static void taskOwneridUpdate(string idSTR){
    
       Task tsk = [Select id,OwnerId from Task where id =: id.valueof(idSTR)];
       
       tsk.OwnerId = userInfo.getUserId();
       
        update tsk;
    }
}