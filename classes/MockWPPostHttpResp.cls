/**
 * @author Terence Chiu
 * @description Generates a mock response to test WP Post fetch callout
*/
global class MockWPPostHttpResp implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req){
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject(); //start main
        gen.writeFieldName('posts'); //write post field name
        gen.writeStartArray(); //start post array
        gen.writeStartObject(); //start test post data
        
        
        gen.writeStringField('Title', 'Test Blog Post');
        gen.writeStringField('short_URL', 'https://test.url');
        
        gen.writeEndObject(); //end test post data
        gen.writeEndArray(); //end post array
        gen.writeEndObject(); //end main

        
        String jsonStr = gen.getAsString();
        
        resp.setBody(jsonStr);
        
        return resp;
    }
    
}