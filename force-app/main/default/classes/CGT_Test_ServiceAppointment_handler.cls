/********************************************************************************************************
* @Author         Tieto
* @Description    Test class for  CGT_ServiceAppointment_Handler.
* @CreatedDate    

*********************************************************************************************************/
@isTest(seeAllData = false)
public class CGT_Test_ServiceAppointment_handler {
/********************************************************************************************************
* @author        
* @description     
* @Paramters     none
* @return        void
*********************************************************************************************************/
  static testMethod void Test_insertDuration(){
      
      List<ServiceAppointment> sa1 = new List<ServiceAppointment>();
      List<ServiceAppointment> sa2 = new List<ServiceAppointment>();
      WorkOrder wo = CGT_TestDataCreation.createWorkOrder_TestData(true);
      //ServiceTerritory st = CGT_TestDataCreation.createServiceTerritory_TestData(true);
      ServiceTerritory st1 = CGT_TestDataCreation.createServiceTerritory_TestData1(true,wo.serviceTerritoryId);
      ServiceAppointment sa = CGT_TestDataCreation.createServiceAppointment_TestData(st1,wo);
      
      sa.DurationType='Hours';
      //update sa;
       Test.startTest();
      //For Insert
      sa1=[select id,SchedStartTime,SchedEndTime,Duration,DurationType from ServiceAppointment where id=:sa.id];
      Decimal decHours = ((sa.SchedEndTime.getTime())/1000/60/60) - ((sa.SchedStartTime.getTime())/1000/60/60);
      Decimal decMin = ((sa.SchedEndTime.getTime())/1000/60) - ((sa.SchedStartTime.getTime())/1000/60);
      Decimal timeT = decMin-(decHours*60);
      Decimal Duration=decHours + (timeT/60);
      system.assertEquals(Duration,sa1[0].duration);
      sa.DurationType='Minutes';
      try{
         update sa;
      }catch(DmlException e){
            System.debug('The following exception has occurred: ' + e.getMessage());

      }
      //For Update
      sa1[0].SchedEndTime=system.today()+1;
      try{
         update sa1[0];
         sa2=[select id,SchedStartTime,SchedEndTime,Duration from ServiceAppointment where id=:sa.id];
       }catch(DmlException e){
            System.debug('The following exception has occurred: ' + e.getMessage());

      }
       sa2=[select id,SchedStartTime,SchedEndTime,Duration from ServiceAppointment where id=:sa.id]; 
       system.assertnotEquals(sa1[0].Duration,sa2[0].duration);
      Test.stopTest();
     }
         
}