#Include YUnit\Assert.ahk
#Include ../codepages/conversion/CharsetConverter.ahk
#Include ../codepages/conversion/ConverterUnicodeSet.ahk

class CharsetConverterTests {

    class Names {
        GetAllNames_GetsNames() {
            enum := CharsetConverter.GetAllNames()

            Assert.IsType(enum, ICUEnumerator)
            Assert.Truthy(enum.Count() > 0)

            enum.Reset()    ; Count() might enumerate names, reset it

            for name in enum {
                Assert.IsType(name, String)
                Assert.Truthy(!IsSpace(name))
                FileAppend(name "`n", "*")
            }
        }

        GetStandardName_GetsStandardName() {
            name := CharsetConverter.GetStandardName("UTF-16-BigEndian", "IANA")
            Assert.IsType(name, String)
            Assert.Equals(name, "UTF-16BE")
        }

        GetCanonicalName_GetsCanonicalName() {
            name := CharsetConverter.GetCanonicalName("ASCII", "IANA")
            Assert.IsType(name, String)
            Assert.Equals(name, "US-ASCII")
        }
        
        GetAllStandardNames_GetsListOfStandardNames() {
            en := CharsetConverter.GetAllStandardNames("UTF-7", "IANA")

            Assert.IsType(en, ICUEnumerator)

            for std in en {
                Assert.IsType(std, String)
                Assert.Truthy(!IsSpace(std))
                FileAppend(std "`n", "*")
            }
        }
    }

    DefaultName_Get_ReturnsValue() {
        defaultName := CharsetConverter.DefaultName
        FileAppend(defaultName "`n", "*")

        Assert.IsType(defaultName, String)
        Assert.Truthy(!IsSpace(defaultName))
    }

    class Aliases {

        CountAliases_CountsAliases() {
            aliases := CharsetConverter.CountAliases("US-ASCII")
            ; Exact count will vary by system, but can reliably expect more than one on Windows systems
            Assert.Truthy(aliases > 1)
        }

        CountAlias_WithUnknownAlias_Returns0() {
            aliases := CharsetConverter.CountAliases("NotAnAlias")
            Assert.Equals(aliases, 0)
        }

        GetAlias_WithValidIndex_GetsAlias() {
            name := CharsetConverter.GetAlias("Unicode", 0)
            Assert.IsType(name, String)
            Assert.Truthy(!IsSpace(name))

            FileAppend("Alias 0 of 'Unicode': " name "`n", "*")
        }

        GetAlias_WithInvalidIndex_ThrowsICUError() {
            Assert.Throws(() => CharsetConverter.GetAlias("UTF-16", -1), ICUError)
        }

        GetAlias_WithUnknownAlias_ReturnsEmptyString() {
            name := CharsetConverter.GetAlias("NotAnAlias", 0)
            Assert.IsType(name, String)
            Assert.Equals(name, "")
        }

        GetAliases_GetsAllAliases() {
            aliases := CharsetConverter.GetAliases("US-ASCII")
            Assert.IsType(aliases, Array)
            Assert.Truthy(aliases.Length > 1)

            for alias in aliases {
                Assert.IsType(alias, String)
                FileAppend(alias "`n", "*")

                Assert.Truthy(!IsSpace(alias))
            }
        }

        GetAliases_WithUnknownAlias_ReturnsEmptyArray() {
            aliases := CharsetConverter.GetAliases("NotAnAlias")
            Assert.ArraysEqual(aliases, [])
        }
    }

    class Open {
        Open_WithNullArgument_OpensDefaultConverter() {
            cnv := CharsetConverter.Open(0)
            Assert.Equals(cnv.Name, CharsetConverter.DefaultName)
        }

        Open_WithValidStringArgument_OpensConverter() {
            cnv := CharsetConverter.Open("US-ASCII")
            Assert.Equals(cnv.Name, "US-ASCII")
        }

        Open_WithInvalidStringArgument_ThrowsICUError() {
            Assert.Throws(
                () => CharsetConverter.Open("NotAnEncoding"),
                ICUError
            )
        }
    }

    class OpenCCSID {
        OpenCCSID_WithIBMCodepage1208_OpensUTF8() {
            ; IBM codepage 1208 is UTF-8
            cnv := CharsetConverter.OpenCCSID(1208, 0)
            Assert.IsType(cnv, CharsetConverter)
            Assert.Equals(cnv.Name, "UTF-8")
        }

        OpenCCSID_WithInvalidCodepage_ThrowsICUError() {
            Assert.Throws(() => CharsetConverter.OpenCCSID(-1, 0), ICUError)
        }
    }

    class AvailableNames {
        GetAvailableName_WithIndex0_ReturnsString() {
            name := CharsetConverter.GetAvailableName(0)
            Assert.IsType(name, String)
            Assert.Truthy(!IsSpace(name))
            FileAppend("GetAvailableName(0): " name "`n", "*")
        }

        GetAvailableName_IndexMatchesCountAvailable() {
            count := CharsetConverter.CountAvailable()
            Assert.Truthy(count > 0)
            ; Last valid index should return a name
            name := CharsetConverter.GetAvailableName(count - 1)
            Assert.IsType(name, String)
            Assert.Truthy(!IsSpace(name))
        }
    }

    class Substitutions {
        GetSubstChars_ReturnsSubstitutionChars() {
            cnv := CharsetConverter.Open("US-ASCII")
            outBuf := Buffer(8, 0)
            cnv.GetSubstChars(outBuf, &len := outBuf.Size)

            ; US-ASCII substitution should be 0x1A, the SUB control character
            Assert.Equals(len, 1)
            Assert.Equals(NumGet(outBuf, 0, "uchar"), 0x1A)
        }

        GetSubstChars_With0LengthBuffer_ThrowsICUError() {
            cnv := CharsetConverter.Open("US-ASCII")
            outBuf := Buffer(0, 0)

            Assert.Throws(() => cnv.GetSubstChars(outBuf, &len := outBuf.Size), ICUError)
        }

        SetSubstChars_SetsSubstitutionChars() {
            cnv := CharsetConverter.Open("US-ASCII")
            buf := Buffer(1, 0)
            NumPut("char", Ord("x"), buf)

            outBuf := Buffer(8, 0)
            cnv.SetSubstChars(buf, 1)

            cnv.GetSubstChars(outBuf, &len := outBuf.Size)
            Assert.Equals(len, 1)
            Assert.Equals(NumGet(outBuf, 0, "uchar"), Ord("x"))
        }

        SetSubstChars_WithInvalidChars_ThrowsICUError() {
            cnv := CharsetConverter.Open("US-ASCII")
            buf := Buffer(2, 0)
            NumPut("char", 0xFFFF, buf)

            Assert.Throws(() => cnv.SetSubstChars(buf, 2), ICUError)
        }

        SetSubstString_WithAHKString_SetsSubsituteString() {
            cnv := CharsetConverter.Open("US-ASCII")
            cnv.SetSubstString("??", -1)
        }

        SetSubstString_StringPointer_SetsSubsituteString() {
            cnv := CharsetConverter.Open("US-ASCII")
            cnv.SetSubstString(StrPtr("??"), -1)
        }

        SetSubstString_WithInvalidString_ThrowsICUError() {
            cnv := CharsetConverter.Open("US-ASCII")
            Assert.Throws(
                () => cnv.SetSubstString("This string in UTF-16 requires more than 32 bytes", -1),
                ICUError)
        }
    }

    class Conversion {
        FromUChars_Preflight_ReturnsRequiredLength() {
            cnv := CharsetConverter.Open("UTF-8")
            ; Preflight with 0-capacity buffer returns needed byte count for "ABC"
            src := "ABC"
            needed := cnv.FromUChars(0, 0, src, StrLen(src))
            Assert.Equals(needed, 3)    ; "ABC" is 3 bytes in UTF-8
        }

        FromUChars_ConvertsUCharsToBytes() {
            cnv := CharsetConverter.Open("UTF-8")
            src := "Hello"
            buf := Buffer(10, 0)
            written := cnv.FromUChars(buf, buf.Size, src, StrLen(src))
            Assert.Equals(written, 5)
            Assert.Equals(NumGet(buf, 0, "uchar"), Ord("H"))
            Assert.Equals(NumGet(buf, 4, "uchar"), Ord("o"))
        }

        ToUChars_Preflight_ReturnsRequiredLength() {
            cnv := CharsetConverter.Open("UTF-8")
            ; "ABC" as UTF-8 bytes
            src := Buffer(3)
            NumPut("uchar", 65, src, 0), NumPut("uchar", 66, src, 1), NumPut("uchar", 67, src, 2)
            needed := cnv.ToUChars(0, 0, src, 3)
            Assert.Equals(needed, 3)    ; 3 UChars
        }

        ToUChars_ConvertsBytesToUChars() {
            cnv := CharsetConverter.Open("UTF-8")
            src := Buffer(5)
            NumPut("uchar", 72, src, 0)    ; H
            NumPut("uchar", 101, src, 1)   ; e
            NumPut("uchar", 108, src, 2)   ; l
            NumPut("uchar", 108, src, 3)   ; l
            NumPut("uchar", 111, src, 4)   ; o
            dest := Buffer(12, 0)
            written := cnv.ToUChars(dest, 6, src, 5)
            Assert.Equals(written, 5)
            Assert.Equals(NumGet(dest, 0, "ushort"), Ord("H"))
            Assert.Equals(NumGet(dest, 8, "ushort"), Ord("o"))
        }

        GetNextUChar_DecodesFirstCodePoint() {
            cnv := CharsetConverter.Open("UTF-8")
            src := Buffer(3)
            NumPut("uchar", 65, src, 0)    ; 'A'
            NumPut("uchar", 66, src, 1)    ; 'B'
            NumPut("uchar", 67, src, 2)    ; 'C'
            srcPtr := src.Ptr
            cp := cnv.GetNextUChar(&srcPtr, src.Ptr + 3)
            Assert.Equals(cp, 65)                   ; U+0041 'A'
            Assert.Equals(srcPtr, src.Ptr + 1)      ; advanced 1 byte
        }

        ToAlgorithmic_ConvertsToUTF8() {
            ; Open a US-ASCII source converter; convert to UTF-8 (algorithmicType = 4 = ConverterType.UTF8)
            cnv := CharsetConverter.Open("US-ASCII")
            src := Buffer(3)
            NumPut("uchar", 65, src, 0), NumPut("uchar", 66, src, 1), NumPut("uchar", 67, src, 2)
            dest := Buffer(8, 0)
            written := cnv.ToAlgorithmic(4, dest, dest.Size, src, 3)
            Assert.Equals(written, 3)
            Assert.Equals(NumGet(dest, 0, "uchar"), 65)
        }

        FromUnicode_StreamConvertsUCharsToBytes() {
            cnv := CharsetConverter.Open("UTF-8")
            ; Source: UChars for "Hi"
            src := Buffer(4, 0)
            NumPut("ushort", Ord("H"), src, 0)
            NumPut("ushort", Ord("i"), src, 2)
            dest := Buffer(8, 0)

            srcPtr := src.Ptr
            dstPtr := dest.Ptr
            cnv.FromUnicode(&dstPtr, dest.Ptr + dest.Size, &srcPtr, src.Ptr + 4, 0, true)

            Assert.Equals(dstPtr - dest.Ptr, 2)     ; 2 bytes written
            Assert.Equals(NumGet(dest, 0, "uchar"), Ord("H"))
            Assert.Equals(NumGet(dest, 1, "uchar"), Ord("i"))
        }

        ToUnicode_StreamConvertsBytesToUChars() {
            cnv := CharsetConverter.Open("UTF-8")
            src := Buffer(2)
            NumPut("uchar", Ord("H"), src, 0)
            NumPut("uchar", Ord("i"), src, 1)
            dest := Buffer(8, 0)

            srcPtr := src.Ptr
            dstPtr := dest.Ptr
            cnv.ToUnicode(&dstPtr, dest.Ptr + dest.Size, &srcPtr, src.Ptr + 2, 0, true)

            Assert.Equals(dstPtr - dest.Ptr, 4)     ; 2 UChars = 4 bytes
            Assert.Equals(NumGet(dest, 0, "ushort"), Ord("H"))
            Assert.Equals(NumGet(dest, 2, "ushort"), Ord("i"))
        }

        ConvertEx_ConvertsUTF8ToASCII() {
            tCnv := CharsetConverter.Open("US-ASCII")
            sCnv := CharsetConverter.Open("UTF-8")
            src := Buffer(3)
            NumPut("uchar", 65, src, 0), NumPut("uchar", 66, src, 1), NumPut("uchar", 67, src, 2)
            dest := Buffer(8, 0)
            tgtPtr := dest.Ptr
            srcPtr := src.Ptr
            ; pivotStart = 0 = internal pivot; reset and flush must both be true
            CharsetConverter.ConvertEx(tCnv, sCnv, &tgtPtr, dest.Ptr + dest.Size, &srcPtr, src.Ptr + 3,
                0, , , 0, true, true)
            Assert.Equals(tgtPtr - dest.Ptr, 3)
            Assert.Equals(NumGet(dest, 0, "uchar"), 65)
        }
    }

    class PendingCounts {
        FromUCountPending_FreshConverter_ReturnsZero() {
            cnv := CharsetConverter.Open("UTF-8")
            Assert.Equals(cnv.FromUCountPending, 0)
        }

        ToUCountPending_FreshConverter_ReturnsZero() {
            cnv := CharsetConverter.Open("UTF-8")
            Assert.Equals(cnv.ToUCountPending, 0)
        }
    }

    class Fallback {
        UsesFallback_DefaultIsFalse() {
            cnv := CharsetConverter.Open("UTF-8")
            Assert.Equals(cnv.UsesFallback, 0)
        }

        UsesFallback_SetterEnablesFallback() {
            cnv := CharsetConverter.Open("UTF-8")
            cnv.UsesFallback := true
            Assert.Equals(cnv.UsesFallback, 1)
        }

        UsesFallback_SetterDisablesFallback() {
            cnv := CharsetConverter.Open("UTF-8")
            cnv.UsesFallback := true
            cnv.UsesFallback := false
            Assert.Equals(cnv.UsesFallback, 0)
        }
    }

    class Starters {
        ; ucnv_getStarters only works for converters of type UCNV_MBCS (type 2).
        ; Shift-JIS is a well-known MBCS/type-2 converter available in all standard ICU builds.

        GetStarters_RequiresMBCSConverter() {
            ; Confirm the converter is actually type MBCS (2) — anything else will throw
            ; U_ILLEGAL_ARGUMENT_ERROR on GetStarters()
            cnv := CharsetConverter.Open("UTF-8", false)
            Assert.Throws(() => cnv.GetStarters(), ICUError)
        }

        GetStarters_ReturnsWith256Elements() {
            starters := CharsetConverter.Open("Shift_JIS", false).GetStarters()
            Assert.IsType(starters, Array)
            Assert.Equals(starters.Length, 256)
        }

        GetStarters_ShiftJIS_LeadBytesAreMarked() {
            starters := CharsetConverter.Open("Shift_JIS", false).GetStarters()
            ; ucnv_getStarters marks only lead bytes of *multi-byte* sequences, not single-byte
            ; characters. In Shift-JIS the two-byte lead ranges are 0x81-0x9F and 0xE0-0xFC.
            Assert.Truthy(starters[0x81 + 1])   ; first byte of first lead range
            Assert.Truthy(starters[0x9F + 1])   ; last byte of first lead range
            Assert.Truthy(starters[0xE0 + 1])   ; first byte of second lead range
        }

        GetStarters_ShiftJIS_SingleByteAndTrailBytesAreNotMarked() {
            starters := CharsetConverter.Open("Shift_JIS", false).GetStarters()
            ; Single-byte ASCII characters are NOT marked, even though they are valid
            Assert.Truthy(!starters[0x41 + 1])  ; 'A' — valid but single-byte, not a lead byte
            ; Trail-only bytes are also not marked
            Assert.Truthy(!starters[0x40 + 1])  ; valid trail byte, never a lead byte
        }
    }

    class Callbacks {
        GetFromUCallback_ReturnsNonNullPointer() {
            cnv := CharsetConverter.Open("UTF-8")
            cnv.GetFromUCallback(&action := 0, &context := 0)
            Assert.Truthy(action != 0)
        }

        GetToUCallback_ReturnsNonNullPointer() {
            cnv := CharsetConverter.Open("UTF-8")
            cnv.GetToUCallback(&action := 0, &context := 0)
            Assert.Truthy(action != 0)
        }

        SetFromUCallback_RoundTrip_RestoresOriginal() {
            cnv := CharsetConverter.Open("UTF-8")
            cnv.GetFromUCallback(&origAction := 0, &origContext := 0)
            ; Set it to itself — should succeed with no error
            cnv.SetFromUCallback(origAction, origContext, &oldAction := 0, &oldContext := 0)
            Assert.Equals(oldAction, origAction)
            Assert.Equals(oldContext, origContext)
        }

        SetToUCallback_RoundTrip_RestoresOriginal() {
            cnv := CharsetConverter.Open("UTF-8")
            cnv.GetToUCallback(&origAction := 0, &origContext := 0)
            cnv.SetToUCallback(origAction, origContext, &oldAction := 0, &oldContext := 0)
            Assert.Equals(oldAction, origAction)
            Assert.Equals(oldContext, origContext)
        }
    }

    class UnicodeSet {
        GetUnicodeSet_DoesNotThrow() {
            cnv := CharsetConverter.Open("US-ASCII")
            us := DllCall("icu.dll\uset_openEmpty", "cdecl ptr")
            try {
                cnv.GetUnicodeSet(us, ConverterUnicodeSet.ROUNDTRIP)
                Assert.Truthy(DllCall("icu.dll\uset_size", "ptr", us, "cdecl int") > 0)
            } finally {
                DllCall("icu.dll\uset_close", "ptr", us, "cdecl")
            }
        }
    }
}