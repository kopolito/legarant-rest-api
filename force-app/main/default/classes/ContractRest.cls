/**
 * @description       : Contracts REST Interface
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-05-05
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-15   Etienne Knoerr   Initial Version
 **/

@RestResource(urlMapping='/contracts/*')
global with sharing class ContractRest extends RestManager {
	/**
	 * @description GET
	 **/
	@HttpGet
	global static void getContract() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			// check requestURI pattern
			Pattern collectionPattern = Pattern.compile('/contracts/?$');
			Matcher match = collectionPattern.matcher(RestContext.request.requestURI);
			Boolean getCollection = match.matches();
			// collect Contract field list
			Map<String, Schema.SObjectField> fieldMap = Contract.sObjectType.getDescribe().fields.getMap();
			List<String> fieldNames = new List<String>(fieldMap.keySet());

			if (getCollection) {
				List<Contract> records = Database.query('SELECT ' + String.join(fieldNames, ',') + ' FROM Contract');
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(records));
			} else {
				// check Id is valid
				String recordId = RestContext.request.requestURI.substring(
					RestContext.request.requestURI.lastIndexOf('/') + 1
				);
				if (!isValidSalesforceId(recordId, Contract.class)) {
					throw new System.StringException();
				}
				Contract record = Database.query(
					'SELECT ' +
					String.join(fieldNames, ',') +
					' FROM Contract  WHERE Id = \'' +
					recordId +
					'\''
				);
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize(record));
			}
			RestContext.response.statusCode = 200;
		} catch (Exception e) {
			handleRestException(e, 'Contract');
		}
	}
	/**
	 * @description POST
	 **/
	@HttpPost
	global static void createContract() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			Contract thisContract = applyParameters(new Contract());
			GenericResult result = new GenericResult(Database.insert(thisContract, false));
			// manage error
			if (result.getErrors().size() != 0) {
				throw new ParamException(result.getErrors()[0].message);
			}
			// Send response
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContract));
		} catch (Exception e) {
			handleRestException(e, 'Contract');
		}
	}

	/**
	 * @description PUT
	 **/
	@HttpPut
	global static void upsertContract() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			Contract thisContract = applyParameters(new Contract());
			GenericResult result = new GenericResult(Database.upsert(thisContract, false));
			// manage error
			if (result.getErrors().size() != 0) {
				throw new ParamException(result.getErrors()[0].message);
			}
			// Send response
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContract));
		} catch (Exception e) {
			handleRestException(e, 'Contract');
		}
	}

	/**
	 * @description PATCH
	 **/
	@HttpPatch
	global static void updateContract() {
		RestContext.response.headers.put('Content-Type', 'application/json');
		try {
			Id contractId = RestContext.request.requestURI.substring(
				RestContext.request.requestURI.lastIndexOf('/') + 1
			);
			Contract thisContract = [SELECT Id FROM Contract WHERE Id = :contractId];
			thisContract = applyParameters(thisContract);
			GenericResult result = new GenericResult(Database.update(thisContract, false));
			// manage error
			if (result.getErrors().size() != 0) {
				throw new ParamException(result.getErrors()[0].message);
			}
			// Send response
			RestContext.response.statusCode = 200;
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(thisContract));
		} catch (Exception e) {
			handleRestException(e, 'Contract');
		}
	}

	/**
	 * @description apply request parameters to Contract
	 * @param Contract thisContract
	 * @return Contract
	 **/
	public static Contract applyParameters(Contract thisContract) {
		// Deserialize the JSON string into name-value pairs
		Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
			RestContext.request.requestbody.tostring()
		);
		// Iterate through each parameter field and value
		for (String fieldName : params.keySet()) {
			// Set the field and value on the Contract sObject
			if (fieldName != 'StartDate') {
				thisContract.put(fieldName, params.get(fieldName));
			} else {
				try {
					String dateString = params.get(fieldName).toString();
					Date myDate = Date.parse(dateString);
					thisContract.put(fieldName, myDate);
				} catch (Exception e) {
					throw new ParamException(e.getMessage());
				}
			}
		}
		return thisContract;
	}
}
