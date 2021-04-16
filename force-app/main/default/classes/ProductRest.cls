/**
 * @description       : Product2s REST Interface
 * @author            : Etienne Knoerr
 * @group             : 
 * @last modified on  : 2021-04-16
 * @last modified by  : Etienne Knoerr
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   2021-04-01   Etienne Knoerr   Initial Version
**/
@RestResource(urlMapping='/Products/*')
global with sharing class ProductRest extends RestManager{
  /**
   * GET
   */ 
  @HttpGet
  global static void getProduct2ById() {
    RestContext.response.headers.put('Content-Type', 'application/json');
    try{
      String productId = RestContext.request.requestURI.substring(
        RestContext.request.requestURI.lastIndexOf('/') + 1
      );
      if(isValidSalesforceId(productId, Product2.class)){
        handleSingle(productId);
      } else {
        handleCollection();
      }      
    } catch (Exception e) {
      handleRestException(e, 'Product');
    }
  }

  /**
  * @description handleSingle > One Product2
  * @param String productId 
  **/
  private static void handleSingle(Id productId){
    // collect Product2 field list
    Map<String, Schema.SObjectField> fieldMap = Product2.sObjectType.getDescribe().fields.getMap();
    List<String> fieldNames = new List<String>(fieldMap.keySet());
    Product2 thisProduct = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Product2  WHERE Id = \'' + productId + '\'');

    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisProduct));
  }

  /**
  * @description handleCollection > Product2 List
  **/
  private static void handleCollection(){
    // collect Product2 field list
    Map<String, Schema.SObjectField> fieldMap = Product2.sObjectType.getDescribe().fields.getMap();
    List<String> fieldNames = new List<String>(fieldMap.keySet());
    List<Product2> thisProducts = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Product2  LIMIT 20');

    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisProducts));
  }
}
