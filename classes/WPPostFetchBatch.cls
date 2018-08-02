/**
 * @author Terence Chiu
 * @description Executes callouts to fetch wordpress.com blog post data by domains stored in WP Site custom setting.
 * 				Inserts any post data into the WP Post object as records
*/
global class WPPostFetchBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

   global String query; 
    
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<WP_Post__c> posts = new List<WP_Post__c>();
       List<sObject> upsRecs = new List<sObject>();
       
       for(sObject wpSite : scope){
       		String httpRespBody = WPPostSubscribeService.postRetrievalCallout((String)wpSite.get('Domain__c'), (Date) wpSite.get('Last_Fetch_Date__c'));
            if(!httpRespBody.contains('Error during callout:')){
                posts.addAll(WPPostSubscribeService.parsePostResp(httpRespBody));
                wpSite.put('Last_Fetch_Date__c', Date.today());
                upsRecs.add(wpSite);
            }
       }
       
       try{
           insert posts;
           update upsRecs;
       }catch(DMLException ex){
           system.debug('Error during post insert: ' + ex.getMessage());
       }
       
   }

   global void finish(Database.BatchableContext BC){
   }
}