public inherited sharing class DataService implements Callable {
    // Actual methods
    String versionOne(Id recordId) {
        return [SELECT Name FROM Contact WHERE AccountId = :recordId LIMIT 1].Name.toLowerCase();
    }

    String versionTwo(Id recordId) {
        return [SELECT Name FROM Contact WHERE AccountId = :recordId LIMIT 1].Name.toUpperCase();
    }

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_Callable.htm
    public Object call(String action, Map<String, Object> args) {
        switch on action.toLowerCase() {
            when 'feature_one' {
                return this.versionOne((String) args.get('recordId'));
            }
            when 'feature_two' {
                return this.versionTwo((String) args.get('recordId'));
            }
            when else {
                throw new ExtensionMalformedCallException('Method not implemented');
            }
        }
    }

    public class ExtensionMalformedCallException extends Exception {
    }
}
