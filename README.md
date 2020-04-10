# Feature Flag Designs

This repo shows a few flag design patterns while demonstrating their utility both client and serverside.

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

And moving forward, when Dynamic Forms (or whatever they call it) gets released and component visibility comes down to the field level - having the flexibility of custom permissions governing how a Flexipage's record detail/form is composed will be even more useful.

Imagine a custom permission being toggled that will show the user an entire new suite of fields to data enter - no more binding to page layouts and/or record types!

In the scratch org, navigate to the default `Sales` app and any `Account` record and see the following:

![account-record](/readme-images/account-one.png?raw=true)

Notice that there are two currently configured component visibilities in `Setup` > `Edit Page` :

![account-flexipage](/readme-images/account-two.png?raw=true)

## Apex Utilization

### Feature Flags within the Implementing class

Here we see the lowest complexity which uses `FeatureDecisions` to help aggregate the various permissions a user has access to at runtime.

The code is still routable but as you can see, it's not ideal except for the simplest of use cases.

```java
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
```

### Feature Flags toggling code flow for specific methods

Then next level up is to introduce the concept of Dependency Injection (aka DI or Inversion of Control) for apex methods.

This is still one step away from full DI where the actual `DataService.cls` gets abstracted away but it nets some benefits in that the runtime method called is configurable through custom permissions (in this example) or could also be controlled through custom metadata (not shown).

```java
public with sharing class SomeOtherClass {
    public static final FeatureDecisions featureDecisions = new FeatureDecisions();

    /**
     * This example uses runtime (depndency injected) apex methods but a compiled dependency on the class.
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
        Map<String, Object> args = new Map<String, Object>{ 'recordId' => recordId };
        return (String) service.call(featureDecisions.getLatestFeature(), args);
    }
}
```

### Feature Flags toggling code flow with Injected Service

// TODO

## LWC Utilization

// TODO
