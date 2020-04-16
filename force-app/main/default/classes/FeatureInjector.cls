public abstract class FeatureInjector {
    private static final FeatureDecisions decisions = new FeatureDecisions();

    public static FeatureService getLatestService() {
        return (FeatureService) Type.forName(decisions.getLatestFeatureImplementationClassName()).newInstance();
    }
}
