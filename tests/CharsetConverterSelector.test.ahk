#Include YUnit\Assert.ahk
#Include ../codepages/conversion/CharsetConverterSelector.ahk
#Include ../codepages/conversion/ConverterUnicodeSet.ahk

class CharsetConverterSelectorTests {

    class Open {
        Open_WithZeroSize_ReturnsSelector() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)
            Assert.IsType(sel, CharsetConverterSelector)
        }

        Open_WithFallbackSet_ReturnsSelector() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP_AND_FALLBACK)
            Assert.IsType(sel, CharsetConverterSelector)
        }
    }

    class New {
        New_WithNonIntegerArg_ThrowsTypeError() {
            Assert.Throws(() => CharsetConverterSelector("not_a_ptr"), TypeError)
        }
    }

    class SelectForString {
        SelectForString_WithASCIIString_ReturnsEnumerator() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)
            en := sel.SelectForString("Hello")
            Assert.IsType(en, ICUEnumerator)
            Assert.Truthy(en.Count() > 0)
        }

        SelectForString_WithStringPointer_ReturnsEnumerator() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)
            str := "Hello"
            en := sel.SelectForString(StrPtr(str))
            Assert.IsType(en, ICUEnumerator)
            Assert.Truthy(en.Count() > 0)
        }

        SelectForString_EnumeratedNamesAreNonEmptyStrings() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)
            en := sel.SelectForString("Hello")
            en.Reset()

            for name in en {
                Assert.IsType(name, String)
                Assert.Truthy(!IsSpace(name))
                FileAppend(name "`n", "*")
            }
        }

        SelectForString_WithExplicitLength_ReturnsEnumerator() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)
            str := "Hello"
            en := sel.SelectForString(str, StrLen(str))
            Assert.IsType(en, ICUEnumerator)
            Assert.Truthy(en.Count() > 0)
        }
    }

    class SelectForUTF8 {
        SelectForUTF8_WithASCIIBuffer_ReturnsEnumerator() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)

            buf := Buffer(StrPut("Hello", "UTF-8"))
            StrPut("Hello", buf, "UTF-8")

            en := sel.SelectForUTF8(buf, buf.Size - 1)  ; exclude null terminator
            Assert.IsType(en, ICUEnumerator)
            Assert.Truthy(en.Count() > 0)
        }

        SelectForUTF8_WithNulTerminatedBuffer_ReturnsEnumerator() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)

            buf := Buffer(StrPut("Hello", "UTF-8"))
            StrPut("Hello", buf, "UTF-8")

            en := sel.SelectForUTF8(buf, -1)
            Assert.IsType(en, ICUEnumerator)
            Assert.Truthy(en.Count() > 0)
        }
    }

    class Serialization {
        Serialize_Preflight_ReturnsPositiveCapacity() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)
            ; Pass NULL + 0 capacity — ICU returns the required size via U_BUFFER_OVERFLOW_ERROR,
            ; which Serialize handles without throwing
            requiredSize := sel.Serialize(0, 0)
            Assert.Truthy(requiredSize > 0)
        }

        Serialize_WithSufficientBuffer_WritesExpectedByteCount() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)
            requiredSize := sel.Serialize(0, 0)

            buf := Buffer(requiredSize, 0)
            written := sel.Serialize(buf, buf.Size)
            Assert.Equals(written, requiredSize)
        }

        Deserialize_FromSerializedBuffer_ReturnsSelector() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)
            requiredSize := sel.Serialize(0, 0)
            buf := Buffer(requiredSize, 0)
            sel.Serialize(buf, buf.Size)

            sel2 := CharsetConverterSelector.Deserialize(buf, buf.Size)
            Assert.IsType(sel2, CharsetConverterSelector)
        }

        Deserialize_RoundTrip_SelectsConverters() {
            sel := CharsetConverterSelector.Open(0, 0, 0, ConverterUnicodeSet.ROUNDTRIP)
            requiredSize := sel.Serialize(0, 0)
            buf := Buffer(requiredSize, 0)
            sel.Serialize(buf, buf.Size)

            sel2 := CharsetConverterSelector.Deserialize(buf, buf.Size)
            en := sel2.SelectForString("Hello")
            Assert.IsType(en, ICUEnumerator)
            Assert.Truthy(en.Count() > 0)
        }
    }
}
