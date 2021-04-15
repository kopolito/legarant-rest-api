/**
 * @description       : Contacts REST Interface
 * @author            : Etienne Knoerr
 * @group             : 
 * @last modified on  : 2021-04-15
 * @last modified by  : Etienne Knoerr
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   2021-04-01   Etienne Knoerr   Initial Version
**/

/*
Questions : 
  - si on ne supprime pas, en mettant Active__c à false : autorise-t-on la récupération / modification de contacts inactifs ?
  - PATCH : passer l'ID en paramètre JSON ou dans l'URL ?
*/
@RestResource(urlMapping='/Contacts/*')
global with sharing class ContactRest extends RestManager{
  /**
   * GET
   */ 
  @HttpGet
  global static void getContactById() {
    RestContext.response.headers.put('Content-Type', 'application/json');
    try {
      // grab the contactId from the end of the URL
      Id contactId = RestContext.request.requestURI.substring(
        RestContext.request.requestURI.lastIndexOf('/') + 1
      );
      // collect Contact field list
      Map<String, Schema.SObjectField> fieldMap = Contact.sObjectType.getDescribe().fields.getMap();
      List<String> fieldNames = new List<String>(fieldMap.keySet());
      Contact thisContact = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Contact  WHERE Id = \'' + contactId + '\'');
      //Contact thisContact = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = :contactId] ;
      
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContact));
    } catch (Exception e) {
      handleException(e, 'Contact');
    }
  }

  /**
   * DELETE
   */
  @HttpDelete
  global static void deleteContact() {
    RestContext.response.headers.put('Content-Type', 'application/json');
    try {
      // grab the contactId from the end of the URL
      Id contactId = RestContext.request.requestURI.substring(
        RestContext.request.requestURI.lastIndexOf('/') + 1
      );
      Contact thisContact = [SELECT Id, Active__c FROM Contact WHERE Id = :contactId];
      thisContact.Active__c = false;
      DataBase.SaveResult result = Database.update(thisContact);
      RestContext.response.statusCode = 204;
    } catch (Exception e) {
      handleException(e, 'Contact');
    }
  }

  /**
   * POST
   */
  @HttpPost
  global static void createContact() {
    manageContact('POST');
  }

  /**
   * PUT
   */
  @HttpPut
  global static void upsertContact() {
    manageContact('PUT');
  }

  /**
   * PATCH
   */
  @HttpPatch
  global static void updateContactFields() {
    manageContact('PATCH');
  }

  /**
   * manageContact
   * @param verb : String{POST, PATCH, PUT}
   */
  private static void manageContact(String verb) {
    RestContext.response.headers.put('Content-Type', 'application/json');
    try {
      checkVerb(verb);
      Contact thisContact;
      //TODO : check is Id needed in URL or in JSON params ?
      if (verb == 'PATCH') {
        Id contactId = RestContext.request.requestURI.substring(
          RestContext.request.requestURI.lastIndexOf('/') + 1
        );
        thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
      } else {
        thisContact = new Contact();
      }
      // Deserialize the JSON string into name-value pairs
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        RestContext.request.requestbody.tostring()
      );

      // Iterate through each parameter field and value
      for (String fieldName : params.keySet()) {
        // Set the field and value on the Contact sObject
        thisContact.put(fieldName, params.get(fieldName));
      }
      Boolean duplicate;
      // test for duplicate
      if(verb != 'PATCH'){
        try {
          Contact testContactDuplicate = [SELECT Id FROM Contact WHERE Email = :thisContact.Email];
          thisContact.put('Id', testContactDuplicate.Id);
          verb = 'PATCH';
          duplicate = true;
        } catch (System.QueryException e) {
          duplicate = false;
        }
      }

      GenericResult result;
      if (verb == 'POST') {
        // allOrNone param set to false in order to get error type
        result = new GenericResult(Database.insert(thisContact, false));
      } else if (verb == 'PATCH') {
        result = new GenericResult(Database.update(thisContact, false));
      } else if (verb == 'PUT') {
        result = new GenericResult(Database.upsert(thisContact, false));
      }
      // manage error
      if (result.getErrors().size() != 0) {
        if (result.getErrors()[0] instanceof Database.DuplicateError) {
          throw new DuplicateException();
        } else {
          throw new ParamException(result.getErrors()[0].message);
        }
      }
      // Send response
      RestContext.response.statusCode = 200;
      RestContext.response.responseBody = Blob.valueOf(
        JSON.serialize(thisContact)
      );
    } catch (Exception e) {
      handleException(e, 'Contact');
    }
  }
  private static void checkVerb(String verb){
    List<String> verbs = new List<String>{ 'POST', 'PATCH', 'PUT' };
      if (!verbs.contains(verb)) {
        throw new VerbException();
      }
  }
}
