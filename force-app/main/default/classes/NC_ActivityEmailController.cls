public class NC_ActivityEmailController {

    @AuraEnabled
    public static List<EmailMessage> getEmails(String recordId) {
        List<EmailMessage> emailList = [SELECT Id,Subject,ToAddress,MessageDate,FromName,LastOpenedDate,HasAttachment from EmailMessage where RelatedToId=:recordId ORDER BY MessageDate desc];
        return emailList;
    }

}