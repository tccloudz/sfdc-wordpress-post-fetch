/**
 * @author Terence Chiu
 * @description Performs web service callout to wordpress.com api and fetchs post data. Parses posts data in json response and generates
 * 				WP Post object records.
*/
public with sharing class WPPostSubscribeService {

    public static String postRetrievalCallout(String domain, Date lastFetchDate){
        String respBody;
        String dateFilter =  lastFetchDate != null ? '?after=' + lastFetchDate.year() + '-' + lastFetchDate.month() + '-' + lastFetchDate.day() : '';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://public-api.wordpress.com/rest/v1.1/sites/' + domain + '/posts/' + dateFilter);
                
        try{
        	HttpResponse resp = h.send(req);
            respBody = resp.getStatusCode() == 200 ? resp.getBody() : 'Error during callout: ' + resp.getStatusCode() + ': ' + resp.getStatus() + ' - ' + resp.getBody();
        }catch(Exception ex){
            respBody = 'Error during callout: ' + ex.getMessage();
        }

        return respBody;        
    }
    
    public static List<WP_Post__c> parsePostResp(String respBody){
        List<WP_Post__c> posts = new List<WP_Post__c>();
        
        JSONParser parser = JSON.createParser(respBody);
        Boolean titleFound = false;
        Boolean urlFound = false;
		WP_Post__c post;
        
        while(parser.nextToken() != null){
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'title'){
                parser.nextToken();
                
                titleFound = true;
                post = new WP_Post__c();
                post.Title__c = parser.getText();
            }
            else if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'short_URL'){
                parser.nextToken();
                titleFound = false;
                post.URL__c = parser.getText();
                posts.add(post);
            }
        }

        return posts;
    }
}