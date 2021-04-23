/**
 * @description       :
 * @author            : Etienne Knoerr
 * @group             :
 * @last modified on  : 2021-04-23
 * @last modified by  : Etienne Knoerr
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2021-04-23   Etienne Knoerr   Initial Version
 **/
@isTest
private class ProductRestTest {
	/*****************************************************************************************
	 *** GET
	 *****************************************************************************************/
	@isTest
	static void testGetProduct2() {
		Product2 product2 = TestDataFactory.createProduct('aaa');
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri =
			'https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Product2s/' + product2.id;
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ProductRest.getProduct2ById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains(product2.Name), 'Bad Name');
		System.assert(testBlob.contains(product2.Id), 'Bad Id');
		System.assertEquals(200, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetProduct2WithoutId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Product2s/';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ProductRest.getProduct2ById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Id is not a valid Id'), 'Bad response');
		System.assert(testBlob.contains('MISSING_PARAM'), 'Bad response');
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetProduct2WithBadId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Product2s/01t1x00000CQS6VAAY';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ProductRest.getProduct2ById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Product2 not found'), 'Bad response');
		System.assert(testBlob.contains('NOT_FOUND'), 'Bad response');
		System.assertEquals(404, RestContext.response.statusCode, 'Bad response code');
	}

	@isTest
	static void testGetProduct2WithInvalidId() {
		// Set up a test request
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = 'https://customer-agility-8073-dev-ed.lightning.force.com/services/apexrest/Product2s/0031x3oqAAD';
		request.httpMethod = 'GET';
		RestContext.request = request;
		RestContext.response = res;
		// Call the method to test
		Test.startTest();
		ProductRest.getProduct2ById();
		Test.stopTest();
		// Verify results
		String testBlob = res.responseBody.toString();
		System.assert(testBlob.contains('Id is not a valid Id'), 'Bad response');
		System.assert(testBlob.contains('MISSING_PARAM'), 'Bad response');
		System.assertEquals(400, RestContext.response.statusCode, 'Bad response code');
	}
}
