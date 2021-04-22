/**
 * @description       :
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-04-22
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-22   Etienne Knoerr   Initial Version
 **/
@isTest
private class ContractRestTest {
	@isTest
	static void testGetContract() {
		Account account = TestDataFactory.createAccount('aaa');
		Contract contract = TestDataFactory.createContractForAccount(account);
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri =
			'https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contracts/' + contract.id;
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.getContractById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains(account.id), 'Bad Account Id');
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetContractWithoutId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contracts/';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.getContractById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Id is not a valid Id'), 'Bad response');
		System.assert(testBlob.contains('MISSING_PARAM'), 'Bad response');
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetContractWithInvalidId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Contracts/0031x3oqAAD';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.getContractById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Id is not a valid Id'), 'Bad response');
		System.assert(testBlob.contains('MISSING_PARAM'), 'Bad response');
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
	}
}
