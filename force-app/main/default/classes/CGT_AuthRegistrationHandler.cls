/********************************************       
@ClassName: CGT_AuthRegistrationHandler         
@TestClass Name: CGT_AuthRegistrationHandlerTest       
@Author: Prince Kumar 
@CreatedDate: 15/05/2018    
     
Modification Log:       
================================================        
Ver   Date         Author                         Modification      
------------------------------------------------------------------------------------        
1.0   15/05/2018    Prince Kumar               Initial Code      

*********************************************/ 
global class CGT_AuthRegistrationHandler implements Auth.RegistrationHandler{
    // Custom Exception class
    class RegHandlerException extends Exception {}
    /************************************************************************************************************
    * @description      Query user record based on email Id 
    * @Paramters        Auth.UserData data
    * @return           User Instance
    *************************************************************************************************************/   
    global User getUserRecord(Auth.UserData data){
        System.debug('---Auth Data----'+data);
        //String email= data.attributeMap.get('email');
        System.debug('------Email Id-------'+data.email);
        List<User> userList=[Select Id,UserName,Email from User where Email=:data.email];
        if(userList.isEmpty()){
            throw new RegHandlerException(System.Label.CGT_Auth_Registration_Error_Message);
        }else{
            return userList[0];
        }
    }

    /************************************************************************************************************
    * @description      standard createUser method to handle user creation based on auth user data
    * @Paramters        Auth.UserData data
    * @return           User Instance
    *************************************************************************************************************/  
    global User createUser(Id portalId, Auth.UserData data){
        User userInst=getUserRecord(data);
        return userInst;
    }
    /************************************************************************************************************
    * @description      update user method to handle user update based on auth user data
    * @Paramters        Auth.UserData data
    * @return           User Instance
    *************************************************************************************************************/  
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        User userInst=getUserRecord(data);
        update(userInst);
    }
}