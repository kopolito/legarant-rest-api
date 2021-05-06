/**
 * @description       : Accounts REST Interface
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-05-06
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
	
	/**
	 * @description POST
	 **/
	@HttpPost
	global static void createAccount() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			Account thisAccount = applyParameters(new Account());
			GenericResult result = new GenericResult(Database.insert(thisAccount, false));
			// manage error
			if (result.getErrors().size() != 0) {
				throw new ParamException(result.getErrors()[0].message);
			}
			// Send response
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisAccount));
		} catch (Exception e) {
			handleRestException(e, 'Account');
		}
	}

	/**
	 * @description PUT
	 **/
	@HttpPut
	global static void upsertAccount() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			Account thisAccount = applyParameters(new Account());
			GenericResult result = new GenericResult(Database.upsert(thisAccount, false));
			// manage error
			if (result.getErrors().size() != 0) {
				throw new ParamException(result.getErrors()[0].message);
			}
			// Send response
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisAccount));
		} catch (Exception e) {
			handleRestException(e, 'Account');
		}
	}

	/**
	 * @description PATCH
	 **/
	@HttpPatch
	global static void updateAccount() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			Id recordId = RestContext.request.requestURI.substring(
				RestContext.request.requestURI.lastIndexOf('/') + 1
			);
			Account thisAccount = [SELECT Id FROM Account WHERE Id = :recordId];
			thisAccount = applyParameters(thisAccount);
			GenericResult result = new GenericResult(Database.update(thisAccount, false));
			// manage error
			if (result.getErrors().size() != 0) {
				throw new ParamException(result.getErrors()[0].message);
			}
			// Send response
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisAccount));
		} catch (Exception e) {
			handleRestException(e, 'Account');
		}
	}

	/**
	 * @description apply request parameters to Account
	 * @param Account thisAccount
	 * @return Account
	 **/
	public static Account applyParameters(Account thisAccount) {
		// Deserialize the JSON string into name-value pairs
		Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
			RestContext.request.requestbody.tostring()
		);
		// Iterate through each parameter field and value
		for (String fieldName : params.keySet()) {
			// Set the field and value on the Account sObject
			thisAccount.put(fieldName, params.get(fieldName));
		}
		return thisAccount;
	}
}
