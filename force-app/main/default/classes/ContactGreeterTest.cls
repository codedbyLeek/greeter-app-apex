@isTest
public class ContactGreeterTest {

    @isTest
    static void testGreet() {
        Contact testContact = new Contact(FirstName = 'Ada', LastName = 'Lovelace');
        insert testContact;

        Test.startTest();
        String result = ContactGreeter.greet(testContact.Id);
        Test.stopTest();

        System.assertEquals('Hello, Ada!', result);
    }
}