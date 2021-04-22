/**
 * @description       : Accounts REST Interface
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-04-22
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-15   Etienne Knoerr   Initial Version
 **/

@RestResource(urlMapping='/Accounts/*')
global with sharing class AccountRest extends RestManager {
	/**
	 * GET
	 */
	@HttpGet
	global static void getAccountById() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			String accountId = RestContext.request.requestURI.substring(
				RestContext.request.requestURI.lastIndexOf('/') + 1
			);
			if (!isValidSalesforceId(accountId, Account.class)) {
				throw new System.StringException();
			}
			// collect Account field list
			Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
			List<String> fieldNames = new List<String>(fieldMap.keySet());
			Account thisAccount = Database.query(
				'SELECT ' +
				String.join(fieldNames, ',') +
				' FROM Account  WHERE Id = \'' +
				accountId +
				'\''
			);
			//Account thisAccount = [SELECT Id, FirstName, LastName, Email, Phone FROM Account WHERE Id = :accountId] ;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisAccount));
			RestContext.response.statusCode = 200;
		} catch (Exception e) {
			handleRestException(e, 'Account');
		}
	}
}
