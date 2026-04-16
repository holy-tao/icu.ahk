#Requires AutoHotkey v2.0

#Include ./YUnit/YUnit.ahk
#Include ./YUnit/ResultCounter.ahk
#Include ./YUnit/JUnit.ahk
#Include ./YUnit/Stdout.ahk

#Include ICUError.test.ahk
#Include ICUEnumerator.test.ahk
#Include CharsetDetector.test.ahk
#Include CharsetConverter.test.ahk
#Include BreakIterator.test.ahk
#Include CharsetConverterSelector.test.ahk
#Include UNormalizer2.test.ahk

YUnit.Use(YunitResultCounter, YUnitJUnit, YUnitStdOut).Test(
	ICUErrorTests,
	ICUEnumeratorTests,
	CharsetDetectorTests,
	CharsetConverterTests,
	BreakIteratorTests,
	CharsetConverterSelectorTests,
	UNormalizer2Tests
)

Exit(-YunitResultCounter.failures)