#Requires AutoHotkey v2.0 

#Include ../common/ICUError.ahk

#DllLoad icu.dll

/**
 * C API: New API for Unicode Normalization.
 * 
 * Unicode normalization functionality for standard Unicode normalization or for using custom mapping tables. All 
 * instances of `UNormalizer2` are unmodifiable/immutable. Instances returned by {@link Unormalizer2.NFC `NFC()`}, etc.
 * are singletons that must not be deleted by the caller.
 * @see {@link https://unicode-org.github.io/icu/design/normalization/custom.html Custom Normalization | ICU User Guide}
 * @see {@link https://unicode.org/reports/tr15/ Unicode Standard Annex #15: Unicode Normalization Forms}
 */
class UNormalizer2 {

;@region Static Properties
    /**
     * Returns a `UNormalizer2` instance for Unicode NFC normalization.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#af617e4f945ce7175a8002b935de678f9 `unorm2_getNFCInstance`}
     * @returns {UNormalizer2} the requested Normalizer2, if successful
     */
    static NFC() => (
        ptr := DllCall("icu.dll\unorm2_getNFCInstance", "int*", &stat := 0, "cdecl ptr"),
        ICUError.ThrowFor(stat),
        UNormalizer2(ptr, false))

    /**
     * Returns a `UNormalizer2` instance for Unicode NFC normalization.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#ab1f3bf293f7817d3f90c729830e1559c `unorm2_getNFDInstance`}
     * @returns {UNormalizer2} the requested Normalizer2, if successful
     */
    static NFD() => (
        ptr := DllCall("icu.dll\unorm2_getNFDInstance", "int*", &stat := 0, "cdecl ptr"),
        ICUError.ThrowFor(stat),
        UNormalizer2(ptr, false))

    /**
     * Returns a UNormalizer2 instance for Unicode NFKC normalization.
     * 
     * Same as {@link UNormalizer2.GetInstance `GetInstance(0, "nfkc", UNormalization2Mode.COMPOSE)`}. Returns an
     * unmodifiable singleton instance. Do not delete it.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a47f04495d52791727bb38e3bfce03834 `unorm2_getNFKCInstance`}
     * @returns {UNormalizer2} the requested Normalizer2, if successful
     */
    static NFKC() => (
        ptr := DllCall("icu.dll\unorm2_getNFKCInstance", "int*", &stat := 0, "cdecl ptr"),
        ICUError.ThrowFor(stat),
        UNormalizer2(ptr, false))

    /**
     * Returns a UNormalizer2 instance for Unicode NFKD normalization.
     * 
     * Same as {@link UNormalizer2.GetInstance `GetInstance(0, "nfkc", UNormalization2Mode.DECOMPOSE)`}. Returns an
     * unmodifiable singleton instance. Do not delete it.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#ad92492f5b6938ce5b60608445179f68f `unorm2_getNFKDInstance`}
     * @returns {UNormalizer2} the requested Normalizer2, if successful
     */
    static NFKD() => (
        ptr := DllCall("icu.dll\unorm2_getNFKDInstance", "int*", &stat := 0, "cdecl ptr"),
        ICUError.ThrowFor(stat),
        UNormalizer2(ptr, false))

    /**
     * Returns a `UNormalizer2` instance for Unicode toNFKC_Casefold() normalization which is equivalent to applying the 
     * NFKC_Casefold mappings and then NFC.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a97332b4f0918763dff9770a0d23ddd3c `unorm2_getNFKCCasefoldInstance`}
     *      and {@link https://www.unicode.org/reports/tr44/#NFKC_Casefold}
     * @returns {UNormalizer2} the requested Normalizer2, if successful
     */
    static NFKCCasefold() => (
        ptr := DllCall("icu.dll\unorm2_getNFKCCasefoldInstance", "int*", &stat := 0, "cdecl ptr"),
        ICUError.ThrowFor(stat),
        UNormalizer2(ptr, false))

    /**
     * Returns a UNormalizer2 instance which uses the specified data file (packageName/name similar to `ucnv_openPackage()` 
     * and `ures_open()`/`ResourceBundle`) and which composes or decomposes text according to the specified mode.
     * 
     * Returns an unmodifiable singleton instance. Do not delete it.
     * 
     * Use packageName=NULL for data files that are part of ICU's own data. Use name="nfc" and `UNORM2_COMPOSE/UNORM2_DECOMPOSE` 
     * for Unicode standard NFC/NFD. Use name="nfkc" and UNORM2_COMPOSE/UNORM2_DECOMPOSE for Unicode standard NFKC/NFKD. 
     * Use name="nfkc_cf" and `UNORM2_COMPOSE` for Unicode standard NFKC_CF=NFKC_Casefold.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a70af54b0aa3163361691374e16e1e44a `unorm2_getInstance`}
     * 
     * @param {Integer | String} packageName NULL for ICU built-in data, otherwise application data package name
     * @param {String} name "nfc" or "nfkc" or "nfkc_cf" or "nfkc_scf" or name of custom data file
     * @param {UNormalization2Mode} mode normalization mode (compose or decompose etc.)
     * @returns {UNormalizer2} the requested `UNormalizer2`, if successful
     */
    static GetInstance(packageName, name, mode) => (
        ptr := DllCall("icu.dll\unorm2_getInstance",
            packageName is Integer ? "ptr" : "astr", packageName,
            "astr", name,
            "uint", mode,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        UNormalizer2(ptr, false))

;@endregion Static Properties
;@region Instance Methods

    /**
     * Adopts a pointer. Do not call this directly, instead, use {@link UNormalizer2.GetInstance `GetInstance`} or one 
     * of the singletons.
     * @param {Integer} ptr pointer to the `UNormalizer22` to adopt 
     * @param {Integer} owned whether or not this normalizer is owned by the script and needs to be deleted.
     */
    __New(ptr, owned) {
        this.ptr := ptr
        this.owned := owned
    }

    /**
     * Constructs a filtered normalizer wrapping any UNormalizer2 instance and a filter set.
     * 
     * Both are aliased and must not be modified or deleted while this object is used. The filter set should be 
     * frozen; otherwise the performance will suffer greatly.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a09aadedbb32baa04b321be42ef8f94f4 `unorm2_openFiltered`}
     * 
     * @param {USet} filterSet `USet` which determines the characters to be normalized. Note `USet` is not projected,
     *      you'll have to get this pointer yourself
     * @returns {UNormalizer2} the requested UNormalizer2, if successful
     */
    OpenFiltered(filterSet) => (
        ptr := DllCall("icu.dll\unorm2_openFiltered",
            "ptr", this,
            "ptr", filterSet,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        UNormalizer2(ptr, true))

    /**
     * Tests if the character is normalization-inert.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#aa546b77068fceb75d9a8409720086f83 `unorm2_isInert`}
     * @param {Integer} char a 32-bit Integer representing a character to test
     * @returns {Boolean} true if `char` is normalization-intert
     */
    IsInert(char) => DllCall("icu.dll\unorm2_isInert", "ptr", this, "uint", char, "cdecl char")

    /**
     * Tests if a string is normalized.
     * 
     * Internally, in cases where the quickCheck() method would return "maybe" (which is only possible for the two 
     * COMPOSE modes) this method resolves to "yes" or "no" to provide a definitive result, at the cost of doing more 
     * work in those cases.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a21219b3111746cf6a0b61b95eda565b9 `unorm2_isNormalized`}
     * 
     * @param {Integer | String} pStr String or pointer to the string to test 
     * @param {Integer} length length of the string, or -1 if NUL-terminated
     * @returns {Boolean} true if string pointed to by `pStr` is normalized
     */
    IsNormalized(pStr, length := -1) => (
        normalized := DllCall("icu.dll\unorm2_isNormalized",
            "ptr", this,
            "ptr", pStr is String ? StrPtr(pStr) : pStr,
            "int", length,
            "int*", &stat := 0,
            "cdecl char"),
        ICUError.ThrowFor(stat),
        normalized)

    /**
     * Writes the normalized form of the source string to the destination string (replacing its contents) and returns 
     * the length of the destination string.
     * 
     * The source and destination strings must be different buffers.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a2391f4681aeea7242026a95eef502dbe `unorm2_normalize`}
     * 
     * @param {String | Integer} src (pointer to) source string
     * @param {Integer} length length of the source string, or -1 if NUL-terminated
     * @param {Integer} dest pointer to the destination buffer; its contents is replaced with normalized src
     * @param {Integer} capacity number of UChars that can be written to dest
     * @returns {Integer} the length of the destination string
     */
    Normalize(src, length, dest, capacity) => (
        destLength := DllCall("icu.dll\unorm2_normalize",
            "ptr", this,
            "ptr", src is String ? StrPtr(src) : src,
            "int", length,
            "ptr", dest,
            "int", capacity,
            "int*", &stat := 0,
            "cdecl int"),
        (dest > 0 && ICUError.ThrowFor(stat)),
        destLength)

    /**
     * Appends the normalized form of the second string to the first string (merging them at the boundary) and returns 
     * the length of the first string.
     * 
     * The result is normalized if the first string was normalized. The first and second strings must be different 
     * buffers.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#ad179ca11e80ea3ee2e65d1af49b2362a `unorm2_normalizeSecondAndAppend`}
     * 
     * @param {Integer} first pointer to the first (destination) string, should be normalized
     * @param {Integer} firstLength length of the first string, or -1 if NUL-terminated
     * @param {Integer} firstCapacity number of UChars that can be written to `first`
     * @param {Integer | String} second string or pointer to string, will be normalized
     * @param {Integer} secondLength length of the source string, or -1 if NUL-terminated
     * @returns {Integer} the new length of the first (destination) string
     */
    NormalizeSecondAndAppend(first, firstLength, firstCapacity, second, secondLength) => (
        firstLengthAfter := DllCall("icu.dll\unorm2_normalizeSecondAndAppend",
            "ptr", this,
            "ptr", first,
            "int", firstLength,
            "int", firstCapacity,
            "ptr", second is String ? StrPtr(second) : second,
            "int", secondLength,
            "int*", &stat := 0,
            "cdecl int"),
        ICUError.ThrowFor(stat),
        firstLengthAfter)

    /**
     * Appends the second string to the first string (merging them at the boundary) and returns the length of the
     * first string.
     * 
     * The result is normalized if both the strings were normalized. The first and second strings must be different 
     * buffers.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a2782df22a6f9956d517ef5e7e25873b1 `unorm2_append`}
     * 
     * @param {Integer | String} first string or pointer to the first (destination) string, should be normalized
     * @param {Integer} firstLength length of the first string, or -1 if NUL-terminated
     * @param {Integer} firstCapacity number of UChars that can be written to `first`
     * @param {Integer | String} second string or pointer to string, will be normalized
     * @param {Integer} secondLength length of the source string, or -1 if NUL-terminated
     * @returns {Integer} the new length of the first (destination) string
     */
    Append(first, firstLength, firstCapacity, second, secondLength) => (
        firstLengthAfter := DllCall("icu.dll\unorm2_append",
            "ptr", this,
            "ptr", first is String ? StrPtr(first) : first,
            "int", firstLength,
            "int", firstCapacity,
            "ptr", second is String ? StrPtr(second) : second,
            "int", secondLength,
            "int*", &stat := 0,
            "cdecl int"),
        ICUError.ThrowFor(stat),
        firstLengthAfter)

    /**
     * Tests if the string is normalized.
     *
     * Unlike {@link UNormalizer2.IsNormalized `IsNormalized()`}, this method returns a tri-state result for composition
     * forms: `UNormalizationCheckResult.MAYBE` in addition to `YES` and `NO`. `MAYBE` is only returned for the two
     * `COMPOSE` modes, and indicates that the input may or may not be normalized (surrounding context must be analyzed
     * to determine definitively).
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a8e6e9d27bd04af879c40b31e0ceeebcd `unorm2_quickCheck`}
     *
     * @param {Integer | String} pStr String or pointer to the string to test
     * @param {Integer} length length of the string, or -1 if NUL-terminated
     * @returns {Integer} `UNormalizationCheckResult.YES`, `NO`, or `MAYBE`
     */
    QuickCheck(pStr, length := -1) => (
        result := DllCall("icu.dll\unorm2_quickCheck",
            "ptr", this,
            "ptr", pStr is String ? StrPtr(pStr) : pStr,
            "int", length,
            "int*", &stat := 0,
            "cdecl int"),
        ICUError.ThrowFor(stat),
        result)

    /**
     * Returns the end of the normalized substring of the input string.
     *
     * In other words, with `end := SpanQuickCheckYes(s, length)`, the substring `s[0..end-1]` will pass the
     * quick check with a `YES` result. `s[end..]` starts with a character that does not pass the quick check
     * with `YES`.
     *
     * In addition, the pointer to the substring `s[end..]` can be passed to `Normalize()` as the `src` argument,
     * since the buffer preceding it (s[0..end-1]) is already normalized.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a4fee9a27e6c4aade673a3c10b6c47afa `unorm2_spanQuickCheckYes`}
     *
     * @param {Integer | String} pStr String or pointer to the string to check
     * @param {Integer} length length of the string, or -1 if NUL-terminated
     * @returns {Integer} "yes" span end index
     */
    SpanQuickCheckYes(pStr, length := -1) => (
        spanEnd := DllCall("icu.dll\unorm2_spanQuickCheckYes",
            "ptr", this,
            "ptr", pStr is String ? StrPtr(pStr) : pStr,
            "int", length,
            "int*", &stat := 0,
            "cdecl int"),
        ICUError.ThrowFor(stat),
        spanEnd)

    /**
     * Gets the combining class of a character.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a2feac3ffe5e94b06eb6ceaca9e87e5dc `unorm2_getCombiningClass`}
     *
     * @param {Integer} char a 32-bit Integer representing the character to query
     * @returns {Integer} `c`'s combining class, or 0 if it has none
     */
    GetCombiningClass(char) => DllCall("icu.dll\unorm2_getCombiningClass", "ptr", this, "uint", char, "cdecl uchar")

    /**
     * Gets the decomposition mapping of a character.
     *
     * Roughly equivalent to normalizing the `String.fromCodePoint(c)` on a `DECOMPOSE` normalizer, but much faster
     * and without memory allocation.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a40b7f04e8e46c31474f6d22f3b9d18f5 `unorm2_getDecomposition`}
     *
     * @param {Integer} char a 32-bit Integer representing the character to decompose
     * @param {Integer} dest pointer to the destination buffer to write the decomposition into
     * @param {Integer} capacity number of UChars that can be written to `dest`
     * @returns {Integer} the number of UChars written to `dest`, or a negative value if `char` does not have a
     *      decomposition mapping
     */
    GetDecomposition(char, dest, capacity) => (
        written := DllCall("icu.dll\unorm2_getDecomposition",
            "ptr", this,
            "uint", char,
            "ptr", dest,
            "int", capacity,
            "int*", &stat := 0,
            "cdecl int"),
        (dest > 0 && ICUError.ThrowFor(stat)),
        written)

    /**
     * Gets the raw (not recursively decomposed) decomposition mapping of a character.
     *
     * This is similar to {@link UNormalizer2.GetDecomposition `GetDecomposition()`}, but only returns the immediate
     * mapping if it exists. For most characters the two will be identical, but for some characters (e.g., U+00C0
     * LATIN CAPITAL LETTER A WITH GRAVE) the full decomposition goes further than the raw mapping (U+0041 U+0300
     * vs. just U+00C0 → U+0041 U+0300 directly).
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a2d0bcebef8d68f09b55c6ade5a6f4ab2 `unorm2_getRawDecomposition`}
     *
     * @param {Integer} char a 32-bit Integer representing the character to query
     * @param {Integer} dest pointer to the destination buffer to write the decomposition into
     * @param {Integer} capacity number of UChars that can be written to `dest`
     * @returns {Integer} the number of UChars written to `dest`, or a negative value if `char` does not have a
     *      direct (single-step) decomposition mapping
     */
    GetRawDecomposition(char, dest, capacity) => (
        written := DllCall("icu.dll\unorm2_getRawDecomposition",
            "ptr", this,
            "uint", char,
            "ptr", dest,
            "int", capacity,
            "int*", &stat := 0,
            "cdecl int"),
        (dest > 0 && ICUError.ThrowFor(stat)),
        written)

    /**
     * Performs pairwise composition of characters `a` and `b` and returns the composite if there is one.
     *
     * Returns a composite code point `c` only if `c = compose(a, b)`. If the two characters do not combine,
     * returns a negative value.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a76f49dc78c0b2413fcdca15c44e79e76 `unorm2_composePair`}
     *
     * @param {Integer} a a 32-bit Integer representing the first character to compose
     * @param {Integer} b a 32-bit Integer representing the second character to compose
     * @returns {Integer} the non-negative composite code point if there is one, otherwise a negative value
     */
    ComposePair(a, b) => DllCall("icu.dll\unorm2_composePair", "ptr", this, "uint", a, "uint", b, "cdecl int")

    /**
     * Tests if the character always has a normalization boundary before it, regardless of context.
     *
     * If true, then the character does not combine backwards, i.e., `combine(preceding, c)` has no result.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a03caac58c36f8cc8a27e3fddc22ef9f5 `unorm2_hasBoundaryBefore`}
     *
     * @param {Integer} char a 32-bit Integer representing the character to test
     * @returns {Boolean} true if `char` always has a normalization boundary before it
     */
    HasBoundaryBefore(char) => DllCall("icu.dll\unorm2_hasBoundaryBefore", "ptr", this, "uint", char, "cdecl char")

    /**
     * Tests if the character always has a normalization boundary after it, regardless of context.
     *
     * If true, then the character does not combine forwards, i.e., `compose(c, following)` has no result.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#ab5702abc5d01a8e9e4fa10bcb4e4dc29 `unorm2_hasBoundaryAfter`}
     *
     * @param {Integer} char a 32-bit Integer representing the character to test
     * @returns {Boolean} true if `char` always has a normalization boundary after it
     */
    HasBoundaryAfter(char) => DllCall("icu.dll\unorm2_hasBoundaryAfter", "ptr", this, "uint", char, "cdecl char")

    /**
     * If this normalizer is script owned, closes it
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a3320baa26fad67d9bb53f79a734e027f `unorm2_close`}
     */
    __Delete() {
        if(this.owned)
            DllCall("icu.dll\unorm2_close", "ptr", this, "cdecl")
    }

;@endregion Instance Methods
}

#Include UNormalization2Mode.ahk