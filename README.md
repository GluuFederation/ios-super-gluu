# Super Gluu

## Basics

AuthHelper

## Helpers

Initialize View Controllers Easier

`let viewController = LandingViewController.fromStoryboard("Authentication")`

Initialize View

`let loadingView: LoadingView = .fromNib()`

Show Error Message

`SwiftMessages.show(.error, message: loginValidationError)`

Display Alert/Error Messages 

Use `SwiftMessages+ApartmentButler`

Use ObjectMapper, PromiseKit, and Alamofire together.

```
Alamofire.request(AuthorizationRouter.signIn(user)).responseModel(AuthenticationResponse.self).then { loginResponse -> Void in

  // Handle the model response here
  
}.always {

  // Remove loading here
  
}.catch { error in

  // Handle errors here
  
}
```


## Styles

Colors `UIColor+ApartmentButler`

Font `UIFont+ApartmentButler`



## Dependencies
[BonMot](https://github.com/Raizlabs/BonMot)

BonMot (pronounced Bon Mo, French for good word) is a Swift attributed string library. It abstracts away the complexities of the iOS, macOS, tvOS, and watchOS typography tools, freeing you to focus on making your text beautiful.

[StatefulViewController](https://github.com/aschuch/StatefulViewController)

A protocol to enable UIViewControllers or UIViews to present placeholder views based on content, loading, error or empty states.

[Alamofire](https://github.com/Alamofire/Alamofire)

Alamofire is an HTTP networking library written in Swift.

[AlamofireImage](https://github.com/Alamofire/AlamofireImage)

AlamofireImage is an image component library for Alamofire.

[AlamofireImage](https://github.com/Alamofire/AlamofireImage)

AlamofireImage is an image component library for Alamofire.

[PromiseKit](https://github.com/mxcl/PromiseKit)

Promises simplify asynchronous programming, freeing you up to focus on the more important things. They are easy to learn, easy to master and result in clearer, more readable code. Your co-workers will thank you.

[PromiseKit](https://github.com/mxcl/PromiseKit)

Promises simplify asynchronous programming, freeing you up to focus on the more important things. They are easy to learn, easy to master and result in clearer, more readable code. Your co-workers will thank you.

[ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)

ObjectMapper is a framework written in Swift that makes it easy for you to convert your model objects (classes and structs) to and from JSON.

[AlamofireObjectMapper](https://github.com/tristanhimmelman/AlamofireObjectMapper)

An Alamofire extension which converts JSON response data into swift objects using ObjectMapper

[SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages)

A very flexible message bar for iOS written in Swift.

[KeyboardHelper](https://github.com/nodes-ios/KeyboardHelper)

A small (but cool) tool for handling UIKeyboard appearing and disappearing in your view controllers.

[SwiftDate](https://github.com/malcommac/SwiftDate)

We really ♥ Swift and we think that dates and timezones management should be painless: this is the reason we made SwiftDate, probably the best way to manage date and time in Swift.
