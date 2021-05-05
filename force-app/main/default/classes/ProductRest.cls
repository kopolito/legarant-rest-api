/**
 * @description       : Product2s REST Interface
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-05-05
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-01   Etienne Knoerr   Initial Version
 **/
@RestResource(urlMapping='/products/*')
global with sharing class ProductRest extends RestManager {
	/**
	 * GET
	 */
	@HttpGet
	global static void getProduct() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			// check requestURI pattern
			Pattern collectionPattern = Pattern.compile('/products/?$');
			Matcher match = collectionPattern.matcher(RestContext.request.requestURI);
			Boolean getCollection = match.matches();
			// collect Product2 field list
			Map<String, Schema.SObjectField> fieldMap = Product2.sObjectType.getDescribe().fields.getMap();
			List<String> fieldNames = new List<String>(fieldMap.keySet());

			if (getCollection) {
				List<Product2> records = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Product2');
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(records));
			} else {
				// check Id is valid
				String recordId = RestContext.request.requestURI.substring(
					RestContext.request.requestURI.lastIndexOf('/') + 1
				);
				if (!isValidSalesforceId(recordId, Product2.class)) {
					throw new System.StringException();
				}
				Product2 record = Database.query(
					'SELECT ' +
					String.join(fieldNames, ',') +
					' FROM Product2  WHERE Id = \'' +
					recordId +
					'\''
				);
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(record));
			}
			RestContext.response.statusCode = 200;
		} catch (Exception e) {
			handleRestException(e, 'Product2');
		}
	}
}
