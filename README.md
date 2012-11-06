## RHHorizontalSwipeViewController

A static library for iOS that allows for navigation inside a UIViewController by swiping left and right. 
It supports an arbitrary number of child view controllers as well as custom overlay views that are notified of changes to the underlying controller positions.

Also includes a sample project that allows swipes between 3 main navigations stacks without use of a TabBar etc.
The demo project also shows a floating overlay bar that gives an indication of the current position in swipe stack.

## Installing
For instructions on how to get started using this static library see [Using Static iOS Libraries](http://rheard.com/blog/using-static-ios-libraries/) at [rheard.com](http://rheard.com).

## Licence

Released under the Modified BSD License.
(Attribution Required)
<pre>
RHHorizontalSwipe

Copyright (c) 2012 Richard Heard. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
</pre>

### Pre iOS 5 support

This code all works on and has been tested on at-least 4.3, however there is no official support for UIViewController containment pre iOS5.

This means that there is some unusual behaviour when presenting modal views / popovers using the default [self presentModalViewController:animated:]
To work around this you must say [appDelegate.layoutScrollViewController presentModalViewController:animated:]
Comments to this effect are in place in the code.

