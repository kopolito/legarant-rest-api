/**
 * @description       :
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-05-05
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-15   Etienne Knoerr   Initial Version
 **/
@isTest
private class ContactRestTest {
	/*****************************************************************************************
	 *** GET
	 *****************************************************************************************/
	@isTest
	static void testGetContact() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/' + contact.id;
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.getContact();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains(contact.FirstName), 'Bad Name');
		System.assert(testBlob.contains(contact.Id), 'Bad Id');
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetContactList() {
		Contact contactOne = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		Contact contactTwo = TestDataFactory.createContact('ccc', 'ddd', 'ccc@ddd.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.getContact();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.startsWith('[') && testBlob.endsWith(']'), 'Must contain an array');
		System.assert(testBlob.contains(contactOne.Id), 'Must contain contactOne : ' + testBlob);
		System.assert(testBlob.contains(contactTwo.Id), 'Must contain contactTwo');
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetContactWithBadId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/0031x000016W3oqAAD';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.getContact();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Contact not found'), 'Bad response');
		System.assert(testBlob.contains('NOT_FOUND'), 'Bad response');
		System.assertEquals(404, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetContactWithInvalidId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/0031x3oqAAD';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.getContact();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Id is not a valid Id'), 'Bad response');
		System.assert(testBlob.contains('MISSING_PARAM'), 'Bad response');
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
	}

	/*****************************************************************************************
	 *** DELETE
	 *****************************************************************************************/

	@isTest
	static void testDeleteContact() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/' + contact.id;
		request.httpMethod = 'DELETE';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.deleteContact();
		Test.stopTest();
		// Verify results
		List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :contact.Id AND Active__c = TRUE];
		System.assertEquals(0, contacts.size(), 'Contact should be deleted');
		System.assertEquals(204, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testDeleteContactWithBadId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/0031x000016W3oqAAD';
		request.httpMethod = 'DELETE';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.deleteContact();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Contact not found'), 'Bad response');
		System.assert(testBlob.contains('NOT_FOUND'), 'Bad response');
		System.assertEquals(404, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testDeleteContactWithoutId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'DELETE';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.deleteContact();
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
	static void testCreateContact() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "Firstname": "bbb", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('aaa@bbb.com'), 'Bad response');
	}

	@isTest
	static void testCreateContactWithBadParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"Lastame": "aaa", "Firstname": "bbb", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testCreateContactWithBadEmail() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "Firstname": "bbb", "Email": "bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response code');
		System.assert(testBlob.contains('bbb.com'), 'Bad error message');
	}

	@isTest
	static void testCreateContactWithMissingParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "FirstName": "bbb"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('Required fields are missing'), 'Bad response message');
	}

	@isTest
	static void testCreateContactWithNoJSONParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('abcdefgh');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('Params are not in JSON Format'), 'Bad response message');
	}

	@isTest
	static void testCreateContactDuplicate() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "bbb", "Firstname": "ccc", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.createContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains(contact.Id), 'Should contain Id');
	}

	/*****************************************************************************************
	 *** PUT
	 *****************************************************************************************/

	@isTest
	static void testUpsertContact() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "Firstname": "bbb", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.upsertContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('aaa@bbb.com'), 'Bad response');
	}

	@isTest
	static void testUpsertContactWithBadParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"Lastame": "aaa", "Firstname": "bbb", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.upsertContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testUpsertContactWithBadEmail() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "Firstname": "bbb", "Email": "bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.upsertContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response code');
		System.assert(testBlob.contains('bbb.com'), 'Bad error message');
	}

	@isTest
	static void testUpsertContactWithMissingParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "FirstName": "bbb"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.upsertContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('Required fields are missing'), 'Bad response message');
	}

	@isTest
	static void testUpsertContactWithNoJSONParam() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('abcdefgh');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.upsertContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAMS'), 'Bad response code');
		System.assert(testBlob.contains('Params are not in JSON Format'), 'Bad response message');
	}

	@isTest
	static void testUpsertContactDuplicate() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/';
		request.httpMethod = 'POST';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "bbb", "Firstname": "ccc", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.upsertContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains(contact.Id), 'Should contain Id');
	}

	/*****************************************************************************************
	 *** PATCH
	 *****************************************************************************************/

	@isTest
	static void testUpdateContact() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/' + contact.Id;
		request.httpMethod = 'PATCH';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "bbb", "Firstname": "aaa", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.updateContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('aaa@bbb.com'), 'Bad response');
	}

	@isTest
	static void testUpdateContactWithBadParam() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/' + contact.Id;
		request.httpMethod = 'PATCH';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"Lastame": "aaa", "Firstname": "bbb", "Email": "aaa@bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.updateContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response');
	}

	@isTest
	static void testUpdateContactWithBadEmail() {
		Contact contact = TestDataFactory.createContact('aaa', 'bbb', 'aaa@bbb.com');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI = '/contacts/' + contact.Id;
		request.httpMethod = 'PATCH';
		request.headers.put('Content-Type', 'application/json');
		request.requestBody = Blob.valueOf('{"LastName": "aaa", "Firstname": "bbb", "Email": "bbb.com"}');
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ContactRest.updateContact();
		Test.stopTest();
		// Verify results
		System.assertEquals(400, RestContext.response.statusCode, 'Bad status code');
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('BAD_PARAM'), 'Bad response code');
		System.assert(testBlob.contains('bbb.com'), 'Bad error message');
	}
}
