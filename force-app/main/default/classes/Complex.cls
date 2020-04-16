public with sharing class Complex {
    public static final FeatureDecisions featureDecisions = new FeatureDecisions();

    /**
     * This example uses runtime (dependency injected) apex methods but a compiled dependency on the class.
     *
     * Pros: Easy to implement and read. Abstracts away minor-medium changing implementation to the Callable class
     *       Best for small-medium features that need just method routing and not the entire class re-configured.
     *       Suitable for a multiple developers making changes to this class, but merge conflicts can arise on DataService.cls
     *
     * Cons: This class is still dependent on a version of a method inside DataService.cls
     *       DataService.cls has statically typed out methods and could lead to tech debt it not pruned over time.
     *
     */
    @AuraEnabled
    public static String getDataComplex(Id recordId) {
        DataService service = new DataService();
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_System_Callable.htm
        Map<String, Object> args = new Map<String, Object>{ 'recordId' => recordId };
        return (String) service.call(featureDecisions.getLatestFeature(), args);
    }
}
