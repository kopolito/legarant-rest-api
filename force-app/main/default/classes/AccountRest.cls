/**
 * @description       : Accounts REST Interface
 * @author            : Etienne Knoerr
 * @group             : 
 * @last modified on  : 2021-04-16
 * @last modified by  : Etienne Knoerr
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   2021-04-15   Etienne Knoerr   Initial Version
**/

@RestResource(urlMapping='/Accounts/*')
global with sharing class AccountRest extends RestManager{
  /**
   * GET
   */ 
  @HttpGet
  global static void getAccountById() {
    RestContext.response.headers.put('Content-Type', 'application/json');
    try{
      String accountId = RestContext.request.requestURI.substring(
        RestContext.request.requestURI.lastIndexOf('/') + 1
      );
      if(isValidSalesforceId(accountId, Account.class)){
        handleSingle(accountId);
      } else {
        handleCollection();
      }      
    } catch (Exception e) {
      handleRestException(e, 'Account');
    }
  }

  /**
  * @description handleSingle > One Account
  * @param String accountId 
  **/
  private static void handleSingle(Id accountId){
    // collect Account field list
    Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
    List<String> fieldNames = new List<String>(fieldMap.keySet());
    Account thisAccount = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Account  WHERE Id = \'' + accountId + '\'');
    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisAccount));
  }

  /**
  * @description handleCollection > Account List
  **/
  private static void handleCollection(){
    // collect Account field list
    Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
    List<String> fieldNames = new List<String>(fieldMap.keySet());
    List<Account> thisAccounts = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Account LIMIT 20');
    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisAccounts));
  }
}
