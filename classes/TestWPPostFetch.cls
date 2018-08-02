@isTest
private class TestWPPostFetch {
    
    @testSetup static void setupTestData(){
        WPSites__c wpSite = new WPSites__c(Name='Test Domain', Domain__c='test.com', Last_Fetch_Date__c = Date.today().addMonths(-1));
        
        try{
            insert wpSite;
        }catch(Exception testInsEx){
            system.debug(LoggingLevel.ERROR, 'Error during test record setup: ' + testInsEx.getMessage());
        }
    }
    
    private static testMethod void testWPFetchCallout(){
        
        Test.startTest();
        
        WPSites__c testSite = WPSites__c.getValues('Test Domain');
        List<WP_Post__c> testPosts = new List<WP_Post__c>();
        
        if(testSite != null){
            Test.setMock(HttpCalloutMock.class, new MockWPPostHttpResp());
            String respBody = WPPostSubscribeService.postRetrievalCallout(testSite.Domain__c, testSite.Last_Fetch_Date__c);
            system.assertEquals(true, !respBody.contains('Error during callout'), 'Callout should have occurred without error');
            testPosts.addAll(WPPostSubscribeService.parsePostResp(respBody));
        }
        
        system.assertEquals(true, testPosts.size() > 0, 'Callout should have resulted in posts being generated');
        
        Test.stopTest();
        
    }
    
    private static testMethod void testWPPostFetchSchedule(){
        Test.startTest();
        
        String jobId = System.schedule('testWPPostFetch',
                                       '0 0 0 3 9 ? 2022', 
                                       new ScheduleWPPostFetch());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals('0 0 0 3 9 ? 2022', 
                            ct.CronExpression);
        
        System.assertEquals('2022-09-03 00:00:00', 
                            String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
    
    private static testMethod void testWPPostFetchBatch(){
        Test.startTest();
        WPPostFetchBatch wpBatch = new WPPostFetchBatch();
        wpBatch.query = 'SELECT Domain__c, Last_Fetch_Date__c FROM WPSites__c';
        Test.setMock(HttpCalloutMock.class, new MockWPPostHttpResp());
        Database.executeBatch(wpBatch, 5);
        
        Test.stopTest();
        
        List<WP_Post__c> testPosts = [SELECT Id, Title__c, URL__c FROM WP_Post__c WHERE CreatedDate = TODAY];
        
        system.assertEquals(1, testPosts.size(), '1 post record should have been inserted after batch execution');
        system.assertEquals('Test Blog Post', testPosts[0].Title__c);
        system.assertEquals('https://test.url', testPosts[0].URL__c);
    }
    
}