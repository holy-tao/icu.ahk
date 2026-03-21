#Include YUnit\Assert.ahk
#Include ..\util\CharsetDetector.ahk

class CharsetDetectorTests {

    class Detection {
        Detect_WithStringBuffer_ReturnsMatch() {
            ; UTF-8 with this string should be ASCII, which ought to match a bunch of encodings. Specifics will vary by 
            ; system, but should be a safe assumption
            str := "Hello, World!"
            encoding := "UTF-8"

            fullLen := StrPut(str, encoding)
            buf := Buffer(fullLen)
            StrPut(str, buf, encoding)

            detector := CharsetDetector(buf)
            match := detector.Detect()

            Assert.IsType(match, CharsetDetector.Match)
            FileAppend(String(match) "`n", "*")
        }

        Detect_WithAhkString_ReturnsMatch() {
            detector := CharsetDetector()
            detector.SetText("Hello, World!")
            match := detector.Detect()

            Assert.IsType(match, CharsetDetector.Match)
            FileAppend(String(match) "`n", "*")
        }
                
        Detect_WithPointer_ReturnsMatch() {
            detector := CharsetDetector()
            detector.SetText(StrPtr("Hello, World!"))
            match := detector.Detect()

            Assert.IsType(match, CharsetDetector.Match)
            FileAppend(String(match) "`n", "*")
        }

        Detect_WithNoString_ThrowsICUError() {
            Assert.Throws(() => CharsetDetector().Detect(), ICUError)
        }

        DetectAll_WithStringBuffer_GetsMultipleMatches() {
            ; UTF-8 with this string should be ASCII, which ought to match a bunch of encodings. Specifics will vary by 
            ; system, but should be a safe assumption
            str := "Hello, World!"
            encoding := "UTF-8"

            fullLen := StrPut(str, encoding)
            buf := Buffer(fullLen)
            StrPut(str, buf, encoding)

            detector := CharsetDetector(buf)
            matches := detector.DetectAll()

            Assert.Truthy(matches.Length >= 1)

            maxConfidence := 101
            for match in matches {
                Assert.IsType(match, CharsetDetector.Match)
                FileAppend(String(match) "`n", "*")

                ; Assert that we preserve the order that ICU gives to us
                Assert.Truthy(match.Confidence <= maxConfidence)
                maxConfidence := match.Confidence
            }
        }

        DetectAll_WithAhkString_ReturnsMatch() {
            detector := CharsetDetector()
            detector.SetText("Hello, World!")
            matches := detector.DetectAll()

            Assert.Truthy(matches.Length >= 1)

            maxConfidence := 101
            for match in matches {
                Assert.IsType(match, CharsetDetector.Match)
                FileAppend(String(match) "`n", "*")

                ; Assert that we preserve the order that ICU gives to us
                Assert.Truthy(match.Confidence <= maxConfidence)
                maxConfidence := match.Confidence
            }
        }
                
        DetectAll_WithPointer_ReturnsMatch() {
            detector := CharsetDetector()
            detector.SetText(StrPtr("Hello, World!"))
            matches := detector.DetectAll()

            Assert.Truthy(matches.Length >= 1)

            maxConfidence := 101
            for match in matches {
                Assert.IsType(match, CharsetDetector.Match)
                FileAppend(String(match) "`n", "*")

                ; Assert that we preserve the order that ICU gives to us
                Assert.Truthy(match.Confidence <= maxConfidence)
                maxConfidence := match.Confidence
            }
        }

        DetectAll_WithNoString_ThrowsICUError() {
            Assert.Throws(() => CharsetDetector().DetectAll(), ICUError)
        }
    }

    GetAllDetectableCharsets_ReturnsListOfCharsets() {
        detector := CharsetDetector()

        setEnumerator := detector.GetAllDetectableCharsets()

        Assert.IsType(setEnumerator, ICUEnumerator)
        for str in setEnumerator {
            Assert.IsType(str, String)

            FileAppend(str "`n", "*")

            Assert.Truthy(!IsSpace(str))
        }
    }

    FilterMarkup_GetSet_GetAndSetFilterMarkup() {
        detector := CharsetDetector()

        detector.FilterMarkup := true
        Assert.Equals(detector.FilterMarkup, 1)

        detector.FilterMarkup := false
        Assert.Equals(detector.FilterMarkup, 0)
        
        detector.FilterMarkup := true
        Assert.Equals(detector.FilterMarkup, 1)
    }
}