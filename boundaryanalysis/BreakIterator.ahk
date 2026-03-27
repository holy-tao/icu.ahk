
#Include ../common/ICUError.ahk
#Include BreakIteratorType.ahk

#DllLoad icu.dll

/**
 * The BreakIterator C API defines methods for finding the location of boundaries in text. Pointer to a UBreakIterator maintain a current position and scan over text returning the index of characters where boundaries occur.
 * 
 * Code snippets illustrating the use of the Break Iterator APIs are available in the [ICU User Guide](https://unicode-org.github.io/icu/userguide/boundaryanalysis/)
 * 
 * @see {@link https://unicode-org.github.io/icu/userguide/boundaryanalysis/ Boundary Analysis | ICU USer Guide} and
 *      {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#details BreakIterator C API}
 */
class BreakIterator {
;@region Constants
    /**
     * Value indicating all text boundaries have been returned.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a7c31c1e5091fb47ab85db522c7536252 {@link BreakIterator.Done `UBRK_DONE`}}
     */
    static DONE => -1

;@endregion Constants
;@region Static Methods
    /**
     * Open a new `BreakIterator` for locating text boundaries for a specified locale.
     * 
     * A `BreakIterator` may be used for detecting character, line, word, and sentence breaks in text.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#ae3ac488d6827b8476e2b330c3e68a906 `ubrk_open`}
     * 
     * @param {Integer} type The type of `BreakIterator` to open. Must be a {@link BreakIteratorType `BreakIteratorType`}
     *      enum value.
     * @param {String} locale The locale specifying the text-breaking conventions. Note that locale keys such as "lb" 
     *      and "ss" may be used to modify text break behavior, see [general discussion](https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#details) 
     *      of BreakIterator C API. For example, "en", "fr", "ja@lb=strict"
     * @param {Buffer | Integer} text A pointer to the text to be iterated over. May be null, in which case {@link BreakIterator.Prototype.SetText `SetText`} 
     *      is used to specify the text to be iterated.
     * @param {integer} textLength The number of characters in text, or -1 if null-terminated.
     */
    static Open(type, locale, text := 0, textLength := -1) => (
        ptr := DllCall("icu.dll\ubrk_open",
            "uint", type,
            "astr", locale,
            "ptr", text,
            "int", textLength,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        BreakIterator(ptr))

    /**
     * Open a new `BreakIterator` for locating text boundaries using specified breaking rules.
     * 
     * See {@link https://unicode-org.github.io/icu/userguide/boundaryanalysis/break-rules.html Break Rules | ICU User Guide}
     * for details on the rule syntax and the rules that ICU ships with.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#abf4a948ccbf0b0f35ede1a6a4fb5697c `ubrk_openRules`}
     *      and {@link https://unicode-org.github.io/icu/userguide/boundaryanalysis/break-rules.html Break Rules | ICU User Guide}
     * 
     * @param {String} rules A set of rules specifying the text breaking conventions.
     * @param {Integer} rulesLength The number of characters in rules, or -1 if null-terminated.
     * @param {Integer} text The text to be iterated over. May be null, in which case {@link BreakIterator.Prototype.SetText `SetText`}
     * is used to specify the text to be iterated.
     * @param {Integer} textLength The number of characters in text, or -1 if null-terminated.
     * @returns {BreakIterator} A `BreakIterator` for the specified rules.
     */
    static OpenRules(rules, rulesLength := -1, text := 0, textLength := -1) => (
        ptr := DllCall("icu.dll\ubrk_openRules",
            "astr", rules,
            "int", rulesLength,
            "ptr", text,
            "int", textLength,
            "ptr*", &parseError := 0,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        BreakIterator(ptr))

    /**
     * Open a new `BreakIterator` for locating text boundaries using precompiled binary rules.
     * 
     * Opening a `BreakIterator` this way is substantially faster than using ubrk_openRules. Binary rules may be 
     * obtained using {@link BreakIterator.Prototype.GetBinaryRules `GetBinaryRules`}. The compiled rules are not 
     * compatible across different major versions of ICU, nor across platforms of different endianness or different 
     * base character set family (ASCII vs EBCDIC).
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#ac910a25936e99c6cb02559778d535685 `ubrk_openBinaryRules`}
     * 
     * @param {Integer | Buffer} binaryRules A set of compiled binary rules specifying the text breaking conventions.
     *      Ownership of the storage containing the compiled rules remains with the caller of this function. The 
     *      compiled rules must not be modified or deleted during the life of the break iterator.
     * @param {Integer} rulesLength The length of binaryRules in bytes; must be >= 0.
     * @param {Integer} text The text to be iterated over. May be null, in which case {@link BreakIterator.Prototype.SetText `SetText`} 
     *      is used to specify the text to be iterated.
     * @param {Integer} textLength The number of characters in text, or -1 if null-terminated.
     * @returns {BreakIterator} a `BreakIterator` for the specified rules
     */
    static OpenBinaryRules(binaryRules, rulesLength, text := 0, textLength := -1) => (
        ptr := DllCall("icu.dll\ubrk_openBinaryRules",
            "ptr", binaryRules,
            "int", rulesLength,
            "ptr", text,
            "int", textLength,
            "int*", &stat := 0,
            "cdecl ptr"),
        ICUError.ThrowFor(stat),
        BreakIterator(ptr))

    /**
     * Get a locale for which text breaking information is available.
     * A `BreakIterator` in a locale returned by this function will perform the correct text breaking for the locale.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a89ca2f84689fda69dfc5ff09d9827370 `ubrk_getAvailable`}
     * 
     * @param index The index of the desired locale.
     * @returns {Integer} A locale for which number text breaking information is available, or 0 if none.
     */
    static GetAvailable(index) => DllCall("icu.dll\ubrk_getAvailable", "int", index, "cdecl astr")

    /**
     * Determine how many locales have text breaking information available.
     * This function is most useful as determining the loop ending condition for calls to {@link BreakIterator.GetAvailable `GetAvailable`}.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#af1303756451e5edb947ec2666435b684 `ubrk_countAvailable`}
     * 
     * @returns {Integer} The number of locales for which text breaking information is available.
     */
    static CountAvailable() => DllCall("icu.dll\ubrk_countAvailable", "cdecl int")

;@endregion Static Methods
;@region Instance Methods

    /**
     * @private Adopts a pointer. **Do not call this directly**, instead, use {@link BreakIterator.Open `Open`},
     *      {@link BreakIterator.OpenRules `OpenRules`}, or {@link BreakIterator.OpenBinaryRules `OpenBinaryRules`} to
     *      open a new break iterator.
     */
    __New(ptr) {
        if !(ptr is Integer)
            throw TypeError("Expected an Integer but got a(n) " Type(ptr), -1, ptr)
        this.ptr := ptr
    }

    /**
     * Determine the most recently-returned text boundary.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a46b760f7fcd1663583552eb67c757149 `ubrk_current`}
     * 
     * @returns {Integer} The character index most recently returned by {@link BreakIterator.Prototype.Next `Next`},
     *      {@link BreakIterator.Prototype.Previous `Previous`}, {@link BreakIterator.Prototype `First`}, or 
     *      {@link BreakIterator.Prototype.Last `Last`}.
     */
    Current() => DllCall("icu.dll\ubrk_current", "ptr", this, "cdecl int")

    /**
     * Advance the iterator to the boundary following the current boundary.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#aa0851c6d6403e5f87060a862dddf6b84 `ubrk_next`}
     * 
     * @returns {Integer} The character index of the next text boundary, or {@link BreakIterator.Done `UBRK_DONE`} if 
     *      all text boundaries have been returned.
     */
    Next() => DllCall("icu.dll\ubrk_next", "ptr", this, "cdecl int")

    /**
     * Set the iterator position to the boundary preceding the current boundary.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a25576941eefe776e82af8bcd7b971b56 `ubrk_previous`}
     * 
     * @returns {Integer} The character index of the next text boundary, or {@link BreakIterator.Done `UBRK_DONE`} if 
     *      all text boundaries have been returned.
     */
    Previous() => DllCall("icu.dll\ubrk_previous", "ptr", this, "cdecl int")

    /**
     * Set the iterator position to zero, the start of the text being scanned.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a4538a25ebe27ae02954d4456cd515a9a `ubrk_first`}
     * 
     * @returns {0} The new iterator position (zero).
     */
    First() => DllCall("icu.dll\ubrk_first", "ptr", this, "cdecl int")

    /**
     * Set the iterator position to the index immediately beyond the last character in the text being scanned.
     * This is not the same as the last character.
     * {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#ab07291cb072f555d60eddfac38ee4c1b `ubrk_last`}
     * 
     * @returns {Integer} The character offset immediately *beyond* the last character in the text being scanned.
     */
    Last() => DllCall("icu.dll\ubrk_last", "ptr", this, "cdecl int")

    /**
     * Returns true if the specified position is a boundary position.
     * As a side effect, leaves the iterator pointing to the first boundary position at or after `offset`.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a7b6a3a3fcd3db68cbec72cac77d30933 `ubrk_isBoundary`}
     * 
     * @param offset 
     * @returns {Integer} True if `offset` is a boundary position.
     */
    IsBoundary(offset) => DllCall("icu.dll\ubrk_isBoundary", "ptr", this, "int", offset, "cdecl int")

    /**
     * Set the iterator position to the first boundary preceding the specified offset. 
     * The new position is always smaller than offset, or {@link BreakIterator.Done `UBRK_DONE`}.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a00b11da520120f32c0e469e69bf36914 `ubrk_preceding`}
     * 
     * @param {Integer} offset The offset to begin scanning.
     * @returns {Integer} The text boundary preceding offset, or {@link BreakIterator.Done `UBRK_DONE`}.
     */
    Preceding(offset) => DllCall("icu.dll\ubrk_preceding", "ptr", this, "int", offset, "cdecl int")

    /**
    * Set the iterator position to the first boundary following the specified offset. 
     * The new position is always greater than offset, or {@link BreakIterator.Done `UBRK_DONE`}.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a2b4bf12879b20d7094da3ced996f492f `ubrk_following`}
     * 
     * @param {Integer} offset The offset to begin scanning.
     * @returns {Integer} The text boundary following offset, or {@link BreakIterator.Done `UBRK_DONE`}.
     */
    Following(offset) => DllCall("icu.dll\ubrk_following", "ptr", this, "int", offset, "cdecl int")

    /**
     * Sets an existing iterator to point to a new piece of text.
     * 
     * The break iterator retains a pointer to the supplied text. The caller must not modify or delete the text while the 
     * `BreakIterator` retains the reference.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a5dd7b94b1867a291e80369bcbe17c3b0 `ubrk_setText`}
     * 
     * @param {Integer} text The text to be set
     * @param {Integer} textLength The length of the text
     */
    SetText(text, textLength) => (
        DllCall("icu.dll\ubrk_setText", 
            "ptr", this, 
            "ptr", text, 
            "int", textLength, 
            "int*", &stat := 0, "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Sets an existing iterator to point to a new piece of text.
     * 
     * All index positions returned by break iterator functions are native indices from the UText. For example, when
     * breaking UTF-8 encoded text, the break positions returned by {@link BreakIterator.Prototype.Next `Next`}, {@link BreakIterator.Prototype.Previous `Previous`},
     * etc. will be UTF-8 string indices, not UTF-16 positions.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a7aa3cbdb4bb46ac881d1b8b33d685a63 `ubrk_setUText`}
     * 
     * @param {Integer} text The text to be set. This function makes a shallow clone of the supplied UText. This means
     *      that the caller is free to immediately close or otherwise reuse the UText that was passed as a parameter, 
     *      but that the underlying text itself must not be altered while being referenced by the break iterator.
     */
    SetUText(text) => (
        DllCall("icu.dll\ubrk_setUText", "ptr", this, "ptr", text, "int*", &stat := 0, "cdecl"),
        ICUError.ThrowFor(stat))

    /**
     * Get a compiled binary version of the rules specifying the behavior of a UBreakIterator.
     * 
     * The binary rules may be used with {@link BreakIterator.OpenBinaryRules `OpenBinaryRules`} to open a new 
     * `BreakIterator` more quickly than using {@link BreakIterator.OpenRules `OpenRules`}. The compiled rules are not
     * compatible across different major versions of ICU, nor across platforms of different endianness or different 
     * base character set family (ASCII vs EBCDIC). Supports preflighting (with binaryRules=NULL and rulesCapacity=0) 
     * to get the rules length without copying them to the binaryRules buffer. 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a44a5e0393582947af96f7d291dec4101 `ubrk_getBinaryRules`}
     * 
     * @param {Integer | Buffer} binaryRules Buffer or pointer to a Buffer to receive the compiled binary rules; set
     *      to NULL for preflighting.
     * @param {Integer} rulesCapacity Capacity (in bytes) of the binaryRules buffer; set to 0 for preflighting. Must
     *      be >= 0.
     * @returns {Integer} The actual byte length of the binary rules, if <= INT32_MAX; otherwise 0. If not 
     *      preflighting and this is larger than rulesCapacity, an {@link ICUError `ICUError`} will be thrown
     */
    GetBinaryRules(binaryRules, rulesCapacity) => (
        length := DllCall("icu.dll\ubrk_getBinaryRules",
            "ptr", this,
            "ptr", binaryRules,
            "int", rulesCapacity,
            "int*", &stat := 0,
            "cdecl int"),
        ICUError.ThrowFor(stat),
        length)

    /**
     * Return the locale of the break iterator. You can choose between the valid and the actual locale.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a25541b9cd838fd30b23e491b48403a61 `ubrk_getLocaleByType`}
     * 
     * @param {Integer} type locale type (valid or actual) 
     * @returns {String} locale string
     */
    GetLocaleByType(type) => (
        locale := DllCall("icu.dll\ubrk_getLocaleByType",
            "ptr", this,
            "uint", type,
            "int*", &stat := 0,
            "cdecl astr"),
        ICUError.ThrowFor(stat),
        locale)

    /**
     * Return the status from the break rule that determined the most recently returned break position.
     * 
     * The values appear in the rule source within brackets, {123}, for example. For rules that do not specify a 
     * status, a default value of 0 is returned.
     * 
     * For word break iterators, the possible values are defined in enum `WordBreak`.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a4f9582394bbd8a0c2c0955a228eb6ea7 `ubrk_getRuleStatus`}
     * 
     * @returns {Integer} 
     */
    GetRuleStatus() => DllCall("icu.dll\ubrk_getRuleStatus", "ptr", this, "cdecl int")

    /**
     * Get the statuses from the break rules that determined the most recently returned break position.
     * 
     * The values appear in the rule source within brackets, {123}, for example. The default status value for rules
     * that do not explicitly provide one is zero.
     * 
     * For word break iterators, the possible values are defined in enum UWordBreak.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a1717f974cb1e4a8b15944a7688859de8 `ubrk_getRuleStatusVec`}
     * 
     * @param {Integer} fillInVec an array to be filled in with the status values.
     * @param {Integer} capacity the length of the supplied vector. A length of zero causes the function to return the
     *      number of status values, in the normal way, without attempting to store any values.
     * @returns {Integer} The number of rule status values from rules that determined the most recent boundary 
     *      returned by the break iterator.
     */
    GetRuleStatusVec(fillInVec, capacity) => (
        length := DllCall("icu.dll\ubrk_getRuleStatusVec",
            "ptr", this,
            "ptr", fillInVec,
            "int", capacity,
            "int*", &stat := 0,
            "cdecl int"),
        (capacity > 0 && ICUError.ThrowFor(stat)),    ; Don't throw errors if preflighting
        length)

    /**
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a850375bd698be8039e735a721586c843 `ubrk_close`}
     */
    __Delete() => DllCall("icu.dll\ubrk_close", "ptr", this, "cdecl")
}