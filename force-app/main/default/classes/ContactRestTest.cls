/**
 * @description       : 
 * @author            : Etienne Knoerr
 * @group             : 
 * @last modified on  : 2021-04-15
 * @last modified by  : Etienne Knoerr
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   2021-04-15   Etienne Knoerr   Initial Version
**/
@isTest
private class ContactRestTest {
  @TestSetup
  static void makeData() {
    /*for (Integer i = 0; i < 5; i++) {
			TestDataFactory.createAccount('testAccount_' + i);
		}*/
  }
  /* POSITIVE */
  @isTest
  private static void testGetContactById() {
  }
  /* NEGATIVE */
  @isTest
  private static void testGetContactById_whenNoIdGiven() {
  }
  /* NEGATIVE */
  @isTest
  private static void testGetContactById_whenContactNotFound() {
  }
}
