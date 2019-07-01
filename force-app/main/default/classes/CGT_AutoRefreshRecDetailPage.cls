/********************************************************************************************************
* @Author         ext.manoj.gupta@cargotec.com
* @Description    The method defined is used to retrieve the current user session ID. 
* @TestClass      <TBD>
* @CreatedDate    13-07-2018

*********************************************************************************************************/


public class CGT_AutoRefreshRecDetailPage {

@AuraEnabled
public static String getSessionId() {
  return UserInfo.getSessionId();
}

    
}