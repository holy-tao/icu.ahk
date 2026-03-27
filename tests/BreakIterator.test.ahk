#Include YUnit\Assert.ahk
#Include ../boundaryanalysis/BreakIterator.ahk
#Include ../boundaryanalysis/WordBreak.ahk

class BreakIteratorTests {

    class Availability {
        CountAvailable_ReturnsPositiveCount() {
            Assert.Truthy(BreakIterator.CountAvailable() > 0)
        }

        GetAvailable_WithIndex0_ReturnsLocaleString() {
            name := BreakIterator.GetAvailable(0)
            Assert.IsType(name, String)
            Assert.Truthy(!IsSpace(name))
        }
    }

    class Open {
        Open_WordType_ReturnsBreakIterator() {
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en")
            Assert.IsType(bi, BreakIterator)
        }

        Open_CharacterType_ReturnsBreakIterator() {
            bi := BreakIterator.Open(BreakIteratorType.CHARACTER, "en")
            Assert.IsType(bi, BreakIterator)
        }
    }

    class OpenRules {
        OpenRules_WithSimpleRules_ReturnsBreakIterator() {
            ; Minimal rule: break everywhere (each character is a boundary)
            bi := BreakIterator.OpenRules(".", -1)
            Assert.IsType(bi, BreakIterator)
        }
    }

    class BinaryRules {
        GetBinaryRules_Preflight_ReturnsPositiveLength() {
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en")
            len := bi.GetBinaryRules(0, 0)
            Assert.Truthy(len > 0)
        }

        GetBinaryRules_WithBuffer_FillsBuffer() {
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en")
            len := bi.GetBinaryRules(0, 0)
            buf := Buffer(len, 0)
            len2 := bi.GetBinaryRules(buf, buf.Size)
            Assert.Equals(len2, len)
        }

        OpenBinaryRules_RoundTrip_WorksLikeOriginal() {
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en")
            len := bi.GetBinaryRules(0, 0)
            buf := Buffer(len, 0)
            bi.GetBinaryRules(buf, buf.Size)

            text := "Hello World"
            bi2 := BreakIterator.OpenBinaryRules(buf, buf.Size, StrPtr(text), StrLen(text))
            Assert.IsType(bi2, BreakIterator)
            Assert.Equals(bi2.First(), 0)
        }
    }

    class Iteration {
        First_ReturnsZero() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            Assert.Equals(bi.First(), 0)
        }

        Last_ReturnsTextLength() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            Assert.Equals(bi.Last(), 11)
        }

        Next_AdvancesToNextBoundary() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            bi.First()
            Assert.Equals(bi.Next(), 5)
        }

        Next_WhenExhausted_ReturnsDone() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            bi.Last()
            Assert.Equals(bi.Next(), BreakIterator.DONE)
        }

        Previous_ReturnsPreviousBoundary() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            bi.First()
            bi.Next()    ; → 5
            pos := bi.Next()    ; → 6
            Assert.Equals(bi.Previous(), 5)
        }

        Current_ReflectsMostRecentBoundary() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            bi.First()
            pos := bi.Next()
            Assert.Equals(bi.Current(), pos)
        }
    }

    class Positioning {
        IsBoundary_AtStart_ReturnsTrue() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            Assert.Truthy(bi.IsBoundary(0))
        }

        IsBoundary_MidWord_ReturnsFalse() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            Assert.Truthy(!bi.IsBoundary(2))
        }

        Following_ReturnsNextBoundaryAfterOffset() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            Assert.Equals(bi.Following(1), 5)
        }

        Preceding_ReturnsPreviousBoundaryBeforeOffset() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            Assert.Equals(bi.Preceding(5), 0)
        }
    }

    class SetText {
        SetText_ChangesText_IteratesNewText() {
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en")
            text := "Hi"
            bi.SetText(StrPtr(text), StrLen(text))
            Assert.Equals(bi.First(), 0)
            Assert.Equals(bi.Last(), 2)
        }
    }

    class Locale {
        GetLocaleByType_ValidLocale_ReturnsString() {
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en")
            ; 0 = ULOC_ACTUAL_LOCALE, 1 = ULOC_VALID_LOCALE
            locale := bi.GetLocaleByType(1)
            Assert.IsType(locale, String)
            Assert.Truthy(!IsSpace(locale))
            FileAppend("GetLocaleByType: " locale "`n", "*")
        }

        Available_GetsAvailableLocales() {
            Assert.Truthy(BreakIterator.CountAvailable() > 0)

            loop BreakIterator.CountAvailable() {
                localeName := BreakIterator.GetAvailable(A_Index - 1)

                Assert.IsType(localeName, String)
                Assert.Truthy(!IsSpace(localeName))
                FileAppend(localeName "`n", "*")
            }
        }
    }

    class RuleStatus {
        GetRuleStatus_AfterWordToken_ReturnsLetterRange() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            bi.First()
            bi.Next()    ; advances to end of "Hello" (position 5)
            status := bi.GetRuleStatus()
            ; "Hello" is a letter word: status in [200, 300)
            Assert.AtLeast(status, 200)
            Assert.AtMost(status, 299)
        }

        GetRuleStatusVec_Preflight_ReturnsPositiveCount() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            bi.First()
            bi.Next()
            count := bi.GetRuleStatusVec(0, 0)
            Assert.Truthy(count >= 1)
        }

        GetRuleStatusVec_WithBuffer_FillsVector() {
            text := "Hello World"
            bi := BreakIterator.Open(BreakIteratorType.WORD, "en", StrPtr(text), StrLen(text))
            bi.First()
            bi.Next()
            count := bi.GetRuleStatusVec(0, 0)
            buf := Buffer(count * 4, 0)    ; int32 per status
            count2 := bi.GetRuleStatusVec(buf, count)
            Assert.Equals(count2, count)
            Assert.AtLeast(NumGet(buf, 0, "int"), 0)
        }
    }
}
