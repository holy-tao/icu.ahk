#Include ../common/ICUError.ahk
#Include ../common/ICUEnumerator.ahk

#DllLoad icu.dll

/**
 * This API provides a facility for detecting the charset or encoding of character data in an unknown text format. The input data can be from an array of bytes.
 * 
 * Character set detection is at best an imprecise operation. The detection process will attempt to identify the charset that best matches the characteristics of the byte data, but the process is partly statistical in nature, and the results can not be guaranteed to always be correct.
 * 
 * For best accuracy in charset detection, the input data should be primarily in a single language, and a minimum of a few hundred bytes worth of plain text in the language are needed. The detection process will attempt to ignore html or xml style markup that could otherwise obscure the content.
 * 
 * An alternative to the ICU Charset Detector is the [Compact Encoding Detector](https://github.com/google/compact_enc_det). It often gives more accurate results, especially with short input samples.
 * 
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#a8f341f9c43bf58b112afd70c8a94c45d `UCharsetDetector`} and
 *      {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#a8f341f9c43bf58b112afd70c8a94c45d `ucsdet.h` File Reference}
 */
class CharsetDetector {

    /**
     * Indicates whether input filtering is enabled for this charset detector.
     * 
     * If filtering is enabled, text within angle brackets ("<" and ">") will be removed before detection, which will 
     * remove most HTML or xml markup and prevent it from affecting codepage detection.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#a5c633a3b41c43de77722b10877d0d4c5 `ucsdet_isInputFilterEnabled`} and
     *      {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#a2bae2ec77935adf96eb0dae6face306d `ucsdet_enableInputFilter`}
     * 
     * @type {Boolean}
     */
    FilterMarkup {
        get => DllCall("icu.dll\ucsdet_isInputFilterEnabled", "ptr", this, "cdecl char")
        set => DllCall("icu.dll\ucsdet_enableInputFilter", "ptr", this, "uchar", value, "cdecl char")
    }

    /**
     * Opens a new charset detector.
     * 
     * @param {String | Buffer | Integer} text the text to analyze. You can also call `SetText()` to set this later
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#afb5d0e87c7371ce05bc9c64e47966e89 `ucsdet_open`}
     */
    __New(text?) {
        this.ptr := DllCall("icu.dll\ucsdet_open", "uint*", &stat := 0, "cdecl ptr")
        ICUError.ThrowFor(stat)

        if IsSet(text)
            this.SetText(text)
    }

    /**
     * Return the charset that best matches the supplied input data.
     * 
     * Note though, that because the detection only looks at the start of the input data, there is a possibility that 
     * the returned charset will fail to handle the full set of input data.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#af4880eb6b22328e118f698fd2ceaad98 `ucsdet_detect`}
     * 
     * @returns {CharsetDetector.Match | ""} the charset that best matches the supplied input data, or an empty string
     *          if no charsets match
     */
    Detect() {
        match := DllCall("icu.dll\ucsdet_detect", "ptr", this, "uint*", &stat := 0, "cdecl ptr")
        ICUError.ThrowFor(stat)

        return match == 0 ? "" : CharsetDetector.Match(match)
    }

    /**
     * Find all charset matches that appear to be consistent with the input, returning an array of results.
     * 
     * The results are ordered with the best quality match first.
     * 
     * Because the detection only looks at a limited amount of the input byte data, some of the returned charsets may 
     * fail to handle the all of input data.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#a50b60117e8300e81db1671393a785b2a `ucsdet_detectAll`}
     * 
     * @returns {Array<CharsetDetector.Match>} an array of charsets that could represent the input text
     */
    DetectAll() {
        arrPtr := DllCall("icu.dll\ucsdet_detectAll", 
            "ptr", this,
            "int*", &matchesFound := 0,
            "uint*", &stat := 0,
            "cdecl ptr")
        ICUError.ThrowFor(stat)

        matches := [], matches.Length := matchesFound
        loop matchesFound {
            matches[A_Index] := CharsetDetector.Match(NumGet(arrPtr, (A_Index - 1) * A_PtrSize, "ptr"))
        }

        return matches
    }

    /**
     * Get an {@link ICUEnumerator iterator} over the set of all detectable charsets - over the charsets that are 
     * known to the charset detection service.
     * 
     * The state of the Charset detector this is called on does not affect the result of this function, but requiring 
     * a valid, open charset detector as a parameter insures that the charset detection service has been safely 
     * initialized and that the required detection data is available.
     * 
     *      ; Print all detectable charsets to stdout
     *      for cs in CharsetDetector().GetAllDetectableCharsets() {
     *          FileAppend(cs "`n", "*")
     *      }
     * 
     * Multiple different charset encodings in a same family may use a single shared name in this implementation. For 
     * example, this method returns an array including "ISO-8859-1" (ISO Latin 1), but not including "windows-1252" 
     * (Windows Latin 1). However, actual detection result could be "windows-1252" when the input data matches Latin 1 
     * code points with any points only available in "windows-1252".
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#ae0a7f226389b0f4dc9ef5fbc631adb5c `ucsdet_getAllDetectableCharsets`}
     * 
     * @returns {ICUEnumerator} An enumerator that provides access to the names of the charsets
     */
    GetAllDetectableCharsets() {
        en := DllCall("icu.dll\ucsdet_getAllDetectableCharsets", "ptr", this, "uint*", &stat := 0, "cdecl ptr")
        ICUError.ThrowFor(stat)
        return ICUEnumerator(en)
    }

    /**
     * Set the input byte data whose charset is to detected. The input text must be null-terminated.
     * 
     * Ownership of the input text byte array remains with the caller. The input string must not be altered or deleted 
     * until the charset detector is either closed or reset to refer to different input text.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#af48ec21c207011b1f6ddf3c0ed5f0fb1 `ucsdet_setText`}
     * 
     * @param {String | Integer| Buffer} text the text whose charset is to be detected. This can be a String, pointer,
     *          buffer, or buffer-like object
     */
    SetText(text) {
        DllCall("icu.dll\ucsdet_setText", 
            "ptr", this,
            "ptr", text is String ? StrPtr(text) : (IsInteger(text) ? text : text.ptr),
            "int", -1,
            "uint*", &stat := 0,
            "cdecl")
        ICUError.ThrowFor(stat)
    }

    /**
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#a579b6c2408957f80a6fa50dfc4a195ee `ucsdet_close`}
     */
    __Delete() => DllCall("icu.dll\ucsdet_close", "ptr", this, "cdecl")

    /**
     * A match that was identified from a charset detection operation. `CharsetDetector.Match` extracts the relevant
     * fields from the match on construction, which allows match objects to outlive their detectors.
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#a4e40a6a6dae057f9257e144fc65ba667 `UCharsetMatch`}
     */
    class Match {

        /**
         * The name of the charset. The name returned is suitable for use with the ICU conversion APIs.
         * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#aba47914dead8870e144a426356ab063c `ucsdet_getName`}
         * 
         * @type {String}
         */
        Name := unset

        /**
         * Get the [RFC 3066](https://www.ietf.org/rfc/rfc3066.txt) code for the language of the match's input data 
         * (or an empty string if no langauge could be identified).
         * 
         * The Charset Detection service is intended primarily for detecting charsets, not language. For some, but not 
         * all, charsets, a language is identified as a byproduct of the detection process, and that is what is 
         * returned by this function.
         * 
         * CAUTION:
         * Language information is not available for input data encoded in all charsets. In particular, no language is 
         * identified for UTF-8 input data. Closely related languages may sometimes be confused. If more accurate 
         * language detection is required, a linguistic analysis package should be used.
         * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#aeb4322dcfa998c6497cd957f5d6f53c7 `ucsdet_getLanguage`}
         * 
         * @type {String}
         */
        Language := unset

        /**
         * Get a confidence number for the quality of the match of the byte data with the charset.
         * 
         * Confidence numbers range from zero to 100, with 100 representing complete confidence and zero representing 
         * no confidence.
         * 
         * The confidence values are somewhat arbitrary. They define an an ordering within the results for any single 
         * detection operation but are not generally comparable between the results for different input.
         * 
         * A confidence value of ten does have a general meaning - it is used for charsets that can represent the 
         * input data, but for which there is no other indication that suggests that the charset is the correct one. 
         * Pure 7 bit ASCII data, for example, is compatible with a great many charsets, most of which will appear as 
         * possible matches with a confidence of 10.
         * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucsdet_8h.html#a30dd8812653be28766f1ee1bbc412c18 `ucsdet_getConfidence`}
         * 
         * @type {Integer}
         */
        Confidence := unset

        /**
         * Constructs a new match object. This will extract the language, name, and confidence from the opaque
         * strucutre.
         * @param {Integer} ptr Opaque pointer to the struct from which to construct the match object 
         */
        __New(ptr) {
            stat := 0
            this.Name := DllCall("icu.dll\ucsdet_getName", "ptr", ptr, "uint*", &stat, "cdecl astr")
            ICUError.ThrowFor(stat)
            this.Language := DllCall("icu.dll\ucsdet_getLanguage", "ptr", ptr, "uint*", &stat, "cdecl astr")
            ICUError.ThrowFor(stat)
            this.Confidence := DllCall("icu.dll\ucsdet_getConfidence", "ptr", ptr, "uint*", &stat, "cdecl int")
            ICUError.ThrowFor(stat)
        }

        ToString() => Format("{1} (Confidence: {2})", this.Name, this.Confidence)
    }
}