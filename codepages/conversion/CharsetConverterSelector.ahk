
#Include ../../common/ICUError.ahk
#Include ../../common/ICUEnumerator.ahk

#Include ConverterUnicodeSet.ahk

#DllLoad icu.dll

/**
 * A converter selector is built with a set of encoding/charset names and given an input string returns the set of
 * names of the corresponding converters which can convert the string.
 * 
 * A converter selector can be serialized into a buffer and reopened from the serialized form.
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnvsel_8h.html `ucnvsel.h` File Reference}
 */
class CharsetConverterSelector {

    /**
     * Open a selector.
     * 
     * If converterListSize is 0, build for all available converters. If excludedCodePoints is NULL, don't exclude any
     * code points.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnvsel_8h.html#a74b843fb6d932c6fb4498e52ee00cbfd `ucnvsel_open`}
     * 
     * @param {Buffer | Integer} converterList a pointer to encoding names needed to be involved. Can be NULL if 
     *      converterListSize==0. The list and the names will be cloned, and the caller retains ownership of the 
     *      original.
     * @param {Integer} converterListSize number of encodings in above list. If 0, builds a selector for all available 
     *      converters.
     * @param {USet} excludedCodePoints UNSUPPORTED - USets aren't included in the bindings yet. a set of code points 
     *      to be excluded from consideration. That is, excluded code points in a string do not change the selection 
     *      result. (They might be handled by a callback.) Use NULL to exclude nothing. Because USets aren't supported,
     *      this parameter is ignored.
     * @param {Integer} whichSet what {@link ConverterUnicodeSet} converter set to use? Use this to determine whether 
     *      to consider only roundtrip mappings or also fallbacks.
     * @returns {CharsetConverterSelector} the new selector
     */
    static Open(converterList, converterListSize, excludedCodePoints, whichSet) => (
        ptr := DllCall("icu.dll\ucnvsel_open",
            "ptr", converterList,
            "int", converterListSize,
            "ptr", 0, ; TODO: USet not supported, always pass NULL
            "uint", whichSet,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        CharsetConverterSelector(ptr))

    /**
     * Open a selector from its serialized form.
     * 
     * The buffer must remain valid and unchanged for the lifetime of the selector. This is much faster than creating 
     * a selector from scratch. Using a serialized form from a different machine (endianness/charset) is supported.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnvsel_8h.html#aec02d3fa82a067bdbb20faee4b238880 `ucnvsel_openFromSerialized`}
     * 
     * @param {Buffer | Integer} buf pointer to the serialized form of a converter selector; must be 32-bit-aligned
     * @param {Integer} length the capacity of this buffer (can be equal to or larger than the actual data length)
     * @returns {CharsetConverterSelector} the deserialized converter
     */
    static Deserialize(buf, length) => (
        ptr := DllCall("icu.dll\ucnvsel_openFromSerialized",
            "ptr", buf,
            "int", length,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        CharsetConverterSelector(ptr))

    /**
     * @private Adopts a pointer. Do not call this directly, instead use either {@link CharsetConverterSelector.Open `Open`} 
     * or {@link CharsetConverterSelector.Deserialize `Deserialize`} to create or read in a selector.
     */
    __New(ptr) {
        if !IsInteger(ptr) 
            throw TypeError("Expected an Integer but got a(n) " Type(ptr), -1, ptr)
        this.ptr := ptr
    }

    /**
     * Select converters that can map all characters in a UTF-16 string, ignoring the excluded code points.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnvsel_8h.html#a23bf32b0d75fca029e6c6c4cdefe3bed `ucnvsel_selectForString`}
     * 
     * @param {String | Integer} str A UTF-16 string or pointer to such a string
     * @param {Integer} length length of the string, or -1 if NUL-terminated
     * @returns {ICUEnumerator} an enumeration containing encoding names. The returned encoding names and their order
     *      will be the same as supplied when building the selector.
     */
    SelectForString(str, length := -1) => (
        en := DllCall("icu.dll\ucnvsel_selectForString",
            "ptr", this,
            "ptr", str is String ? StrPtr(str) : str,
            "int", length,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        ICUEnumerator(en))

    /**
     * Select converters that can map all characters in a UTF-8 string, ignoring the excluded code points.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnvsel_8h.html#a467365bf0bb7b6989a1777f31251d139 `ucnvsel_selectForUTF8`}
     *
     * @param {Integer} chars Pointer to a UTF-8 string
     * @param {Integer} length length of the string, or -1 if NUL-terminated
     * @returns {ICUEnumerator} an enumeration containing encoding names. The returned encoding names and their order
     *      will be the same as supplied when building the selector.
     */
    SelectForUTF8(chars, length := -1) => (
        en := DllCall("icu.dll\ucnvsel_selectForUTF8",
            "ptr", this,
            "ptr", chars,
            "int", length,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        ICUEnumerator(en))

    /**
     * Serialize a selector into a linear buffer.
     * 
     * The serialized form is portable to different machines.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnvsel_8h.html#a357adbf8e9d25dc643d699406eee31da `ucnvsel_serialize`}
     * @param {Integer | Buffer} buf pointer to 32-bit-aligned memory to be filled with the serialized form of this 
     *      converter selector
     * @param {Integer} capacity the capacity of this buffer
     * @returns {Integer} the required buffer capacity to hold serialize data
     */
    Serialize(buf, capacity) => (
        requiredCapacity := DllCall("icu.dll\ucnvsel_serialize",
            "ptr", this,
            "ptr", buf,
            "int", capacity,
            "int*", &stat := 0,
            "cdecl int"),
        ((ICUError.GetName(stat) != "U_BUFFER_OVERFLOW_ERROR") && ICUError.ThrowFor(stat)),
        requiredCapacity)

    /**
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnvsel_8h.html#aefb8c36821f227c1c769d608ed2700e6 `ucnvsel_close`} 
     */
    __Delete() {
        if this.HasProp("ptr") && this.ptr != 0
            DllCall("icu.dll\ucnvsel_close", "ptr", this, "cdecl")
    }
}