# International Components for Unicode
[ICU](https://icu.unicode.org/) is a mature, widely used set of C/C++ and Java libraries providing Unicode and Globalization support for software applications. ICU is widely portable and gives applications the same results on all platforms and between C/C++ and Java software. ICU is released under a nonrestrictive [open source license](https://www.unicode.org/copyright.html#License) that is suitable for use with both commercial software and with other open source or free software.

The ICU C libraries are [included with Windows](https://learn.microsoft.com/en-us/windows/win32/intl/international-components-for-unicode--icu-#overview) as of the Windows 10 Creators update. They're used by .NET to power a variety of [globalization](https://learn.microsoft.com/en-us/dotnet/core/extensions/globalization-icu) related APIs in a platform-agnostic way.

This library provides *some* bindings for the ICU dlls, allowing callers to work more easily with Unicode strings.

The bindings currently support:
- Character set detection ([`ucsdet.h`](https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html))
- Character set conversion ([`ucnv.h`](https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html))

I'll add more as they become useful to me. The others I'm looking at are the timezone localization APIs.

### Usage

Add this repository to a [library directory](https://www.autohotkey.com/docs/v2/Scripts.htm#lib):
```bash
git clone git@github.com:holy-tao/icu.ahk.git icu
```

Then simply #Include it in a script
```authotkey
#Include <icu\util\CharsetDetector>
```

Consult the individual.ahk files for instructions on use. In general, the pattern with these APIs involes instantiating some object, thus opening a resource, then using it to perform some operations.

#### [Charset Detection](./codepages/CharsetDetector.ahk) and [Charset Conversion](./codepages/conversion/)

The files in the codepages/ namespace allow you to detect and convert between character sets. Originally developed for web browsers to support legacy webpages. You can also use these utilities to discover available character sets on your system and validate existing text.

#### [Boundary Analysis](./boundaryanalysis)

The [`BreakIterator`](./boundaryanalysis/BreakIterator.ahk) class can be used to split strings into logical parts like words, sentences, or [graphemes](https://www.unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries). Read more in the [ICU User Guide](https://unicode-org.github.io/icu/userguide/boundaryanalysis/).

The `BreakIterator` class can be used to iterate such break points, or to split strings into similar groups. One notable use case is splitting a string into graphemes instead of individual characters or code points as described [here](https://github.com/flmnt/graphemer?tab=readme-ov-file#graphemer-unicode-character-splitter-). Using the ICU APIs for this process is roughly an order of magnitude faster than the [`GraphemeSplit`](https://www.autohotkey.com/boards/viewtopic.php?f=83&p=611993) function (see [the benchmark](./tests/benchmarks/graphemesplit.ahk)), which ports the behavior of the afforementioned TypeScript library directly. `BreakIterator` provides a utility method for this.

```autohotkey
; Enumerate the sentences in a paragraph
paragraph := "It was a dark and stormy night <...>"
for sentence in BreakIterator.Enumerate(paragraph, BreakIteratorType.SENTENCE) {
    MsgBox(paragraph)
}
```
```autohotkey
; Split a string into graphemes:
graphemes := BreakIterator.Graphemes("👨‍👨‍👧‍👦") ; => [👨‍👨‍👧‍👦], where StrSplit returns [�, �, �, �, �, �, �, �, �, �, �]
```