/*
 * @Author:  GetonCRM Solutions LLP
 * @Description:  Apex class use to download a excel file for Time and Attendance Summary report.
 * ------------------------------------------------------------------------------------------------------------------------
 * @Modification Logs
 * ------------------------------------------------------------------------------------------------------------------------
 * @version 1.1   - @Author:  Sanket Goswami - 1 July 2020
 */
public with sharing class TimeandSummaryReportController {
    public List<mileageWrapper> mileageWrapperList{get;set;}
    public double totalMileges {get; set;}
    public decimal totalDriveTime {get; set;}
    public decimal totalStayTimeForMonth {get; set;}
    public decimal totalTimeForMonth {get; set;}
    public string contactName {get; set;}
    public decimal totalMinute;
    public decimal totalStay;
    public decimal totalTimes;
    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
    
        }
    
    }
    public TimeandSummaryReportController() {
        drivingTime();
    }
    public void drivingTime(){
        String Id = ApexPages.currentPage().getParameters().get('id');
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String endDate = ApexPages.currentPage().getParameters().get('endDate');
        system.debug('id'+id+'startDate'+startDate+'endDate'+endDate);
        mileageWrapperList = new List<mileageWrapper>();
        Map<Date,String> tripdateDayMap = new Map<Date,String>(); 
        Map<Date,Double> tripdateMileageMap = new Map<Date,Double>();
        Map<Date,Decimal> tripdateDrivingTimeMap = new Map<Date,Decimal>();
        Map<Date,Decimal> tripStayTimeMap = new Map<Date,Double>();
        Map<Date,Decimal> tripTotalTimeMap = new Map<Date,Double>();
        for(Employee_Mileage__c objMileages : [SELECT id,EmployeeReimbursement__r.Name,Trip_Date__c,Day_Of_Week__c, 
                                                        Mileage__c, Driving_Time__c,Origin_Name__c,
                                                        ConvertedStartTime__c, ConvertedEndTime__c, 
                                                        Stay_Time__c, EmployeeReimbursement__r.Contact_Id__c,
                                                        EmployeeReimbursement__r.Contact_Id__r.Name,Total_Time__c
                                                    FROM Employee_Mileage__c 
                                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: Id
                                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                                    AND Trip_Date__c <= : Date.valueOf(endDate)
                                                    ]){
            contactName = objMileages.EmployeeReimbursement__r.Contact_Id__r.Name;
            if(objMileages.Day_Of_Week__c != null ){
            tripdateDayMap.put(objMileages.Trip_Date__c, objMileages.Day_Of_Week__c);
            }
        }
        for(AggregateResult ar : [SELECT Trip_Date__c tdate, SUM(Mileage__c) rtotal
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: id 
                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                    AND Trip_Date__c <= : Date.valueOf(endDate) group by Trip_Date__c ]){

                                        tripdateMileageMap.put((Date)ar.get('tdate'),(Decimal)ar.get('rtotal'));
        }
        for(AggregateResult ar : [SELECT Trip_Date__c tdate, SUM(Driving_Time__c) rtotal
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: id 
                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                    AND Trip_Date__c <= : Date.valueOf(endDate) group by Trip_Date__c ]){

                                        tripdateDrivingTimeMap.put((Date)ar.get('tdate'),(Decimal)ar.get('rtotal'));
        }
        for(AggregateResult ar : [SELECT Trip_Date__c tdate, SUM(Stay_Time__c) rtotal
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: id 
                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                    AND Trip_Date__c <= : Date.valueOf(endDate) group by Trip_Date__c ]){

                                        tripStayTimeMap.put((Date)ar.get('tdate'),(Decimal)ar.get('rtotal'));
        }
        for(AggregateResult ar : [SELECT Trip_Date__c tdate, SUM(Total_Time__c) rtotal
                                    FROM Employee_Mileage__c 
                                    WHERE EmployeeReimbursement__r.Contact_Id__c =: id 
                                    AND Trip_Date__c >= : Date.valueOf(startDate)
                                    AND Trip_Date__c <= : Date.valueOf(endDate) group by Trip_Date__c ]){

                                        tripTotalTimeMap.put((Date)ar.get('tdate'),(Decimal)ar.get('rtotal'));
        }
        
        for(Date currentDate : tripdateDayMap.keySet())
        {
            List<String> dateSplitted = new List<String>();
            if(String.valueOf(currentDate) != null && String.valueOf(currentDate).contains('-')){
                dateSplitted = String.valueOf(currentDate).split('-');
            }
         
            if(totalMinute > 0 ){
                totalMinute = totalMinute + tripdateDrivingTimeMap.get(currentDate);
            } else {
                totalMinute = tripdateDrivingTimeMap.get(currentDate);
            }
            
            if(totalStay > 0 && tripStayTimeMap.containsKey(currentDate)){
                totalStay = totalStay + tripStayTimeMap.get(currentDate);
            } else {
                totalStay = tripStayTimeMap.get(currentDate);
            }

            if(totalTimes > 0 && tripTotalTimeMap.containsKey(currentDate)){
                totalTimes = totalTimes + tripTotalTimeMap.get(currentDate);
            } else {
                totalTimes = tripTotalTimeMap.get(currentDate);
            }

            mileageWrapper objMileageWrap = new mileageWrapper();
            if(!dateSplitted.isEmpty()){
                objMileageWrap.tripDate = dateSplitted[1]+'/'+dateSplitted[2]+'/'+dateSplitted[0].substring(2,4);
            }
            objMileageWrap.tripDay = tripdateDayMap.get(currentDate);
            objMileageWrap.mileage = tripdateMileageMap.get(currentDate);
            objMileageWrap.totaldrivingTime = (tripdateDrivingTimeMap.get(currentDate)).divide(60, 2);
            objMileageWrap.totalStayTime = (tripStayTimeMap.get(currentDate)).divide(60, 2);
            objMileageWrap.totalTime = (tripTotalTimeMap.get(currentDate)).divide(60, 2);
            if(totalMileges > 0 ){
                totalMileges = totalMileges + objMileageWrap.mileage;
            } else {
                totalMileges = objMileageWrap.mileage;
            }
            
            mileageWrapperList.add(objMileageWrap);
        }
        System.debug('mileageWrapperList'+mileageWrapperList);
        
        totalTimeForMonth = totalTimes > 0 ? (totalTimes).divide(60, 2) : 0 ;
        totalDriveTime = totalMinute > 0 ? (totalMinute).divide(60, 2) : 0;
        totalStayTimeForMonth = totalStay > 0 ? (totalStay).divide(60, 2) : 0;
    }

    public class mileageWrapper{
        public string tripDate { get; set; }
        public string tripDay { get; set; }
        public decimal mileage { get; set; }
        public decimal totaldrivingTime { get; set; }
        public decimal totalStayTime { get; set; }
        public decimal totalTime { get; set; }
        public mileageWrapper(){
        }
    }
}