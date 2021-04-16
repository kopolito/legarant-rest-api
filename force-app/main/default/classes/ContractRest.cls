/**
 * @description       : Contracts REST Interface
 * @author            : Etienne Knoerr
 * @group             : 
 * @last modified on  : 2021-04-16
 * @last modified by  : Etienne Knoerr
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   2021-04-15   Etienne Knoerr   Initial Version
**/

@RestResource(urlMapping='/Contracts/*')
global with sharing class ContractRest extends RestManager{
  /**
   * GET
   */ 
  @HttpGet
  global static void getContractById() {
    RestContext.response.headers.put('Content-Type', 'application/json');
    try{
      String contractId = RestContext.request.requestURI.substring(
        RestContext.request.requestURI.lastIndexOf('/') + 1
      );
      if(isValidSalesforceId(contractId, Contract.class)){
        handleSingle(contractId);
      } else {
        handleCollection();
      }      
    } catch (Exception e) {
      handleRestException(e, 'Contract');
    }
  }

  /**
  * @description handleSingle > One Contract
  * @param String contractId 
  **/
  private static void handleSingle(Id contractId){
    // collect Contract field list
    Map<String, Schema.SObjectField> fieldMap = Contract.sObjectType.getDescribe().fields.getMap();
    List<String> fieldNames = new List<String>(fieldMap.keySet());
    Contract thisContract = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Contract  WHERE Id = \'' + contractId + '\'');
    //Contract thisContract = [SELECT Id, FirstName, LastName, Email, Phone FROM Contract WHERE Id = :contractId] ;
    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContract));
  }

  /**
  * @description handleCollection > Contract List
  **/
  private static void handleCollection(){
    // collect Contract field list
    Map<String, Schema.SObjectField> fieldMap = Contract.sObjectType.getDescribe().fields.getMap();
    List<String> fieldNames = new List<String>(fieldMap.keySet());
    List<Contract> thisContracts = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Contract LIMIT 20');
    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContracts));
  }

  /**
   * POST
   */
  @HttpPost
  global static void createContract() {
    manageContract('POST');
  }

  /**
   * PUT
   */
  @HttpPut
  global static void upsertContract() {
    manageContract('PUT');
  }

  /**
   * PATCH
   */
  @HttpPatch
  global static void updateContractFields() {
    manageContract('PATCH');
  }

  /**
   * manageContract
   * @param verb : String{POST, PATCH, PUT}
   */
  private static void manageContract(String verb) {
    RestContext.response.headers.put('Content-Type', 'application/json');
    try {
      checkSubmitVerb(verb);
      Contract thisContract;
      //TODO : check is Id needed in URL or in JSON params ?
      if (verb == 'PATCH') {
        Id contractId = RestContext.request.requestURI.substring(
          RestContext.request.requestURI.lastIndexOf('/') + 1
        );
        thisContract = [SELECT Id FROM Contract WHERE Id = :contractId];
      } else {
        thisContract = new Contract();
      }
      // Deserialize the JSON string into name-value pairs
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        RestContext.request.requestbody.tostring()
      );

      // Iterate through each parameter field and value
      for (String fieldName : params.keySet()) {
        // Set the field and value on the Contract sObject
        if(fieldName != 'StartDate'){
            thisContract.put(fieldName, params.get(fieldName));
        } else{
          String dateString = params.get(fieldName).toString();
          Date myDate = Date.parse(dateString);
          thisContract.put(fieldName, myDate);
        }
      }
      

      GenericResult result;
      if (verb == 'POST') {
        // allOrNone param set to false in order to get error type
        result = new GenericResult(Database.insert(thisContract, false));
      } else if (verb == 'PATCH') {
        result = new GenericResult(Database.update(thisContract, false));
      } else if (verb == 'PUT') {
        result = new GenericResult(Database.upsert(thisContract, false));
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
        JSON.serialize(thisContract)
      );
    } catch (Exception e) {
      handleRestException(e, 'Contract');
    }
  }
}
