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
}
