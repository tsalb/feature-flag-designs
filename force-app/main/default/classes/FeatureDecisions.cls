/**
 * Maintaining one giant list of feature flags shared between all developers
 * makes it easier to maintain, but harder to merge commits
 *
 * Alternatively, public class scoped to each app namespace would work as well,
 * however implementing classes may need to load more than one kind of FeatureDecisions class.
 */
public class FeatureDecisions {
    // Avoid using strings
    public Boolean hasFeatureOne() {
        return FeatureManagement.checkPermission('Feature_One');
    }

    public Boolean hasFeatureTwo() {
        return FeatureManagement.checkPermission('Feature_Two');
    }

    // This can be replaced with custom metadata for the latest global feature unless
    public String getLatestFeature() {
        if (this.hasFeatureTwo()) {
            return 'Feature_Two';
        } else if (this.hasFeatureOne()) {
            return 'Feature_One';
        } else {
            return null;
        }
    }

    // This can be replaced with custom metadata mapping a feature flag to the correct class to return
    public String getLatestFeatureImplementationClassName() {
        switch on this.getLatestFeature() {
            when 'Feature_One' {
                return 'FeatureOneImplementation';
            }
            when 'Feature_Two' {
                return 'FeatureTwoImplementation';
            }
            when else {
                return 'DefaultImplementation';
            }
        }
    }
}
