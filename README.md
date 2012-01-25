## LeftMiddleRight

Sample project that explores creating an application that allows swipes between 3 main navigations stacks without use of a TabBar etc.


## Licence

Released under the Modified BSD License


### Pre iOS 5 support

This code all works on and has been tested on atleast 4.3, however there is no official support for UIViewCOntroller containment pre iOS5.

This means that there is some unusual behavior when presenting modal views / popovers using the default [self presentModalViewController:animated:]
To work around this you must say [appDelegate.layoutScrollViewController presentModalViewController:animated:]
Comments to this effect are in place in the code.

