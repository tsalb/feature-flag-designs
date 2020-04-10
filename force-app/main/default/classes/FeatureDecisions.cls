/**
 * Maintaining one giant list of feature flags shared between all developers
 * makes it easier to maintain, but harder to merge commits
 *
 * Alternatively, public class scoped to each app namespace would work as well,
 * however implementing classes may need to load more than one kind of FeatureDecisions class.
 */
public class FeatureDecisions {
    public Boolean hasFeatureOne() {
        return FeatureManagement.checkPermission('Feature_One');
    }

    public Boolean hasFeatureTwo() {
        return FeatureManagement.checkPermission('Feature_Two');
    }

    public String getLatestFeature() {
        if (this.hasFeatureTwo()) {
            return 'Feature_Two';
        } else if (this.hasFeatureOne()) {
            return 'Feature_One';
        } else {
            return null;
        }
    }
}
