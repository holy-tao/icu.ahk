#Include ../../common/ICUError.ahk
#Include ../../common/ICUEnumerator.ahk

#DllLoad icu.dll

; https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html

/**
 * This API is used to convert codepage or character encoded data to and from UTF-16. You can open a converter by
 * instantiating a `CharsetConverter` object. With that converter, you can get its properties, set options, convert 
 * your data and close the converter.
 * 
 * Since many software programs recognize different converter names for different types of converters, there are other 
 * functions in this API to iterate over the converter aliases. The functions ucnv_getAvailableName(), ucnv_getAlias() 
 * and ucnv_getStandardName() are some of the more frequently used alias functions to get this information.
 * 
 * When a converter encounters an illegal, irregular, invalid or unmappable character its default behavior is to use a 
 * substitution character to replace the bad byte sequence. This behavior can be changed by using 
 * ucnv_setFromUCallBack() or ucnv_setToUCallBack() on the converter. The header ucnv_err.h defines many other 
 * callback actions that can be used instead of a character substitution.
 * 
 * More information about this API can be found in the ICU [User Guide](https://unicode-org.github.io/icu/userguide/conversion/).
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#details `ucnv.h` File Reference } and
 *      {@link https://unicode-org.github.io/icu/userguide/conversion/ Conversion | ICU User Guide}
 */
class CharsetConverter {
;@region Constants
    /**
     * Maximum length of a converter name including the terminating NULL.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a3ab00bb423db8533da12c35848e4c281 `UCNV_MAX_CONVERTER_NAME_LENGTH`}
     * @type {Integer}
     */
    static MAX_NAME_LENGTH => 60

    /**
     * Maximum length of a converter name including path and terminating NULL.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a1a579f67d05b09f731df5a68eb80b851 `UCNV_MAX_FULL_FILE_NAME_LENGTH`}
     * @type {Integer}
     */
    static MAX_FILENAME_LENGTH => 600 + CharsetConverter.MAX_NAME_LENGTH

    /**
     * Shift in for EBDCDIC_STATEFUL and iso2022 states.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a082aba7f50746ff6135a4ca2a00f6d6c `UCNV_SI`}
     * @type {Integer}
     */
    static SI => 0x0F

    /**
     * Shift out for EBDCDIC_STATEFUL and iso2022 states.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ad3918524388c8100107273806bd58c65 `UCNV_SO`}
     * @type {Integer}
     */
    static SO => 0x0E

;@endregion Constants
;@region Static Properties

    /**
     * Gets or sets the default converter name.
     * 
     * If you want to open a default converter, you do not need to access `DefaultName`. It is faster if you pass a 
     * NULL argument to {@link CharsetConverter.Open `Open`} the default converter.
     * 
     * Setting the default name is not thread safe and must never be called when any ICU function is being used in
     * more than one thread.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a1ed2edbd685a1d03c3d546e21159e1df `ucnv_setDefaultName`} and
     *      {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ab905641380c47b304f7adfb8750df9f2 `ucnv_getDefaultName`}
     * @type {String}
     */
    static DefaultName {
        get => DllCall("icu.dll\ucnv_getDefaultName", "cdecl astr")
        set => DllCall("icu.dll\ucnv_setDefaultName", "astr", value, "cdecl")
    }

;@endregion
;@region Static Methods

    /**
     * Calculates the size of a buffer for conversion from Unicode to a charset.
     * 
     * The calculated size is guaranteed to be sufficient for this conversion.
     * 
     * It takes into account initial and final non-character bytes that are output by some converters. It does not 
     * take into account callbacks which output more than one charset character sequence per call, like escape 
     * callbacks. The default (substitution) callback only outputs one charset character sequence.
     * 
     * This method is a port of a macro which apears in [`ucnv.h`](https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h_source.html#l00826) as
     * ```c
     * #define UCNV_GET_MAX_BYTES_FOR_STRING(length, maxCharSize) \
     *      (((int32_t)(length)+10)*(int32_t)(maxCharSize))
     * ```
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#aa3d7e4ae84f8a95b9735ed3491cdb77e `UCNV_GET_MAX_BYTES_FOR_STRING` macro}
     * @param {String | Integer} strOrLen The string to be converted, or the length of the string in UChars
     * @param {Integer} maxCharSize Return value from `CharsetConverter.MaxCharSize` for the converter that will be used.
     * @returns {Integer} Size of a buffer that will be large enough to hold the output bytes of converting length 
     *      UChars with the converter that returned the maxCharSize.
     */
    static GetMaxBytesForString(strOrLen, maxCharSize) => 
        ((strOrLen is String ? StrLen(strOrLen) : Integer(strOrLen)) + 10) * maxCharSize

    /**
     * Returns an {@link ICUEnumerator} to enumerate all of the canonical converter names, as per the alias file, 
     * regardless of the ability to open each converter.
     * 
     *      for name in Converter.GetAllNames() {
     *          FileAppend(name "`n", "*")
     *      }
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#adbc1a4034c4dea8f6fee96b2e65fc255 `ucnv_openAllNames`}
     * @returns {ICUEnumerator} An enumerator object for getting all the recognized canonical converter names.
     */
    static GetAllNames() => (
        en := DllCall("icu.dll\ucnv_openAllNames", "int*", &stat := 0, "cdecl ptr"),
        ICUError.ThrowFor(stat),
        ICUEnumerator(en))

    /**
     * Do a fuzzy compare of two converter/alias names.
     * 
     * The comparison is case-insensitive, ignores leading zeroes if they are not followed by further digits, and 
     * ignores all but letters and digits. Thus the strings "UTF-8", "utf_8", "u*T@f08" and "Utf 8" are exactly 
     * equivalent. 
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#aab6f27d27118014d5ff592f5e5a64fbb `ucnv_compareNames`}
     *      and Section 1.4, Charset Alias Matching in [Unicode Technical Standard #22](http://www.unicode.org/reports/tr22/)
     * @param {String} name1a converter name or alias, null-terminated 
     * @param {String} name2a converter name or alias, null-terminated
     * @returns {Integer} 0 if the names match, or a negative value if the name1 lexically precedes name2, or a 
     *      positive value if the name1 lexically follows name2.
     */
    static CompareNames(name1, name2) => DllCall("icu.dll\ucnv_compareNames",
        "astr", name1,
        "astr", name2,
        "cdecl int")

    /**
     * Convert from one external charset to another.
     * 
     * Internally, two converters are opened according to the name arguments, then the text is converted to and from the 16-bit Unicode "pivot" using ucnv_convertEx(), then the converters are closed again.
     * 
     *      ; Reverse the endianness of `str` This is inefficient, there's no need to convert from
     *      ; UTF-16 to UTF-16 as a pivot, but it's a useful demonstration
     *      str := "Hello, World! I'm in UTF-16!"
     *      buf := Buffer(128, 0)
     *      Converter.Convert("UTF-16", "UTF16_OppositeEndian", buf, buf.Size, StrPtr(str), StrLen(str))
     * 
     * This is a convenience function, not an efficient way to convert a lot of text: `Convert`:
     *  - takes charset names, not converter objects, so that
     *      - two converters are opened for each call
     *      - only single-string conversion is possible, not streaming operation
     *  - does not provide enough information to find out, in case of failure, whether the toUnicode or the 
     *    fromUnicode conversion failed
     *  - allows NUL-terminated input (only a single NUL byte, will not work for charsets with multi-byte NULs) (if 
     *    sourceLength==-1, see parameters)
     *  - terminate with a NUL on output (only a single NUL byte, not useful for charsets with multi-byte NULs), 
     *     or set U_STRING_NOT_TERMINATED_WARNING if the output exactly fills the target buffer
     *  - a pivot buffer is provided internally
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ab281edb8941c4f19786c786f0d1e6d10 `ucnv_convert`}
     * 
     * @param {String} toConverterName The name of the converter that is used to convert from the UTF-16 pivot buffer 
     *      to the target.
     * @param {String} fromConverterName The name of the converter that is used to convert from the source to the 
     *      UTF-16 pivot buffer.
     * @param {Integer} target Pointer to the output buffer.
     * @param {Integer} targetCapacity Capacity of the target, in bytes.
     * @param {Integer} source Pointer to the input buffer.
     * @param {Integer} sourceLength Length of the input text, in bytes, or -1 for NUL-terminated input.
     * @returns {Integer} Length of the complete output text in bytes, even if it exceeds the targetCapacity and a 
     *      U_BUFFER_OVERFLOW_ERROR is set. This method does *not* throw for a U_BUFFER_OVERFLOW_ERROR. 
     */
    static Convert(toConverterName, fromConverterName, target, targetCapacity, source, sourceLength) {
        convertedLength := DllCall("icu.dll\ucnv_convert",
            "astr", toConverterName,
            "astr", fromConverterName,
            "ptr", target,
            "int", targetCapacity,
            "ptr", source,
            "int", sourceLength,
            "int*", &stat := 0,
            "cdecl int")
        
        if ICUError.IsError(stat) && (ICUError.GetName(stat) != "U_BUFFER_OVERFLOW_ERROR")
            throw ICUError(stat)

        return convertedLength
    }

    /**
     * Convert from one external charset to another, using explicit converter objects and optional explicit pivot
     * buffer.
     *
     * This is a more powerful and flexible version of {@link CharsetConverter.Convert `Convert`}. Unlike `Convert`:
     *  - it takes open converter objects, avoiding repeated open/close overhead in streaming scenarios
     *  - it supports streaming: call multiple times with partial buffers until all input is consumed
     *  - it accepts an explicit pivot buffer for state management across calls (pass `0` to use an internal buffer,
     *    requiring `reset` and `flush` to both be `true`)
     *
     * On each call, `target` and `source` are advanced past the converted data. For streaming use, keep calling
     * until `source` reaches `sourceLimit`.
     *
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a8c2852929b99ca983ccd1f33a203cc2a `ucnv_convertEx`}
     * @param {CharsetConverter} targetCnv the converter used to encode the target (output)
     * @param {CharsetConverter} sourceCnv the converter used to decode the source (input)
     * @param {VarRef<Integer>} target on input a pointer to the start of the target buffer; updated on return to
     *      point past the last byte written
     * @param {Integer} targetLimit pointer one byte past the end of the target buffer
     * @param {VarRef<Integer>} source on input a pointer to the next input byte; updated on return to point past
     *      the last byte consumed
     * @param {Integer} sourceLimit pointer one byte past the end of the source buffer
     * @param {Integer} pivotStart pointer to the start of a UChar pivot buffer, or `0` to use an internal buffer
     *      (requires `reset` and `flush` to be `true`)
     * @param {VarRef<Integer>} pivotSource current read position within the pivot buffer (updated on return)
     * @param {VarRef<Integer>} pivotTarget current write position within the pivot buffer (updated on return)
     * @param {Integer} pivotLimit pointer one past the end of the pivot buffer; ignored when `pivotStart` is `0`
     * @param {Integer} reset if truthy, reset both converters before converting; must be `true` when `pivotStart`
     *      is `0`
     * @param {Integer} flush if truthy, indicates the end of the input and flushes incomplete sequences; must be
     *      `true` when `pivotStart` is `0`
     */
    static ConvertEx(targetCnv, sourceCnv, &target, targetLimit, &source, sourceLimit,
        pivotStart := 0, &pivotSource := 0, &pivotTarget := 0, pivotLimit := 0,
        reset := false, flush := false) => (
        DllCall("icu.dll\ucnv_convertEx",
            "ptr", targetCnv,
            "ptr", sourceCnv,
            "ptr*", &target,
            "ptr", targetLimit,
            "ptr*", &source,
            "ptr", sourceLimit,
            "ptr", pivotStart,
            "ptr*", &pivotSource,
            "ptr*", &pivotTarget,
            "ptr", pivotLimit,
            "char", reset,
            "char", flush,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Gives the number of aliases for a given converter or alias name.
     * 
     * If the alias is ambiguous, then the preferred converter is used and the status is set to 
     * U_AMBIGUOUS_ALIAS_WARNING. This method only enumerates the listed entries in the alias file.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ad163e29901ae9f055c1c24e08a82d16b `ucnv_countAliases`}
     * @param {String} alias alias name
     * @returns {Integer} number of names on alias list for given alias
     */
    static CountAliases(alias) => (
        count := DllCall("icu.dll\ucnv_countAliases", "astr", alias, "int*", &stat := 0, "cdecl ushort"),
        ICUError.ThrowFor(stat, true),
        count)

    /**
     * Gives the name of the alias at given index of alias list.
     * 
     * This method only enumerates the listed entries in the alias file. If the alias is ambiguous, then the preferred 
     * converter is used and the status is set to U_AMBIGUOUS_ALIAS_WARNING.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#aab8b957f4d59bf15722ec041820c60ce `ucnv_getAlias`}
     * 
     * @param {String} alias alias name 
     * @param {Integer} n index in alias list
     * @returns {String} returns the name of the alias at given index
     */
    static GetAlias(alias, n) => (
        name := DllCall("icu.dll\ucnv_getAlias", "astr", alias, "short", n, "int*", &stat := 0, "cdecl astr"),
        ICUError.ThrowFor(stat, true),
        name)

    /**
     * Get a list of alias names for the given alias.
     * 
     * This method only enumerates the listed entries in the alias file. If the alias is ambiguous, then the preferred 
     * converter is used and the status is set to U_AMBIGUOUS_ALIAS_WARNING.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a71252fa8748b2f37604a7cc6baa7bba6 `ucnv_getAliases`}
     * 
     * @param {String} alias alias name 
     * @returns {Array<String>} a list of aliases for the input alias 
     */
    static GetAliases(alias) {
        n := this.CountAliases(alias)
        
        DllCall("icu.dll\ucnv_getAliases", 
            "astr", alias,
            "ptr", arrBuf := Buffer(n * A_PtrSize, 0),
            "int*", &stat := 0,
            "cdecl")
        ICUError.ThrowFor(stat)

        outArr := Array(), outArr.Length := n
        loop n {
            strPtr := NumGet(arrBuf, (A_Index - 1) * A_PtrSize, "ptr")
            outArr[A_Index] := StrGet(strPtr, , "UTF-8")
        }

        return outArr
    }

    /**
     * Returns the number of available converters, as per the alias file.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ab759c0b6fc64dfb067a81bdf2f2a9d6b `ucnv_countAvailable`}
     * @returns {Integer} the number of available converters
     */
    static CountAvailable() => DllCall("icu.dll\ucnv_countAvailable", "cdecl int")

    /**
     * Gets the canonical converter name of the specified converter from a list of all available converters
     * contained in the alias table.
     *
     * The number of available converters can be obtained from {@link CharsetConverter.CountAvailable `CountAvailable`}.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a5cce23e2efed3fcb0bff9dc0d1ae9498 `ucnv_getAvailableName`}
     * @param {Integer} n index of the available converter, from 0 to `CountAvailable() - 1`
     * @returns {String} the canonical converter name at the given index.
     */
    static GetAvailableName(n) => DllCall("icu.dll\ucnv_getAvailableName", "int", n, "cdecl astr")

    /**
     * Gives the number of standards associated to converter names.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a97ca1c3ee6b804a38a8993e17a47aab3 `ucnv_countStandards`}
     * @returns {Integer} number of standards
     */
    static CountStandards() => DllCall("icu.dll\ucnv_countStandards", "cdecl ushort")

    /**
     * Gives the name of the standard at given index of standard list.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a683eba61e398605d3a57d4708268922c `ucnv_getStandard`}
     * @param {Integer} index in standard list
     * @returns {String} returns the name of the standard at given index.
     */
    static GetStandard(n) => (
        standard := DllCall("icu.dll\ucnv_getStandard", "short", n, "int*", &stat := 0, "cdecl astr"),
        ICUError.ThrowFor(stat),
        standard)
    
    /**
     * Returns a standard name for a given converter name.
     * 
     * Example alias table: `conv alias1 { STANDARD1 } alias2 { STANDARD1* }`
     * 
     * Result of `ucnv_getStandardName("conv", "STANDARD1")` from example alias table: `"alias2"`
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ae8295835ea44ddd53fcb6f81bff9e21c `ucnv_getStandardName`}
     * 
     * @param {String} name original converter name
     * @param {String} standard name of the standard governing the names; MIME and IANA are such standards
     * @returns {String} returns the standard converter name; if a standard converter name cannot be determined, 
     *      then NULL is returned
     */
    static GetStandardName(name, standard) => (
        name := DllCall("icu.dll\ucnv_getStandardName",
            "astr", name,
            "astr", standard,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        name == 0 ? "" : StrGet(name, , "CP0"))

    /**
     * Return a new {@link ICUEnumerator `ICUEnumerator`} object for enumerating all the alias names for a given 
     * converter that are recognized by a standard.
     * 
     * This method only enumerates the listed entries in the alias file. The `convrtrs.txt` file can be modified to 
     * change the results of this function. The first result in this list is the same result given by {@link CharsetConverter.GetStandardName `GetStandardName`}, 
     * which is the default alias for the specified standard name.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a1c9c616b4f5bb889cb5ffaa8c55469f1 `ucnv_openStandardNames`}
     * 
     * @param {String} name original converter name
     * @param {String} standard name of the standard governing the names; MIME and IANA are such standards
     * @returns {ICUEnumerator} An {@link ICUEnumerator `ICUEnumerator`} object for getting all aliases that are 
     *      recognized by a standard.
     */
    static GetAllStandardNames(name, standard) => (
        en := DllCall("icu.dll\ucnv_openStandardNames",
            "astr", name,
            "astr", standard,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        ICUEnumerator(en))

    /**
     * This function will return the internal canonical converter name of the tagged alias.
     * 
     * This is the opposite of {@link CharsstConverter.GetAllStandardNames `GetAllStandardNames`}, which returns the 
     * tagged alias given the canonical name.
     * 
     * Example alias table: `conv alias1 { STANDARD1 } alias2 { STANDARD1* }`
     * 
     * Result of `GetCanonicalName("alias1", "STANDARD1")` from example alias table: `"conv"`
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a87227bd73fa17240aceb4a2fc131e221 `ucnv_getCanonicalName`}
     * @param {String} alias alias to get the canonical name of
     * @param {String} standard name of the standard governing the names; MIME and IANA are such standards
     * @returns {String} returns the canonical converter name; if a standard or alias name cannot be determined, then
     *      an empty string is returned
     */
    static GetCanonicalName(alias, standard) => (
        name := DllCall("icu.dll\ucnv_getCanonicalName",
            "astr", alias,
            "astr", standard,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        name == 0 ? "" : StrGet(name, , "CP0"))

    /**
     * Detects Unicode signature byte sequences at the start of the byte stream and returns the charset name of the 
     * indicated Unicode charset
     * 
     * The caller can `Open` a converter using the charset name. The first code unit (UChar) from the start of the 
     * stream will be U+FEFF (the Unicode BOM/signature character) and can usually be ignored.
     * 
     * For most Unicode charsets it is also possible to ignore the indicated number of initial stream bytes and start 
     * converting after them. However, there are stateful Unicode charsets (UTF-7 and BOCU-1) for which this will not 
     * work. Therefore, it is best to ignore the first output UChar instead of the input signature bytes.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a838802e9280caaf02172fbe1e743a8ee `ucnv_detectUnicodeSignature`}
     * 
     * @param {Integer | Buffer} source The source string in which the signature should be detected.
     * @param {Integer} sourceLength Length of the input string, or -1 if terminated with a NUL byte.
     * @param {Integer} signatureLength Optionial output parameter which receives the number of bytes that make up the 
     *      signature of the detected UTF. 
     * @returns {String} The name of the encoding detected, or an empty string if encoding is not detected
     */
    static DetectUnicodeSignature(source, sourceLength, &signatureLength := 0) {
        encoding := DllCall("icu.dll\ucnv_detectUnicodeSignature",
            "ptr", source,
            "int", sourceLength,
            "int*", &signatureLength,
            "int*", &stat := 0,
            "cdecl ptr")
        ICUError.ThrowFor(stat)
        return encoding == 0 ? "" : StrGet(encoding, , "CP0")
    }

    /**
     * Creates a Converter object with the name of a coded character set specified as a string.
     * 
     * The actual name will be resolved with the alias file using a case-insensitive string comparison that ignores 
     * leading zeroes and all non-alphanumeric characters. E.g., the names "UTF8", "utf-8", "u*T@f08" and "Utf 8" are 
     * all equivalent. (See also `CompareNames`) If NULL is passed for the converter name, it will create one with the 
     * getDefaultName return value.
     * 
     * A converter name for ICU 1.5 and above may contain options like a locale specification to control the specific 
     * behavior of the newly instantiated converter. The meaning of the options depends on the particular converter. 
     * If an option is not defined for or recognized by a given converter, then it is ignored.
     * 
     * Options are appended to the converter name string, with a UCNV_OPTION_SEP_CHAR between the name and the first 
     * option and also between adjacent options.
     * 
     * The conversion behavior and names can vary between platforms. ICU may convert some characters differently from 
     * other platforms. Details on this topic are in the [User Guide](https://unicode-org.github.io/icu/userguide/conversion/). 
     * Aliases starting with a "cp" prefix have no specific meaning other than its an alias starting with the letters 
     * "cp". Please do not associate any meaning to these aliases.
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#abe52185c0f4c3e001f0df1f17b08f0bc `ucnv_open`}
     *      and {@link CharsetConverter.OpenU `CharsetConverter.OpenU`}
     * @param {String | Integer} converterName the name of the converter to use (optionally with options), a pointer
     *      to an ASCII string containing such a name, or the pure Integer 0 to use the default converter.
     * @param {Boolean} strict if true, throw for warnings as well as hard errors
     * @returns {CharsetConverter} the new converter
     */
    static Open(converterName, strict := true) {
        ptr := DllCall("icu.dll\ucnv_open",
            converterName is Integer ? "ptr" : "astr", converterName,
            "int*", &stat := 0,
            "cdecl ptr"
        )
        ICUError.ThrowFor(stat, strict)
        return CharsetConverter(ptr)
    }

    /**
     * Creates a converter specified using a Coded Character Set ID number (CCSID) and a platform specifier.
     *
     * Note that the usefulness of this function is limited to platforms with numeric encoding IDs. Only IBM and 
     * Microsoft platforms use numeric (16-bit) identifiers for encodings.
     * 
     * In addition, IBM CCSIDs and Unicode conversion tables are not 1:1 related. For many IBM CCSIDs there are 
     * multiple (up to six) Unicode conversion tables, and for some Unicode conversion tables there are multiple 
     * CCSIDs. Some "alternate" Unicode conversion tables are provided by the IBM CDRA conversion table registry. The 
     * most prominent example of a systematic modification of conversion tables that is not provided in the form of 
     * conversion table files in the repository is that S/390 Unix System Services swaps the codes for Line Feed and 
     * New Line in all EBCDIC codepages, which requires such a swap in the Unicode conversion tables as well.
     * 
     * Only IBM default conversion tables are accessible with `OpenCSSID`. {@link CharsetConverter.Prototype.CSSID `CSSID`} 
     * will return the same CCSID for all conversion tables that are associated with that CCSID.
     * 
     * Currently, the only "platform" supported in the ICU converter API is UCNV_IBM.
     * 
     * In summary, the use of CCSIDs and the associated API functions is not recommended.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#aa137eaca8feb7bc66876472288c3cbb2 `ucnv_openCCSID`}
     *
     * @param {Integer} codepage the CCSID to identify the converter
     * @param {Integer} platform the platform in which the codepage number exists; pass `0` for IBM or `-1` for
     *      unknown
     * @param {Boolean} strict if true, throw for warnings as well as hard errors
     * @returns {CharsetConverter} the new converter
     */
    static OpenCCSID(codepage, platform := 0, strict := true) {
        ptr := DllCall("icu.dll\ucnv_openCCSID",
            "int", codepage,
            "int", platform,
            "int*", &stat := 0,
            "cdecl ptr")
        ICUError.ThrowFor(stat, strict)
        return CharsetConverter(ptr)
    }

    /**
     * Creates a Unicode converter with the names specified as unicode string.
     * 
     * The name should be limited to the ASCII-7 alphanumerics range. The actual name will be resolved with the alias 
     * file using a case-insensitive string comparison that ignores leading zeroes and all non-alphanumeric characters. 
     * E.g., the names "UTF8", "utf-8", "u*T@f08" and "Utf 8" are all equivalent. (See also {@link CharsetConverter.CompareNames `CharsetConverter.CompareNames`}.)
     * If NULL is passed for the converter name, it will create one with the `getDefaultName` return value. If 
     * the alias is ambiguous, a U_AMBIGUOUS_ALIAS_WARNING error is thrown.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#abbf8a957d94b1222ddfcadf3a5db75d5 `ucnv_openU`} and
     *      {@link CharsetConverter.Open `CharsetConverter.Open`}
     * 
     * @param {String | Integer} converterName the name of the converter to use (optionally with options), a pointer
     *      to a Unicode string containing such a name, or the pure Integer 0 to use the default converter.
     * @param {Boolean} strict if true, throw for warnings as well as hard errors  
     * @returns {CharsetConverter} the new converter
     */
    static OpenU(converterName, struct := true) {
        ptr := DllCall("icu.dll\ucnv_openu",
            converterName is Integer ? "ptr" : "str", converterName,
            "int*", &stat := 0,
            "cdecl ptr"
        )
        ICUError.ThrowFor(stat, struct)
        return CharsetConverter(ptr)
    }

    /**
     * Creates a `CharsetConverter` object specified from a packageName and a converterName.
     * 
     * The packageName and converterName must point to an ICU udata object, as defined by 
     * `udata_open( packageName, "cnv", converterName, err)` or equivalent. Typically, packageName will refer to a 
     * (.dat) file, or to a package registered with `udata_setAppData()`. Using a full file or directory pathname for 
     * packageName is deprecated.
     * 
     * The name will NOT be looked up in the alias mechanism, nor will the converter be stored in the converter cache
     * or the alias table. The only way to open further converters is call this function multiple times, or use the 
     * `Clone` function to clone a 'primary' converter.
     * 
     * A future version of ICU may add alias table lookups and/or caching to this function.
     * 
     * Example Use: `cnv = ucnv_openPackage("myapp", "myconverter", &err);`
     * 
     * This method is probably of limited use in AutoHotkey scripts
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ae88b63a29cd9c28cb223b04488bcd2ae `ucnv_openPackage`}
     * @param {String | Integer} packageName name of the package (equivalent to 'path' in udata_open() call)
     * @param {String | Integer} converterName name of the data item to be used, without suffix.
     * @returns {CharsetConverter} the created converter object
     */
    static OpenPackage(packageName, converterName) {
        ptr := DllCall("icu.dll\ucnv_openPackage", 
            "ptr", this, 
            packageName is Integer ? "ptr" : "astr", packageName,
            converterName is Integer ? "ptr" : "astr", converterName,
            "int*", &stat := 0,
            "cdecl ptr")
        ICUError.ThrowFor(stat)
        return CharsetConverter(ptr)
    }

    /**
     * Frees up memory occupied by unused, cached converter shared data.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a436883f563d59f9a10995c9fa8f6ac34 `ucnv_flushCache`}
     * @returns {Integer} the number of cached converters successfully deleted
     */
    static FlushCache() => DllCall("icu.dll\ucnv_flushCache", "cdecl")

;@endregion Static Methods
;@region Instance Properties

    /**
     * Returns the maximum number of bytes that are output per UChar in conversion from Unicode using this converter.
     * 
     * The returned number can be used with UCNV_GET_MAX_BYTES_FOR_STRING to calculate the size of a target buffer for 
     * conversion from Unicode.
     * 
     * Note: Before ICU 2.8, this function did not return reliable numbers for some stateful converters 
     * (EBCDIC_STATEFUL, ISO-2022) and LMBCS.
     * 
     * This number may not be the same as the maximum number of bytes per "conversion unit". In other words, it may 
     * not be the intuitively expected number of bytes per character that would be published for a charset, and may 
     * not fulfill any other purpose than the allocation of an output buffer of guaranteed sufficient size for a given 
     * input length and converter.
     * 
     * Examples for special cases that are taken into account:
     *  -   Supplementary code points may convert to more bytes than BMP code points. This function returns bytes per 
     *      UChar (UTF-16 code unit), not per Unicode code point, for efficient buffer allocation.
     *  -   State-shifting output (SI/SO, escapes, etc.) from stateful converters.
     *  -   When m input UChars are converted to n output bytes, then the maximum m/n is taken into account.
     * 
     * The number returned here does not take into account (see {@link CharsetConverter.GetMaxBytesForString `CharsetConverter.GetMaxBytesForString`}):
     *  -   callbacks which output more than one charset character sequence per call, like escape callbacks
     *  -   initial and final non-character bytes that are output by some converters (automatic BOMs, initial escape
     *      sequence, final SI, etc.)
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#af43eaa49c8f0e9bd5c63ace95b014d8b `ucnv_getMaxCharSize`}
     * @type {Integer} The maximum number of bytes per UChar (16 bit code unit) that are output by {@link CharsetConverter.FromUnicode `CharsetConverter.FromUnicode`}
     *      to be used together with {@link CharsetConverter.GetMaxBytesForString `CharsetConverter.GetMaxBytesForString`}
     *      for buffer allocation.
     */
    MaxCharSize => DllCall("icu.dll\ucnv_getMaxCharSize", "ptr", this, "cdecl char")

    /**
     * Returns the minimum byte length (per codepoint) for characters in this codepage.
     * 
     * This is usually either 1 or 2.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a5cca1b29e06b6423cd29e052f63f3c68 `ucnv_getMinCharSize`}
     * @type {Integer}
     */
    MinCharSize => DllCall("icu.dll\ucnv_getMinCharSize", "ptr", this, "cdecl char")

    /**
     * Gets the internal, canonical name of the converter (null-terminated).
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#adcd3d700402d315e8f08d1464bc225d3 `ucnv_getName`}
     * @type {String}
     */
    Name => (
        name := DllCall("icu.dll\ucnv_getName", "ptr", this, "int*", &stat := 0, "cdecl astr"),
        ICUError.ThrowFor(stat),
        name)

    /**
     * Gets a codepage number associated with the converter.
     * 
     * This is not guaranteed to be the one used to create the converter. Some converters do not represent platform 
     * registered codepages and return zero for the codepage number. The error code fill-in parameter indicates if the 
     * codepage number is available. Does not check if the converter is NULL or if converter's data table is NULL.
     * 
     * Important: The use of CCSIDs is not recommended because it is limited to only two platforms in principle and 
     * only one (UCNV_IBM) in the current ICU converter API. Also, CCSIDs are insufficient to identify IBM Unicode 
     * conversion tables precisely. For more details see {@link CharsetConverter.OpenCSSID `OpenCSSID`}.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ac3017dbb7a664efd2ae476b3eba4ce20 `ucnv_getCSSID`}
     * @type {Integer}
     */
    CSSID => (
        cssid := DllCall("icu.dll\ucnv_getCCSID", "ptr", this, "int*", &stat := 0, "cdecl int"),
        ICUError.ThrowFor(stat),
        cssid)

    /**
     * Gets a codepage platform associated with the converter.
     * 
     * Currently, only UCNV_IBM will be returned. Does not test if the converter is NULL or if converter's data table 
     * is NULL.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#afbd1f5da2cc33604d1f3cea3da236b38 `ucnv_getPlatform`}
     * @type {Integer}
     */
    Platform => (
        pform := DllCall("icu.dll\ucnv_getPlatform", "ptr", this, "int*", &stat := 0, "cdecl uint"),
        ICUError.ThrowFor(stat),
        pform)

    /**
     * Gets the type of the converter e.g. SBCS, MBCS, DBCS, UTF8, UTF16_BE, UTF16_LE, ISO_2022, EBCDIC_STATEFUL, 
     * LATIN_1. This will be one of the values in the {@link ConverterType `ConverterType`} enum.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a8f9995074da46c1782966266173f001a `ucnv_getType`}
     * @type {String}
     */
    Type => DllCall("icu.dll\ucnv_getType", "ptr", this, "cdecl uint")

    /**
     * Determines if the converter contains ambiguous mappings of the same character or not.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a1dc5175e11146da34b4dab48e1fe196e `ucnv_isAmbiguous`}
     * @type {Integer} 1 if the converter contains ambiguous mapping of the same character, 0 otherwise.
     */
    IsAmbiguous => DllCall("icu.dll\ucnv_isAmbiguous", "ptr", this, "cdecl char")

    /**
     * Returns whether or not the charset of the converter has a fixed number of bytes per charset character.
     * 
     * An example of this are converters that are of the type UCNV_SBCS or UCNV_DBCS. Another example is UTF-32 which 
     * is always 4 bytes per character. A Unicode code point may be represented by more than one UTF-8 or UTF-16 code 
     * unit but a UTF-32 converter encodes each code point with 4 bytes. Note: This method is not intended to be used 
     * to determine whether the charset has a fixed ratio of bytes to Unicode codes units for any particular Unicode 
     * encoding form. false is returned with the UErrorCode if error occurs or cnv is NULL.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a87d7aecb934aede71851def1ea339e4e `ucnv_isFixedWidth`}
     * @type {Integer}
     */
    IsFixedWidth => (
        val := DllCall("icu.dll\ucnv_isFixedWidth", "ptr", this, "int*", &stat := 0, "cdecl char"),
        ICUError.ThrowFor(stat),
        val)

    /**
     * Gets or sets whether this converter uses fallback mappings for unmappable characters.
     *
     * Fallback mappings are lossy conversions included in some ICU conversion tables as best-effort alternatives
     * when a precise round-trip mapping does not exist. Fallbacks are disabled by default.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a5c167611f1e5de3e9403816ac8254710 `ucnv_setFallback`} and
     *      {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a0be04af9e511098f0b42132ed5964dfb `ucnv_usesFallback`}
     * @type {Integer}
     */
    UsesFallback {
        get => DllCall("icu.dll\ucnv_usesFallback", "ptr", this, "cdecl char")
        set => DllCall("icu.dll\ucnv_setFallback", "ptr", this, "char", value, "cdecl")
    }

    /**
     * Returns the number of UChars held in the converter's internal from-Unicode state that have not yet been
     * converted to the target charset.
     *
     * This is useful to detect incomplete sequences at the end of a streaming conversion.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#adb065b7305e22375f6616a7f01e107be `ucnv_fromUCountPending`}
     * @type {Integer}
     */
    FromUCountPending => (
        count := DllCall("icu.dll\ucnv_fromUCountPending", "ptr", this, "int*", &stat := 0, "cdecl int"),
        ICUError.ThrowFor(stat),
        count)

    /**
     * Returns the number of bytes held in the converter's internal to-Unicode state that have not yet been
     * converted to UChars.
     *
     * This is useful to detect incomplete byte sequences at the end of a streaming conversion.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ad07fce62cb530974aab903210dbb62b1 `ucnv_toUCountPending`}
     * @type {Integer}
     */
    ToUCountPending => (
        count := DllCall("icu.dll\ucnv_toUCountPending", "ptr", this, "int*", &stat := 0, "cdecl int"),
        ICUError.ThrowFor(stat),
        count)

;@endregion Instance Properties
;@region Instance Methods

    /**
     * @private Initializes a CharsetConverter object at a pointer. Do not call this directly - use `Open` or another
     * factory method.
     */
    __New(ptr) {
        if !(ptr is Integer)
            throw TypeError("Expected an Integer but got a(n) " Type(ptr), -1, ptr)
        this.ptr := ptr
    }

    /**
     * Clones the converter. Not that it matters, but this operation is thread-safe.
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a25ae0b75cbb6136f7a0c398d8b0089c6 `ucnv_clone`}
     * @returns {CharsetConverter} the cloned converter
     */
    Clone() {
        new := DllCall("icu.dll\ucnv_clone", "ptr", this, "int*", &stat := 0, "cdecl ptr")
        ICUError.ThrowFor(stat)
        return CharsetConverter(new)
    }

    /**
     * Resets the state of a converter to the default state.
     * 
     * This is used in the case of an error, to restart a conversion from a known default state. It will also empty
     * the internal output buffers.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a60c34691dd1b509a9ad793fd01c506d6 `ucnv_reset`}
     * @returns {void} 
     */
    Reset() => DllCall("icu.dll\ucnv_reset", "ptr", this, "cdecl")

    /**
     * Resets the from-Unicode part of a converter state to the default state.
     * 
     * This is used in the case of an error to restart a conversion from Unicode to a known default state. It will 
     * also empty the internal output buffers used for the conversion from Unicode codepoints.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a4bead45a337a2c4094e8772d24e4fe83 `ucnv_resetFromUnicode`}
     * @returns {void} 
     */
    ResetFromUnicode() => DllCall("icu.dll\ucnv_resetFromUnicode", "ptr", this, "cdecl")

    /**
     * Resets the to-Unicode part of a converter state to the default state.
     * 
     * This is used in the case of an error to restart a conversion to Unicode to a known default state. It will also
     * empty the internal output buffers used for the conversion to Unicode codepoints.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#aee6c52a0f4df13612abec5a5c52602f9 `ucnv_resetToUnicode`}
     * @returns {void} 
     */
    ResetToUnicode() => DllCall("icu.dll\ucnv_resetToUnicode", "ptr", this, "cdecl")

    /**
     * Fixes the backslash character mismapping.
     * 
     * For example, in SJIS, the backslash character in the ASCII portion is also used to represent the yen currency 
     * sign. When mapping from Unicode character 0x005C, it's unclear whether to map the character back to yen or 
     * backslash in SJIS. This function will take the input buffer and replace all the yen sign characters with 
     * backslash. This is necessary when the user tries to open a file with the input buffer on Windows. This function 
     * will test the converter to see whether such mapping is required. You can sometimes avoid using this function by 
     * using the correct version of Shift-JIS.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ae3883bd2446534098433cbae1ea0537c `ucnv_fixFileSeparator`}
     * 
     * @param {Integer | Buffer} source the input buffer to be fixed
     * @param {Integer} sourceLen the length of the input buffer 
     */
    FixFileSeparator(source, sourceLen) => DllCall("icu.dll\ucnv_fixFileSeparator",
        "ptr", this,
        "ptr", source,
        "int", sourceLen,
        "cdecl")

    /**
     * Fills in the output parameter, subChars, with the substitution characters as multiple bytes.
     * 
     * If {@link CharsetConverter.Prototype.SetSubstString `SetSubstString`} set a Unicode string because the 
     * converter is stateful, then subChars will be an empty string.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a3a8d48d318650d2fc56c5f03954b44c3 `ucnv_getSubstChars`}
     * 
     * @param {Integer | Buffer} subChars the substitution characters
     * @param {VarRef<Integer>} len on input the capacity of subChars, on output the number of bytes copied to it
     */
    GetSubstChars(subChars, &len) => (
        DllCall("icu.dll\ucnv_getSubstChars", 
            "ptr", this,
            "ptr", subChars,
            "char*", &len,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Sets the substitution chars when converting from unicode to a codepage.
     * 
     * The substitution is specified as a string of 1-4 bytes, and may contain NULL bytes. The `subChars` must represent 
     * a single character. The caller needs to know the byte sequence of a valid character in the converter's charset. 
     * For some converters, for example some {@link https://en.wikipedia.org/wiki/ISO/IEC_2022 ISO 2022} variants, 
     * only single-byte substitution characters may be supported. The newer {@link CharsetConverter.Prototype.SetSubstString `SetSubstString`}
     * function relaxes these limitations.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a9fa1ebc0d0c35aa2c0e79f9a04de0dcc `ucnv_setSubstChars`}
     * 
     * @param {Integer | Buffer} subChars the substitution characters
     * @param {Integer} len the number of bytes in subChars
     */
    SetSubstChars(subChars, len) => (
        DllCall("icu.dll\ucnv_setSubstChars",
            "ptr", this,
            "ptr", subChars,
            "char", len,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Returns the display name of the converter based on the Locale passed in.
     * 
     * If the locale contains no display name, the internal ASCII name will be filled in.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#abe7fb0a1d6704c68ed544afa459bb901 `ucnv_getDisplayName`}
     * 
     * @param {String} displayLocale is the specific Locale we want to localized for
     * @returns {String} the display name of the converter based on the Locale passed in.
     */
    GetDisplayName(displayLocale) {
        _GetDispName(buf) => (
            requiredSize := DllCall("icu.dll\ucnv_getDisplayName",
                "ptr", this,
                "astr", displayLocale,
                "ptr", buf,
                "int", buf.Size,
                "int*", &stat := 0,
                "cdecl int"),
            ; Ignore U_BUFFER_OVERFLOW_ERROR to allow querying for length
            ICUError.ThrowFor(stat == 0 || stat == 15 ? 0 : stat),
            requiredSize
        )
    
        buf := Buffer(64, 0)
        nameLen := _GetDispName(buf)
        if nameLen < buf.Size / 2 {
            return StrGet(buf, nameLen, "UTF-16")
        }

        ; Not large enough, use correct size
        buf.Size := (nameLen * 2) + 1
        nameLen := _GetDispName(buf)
        return StrGet(buf, nameLen, "UTF-16")
    }

    /**
     * Set a substitution string for converting from Unicode to a charset.
     * 
     * The caller need not know the charset byte sequence for each charset.
     * 
     * Unlike {@link CharsetConverter.Prototype.SetSubstChars `SetSubstChars`} which is designed to set a charset byte 
     * sequence for a single character, this function takes a Unicode string with zero, one or more characters, and 
     * immediately verifies that the string can be converted to the charset. If not, or if the result is too long 
     * (more than 32 bytes as of ICU 3.6), then the function returns with an error accordingly.
     * 
     * Also unlike {@link CharsetConverter.Prototype.SetSubstChars `SetSubstChars`}, this function works for stateful 
     * charsets by converting on the fly at the point of substitution rather than setting a fixed byte sequence.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ad5b9ba0b852941559de2a902b1f60cfa `ucnv_setSubstString`}
     * 
     * @param {String | Integer | Buffer} str The Unicode string.
     * @param {Integer} len The number of UChars in s, or -1 for a NUL-terminated string.
     */
    SetSubstString(str, len) => (
        DllCall("icu.dll\ucnv_setSubstString",
            "ptr", this,
            "ptr", str is String ? StrPtr(str) : str,
            "int", len,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Fills in the output parameter, errBytes, with the error characters from the last failing conversion.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a31551ff4d5a3eab83f7999556e7c9808 `ucnv_getInvalidChars`}
     * @param {Buffer | Integer} errBytes the codepage bytes which were in error
     * @param {VarRef<Integer>} len on input the capacity of errBytes, on output the number of bytes which were copied 
     *      to it
     */
    GetInvalidChars(errBytes, &len) => (
        DllCall("icu.dll\ucnv_getInvalidChars",
            "ptr", this,
            "ptr", errBytes,
            "char*", &len,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Fills in the output parameter, errChars, with the error characters from the last failing conversion.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ab7c6ae5a6c0ba532a69e6c49c96a0df9 `ucnv_getInvalidUChars`}
     * @param {Buffer | Integer} errBytes the UChars which were in error
     * @param {VarRef<Integer>} len on input the capacity of errUChars, on output the number of UChars which were 
     *      copied to it
     */
    GetInvalidUChars(errUChars, &len) => (
        DllCall("icu.dll\ucnv_getInvalidUChars",
            "ptr", this,
            "ptr", errUChars,
            "char*", &len,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))


    /**
     * Convert from one external charset to another.
     * 
     * Internally, the text is converted to and from the 16-bit Unicode "pivot" using ucnv_convertEx(). 
     * `FromAlgorithmic` works exactly like {@link Converter.Convert `Convert`} except that the two converters need 
     * not be looked up and opened completely.
     * 
     * The source-to-pivot conversion uses a purely algorithmic converter according to the specified type, e.g., 
     * UCNV_UTF8 for a UTF-8 converter. The pivot-to-target conversion uses the cnv converter parameter.
     * 
     * Internally, the algorithmic converter is opened and closed for each function call, which is more efficient than 
     * using the public {@link Converter.Open `Open`} but somewhat less efficient than only resetting an existing 
     * converter and using `ucnv_convertEx()`.
     * 
     * This function is more convenient than ucnv_convertEx() for single-string conversions, especially when 
     * "preflighting" is desired (returning the length of the complete output even if it does not fit into the target 
     * buffer; see the User Guide Strings chapter). See {@link Converter.Convert `Convert`} for details.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a252d83e05a2338446bb59e439e06c579 `ucnv_fromAlgorithmic`}
     * 
     * @param {Integer} algorithmicType `ConverterType` constant identifying the desired source charset as a purely
     *      algorithmic converter. Those are converters for Unicode charsets like UTF-8, BOCU-1, SCSU, UTF-7,
     *      IMAP-mailbox-name, etc., as well as US-ASCII and ISO-8859-1.
     * @param {Integer | Buffer} target Pointer to the output buffer.
     * @param {Integer} targetCapacity Capacity of the target, in bytes.
     * @param {Integer | Buffer} source Pointer to the input buffer.
     * @param {Integer} sourceLength Length of the input text, in bytes
     * @returns {Integer} Length of the complete output text in bytes, even if it exceeds the targetCapacity and a 
     *      U_BUFFER_OVERFLOW_ERROR is set.
     */
    FromAlgorithmic(algorithmicType, target, targetCapacity, source, sourceLength) {
        outputLength := DllCall("icu.dll\ucnv_fromAlgorithmic",
            "ptr", this,
            "uint", algorithmicType,
            "ptr", target,
            "int", targetCapacity,
            "ptr", source,
            "int", sourceLength,
            "int*", &stat := 0,
            "cdecl int")

        if ICUError.IsError(stat) && (ICUError.GetName(stat) != "U_BUFFER_OVERFLOW_ERROR")
            throw ICUError(stat)

        return outputLength
    }

    /**
     * Convert the Unicode string in `src` to codepage bytes and put the result in `dest`.
     *
     * Preflighting: if `destCapacity` is 0 or smaller than the required output, the function returns the required
     * size without throwing, analogous to the U_BUFFER_OVERFLOW_ERROR behaviour of other ICU functions.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a4e7ebc80f4ee5a02472b139dbaa99c0f `ucnv_fromUChars`}
     *
     * @param {Integer | Buffer} dest output buffer for the converted codepage bytes
     * @param {Integer} destCapacity capacity of `dest` in bytes; pass `0` to preflight
     * @param {String | Integer} src the source UChar string or a pointer to one
     * @param {Integer} srcLength number of UChars in `src`, or `-1` for a NUL-terminated string
     * @returns {Integer} the number of bytes required in `dest`, even if it exceeds `destCapacity`
     */
    FromUChars(dest, destCapacity, src, srcLength) {
        len := DllCall("icu.dll\ucnv_fromUChars",
            "ptr", this,
            "ptr", dest,
            "int", destCapacity,
            "ptr", src is String ? StrPtr(src) : src,
            "int", srcLength,
            "int*", &stat := 0,
            "cdecl int")
        if ICUError.IsError(stat) && (ICUError.GetName(stat) != "U_BUFFER_OVERFLOW_ERROR")
            throw ICUError(stat)
        return len
    }

    /**
     * Convert the codepage bytes in `src` to Unicode UChars and put the result in `dest`.
     *
     * Preflighting: if `destCapacity` is 0 or smaller than the required output, the function returns the required
     * size (in UChars) without throwing.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ae1049fcb893783c860fe0f9d4da84939 `ucnv_toUChars`}
     *
     * @param {Integer | Buffer} dest output buffer for the UChars
     * @param {Integer} destCapacity capacity of `dest` in UChars; pass `0` to preflight
     * @param {Integer | Buffer} src the source codepage bytes
     * @param {Integer} srcLength number of bytes in `src`, or `-1` for a NUL-terminated single-byte string
     * @returns {Integer} the number of UChars required in `dest`, even if it exceeds `destCapacity`
     */
    ToUChars(dest, destCapacity, src, srcLength) {
        len := DllCall("icu.dll\ucnv_toUChars",
            "ptr", this,
            "ptr", dest,
            "int", destCapacity,
            "ptr", src,
            "int", srcLength,
            "int*", &stat := 0,
            "cdecl int")
        if ICUError.IsError(stat) && (ICUError.GetName(stat) != "U_BUFFER_OVERFLOW_ERROR")
            throw ICUError(stat)
        return len
    }

    /**
     * Decode a single Unicode code point from the current position in a codepage byte stream.
     *
     * The `source` pointer is advanced past the bytes consumed. Returns `0xFFFF` (U+FFFF) if a callback was
     * invoked and did not produce a code point.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a51b29c8ad1beab018718a0982e4ffa07 `ucnv_getNextUChar`}
     *
     * @param {VarRef<Integer>} source on input a pointer to the next input byte; advanced on return past the
     *      consumed bytes
     * @param {Integer} sourceLimit pointer one byte past the end of the source buffer
     * @returns {Integer} the next Unicode code point (UChar32)
     */
    GetNextUChar(&source, sourceLimit) {
        codepoint := DllCall("icu.dll\ucnv_getNextUChar",
            "ptr", this,
            "ptr*", &source,
            "ptr", sourceLimit,
            "int*", &stat := 0,
            "cdecl int")
        ICUError.ThrowFor(stat)
        return codepoint
    }

    /**
     * Convert a buffer of codepage bytes from this converter's charset to an algorithmic target charset.
     *
     * This is the complement of {@link CharsetConverter.Prototype.FromAlgorithmic `FromAlgorithmic`}: this
     * converter decodes the source bytes, and `algorithmicType` encodes the UTF-16 pivot to the output.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#adcdd972330852322a070f1c61c43a670 `ucnv_toAlgorithmic`}
     *
     * @param {Integer} algorithmicType `ConverterType` constant identifying the target charset (must be a purely
     *      algorithmic converter such as UTF-8, BOCU-1, SCSU, UTF-7, US-ASCII, ISO-8859-1, etc.)
     * @param {Integer | Buffer} target pointer to the output buffer
     * @param {Integer} targetCapacity capacity of the target, in bytes
     * @param {Integer | Buffer} source pointer to the input buffer of bytes in this converter's charset
     * @param {Integer} sourceLength length of the input, in bytes
     * @returns {Integer} length of the complete output text in bytes, even if it exceeds `targetCapacity`
     */
    ToAlgorithmic(algorithmicType, target, targetCapacity, source, sourceLength) {
        outputLength := DllCall("icu.dll\ucnv_toAlgorithmic",
            "uint", algorithmicType,
            "ptr", this,
            "ptr", target,
            "int", targetCapacity,
            "ptr", source,
            "int", sourceLength,
            "int*", &stat := 0,
            "cdecl int")
        if ICUError.IsError(stat) && (ICUError.GetName(stat) != "U_BUFFER_OVERFLOW_ERROR")
            throw ICUError(stat)
        return outputLength
    }

    /**
     * Converts an array of unicode characters to an array of codepage characters.
     * 
     * This function is optimized for converting a continuous stream of data in buffer-sized chunks, where the entire 
     * source and target does not fit in available buffers.
     * 
     * The source pointer is an in/out parameter. It starts out pointing where the conversion is to begin, and ends up 
     * pointing after the last UChar consumed.
     * 
     * Target similarly starts out pointer at the first available byte in the output buffer, and ends up pointing 
     * after the last byte written to the output.
     * 
     * The converter always attempts to consume the entire source buffer, unless (1.) the target buffer is full, or 
     * (2.) a failing error is returned from the current callback function. When a successful error status has been 
     * returned, it means that all of the source buffer has been consumed. At that point, the caller should reset the 
     * source and sourceLimit pointers to point to the next chunk.
     * 
     * At the end of the stream (flush==true), the input is completely consumed when *source==sourceLimit and no error 
     * code is set. The converter object is then automatically reset by this function. (This means that a converter 
     * need not be reset explicitly between data streams if it finishes the previous stream without errors.)
     * 
     * This is a *stateful* conversion. Additionally, even when all source data has been consumed, some data may be in 
     * the converters' internal state. Call this function repeatedly, updating the target pointers with the next empty 
     * chunk of target in case of a U_BUFFER_OVERFLOW_ERROR, and updating the source pointers with the next chunk of 
     * source when a successful error status is returned, until there are no more chunks of source data.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#aa820d3bc3942522eb31bdb5b8ae73727 `ucnv_fromUnicode`}
     *
     * @param {VarRef<Integer>} target on input a pointer to the start of the output buffer; advanced on return
     *      past the last byte written
     * @param {Integer} targetLimit pointer one byte past the end of the target buffer
     * @param {VarRef<Integer>} source on input a pointer to the next UChar to convert; advanced on return past
     *      the last UChar consumed
     * @param {Integer} sourceLimit pointer one UChar past the end of the source buffer
     * @param {Integer} offsets optional pointer to a pre-allocated `int32_t[targetCapacity]` array that receives
     *      the source offset for each output byte; pass `0` to skip
     * @param {Integer} flush `true` on the final call to flush incomplete sequences
     */
    FromUnicode(&target, targetLimit, &source, sourceLimit, offsets := 0, flush := true) => (
        DllCall("icu.dll\ucnv_fromUnicode",
            "ptr", this,
            "ptr*", &target,
            "ptr", targetLimit,
            "ptr*", &source,
            "ptr", sourceLimit,
            "ptr", offsets,
            "char", flush,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Converts a buffer of codepage bytes into an array of unicode UChars characters.
     * 
     * This function is optimized for converting a continuous stream of data in buffer-sized chunks, where the entire 
     * source and target does not fit in available buffers.
     * 
     * The source pointer is an in/out parameter. It starts out pointing where the conversion is to begin, and ends up 
     * pointing after the last byte of source consumed.
     * 
     * Target similarly starts out pointer at the first available UChar in the output buffer, and ends up pointing 
     * after the last UChar written to the output. It does NOT necessarily keep UChar sequences together.
     * 
     * The converter always attempts to consume the entire source buffer, unless (1.) the target buffer is full, or 
     * (2.) a failing error is returned from the current callback function. When a successful error status has been 
     * returned, it means that all of the source buffer has been consumed. At that point, the caller should reset the 
     * source and sourceLimit pointers to point to the next chunk.
     * 
     * At the end of the stream (flush==true), the input is completely consumed when *source==sourceLimit and no error 
     * code is set The converter object is then automatically reset by this function. (This means that a converter 
     * need not be reset explicitly between data streams if it finishes the previous stream without errors.)
     * 
     * This is a stateful conversion. Additionally, even when all source data has been consumed, some data may be in 
     * the converters' internal state. Call this function repeatedly, updating the target pointers with the next empty 
     * chunk of target in case of a U_BUFFER_OVERFLOW_ERROR, and updating the source pointers with the next chunk of 
     * source when a successful error status is returned, until there are no more chunks of source data.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a9451f05be7b1b75832d5ec55b4e6d67f `ucnv_toUnicode`}
     *
     * @param {VarRef<Integer>} target on input a pointer to the start of the output UChar buffer; advanced on
     *      return past the last UChar written
     * @param {Integer} targetLimit pointer one UChar past the end of the target buffer
     * @param {VarRef<Integer>} source on input a pointer to the next input byte; advanced on return past the last
     *      byte consumed
     * @param {Integer} sourceLimit pointer one byte past the end of the source buffer
     * @param {Integer} offsets optional pointer to a pre-allocated `int32_t[targetCapacity]` array that receives
     *      the source offset for each output UChar; pass `0` to skip
     * @param {Integer} flush `true` on the final call to flush incomplete byte sequences
     */
    ToUnicode(&target, targetLimit, &source, sourceLimit, offsets := 0, flush := true) => (
        DllCall("icu.dll\ucnv_toUnicode",
            "ptr", this,
            "ptr*", &target,
            "ptr", targetLimit,
            "ptr*", &source,
            "ptr", sourceLimit,
            "ptr", offsets,
            "char", flush,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Retrieves the current to-Unicode error callback function and its context pointer.
     *
     * The returned `action` pointer identifies the callback function currently installed; it can be passed back to
     * {@link CharsetConverter.Prototype.SetToUCallback `SetToUCallback`} to restore it.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a77ea5ac13592471532532b724e865a7f `ucnv_getToUCallBack`}
     *
     * @param {VarRef<Integer>} action receives the pointer to the current to-Unicode callback function
     * @param {VarRef<Integer>} context receives the pointer to the callback's context data
     */
    GetToUCallback(&action, &context) => DllCall("icu.dll\ucnv_getToUCallBack",
        "ptr", this,
        "ptr*", &action,
        "ptr*", &context,
        "cdecl")

    /**
     * Installs a new to-Unicode error callback function on this converter.
     *
     * The previous callback and its context are returned so they can be restored later.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#acf5d877019d10500135f3baa95aa94b4 `ucnv_setToUCallBack`}
     *
     * @param {Integer} newAction pointer to the new callback function (e.g. obtained via `CallbackCreate`)
     * @param {Integer} newContext context pointer passed to the callback on each invocation; pass `0` for none
     * @param {VarRef<Integer>} oldAction receives the pointer to the previously installed callback
     * @param {VarRef<Integer>} oldContext receives the context pointer of the previously installed callback
     */
    SetToUCallback(newAction, newContext, &oldAction, &oldContext) => (
        DllCall("icu.dll\ucnv_setToUCallBack",
            "ptr", this,
            "ptr", newAction,
            "ptr", newContext,
            "ptr*", &oldAction,
            "ptr*", &oldContext,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Retrieves the current from-Unicode error callback function and its context pointer.
     *
     * The returned `action` pointer identifies the callback function currently installed; it can be passed back to
     * {@link CharsetConverter.Prototype.SetFromUCallback `SetFromUCallback`} to restore it.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#af161e1bdd8f3ba0fd2da8ebee3320140 `ucnv_getFromUCallBack`}
     *
     * @param {VarRef<Integer>} action receives the pointer to the current from-Unicode callback function
     * @param {VarRef<Integer>} context receives the pointer to the callback's context data
     */
    GetFromUCallback(&action, &context) => DllCall("icu.dll\ucnv_getFromUCallBack",
        "ptr", this,
        "ptr*", &action,
        "ptr*", &context,
        "cdecl")

    /**
     * Installs a new from-Unicode error callback function on this converter.
     *
     * The previous callback and its context are returned so they can be restored later.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a2975b51ae20ae5302a83cbfd926ebb86 `ucnv_setFromUCallBack`}
     *
     * @param {Integer} newAction pointer to the new callback function (e.g. obtained via `CallbackCreate`)
     * @param {Integer} newContext context pointer passed to the callback on each invocation; pass `0` for none
     * @param {VarRef<Integer>} oldAction receives the pointer to the previously installed callback
     * @param {VarRef<Integer>} oldContext receives the context pointer of the previously installed callback
     */
    SetFromUCallback(newAction, newContext, &oldAction, &oldContext) => (
        DllCall("icu.dll\ucnv_setFromUCallBack",
            "ptr", this,
            "ptr", newAction,
            "ptr", newContext,
            "ptr*", &oldAction,
            "ptr*", &oldContext,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Returns an array of 256 booleans indicating which byte values are lead bytes of multi-byte sequences for
     * this converter.
     *
     * Only works for MBCS-type converters (`Type == 2`); throws `U_ILLEGAL_ARGUMENT_ERROR` for algorithmic
     * converters (UTF-8, UTF-16, LMBCS, ISO-2022, etc.) which have their own distinct types.
     *
     * Note: only bytes that **begin a multi-byte sequence** are marked. Single-byte characters — including
     * all of ASCII in encodings like Shift-JIS — are **not** marked, even though they are valid characters.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a68a3410a830234700d234ccb813aac05 `ucnv_getStarters`}
     *
     * @returns {Array<Integer>} 256-element Array where each element is `1` if the byte is a lead byte for a
     *      multi-byte sequence, or `0` otherwise
     */
    GetStarters() {
        buf := Buffer(256, 0)
        DllCall("icu.dll\ucnv_getStarters",
            "ptr", this,
            "ptr", buf,
            "int*", &stat := 0,
            "cdecl")
        ICUError.ThrowFor(stat)

        starters := Array()
        starters.Length := 256
        loop 256 {
            starters[A_Index] := NumGet(buf, A_Index - 1, "uchar") != 0
        }
        return starters
    }

    /**
     * Fills the given `USet` with all Unicode code points that this converter can map (in either direction).
     *
     * The caller must allocate and close the `USet`. Create one with `uset_openEmpty` (or similar) from the ICU
     * `uset.h` API, then pass its pointer here. Use {@link ConverterUnicodeSet `ConverterUnicodeSet`} constants for
     * `whichSet`.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a4f1821c0ee81813a52c95249ccf4d179 `ucnv_getUnicodeSet`}
     *
     * @param {Integer} setFillIn pointer to the `USet` to fill (created by the caller; the set is cleared first)
     * @param {Integer} whichSet `ConverterUnicodeSet.ROUNDTRIP` or `ConverterUnicodeSet.ROUNDTRIP_AND_FALLBACK`
     */
    GetUnicodeSet(setFillIn, whichSet := 0) => (
        DllCall("icu.dll\ucnv_getUnicodeSet",
            "ptr", this,
            "ptr", setFillIn,
            "int", whichSet,
            "int*", &stat := 0,
            "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#ae46ba3c408a77cde2b569111c5ac5596 `ucnv_close`}
     */
    __Delete() {
        if this.HasProp("ptr") && this.ptr != 0
            DllCall("icu.dll\ucnv_close", "ptr", this, "cdecl")
    }
;@endregion Instance Methods
}