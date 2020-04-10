public with sharing class SomeOtherClass {
    public static final FeatureDecisions featureDecisions = new FeatureDecisions();

    @AuraEnabled
    public static String getDataComplex(Id recordId) {
        DataService service = new DataService();
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_Callable.htm
        Map<String, Object> args = new Map<String, Object>{ 'recordId' => recordId };
        return (String) service.call(featureDecisions.getLatestFeature(), args);
    }
}
