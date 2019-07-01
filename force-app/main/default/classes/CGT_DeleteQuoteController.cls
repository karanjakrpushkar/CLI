/*******************************************************************
@Author: Amit(ext.amit.kumar@cargotec.com)
@Class Name: CGT_DeleteQuoteController
@Created Date: 20nd Feb 2019
@Description: This class is used to delete Quote if the status is Draft.
********************************************************************/
public without sharing Class CGT_DeleteQuoteController{
    
/*******************************************************************
@Author: Amit(ext.amit.kumar@cargotec.com)
@Method Name: deleteQuote()
@Description: This Method delete Quote if the status is Draft 
and prevent deletion if status is other than Draft.
********************************************************************/    
    @AuraEnabled 
    public static string deleteQuote(string id,string bool) {
        
        if(id!=null){
            Quote qot = [Select id,Status from Quote where id =: id];
            
            if(bool=='true'){
                if(qot.status=='Draft')
                { 
                    return 'true'; 
                }else if(qot.status=='Withdrawn' || qot.status=='Sent'){
                    
                    return 'false'; 
                }
                return 'false';
            }else{
                if(qot.status=='Draft'){
                    try {
                        delete qot;
                    }catch (DmlException e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                        return 'An Exception Occured. Please contact Administrator';
                    }
                    return 'true';
                    
                }else{
                    return 'false';
                }
            }
            
        }else{
            System.debug('id: ' + id);
            return 'An Exception Occured. Please contact Administrator';
        }
    }
}