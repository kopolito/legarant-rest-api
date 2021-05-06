/**
 * @description       :
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-05-06
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-22   Etienne Knoerr   Initial Version
 **/
@isTest
private class AccountRestTest {
	/*****************************************************************************************
	 *** GET
	 *****************************************************************************************/
	@isTest
	static void testGetAccount() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/' + account.id;
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.getAccount();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains(account.Name), 'Bad Name');
		System.assert(testBlob.contains(account.Id), 'Bad Id');
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetAccountList() {
		Account accountOne = TestDataFactory.createAccount('aaa');
		Account accountTwo = TestDataFactory.createAccount('bbb');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.getAccount();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.startsWith('[') && testBlob.endsWith(']'), 'Must contain an array');
		System.assert(testBlob.contains(accountOne.Id), 'Must contain accountOne : ' + testBlob);
		System.assert(testBlob.contains(accountTwo.Id), 'Must contain accountTwo');
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetAccountWithBadId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/0011X00000oWB9TQAB';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.getAccount();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Account not found'), 'Bad response');
		System.assert(testBlob.contains('NOT_FOUND'), 'Bad response');
		System.assertEquals(404, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetAccountWithInvalidId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/0031x3oqAAD';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.getAccount();
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
	static void testCreateAccount() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody = '{"Name": "aaa"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.createAccount();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('"type":"Account"'), 'Bad response type');
		System.assert(testBlob.contains('aaa'), 'Bad account Name');
	}

	@isTest
	static void testCreateAccountWithBadParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody = '{"Name": ""}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.createAccount();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testCreateAccountWithMissingParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody = '{}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.createAccount();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('Name'), 'Bad error message');
	}

	@isTest
	static void testCreateAccountWithNoJSONParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('abcdefgh');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.createAccount();
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
	static void testUpsertAccount() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'PUT';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody = '{"Name": "aaa"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.upsertAccount();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('"type":"Account"'), 'Bad response type');
		System.assert(testBlob.contains('aaa'), 'Bad account name');
	}

	@isTest
	static void testUpsertAccountWithExistingAccount() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'PUT';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"Id":"' +
			account.Id +
			'", "Name": "bbb"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.upsertAccount();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('"type":"Account"'), 'Bad response type');
		System.assert(testBlob.contains('bbb'), 'Bad account name');
		System.assert(testBlob.contains(account.id), 'Bad account id');
	}

	@isTest
	static void testUpsertAccountWithBadParam() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"AccountId": "' +
			account.id +
			'","Name": ""}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.upsertAccount();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testUpsertAccountWithMissingParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody = '{}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.upsertAccount();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('Name'), 'Bad error message');
	}

	@isTest
	static void testUpsertAccountWithNoJSONParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('abcdefgh');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.upsertAccount();
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
	static void testUpdateAccount() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/' + account.Id;
		request.httpMethod = 'PATCH';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"Id": "' +
			account.id +
			'","Name": "bbb"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.updateAccount();
		Test.stopTest();
		// Verify results
		//System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('"type":"Account"'), 'Bad response type : ' + testBlob);
		System.assert(testBlob.contains('bbb'), 'Bad account name');
		System.assert(testBlob.contains(account.id), 'Bad account id');
	}

	@isTest
	static void testUpdateAccountWithBadParam() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/' + account.Id;
		request.httpMethod = 'PATCH';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"AccountId": "' +
			account.id +
			'","Name": "bbb"}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.updateAccount();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testUpdateAccountWithMissingParam() {
		Account account = TestDataFactory.createAccount('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/accounts/' + account.Id;
		request.httpMethod = 'PATCH';
		request.headers.put('Content-Type', 'application/json');
		String jsonBody =
			'{"Id": "' +
			account.id +
			'","Name": ""}';
		request.requestBody = Blob.valueOf(jsonBody);
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		AccountRest.updateAccount();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}
}
