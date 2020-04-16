public class Injected {
    private static final FeatureService service = FeatureInjector.getLatestService();

    @AuraEnabled
    public static String getData(Id recordId) {
        return service.getData(recordId);
    }
}
