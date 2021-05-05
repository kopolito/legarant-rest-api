/**
 * @description       : Accounts REST Interface
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-05-05
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-15   Etienne Knoerr   Initial Version
 **/

@RestResource(urlMapping='/accounts/*')
global with sharing class AccountRest extends RestManager {
	/**
	 * GET
	 */
	@HttpGet
	global static void getAccount() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			// check requestURI pattern
			Pattern collectionPattern = Pattern.compile('/accounts/?$');
			Matcher match = collectionPattern.matcher(RestContext.request.requestURI);
			Boolean getCollection = match.matches();
			// collect Account field list
			Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
			List<String> fieldNames = new List<String>(fieldMap.keySet());

			if (getCollection) {
				List<Account> records = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Account');
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(records));
			} else {
				// check Id is valid
				String recordId = RestContext.request.requestURI.substring(
					RestContext.request.requestURI.lastIndexOf('/') + 1
				);
				if (!isValidSalesforceId(recordId, Account.class)) {
					throw new System.StringException();
				}
				Account record = Database.query(
					'SELECT ' +
					String.join(fieldNames, ',') +
					' FROM Account  WHERE Id = \'' +
					recordId +
					'\''
				);
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(record));
			}
			RestContext.response.statusCode = 200;
		} catch (Exception e) {
			handleRestException(e, 'Account');
		}
	}
}
