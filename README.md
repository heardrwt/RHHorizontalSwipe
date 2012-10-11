## RHHorizontalSwipeViewController

A static library for iOS that allows for navigation inside a UIViewController by swiping left and right. 
It supports an arbitrary number of child view controllers as well as custom overlay views that are notified of changes to the underlying controller positions.

Also includes a sample project that allows swipes between 3 main navigations stacks without use of a TabBar etc.
The demo project also shows a floating overlay bar that gives an indication of the current position in swipe stack.


## Licence

Released under the Modified BSD License.


### Pre iOS 5 support

This code all works on and has been tested on at-least 4.3, however there is no official support for UIViewController containment pre iOS5.

This means that there is some unusual behaviour when presenting modal views / popovers using the default [self presentModalViewController:animated:]
To work around this you must say [appDelegate.layoutScrollViewController presentModalViewController:animated:]
Comments to this effect are in place in the code.

