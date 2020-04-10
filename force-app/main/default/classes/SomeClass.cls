public with sharing class SomeClass {
    public static final FeatureDecisions featureDecisions = new FeatureDecisions();

    /**
     * This example uses a runtime compiled list of feature flags against the current running user
     * and then uses configuration properties against the FeatureDecisions class to delegate feature gates
     *
     * Pros: Easy to implement and read. Avoid using strings in the config itself to determine code path.
     *       Best for small features that need just simple routing and not the entire class logic configured.
     *
     * Cons: Hard to maintain in long run if deprecation of unused flags is not properly maintained.
     *       Proliferation of if conditions can wreak havoc if multiple developers need to commit to the same file.
     *
     */
    @AuraEnabled
    public static String getDataSimple() {
        String message = 'User Has: ';

        if (featureDecisions.hasFeatureOne()) {
            message += 'Feature One ';
        }
        if (featureDecisions.hasFeatureTwo()) {
            message += 'Feature Two ';
        }
        return message;
    }
}
