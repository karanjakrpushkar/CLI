@isTest(seeAllData = false)
public class CGT_DeleteQuoteControllerTest {


    public static testMethod void deleteQuotes(){
     
      Opportunity opportunityObj = new Opportunity();
        opportunityObj.name = 'Test Opportunity';
        opportunityObj.CloseDate = System.today().addDays(2);
        opportunityObj.CGT_Opportunity_Segment_main__c = 'Offshore';
        opportunityObj.StageName = 'Budget Quote';
        opportunityObj.Probability= 5;
        //opportunityObj.CGT_Shipyard_Project__c = shipyardObj1.id;
        insert opportunityObj;
        
        List<Quote> qteList = new List<Quote>();
        Quote qte = new Quote();
        qte.name = 'Test Quote';
        qte.Status = 'Draft';
        qte.OpportunityId= opportunityObj.id;
        
         Quote qte1 = new Quote();
        qte1.name = 'Test Quote1';
        qte1.Status = 'Sent';
        qte1.OpportunityId= opportunityObj.id;
        qteList.add(qte);
        qteList.add(qte1);
        insert qteList;
        
        CGT_DeleteQuoteController.deleteQuote(qteList[0].id,'true');
        CGT_DeleteQuoteController.deleteQuote(qteList[0].id,'false');
        CGT_DeleteQuoteController.deleteQuote(qteList[1].id,'true');
        CGT_DeleteQuoteController.deleteQuote(qteList[1].id,'false');
        CGT_DeleteQuoteController.deleteQuote(null,'false');
    }
}