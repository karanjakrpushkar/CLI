/********************************************************************************************************
* @Author         ext.chandan.singh@cargotec.com
* @Description    This is a utility Class.     
* @CreatedDate    01-02-2019
* @TestClass      CGT_Test_WorkOrder_Handler
* @Modified Date  

*********************************************************************************************************/  
    
public class CGT_FSM_Utility{
    public static String CGT_Sunday = 'Sunday';
    public static String CGT_Monday = 'Monday';
    public static String CGT_Tuesday = 'Tuesday';
    public static String CGT_Wednesday = 'Wednesday';
    public static String CGT_Thursday = 'Thursday';
    public static String CGT_Friday = 'Friday';
    public static String CGT_Saturday = 'Saturday';
    public static boolean isNotAfterInsert = true;
    
     /********************************************************************************************************
    * @Author         ext.chandan.singh@cargotec.com
    * @Method          calculateDuration
    * @Parameters      StartDate,EndDate,DurationType
    * @description     This method is used for calculating Duration based on StartDate and EndDate. In first line StartDate will be subtracted from EndDate to get 
                        duration in hours and then in second line it will be subtracted again to get duration in mins and then both time will be added and converted in hours
                        or mins.
    * @CreatedDate    01-02-2019
    *********************************************************************************************************/
    public static Decimal calculateDuration (Datetime StartDate,DateTime EndDate,String DurationType) {
        Decimal Duration ;
        if(DurationType == system.Label.CGT_Service_Appointment_Time){
         Decimal decHours = ((endDate.getTime())/1000/60/60) - ((startDate.getTime())/1000/60/60);
         Decimal decMin = ((endDate.getTime())/1000/60) - ((startDate.getTime())/1000/60);
         Decimal timeT = decMin-(decHours*60);
         Duration = decHours + (timeT/60);
        }
        else{
         Decimal decMin = ((endDate.getTime())/1000/60) - ((startDate.getTime())/1000/60);
         Duration = decMin;
        }
        return Duration;
        
    }
     /********************************************************************************************************
    * @Author         ext.chandan.singh@cargotec.com
    * @Method          calculateEndDate
    * @Parameters      StartDate,Duration,DurationType
    * @description     This method is used for calculating EndDate based on StartDate and Duration. Here Duration will be added in StartDate to give EndDate.
    * @CreatedDate    01-02-2019
    *********************************************************************************************************/
    public static DateTime calculateEndDate (Datetime StartDate,Decimal Duration,String DurationType) {
        DateTime EndDate;
        if(DurationType == system.Label.CGT_Service_Appointment_Time){
            Integer DurationinHrs = Duration.intValue();
            Integer DurationinMin = (Duration*60).intValue() - (DurationinHrs*60);
            endDate = startDate.addMinutes((DurationinHrs *60) + DurationinMin);
        }else{
            Integer DurationinMin = Duration.intValue();
            EndDate = startDate.addMinutes(DurationinMin);
        }
        return EndDate;
    }
    
/********************************************************************************************************
* @author        Tieto 
* @description    Getting StartDate of TimeSheet.
* @date           2019-03-24
* @group          Time Sheet
*********************************************************************************************************/ 
    public static Date timeSheetStartDate(Date startDate){
        Date timesheetStartDate;
        Date weekStart = startDate.toStartofWeek();
        DateTime weekStartTime = DateTime.newInstance(weekStart, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek=weekStartTime.format('EEEE');
        String timeSheetEntryDay = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0)).format('EEEE');
        if(dayOfWeek.equalsIgnoreCase(CGT_Sunday)){
            if(timeSheetEntryDay.equalsIgnoreCase(CGT_Sunday)){
                timesheetStartDate = weekStartTime.Date().addDays(-6);
            }else{
                timesheetStartDate = weekStartTime.Date().addDays(1);
            }
        }else if (dayOfWeek.equalsIgnoreCase(CGT_Monday)){
            timesheetStartDate = weekStartTime.Date();
        }
        return timesheetStartDate;
    }
    
    /********************************************************************************************************
* @author        Tieto 
* @description    Getting First WOLI of WorkOrder.
* @date           2019-04-25
* @group          Time Sheet
*********************************************************************************************************/ 
    public static Map<Id,Id> firstWOLIofWO(List<Id> woList){
    Set<Id> woSet = new Set<Id>();
    woset.addAll(woList);
        Map<Id,Id> woIdwoliIdMap = new Map<Id,Id>();
        List<WorkOrder> workOrderList = [SELECT
                                                Id,(Select Id from WorkOrderLineItems)
                                                FROM
                                                WorkOrder
                                                WHERE
                                                Id IN :woSet
                                            ];
                                            
        for(WorkOrder wo : workOrderList){   
            if(wo.WorkOrderLineItems != null && !wo.WorkOrderLineItems.isEmpty()){
                    woIdwoliIdMap.put(wo.id,wo.WorkOrderLineItems[0].Id);
            }
        }
        return woIdwoliIdMap;
        
    }
}