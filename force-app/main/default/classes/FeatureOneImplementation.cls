public class FeatureOneImplementation implements FeatureService {
    // Same as DataService.call('feature_one')
    public String getData(Id recordId) {
        return [SELECT Name FROM Contact WHERE AccountId = :recordId LIMIT 1].Name.toLowerCase();
    }
}
