# International Components for Unicode
[ICU](https://icu.unicode.org/) is a mature, widely used set of C/C++ and Java libraries providing Unicode and Globalization support for software applications. ICU is widely portable and gives applications the same results on all platforms and between C/C++ and Java software. ICU is released under a nonrestrictive [open source license](https://www.unicode.org/copyright.html#License) that is suitable for use with both commercial software and with other open source or free software.

The ICU C libraries are [included with Windows](https://learn.microsoft.com/en-us/windows/win32/intl/international-components-for-unicode--icu-#overview) as of the Windows 10 Creators update. They're used by .NET to power a variety of [globalization](https://learn.microsoft.com/en-us/dotnet/core/extensions/globalization-icu) related APIs in a platform-agnostic way.

This library provides *some* bindings for the ICU dlls, allowing callers to work more easily with Unicode strings.

### Usage

Add this repository to a [library directory](https://www.autohotkey.com/docs/v2/Scripts.htm#lib):
```bash
git clone git@github.com:holy-tao/icu.ahk.git icu
```

Then simply #Include it in a script
```authotkey
#Include <icu\util\CharsetDetector>
```