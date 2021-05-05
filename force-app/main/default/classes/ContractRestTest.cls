/**
 * @description       :
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-05-05
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-22   Etienne Knoerr   Initial Version
 **/
@isTest
private class ContractRestTest {
	/*****************************************************************************************
	 *** GET
	 *****************************************************************************************/
	@isTest
	static void testGetContract() {
		Account account = TestDataFactory.createAccount('aaa');
		Contract contract = TestDataFactory.createContractForAccount(account);
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/' + contract.id;
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.getContract();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains(account.id), 'Bad Account Id');
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetContractList() {
		Account account = TestDataFactory.createAccount('aaa');
		Contract contractOne = TestDataFactory.createContractForAccount(account);
		Contract contractTwo = TestDataFactory.createContractForAccount(account);
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.getContract();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.startsWith('[') && testBlob.endsWith(']'), 'Must contain an array');
		System.assert(testBlob.contains(contractOne.Id), 'Must contain contractOne : ' + testBlob);
		System.assert(testBlob.contains(contractTwo.Id), 'Must contain contractTwo');
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetContractWithInvalidId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/0031x3oqAAD';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.getContract();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Id is not a valid Id'), 'Bad response');
		System.assert(testBlob.contains('MISSING_PARAM'), 'Bad response');
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
	}

	/*****************************************************************************************
	 *** POST
	 *****************************************************************************************/

	@isTest
	static void testCreateContract() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"AccountId": "' +
			account.id +
			'","ContractTerm": 12,"StartDate": "01/04/2021","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.createContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('"type":"Contract"'), 'Bad response type');
		System.assert(testBlob.contains(account.id), 'Bad account id');
	}

	@isTest
	static void testCreateContractWithBadParam() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"AccountId": "' +
			account.id +
			'","ContractTerm": 12,"StartDate": "12345","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.createContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testCreateContractWithMissingParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody = '{"ContractTerm": 12,"StartDate": "01/04/2021","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.createContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('AccountId'), 'Bad error message');
	}

	@isTest
	static void testCreateContractWithNoJSONParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('abcdefgh');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.createContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('Params are not in JSON Format'), 'Bad response message');
	}

	/*****************************************************************************************
	 *** PUT
	 *****************************************************************************************/

	@isTest
	static void testUpsertContract() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'PUT';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"AccountId": "' +
			account.id +
			'","ContractTerm": 12,"StartDate": "01/04/2021","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.upsertContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('"type":"Contract"'), 'Bad response type');
		System.assert(testBlob.contains(account.id), 'Bad account id');
	}

	@isTest
	static void testUpsertContractWithExistingContract() {
		Account account = TestDataFactory.createAccount('aaa');
		Contract contract = TestDataFactory.createContractForAccount(account);
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'PUT';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"Id":"' +
			contract.Id +
			'", "AccountId": "' +
			account.id +
			'","ContractTerm": 12,"StartDate": "01/04/2021","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.upsertContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('"type":"Contract"'), 'Bad response type');
		System.assert(testBlob.contains('"ContractTerm":12'), 'ContractTerm should be 12');
	}

	@isTest
	static void testUpsertContractWithBadParam() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"AccountId": "' +
			account.id +
			'","ContractTerm": 12,"StartDate": "12345","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.upsertContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testUpsertContractWithMissingParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody = '{"ContractTerm": 12,"StartDate": "01/04/2021","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.upsertContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('AccountId'), 'Bad error message');
	}

	@isTest
	static void testUpsertContractWithNoJSONParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('abcdefgh');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.upsertContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('Params are not in JSON Format'), 'Bad response message');
	}

	/*****************************************************************************************
	 *** PATCH
	 *****************************************************************************************/

	@isTest
	static void testUpdateContract() {
		Account account = TestDataFactory.createAccount('aaa');
		Contract contract = TestDataFactory.createContractForAccount(account);
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/' + contract.Id;
		request.httpMethod = 'PATCH';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"AccountId": "' +
			account.id +
			'","ContractTerm": 12,"StartDate": "01/04/2021","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.updateContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('"type":"Contract"'), 'Bad response type');
		System.assert(testBlob.contains('"ContractTerm":12'), 'ContractTerm should be 12');
	}

	@isTest
	static void testUpdateContractWithBadDate() {
		Account account = TestDataFactory.createAccount('aaa');
		Contract contract = TestDataFactory.createContractForAccount(account);
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/' + contract.Id;
		request.httpMethod = 'PATCH';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"AccountId": "' +
			account.id +
			'","ContractTerm": 12,"StartDate": "1234","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.updateContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testUpdateContractWithBadParam() {
		Account account = TestDataFactory.createAccount('aaa');
		Contract contract = TestDataFactory.createContractForAccount(account);
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contracts/' + contract.Id;
		request.httpMethod = 'PATCH';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"AccountId": "' +
			account.id +
			'","ContractTerm": 0,"StartDate": "01/04/2021","Status": "Draft"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContractRest.updateContract();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}
}
