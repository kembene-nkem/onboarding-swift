import FormManager
import UIKit
import Core

/// An onboarding component that is responsible for beginning the onboarding process
/// There are different ways this could be done, but we are working with the assumption that this onboarding component is
/// self contained. It's it knows about what data it needs to collect. However it goes a step further by providing an avenue
/// for client applications to intercept and do other things along the way.
/// Things like add a field to the fields this component already processes
public class OnBoardingComponentProvider {
    let formManager: FormManager
    let resourceLoader: OnboardingComponentResourceLoader
    public init(formManager: FormManager, resourceLoader: OnboardingComponentResourceLoader) {
        self.formManager = formManager
        self.resourceLoader = resourceLoader
    }
    
    public func beginOnBoardingFlow(navigationController: UIViewController, formsToRender: [DataCategory]? = nil, delegate: FormDelegate? = nil, onDataCollected: ValueChangeCallback<OnBoardingCollectedData>? = nil){
        let renderItems = formsToRender ?? DataCategory.allCases
        let model = OnboardingFlowViewModel(formManager: formManager, formsToRender: renderItems)
        model.formDelegate = delegate
        model.resources = resourceLoader.resources
        model.resourceLoader = resourceLoader
        model.theme = resourceLoader
        model.configuration = resourceLoader.configuration
        model.afterCollectionCallback = onDataCollected
        model.gotoNextForm(currentViewController: navigationController)
    }
}
