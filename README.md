# mailWithMailCore
In this code i implement SMTP and IMAP with help of mail core lib.(without using pod just drang and drop mailcore code).
Instruction To Use
Build for iOS/OSX

-If you're migrating from MailCore1, you should first clean your build folder.
-Checkout MailCore2 into a directory relative to your project.
-Under the build-mac directory, locate the mailcore2.xcodeproj file, and drag this into your Xcode project.

For Mac 
    - If you're building for Mac, you can either link against MailCore 2 as a framework, or as a static library:
Mac framework
    -Go to Build Phases from your build target, and under 'Link Binary With Libraries', add MailCore.framework and Security.framework.
    -Make sure to use LLVM C++ standard library. Open Build Settings, scroll down to 'C++ Standard Library', and select libc++.
    -In Build Phases, add a Target Dependency of mailcore osx (it's the one with a little toolbox icon).
    -Goto Editor > Add Build Phase > Copy Files.
    -Expand the newly created Build Phase and change it's destination to "Frameworks".
-   Click the + icon and select MailCore.framework.
Mac static library
    -Go to Build Phases from your build target, and under 'Link Binary With Libraries', add libMailCore.a and Security.framework.
    -Set 'Other Linker Flags' under Build Settings: -lctemplate -letpan -lxml2 -lsasl2 -liconv -ltidy -lz -lc++ -stdlib=libc++ -ObjC -lcrypto -lssl -lresolv
    -Make sure to use LLVM C++ standard library. In Build Settings, locate 'C++ Standard Library', and select libc++.

In Build Phases, add a Target Dependency of static mailcore2 osx.

For iOS 
    - If you're targeting iOS, you have to link against MailCore 2 as a static library:
        Add libMailCore-ios.a
        Add CFNetwork.framework
        Add Security.framework
    -Set 'Other Linker Flags': -lctemplate-ios -letpan-ios -lxml2 -lsasl2 -liconv -ltidy -lz -lc++ -lresolv -stdlib=libc++ -ObjC
    -Make sure to use LLVM C++ standard library. Open Build Settings, scroll down to 'C++ Standard Library', and select libc++.
    -In Build Phases, add a Target Dependency of static mailcore2 ios.
