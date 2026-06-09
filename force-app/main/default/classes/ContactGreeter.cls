public class ContactGreeter {

    public static String greet(Id contactId) {
        Contact c = [SELECT FirstName FROM Contact WHERE Id = :contactId Limit 1];
        return 'Hello, ' + c.FirstName + '!';
    }

}