/**
 * @description       : 
 * @author            : Etienne Knoerr
 * @group             : 
 * @last modified on  : 2021-04-16
 * @last modified by  : Etienne Knoerr
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   2021-04-01   Etienne Knoerr   Initial Version
**/
public abstract class RestManager {
    /**
     * Custom Exceptions for custom Error messages
     */
    public virtual class VerbException extends Exception {}
    public virtual class DuplicateException extends Exception {}
    public virtual class ParamException extends Exception {}
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
     * Standard Salesforce Database save/update/upsert response structure
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
     * handleRestException
    * @description manage error response
    * @param Exception e 
    **/
    public static void handleRestException(Exception e, String resource){
        SalesforceError[] errors = new List<SalesforceError>();
        // errors.add(new SalesforceError('ERROR', e.getTypeName()));
        if (e instanceof RestManager.VerbException) {
            setError(405, 'BAD_VERB', 'Method Not Allowed');
        } else if (e instanceof System.StringException) {
            setError(400, 'MISSING_PARAM', 'Id is not a valid Id');
        } else if (e instanceof System.JSONException) {
            setError(400, 'BAD_PARAMS', 'Params are not in JSON Format');
        } else if (e instanceof RestManager.ParamException) {
            setError(400, 'BAD_PARAMS', e.getMessage());
        } else if (e instanceof System.QueryException) {
            setError(404, 'NOT_FOUND', resource + ' not found');
        } else if (e instanceof RestManager.DuplicateException) {
            setError(400, 'DUPLICATE', resource + ' already exists');
        } else if (e instanceof System.SObjectException) {
            setError(400, 'BAD_PARAMS', e.getMessage());
        } else {
            setError(500, 'SERVER_ERROR', e.getMessage());
        }
    }

    /**
    * @description setError response
    * @param Integer statusCode 
    * @param String errorCode 
    * @param String message 
    **/
    private static void setError(Integer statusCode, String errorCode, String message){
        RestContext.response.statusCode = statusCode;
        SalesforceError[] errors = new List<SalesforceError>{new SalesforceError(errorCode, message)};
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errors));
    }



    /**
    * @description check submitVerb
    * @param String verb 
    **/
    public static void checkSubmitVerb(String verb){
        List<String> verbs = new List<String>{ 'POST', 'PATCH', 'PUT' };
          if (!verbs.contains(verb)) {
            throw new VerbException();
          }
      }

      /**
     * Test a String to see if it is a valid SFDC  ID
     * @param  sfdcId The ID to test.
     * @param  t      The Type of the sObject to compare against
     * @return        Returns true if the ID is valid, false if it is not.
     */
    public static Boolean isValidSalesforceId( String sfdcId, System.Type t ){
        try {
            if ( Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( sfdcId ).matches() ){
                Id id = sfdcId;
                sObject sObj = (sObject) t.newInstance();
                sObj.Id = id;
                return true;
            }
        } catch ( Exception e ){ // StringException, TypeException
            return false;
        }
        // ID is not valid
        return false;
    }
}
