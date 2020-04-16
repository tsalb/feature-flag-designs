public class FeatureTwoImplementation implements FeatureService {
    // Same as DataService.call('feature_two')
    public String getData(Id recordId) {
        return [SELECT Name FROM Contact WHERE AccountId = :recordId LIMIT 1].Name.toUpperCase();
    }
}
