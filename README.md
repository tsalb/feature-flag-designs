# Feature Flag Designs

This repo highlights different design patterns to tackle feature flags using Custom Permissions in both the UI and Apex.

## Useful Publications

This repo distills strategies and design patterns found in:

-   Martin Fowler's [Feature Toggle](https://martinfowler.com/articles/feature-toggles.html) article.
-   Philippe Ozil's [Dependency Injection SFDC Dev Blog](https://developer.salesforce.com/blogs/2019/07/breaking-runtime-dependencies-with-dependency-injection.html) and his accompanying [sample code repo](https://github.com/pozil/apex-dependency-injection).

## Install with SFDX

For VSCode and SFDX setup see steps (1 and 2) from the [official lwc-recipes repo](https://github.com/trailheadapps/lwc-recipes#installing-recipes-using-salesforce-dx). Once you have the SFDX CLI set up and Authed into a Dev Hub you can then:

1. Clone this repo to a desired directory.

```
git clone https://github.com/tsalb/feature-flag-designs
```

2. Open VSCode (with a Dev Hub already connected), and open the `feature-flag-designs` folder.

3. Use [Command Palette](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette) to `SFDX: Create a Default Scratch Org` .

4. Use Command Palette to `SFDX: Push Source to Default Scratch Org`.

5. Use Command Palette to `SFDX: Open Default Org`.

## Custom Metadata or Custom Permission?

Custom metadata cannot be exposed to the flexipage, so leveraging those are more fitting for server-side only toggling as shown in pozil's sample repo [here](https://github.com/pozil/apex-dependency-injection/blob/290eacd69b4e8e11634cc7cb86479c8a61d8cf5f/src/main/default/classes/ShippingInjector.cls#L69). It's possible to combine both for increased cognitive complexity but also improved maintainability since separation of concerns is more dynamic.

If there is a large feature that needs both UI and apex toggles, then marrying them to one to a custom permission makes sense unless there is some level of dynamic logic happening regardless of permissiveness / accessibility to a UI gate or functional gate.

In short, Custom Metadata applies better for global dynamic logic whereas Custom Perms scoped to profile/user.

## Sample Custom Permissions

Custom permissions are assigned by default as follows:

Profile - **System Admin**

-   `Feature_One`

Permission Set - **Feature Two**

-   `Feature_Two`

**To configure how the `apexCaller` component behaves placed on the Account Flexipage, add or remove the permissions from your user/profile.**

## Flexipage Utilization

Component visibility in general is an easy way to configure the dynamic visibility of your apps based on various attributes:

-   Record Data Values
-   Device
-   Current User's attributes (Profile, etc)
-   Custom Permissions

And moving forward, when Dynamic Forms gets GA-ed and the flexipage's [component visibility](https://help.salesforce.com/articleView?id=lightning_page_components_visibility.htm&type=5) comes down to the field level - having the flexibility of custom permissions governing how a record detail/form is composed will be even more useful.

Imagine a custom permission being toggled that will show the user an entire new suite of fields to data enter - no more binding to page layouts and/or record types!

In the scratch org, navigate to the default `Sales` app and any `Account` record and see the following:

![account-record](/readme-images/account-one.png?raw=true)

Notice that there are two currently configured component visibilities in `Setup` > `Edit Page` :

![account-flexipage](/readme-images/account-two.png?raw=true)

## Apex Utilization

### Feature Flags within the Implementing class

Here we see the lowest complexity which uses `FeatureDecisions` to help aggregate the various permissions a user has access to at runtime.

The code is still route-able but as you can see, it's not ideal except for the simplest of use cases.

```java
public class Simple {
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
```

### Feature Flags toggling code flow for specific methods

Then next level up is to introduce the concept of Dependency Injection (aka DI or Inversion of Control) for apex methods.

This is still one step away from full DI where the actual `DataService.cls` gets abstracted away but it nets some benefits in that the runtime method called is configurable through custom permissions (in this example) or could also be controlled through custom metadata (not shown).

```java
public class Complex {
    public static final FeatureDecisions featureDecisions = new FeatureDecisions();

    /**
     * This example uses runtime (dependency injected) apex methods but a compiled dependency on the class.
     *
     * Pros: Easy to implement and read. Abstracts away minor-medium changing implementation to the Callable class
     *       Best for small-medium features that need just method routing and not the entire class re-configured.
     *       Suitable for a multiple developers making changes to this class, but merge conflicts can arise on `DataService`
     *
     * Cons: This class is still dependent on a version of a method inside `DataService`
     *       `DataService` has statically typed out methods and could lead to tech debt it not pruned over time.
     *
     */
    @AuraEnabled
    public static String getDataComplex(Id recordId) {
        DataService service = new DataService();
        Map<String, Object> args = new Map<String, Object>{ 'recordId' => recordId };
        return (String) service.call(featureDecisions.getLatestFeature(), args);
    }
}
```

### Feature Flags toggling code flow with Injected Service

This example now uses DI with the `FeatureService` interface and the `FeatureInjector` class coupled with `FeatureDecisions.getLatestFeatureImplementationClassName()` to dynamically instantiate one of many implementations of a `service` which can provide data to the running user.

```java
public class Injected {
    private static final FeatureService service = FeatureInjector.getLatestService();

    /**
     * This example uses runtime (dependency injected) service call based logic from the `FeatureInjector` class
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

```

## LWC Utilization

// TODO
