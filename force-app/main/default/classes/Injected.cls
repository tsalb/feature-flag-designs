public class Injected {
    private static final FeatureService service = FeatureInjector.getLatestService();

    /**
     * This example uses runtime (dependency injected) service call based logic from the FeatureInjector class
     *
     * Pros: Abstraction is reliant on logic inside `FeatureInjector` and how it allocates what is defined as the "Latest"
     *       service to provide to the currently running user based on `FeatureDecisions` inside the injector class.
     *
     *       This allows for multiple classes, `DefaultImplementation`, `FeatureOneImplementation` etc. which all
     *       implement some variant of `getData()`, based on which feature flag(s) a user has enabled back to the user.
     *
     *       Multiple developers can each work on their own implementations of the same methods allowing for variability of
     *       behavior based on feature flags in the system.
     *
     * Cons: Unit Testing combinations of feature flag to users can be time consuming to test variations if one, two or multiple
     *       custom permissions are enabled on a per user/profile basis.
     *
     *       Additionally, since the `FeatureService` interface guarantees shared functionality across all implementations,
     *       it is a double-edged sword in that if newer implementations have exclusive features that older implementations
     *       would otherwise have no access to.
     *
     *       So then, feature drift can happen across time if:
     *       1) Older implementations aren't deleted once their feature flags are expired.
     *       2) Multiple implementations have to simultaneously exist (i.e. some users on Feature One and some on Feature Two)
     *          but this `Injected` class needs to call additional methods ONLY for those with the newer implementations.
     *
     *          This drift is highlighted in `getDataForFeatureTwo()`.
     *
     */
    @AuraEnabled
    public static String getData(Id recordId) {
        return service.getData(recordId);
    }

    @AuraEnabled
    public static String getDataForFeatureTwo() {
        if (service instanceof FeatureTwoImplementation) {
            FeatureTwoImplementation serviceTwo = (FeatureTwoImplementation) service;
            return serviceTwo.getDataForFeatureTwo();
        } else {
            throw new FeatureAccessException('Running user has no access to FeatureTwoImplementation');
        }
    }

    public class FeatureAccessException extends Exception {
    }
}
