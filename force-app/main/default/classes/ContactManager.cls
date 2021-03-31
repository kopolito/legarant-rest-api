@RestResource(urlMapping='/Contacts/*')
global with sharing class ContactManager {
  /**
   * Standard Salesforce Error response structure
   */
  public class SalesforceError {
    public String errorCode;
    public String message;
    public SalesforceError(String errorCode, string message) {
      this.errorCode = errorCode;
      this.message = message;
    }
  }
  /**
   * Standard Salesforce Database Save/update/upsert response structure
   */
  public class GenericResult {
    final Id recordId;
    final List<Database.Error> errors;
    public Id getId() {
      return recordId;
    }
    public List<Database.Error> getErrors() {
      return errors;
    }

    public GenericResult(Id recordId, List<Database.Error> errors) {
      this.recordId = recordId;
      this.errors = (errors != null) ? errors : new List<Database.Error>();
    }
    public GenericResult(Database.SaveResult result) {
      this(result.getId(), result.getErrors());
    }
    public GenericResult(Database.UpsertResult result) {
      this(result.getId(), result.getErrors());
    }
    public GenericResult(Database.DeleteResult result) {
      this(result.getId(), result.getErrors());
    }
    public GenericResult(Database.UndeleteResult result) {
      this(result.getId(), result.getErrors());
    }
  }

  /**
   * GET
   */
  @HttpGet
  global static void getContactById() {
    try {
      // grab the contactId from the end of the URL
      Id contactId = RestContext.request.requestURI.substring(
        RestContext.request.requestURI.lastIndexOf('/') + 1
      );
      Contact result = [
        SELECT
          Id,
          FirstName,
          LastName,
          Email,
          Phone,
          MobilePhone,
          AccountId,
          Active__c
        FROM Contact
        WHERE Id = :contactId
      ];
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(result));
    } catch (System.StringException e) {
      RestContext.response.statusCode = 400;
      SalesforceError[] errs = new List<SalesforceError>{
        new SalesforceError('MISSING_PARAM', 'Id is not a valid Id')
      };
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
    } catch (System.QueryException e) {
      RestContext.response.statusCode = 404;
      SalesforceError[] errs = new List<SalesforceError>{
        new SalesforceError('NOT_FOUND', 'Contact not found')
      };
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
    } catch (Exception e) {
      //something else happened
      RestContext.response.statusCode = 500;
      SalesforceError[] errs = new List<SalesforceError>{
        new SalesforceError('SERVER_ERROR', e.getMessage())
      };
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
    }
  }

  /**
   * DELETE
   */
  @HttpDelete
  global static void deleteContact() {
    // grab the contactId from the end of the URL
    Id contactId = RestContext.request.requestURI.substring(
      RestContext.request.requestURI.lastIndexOf('/') + 1
    );
    Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
    //
    thisContact.Active__c = false;

    DataBase.SaveResult result = Database.update(thisContact);
    if (result.getErrors().size() != 0) {
      RestContext.response.statusCode = 400;
      SalesforceError[] errs = new List<SalesforceError>{
        new SalesforceError('BAD_REQUEST', JSON.serialize(result.errors))
      };
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
    } else {
      RestContext.response.statusCode = 200;
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
   * @param verb : String(POST, PATCH, PUT)
   */
  private static void manageContact(String verb) {
    List<String> verbs = new List<String>{ 'POST', 'PATCH', 'PUT' };
    if (!verbs.contains(verb)) {
      RestContext.response.statusCode = 500;
      SalesforceError[] errs = new List<SalesforceError>{
        new SalesforceError('BAD_REQUEST', 'BAD VERB')
      };
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
      return;
    }
    Contact thisContact;
    try {
      if (verb == 'PATCH') {
        Id contactId = RestContext.request.requestURI.substring(
          RestContext.request.requestURI.lastIndexOf('/') + 1
        );
        Contact result = [SELECT Id FROM Contact WHERE Id = :contactId];
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
      GenericResult result;
      if (verb == 'POST') {
        result = new GenericResult(Database.insert(thisContact, false));
      } else if (verb == 'PATCH') {
        result = new GenericResult(Database.update(thisContact));
      } else if (verb == 'PUT') {
        result = new GenericResult(Database.upsert(thisContact));
      }

      if (result.getErrors().size() != 0) {
        RestContext.response.statusCode = 400;
        //if (result.errors[0] instanceof Database.DuplicateError) {
        SalesforceError[] errs = new List<SalesforceError>{
          new SalesforceError('DB_ERROR', result.errors[0].message)
        };
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
      } else {
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(
          JSON.serialize(thisContact)
        );
      }
    } catch (System.StringException e) {
      RestContext.response.statusCode = 400;
      SalesforceError[] errs = new List<SalesforceError>{
        new SalesforceError('MISSING_PARAM', 'Id is not a valid Id')
      };
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
    } catch (System.QueryException e) {
      RestContext.response.statusCode = 404;
      SalesforceError[] errs = new List<SalesforceError>{
        new SalesforceError('NOT_FOUND', 'Contact not found')
      };
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
    } catch (Exception e) {
      //something else happened
      RestContext.response.statusCode = 500;
      SalesforceError[] errs = new List<SalesforceError>{
        new SalesforceError('SERVER_ERROR', e.getMessage())
      };
      RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errs));
    }
  }
}
