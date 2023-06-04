/**
 * @description       : This class contains methods to make callouts to a Node.js server and create PDFs from the response.
 * @author            : Kishan Kumar
 * @group             : 
 * @last modified on  : 06-04-2023
 * @last modified by  : Kishan Kumar
**/
public class HerokuCallout {
    
    /**
         * This method makes a callout to a Node.js server and sends a JSON payload containing a map of subordinates by manager.
         * It then creates a PDF from the response and links it to a specified account record.
         **/
        public static void makeCalloutNodeJSGraphs(){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:GraphNodeJS');
            request.setMethod('POST');
            Jsoninput js= new Jsoninput(RoleHierarchy.getSubordinatesByManagerMap());
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(js));
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 200) {
                // Deserialize the JSON string into collections of primitive data types.
                System.debug('Received the following :'+response.getBody());
                createPDF(response.getBody(),'RoleHierarchy','0012x00000hIpGrAAK');
            }
        }
        
        /**
         * This method makes a callout to a Node.js server and sends a JSON payload containing a map of accounts for a specified account ID.
         * It then creates a PDF from the response and links it to the specified account record.
         **/
        public static void makeCalloutNodeJSGraphs1(String AccId){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:GraphNodeJS');
            request.setMethod('POST');
            Jsoninput js= new Jsoninput(RoleHierarchy.getAccountMap(AccId));
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(js));
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 200) {
                // Deserialize the JSON string into collections of primitive data types.
                System.debug('Received the following :'+response.getBody());
                createPDF(response.getBody(),'AccountHierarchy',AccId);
            }
        }
        
        /**
         * This method creates a PDF from a given data string and inserts it as a ContentVersion record.
         * It then links the ContentVersion record to a specified account record as a ContentDocumentLink.
         **/
        public static void createPDF(String data,String fileName,String AccId) {
            ContentVersion conver = new ContentVersion();
            conver.Title = fileName;
            conver.PathOnClient = fileName + '.PDF';
            conver.VersionData = EncodingUtil.base64Decode(data);//blob.valueOf(response.content);
            insert conver;
            
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conver.Id].ContentDocumentId;
            
            // Link the content document to sObject record in this case it is account 
            ContentDocumentLink condocLink = new ContentDocumentLink();
            condocLink.ContentDocumentId = contentDocumentId;
            //Link the File to CRM Record  
            condocLink.LinkedEntityId = AccId;
            condocLink.ShareType = 'V';
            insert condocLink;
        }
        
        /**
         * This inner class is used to serialize a map of strings to lists of strings as a JSON payload for the callout methods.
         **/
        Public class Jsoninput{
            Public Map<String, List<String>> data;
            public Jsoninput(Map<String, List<String>> data){
                this.data=data;
            }
        }
    }
