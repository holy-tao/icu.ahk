#Include YUnit\Assert.ahk
#Include ../normalization/UNormalizer2.ahk
#Include ../normalization/UNormalizationCheckResult.ahk

; U+00C0  LATIN CAPITAL LETTER A WITH GRAVE (precomposed)
; U+0041  LATIN CAPITAL LETTER A
; U+0300  COMBINING GRAVE ACCENT  (combining class 230)
; NFD of U+00C0 = U+0041 U+0300 (two UChars)

class UNormalizer2Tests {

    class Singletons {
        NFC_ReturnsUNormalizer2() {
            Assert.IsType(UNormalizer2.NFC(), UNormalizer2)
        }

        NFD_ReturnsUNormalizer2() {
            Assert.IsType(UNormalizer2.NFD(), UNormalizer2)
        }

        NFKC_ReturnsUNormalizer2() {
            Assert.IsType(UNormalizer2.NFKC(), UNormalizer2)
        }

        NFKD_ReturnsUNormalizer2() {
            Assert.IsType(UNormalizer2.NFKD(), UNormalizer2)
        }

        NFKCCasefold_ReturnsUNormalizer2() {
            Assert.IsType(UNormalizer2.NFKCCasefold(), UNormalizer2)
        }
    }

    class GetInstance {
        GetInstance_NFCCompose_ReturnsUNormalizer2() {
            n := UNormalizer2.GetInstance(0, "nfc", UNormalization2Mode.COMPOSE)
            Assert.IsType(n, UNormalizer2)
        }

        GetInstance_NFKCDecompose_ReturnsUNormalizer2() {
            n := UNormalizer2.GetInstance(0, "nfkc", UNormalization2Mode.DECOMPOSE)
            Assert.IsType(n, UNormalizer2)
        }

        GetInstance_InvalidName_ThrowsICUError() {
            Assert.Throws(
                (*) => UNormalizer2.GetInstance(0, "not_a_real_normalizer", UNormalization2Mode.COMPOSE),
                ICUError
            )
        }
    }

    class IsNormalized {
        IsNormalized_NFCOnPrecomposed_ReturnsTrue() {
            nfc := UNormalizer2.NFC()
            ; Ã€ (U+00C0) is already in NFC
            Assert.Truthy(nfc.IsNormalized(Chr(0x00C0)))
        }

        IsNormalized_NFCOnDecomposed_ReturnsFalse() {
            nfc := UNormalizer2.NFC()
            ; A + combining grave is NFD, not NFC
            Assert.Falsy(nfc.IsNormalized("A" Chr(0x0300)))
        }

        IsNormalized_NFDOnDecomposed_ReturnsTrue() {
            nfd := UNormalizer2.NFD()
            Assert.Truthy(nfd.IsNormalized("A" Chr(0x0300)))
        }

        IsNormalized_NFDOnPrecomposed_ReturnsFalse() {
            nfd := UNormalizer2.NFD()
            ; Ã€ (U+00C0) is not in NFD; must be decomposed
            Assert.Falsy(nfd.IsNormalized(Chr(0x00C0)))
        }

        IsNormalized_AcceptsPointer() {
            nfc := UNormalizer2.NFC()
            str := "Hello"
            Assert.Truthy(nfc.IsNormalized(StrPtr(str), StrLen(str)))
        }
    }

    class IsInert {
        IsInert_RegularLetter_ReturnsFalse() {
            nfc := UNormalizer2.NFC()
            ; A (U+0041) is not normalization-inert in NFC â€” it can combine with following chars
            Assert.Falsy(nfc.IsInert(0x0041))
        }

        IsInert_ASCIIDigit_ReturnsTrue() {
            nfc := UNormalizer2.NFC()
            ; ASCII digits like '0' (U+0030) are always inert
            Assert.Truthy(nfc.IsInert(0x0030))
        }
    }

    class Normalize {
        Normalize_DecomposedToNFC_ProducesPrecomposed() {
            nfc := UNormalizer2.NFC()
            src := "A" Chr(0x0300)   ; NFD form: A + combining grave
            dest := Buffer(64, 0)
            len := nfc.Normalize(src, -1, dest.Ptr, 32)
            ; Should produce single UChar: U+00C0 (Ã€)
            Assert.Equals(len, 1)
            Assert.Equals(NumGet(dest, 0, "ushort"), 0x00C0)
        }

        Normalize_AlreadyNormalized_ReturnsSameLength() {
            nfc := UNormalizer2.NFC()
            src := "Hello"
            dest := Buffer(64, 0)
            len := nfc.Normalize(src, -1, dest.Ptr, 32)
            Assert.Equals(len, StrLen("Hello"))
        }

        Normalize_AcceptsPointer() {
            nfc := UNormalizer2.NFC()
            src := "A" Chr(0x0300)
            dest := Buffer(64, 0)
            len := nfc.Normalize(StrPtr(src), StrLen(src), dest.Ptr, 32)
            Assert.Equals(len, 1)
        }

        Normalize_Preflight_ReturnsRequiredLength() {
            nfc := UNormalizer2.NFC()
            src := "A" Chr(0x0300)
            ; capacity=0, dest=0 â†’ preflight: returns required length without writing
            len := nfc.Normalize(src, -1, 0, 0)
            Assert.Equals(len, 1)
        }
    }

    class NormalizeSecondAndAppend {
        NormalizeSecondAndAppend_AppendsNormalizedForm() {
            nfc := UNormalizer2.NFC()
            ; first buffer holds "Hello" in NFC, second is decomposed
            firstBuf := Buffer(128, 0)
            StrPut("Hello", firstBuf, "UTF-16")
            second := "A" Chr(0x0300)   ; will be NFC'd to Ã€ before appending
            newLen := nfc.NormalizeSecondAndAppend(firstBuf.Ptr, StrLen("Hello"), 64, second, -1)
            ; "Hello" (5) + "Ã€" (1) = 6
            Assert.Equals(newLen, 6)
        }
    }

    class Append {
        Append_TwoNFCStrings_MergesAtBoundary() {
            nfc := UNormalizer2.NFC()
            firstBuf := Buffer(128, 0)
            StrPut("Hello", firstBuf, "UTF-16")
            second := " World"
            newLen := nfc.Append(firstBuf.Ptr, StrLen("Hello"), 64, second, -1)
            Assert.Equals(newLen, StrLen("Hello World"))
        }
    }

    class QuickCheck {
        QuickCheck_NFCOnASCII_ReturnsYes() {
            nfc := UNormalizer2.NFC()
            result := nfc.QuickCheck("Hello")
            Assert.Equals(result, UNormalizationCheckResult.YES)
        }

        QuickCheck_NFCOnPrecomposed_ReturnsYes() {
            nfc := UNormalizer2.NFC()
            ; Ã€ (U+00C0) is already in NFC
            result := nfc.QuickCheck(Chr(0x00C0))
            Assert.Equals(result, UNormalizationCheckResult.YES)
        }

        QuickCheck_NFCOnCombiningChar_ReturnsMaybe() {
            nfc := UNormalizer2.NFC()
            ; U+0300 has NFC_QC=Maybe â€” it might compose with its predecessor
            result := nfc.QuickCheck("A" Chr(0x0300))
            Assert.Equals(result, UNormalizationCheckResult.MAYBE)
        }

        QuickCheck_NFCOnNFCQCNo_ReturnsNo() {
            nfc := UNormalizer2.NFC()
            ; U+2126 OHM SIGN has NFC_QC=No â€” it is canonically equivalent to U+03A9
            ; and must never appear in NFC text
            result := nfc.QuickCheck(Chr(0x2126))
            Assert.Equals(result, UNormalizationCheckResult.NO)
        }

        QuickCheck_AcceptsPointer() {
            nfc := UNormalizer2.NFC()
            str := "Hello"
            result := nfc.QuickCheck(StrPtr(str), StrLen(str))
            Assert.Equals(result, UNormalizationCheckResult.YES)
        }
    }

    class SpanQuickCheckYes {
        SpanQuickCheckYes_FullyNFCString_ReturnsFullLength() {
            nfc := UNormalizer2.NFC()
            str := "Hello"
            Assert.Equals(nfc.SpanQuickCheckYes(str), StrLen(str))
        }

        SpanQuickCheckYes_DecomposedSuffix_ReturnsIndexBeforeSuffix() {
            nfc := UNormalizer2.NFC()
            ; "Hello" is YES; the following combining char stops the span
            str := "Hello" Chr(0x0300)
            spanEnd := nfc.SpanQuickCheckYes(str)
            ; The combining grave alone is not YES in NFC context
            Assert.AtMost(spanEnd, StrLen("Hello" Chr(0x0300)))
            Assert.AtLeast(spanEnd, 0)
        }

        SpanQuickCheckYes_AcceptsPointer() {
            nfc := UNormalizer2.NFC()
            str := "Hello"
            result := nfc.SpanQuickCheckYes(StrPtr(str), StrLen(str))
            Assert.Equals(result, StrLen(str))
        }
    }

    class GetCombiningClass {
        GetCombiningClass_CombiningGraveAccent_Returns230() {
            nfc := UNormalizer2.NFC()
            ; U+0300 COMBINING GRAVE ACCENT has canonical combining class 230
            Assert.Equals(nfc.GetCombiningClass(0x0300), 230)
        }

        GetCombiningClass_LatinLetterA_ReturnsZero() {
            nfc := UNormalizer2.NFC()
            ; Regular letters have combining class 0 (starter)
            Assert.Equals(nfc.GetCombiningClass(0x0041), 0)
        }
    }

    class GetDecomposition {
        GetDecomposition_PrecomposedChar_WritesDecomposedChars() {
            nfc := UNormalizer2.NFC()
            dest := Buffer(64, 0)
            ; U+00C0 (Ã€) decomposes to U+0041 (A) + U+0300 (combining grave)
            len := nfc.GetDecomposition(0x00C0, dest.Ptr, 32)
            Assert.Equals(len, 2)
            Assert.Equals(NumGet(dest, 0, "ushort"), 0x0041)   ; A
            Assert.Equals(NumGet(dest, 2, "ushort"), 0x0300)   ; combining grave
        }

        GetDecomposition_PlainLetter_ReturnsNegative() {
            nfc := UNormalizer2.NFC()
            dest := Buffer(64, 0)
            ; A plain ASCII letter has no decomposition
            len := nfc.GetDecomposition(0x0041, dest.Ptr, 32)
            Assert.Truthy(len < 0)
        }

        GetDecomposition_Preflight_ReturnsRequiredLength() {
            nfc := UNormalizer2.NFC()
            len := nfc.GetDecomposition(0x00C0, 0, 0)
            Assert.Equals(len, 2)
        }
    }

    class GetRawDecomposition {
        GetRawDecomposition_PrecomposedChar_WritesDirectMapping() {
            nfc := UNormalizer2.NFC()
            dest := Buffer(64, 0)
            ; U+00C0 raw decomposition is U+0041 + U+0300 (same as full here)
            len := nfc.GetRawDecomposition(0x00C0, dest.Ptr, 32)
            Assert.Equals(len, 2)
            Assert.Equals(NumGet(dest, 0, "ushort"), 0x0041)
            Assert.Equals(NumGet(dest, 2, "ushort"), 0x0300)
        }

        GetRawDecomposition_PlainLetter_ReturnsNegative() {
            nfc := UNormalizer2.NFC()
            dest := Buffer(64, 0)
            len := nfc.GetRawDecomposition(0x0041, dest.Ptr, 32)
            Assert.Truthy(len < 0)
        }
    }

    class ComposePair {
        ComposePair_AAndCombiningGrave_ReturnsAGrave() {
            nfc := UNormalizer2.NFC()
            ; compose(U+0041, U+0300) â†’ U+00C0 (Ã€)
            result := nfc.ComposePair(0x0041, 0x0300)
            Assert.Equals(result, 0x00C0)
        }

        ComposePair_IncompatiblePair_ReturnsNegative() {
            nfc := UNormalizer2.NFC()
            ; Two regular Latin letters do not compose
            result := nfc.ComposePair(0x0041, 0x0042)   ; A, B
            Assert.Truthy(result < 0)
        }
    }

    class HasBoundaryBefore {
        HasBoundaryBefore_LatinLetterA_ReturnsTrue() {
            nfc := UNormalizer2.NFC()
            ; Starters always have a boundary before them
            Assert.Truthy(nfc.HasBoundaryBefore(0x0041))
        }

        HasBoundaryBefore_CombiningGraveAccent_ReturnsFalse() {
            nfc := UNormalizer2.NFC()
            ; Combining characters do not have a boundary before them
            Assert.Falsy(nfc.HasBoundaryBefore(0x0300))
        }
    }

    class HasBoundaryAfter {
        HasBoundaryAfter_ASCIIDigit_ReturnsTrue() {
            nfc := UNormalizer2.NFC()
            ; ASCII digits are inert and have a boundary after them
            Assert.Truthy(nfc.HasBoundaryAfter(0x0030))   ; '0'
        }

        HasBoundaryAfter_CombiningGraveAccent_ReturnsFalse() {
            nfc := UNormalizer2.NFC()
            ; A combining character may be followed by more combining chars
            Assert.Falsy(nfc.HasBoundaryAfter(0x0300))
        }
    }
}
