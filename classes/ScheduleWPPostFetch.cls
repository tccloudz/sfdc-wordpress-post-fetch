/**
 * @author Terence Chiu
 * description Schedules WPPostFetchBatch job. Passes query to select WP Site custom setting records.
*/
global class ScheduleWPPostFetch implements Schedulable {
   global void execute(SchedulableContext sc) {
      WPPostFetchBatch wpBatch = new WPPostFetchBatch();
      wpBatch.query = 'SELECT Domain__c, Last_Fetch_Date__c FROM WPSites__c';
      Database.executebatch(wpBatch, 5);
   }
}