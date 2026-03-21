#Include ./ICUError.ahk
#DllLoad icu.dll

/**
 * Shared base for C string enumeration used by ICU APIs. Functions that return enumerators generally return instances
 * of this class or of a derived class.
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/uenum_8h.html#afde1d761cfe211d150edc3f17948ec74 `uenum.h` File Reference}
 */
class ICUEnumerator {

    /**
     * Creates a new enumerator
     * 
     * @param {Integer} ptr the opaque pointer obtained from an ICU API to wrap
     * @param {"UTF-8" | "UTF-16"} mode whether to enumerate values as UTF-8 (char) or UTF-16 (uchar) strings
     */
    __New(ptr, mode := "UTF-8") {
        this.ptr := ptr
        this.mode := mode
    }

    /**
     * Returns the next string in the enumeration or the pure Integer 0 (to differentiate from an empty string, which
     * is theoretically a valid return type) if there are no more strings. The enumerator's  `mode` determines whether 
     * the enumerator tries to read the value as a UTF-8 (`char*`) string or UFT-16 (`uchar*`) string. 
     * 
     * Note that if the `mode` is "UTF-8" but the underlying source is UTF-16, the ICUEnum will try to convert to 
     * UFT-8. This operation can fail, in which case an {@link ICUError `ICUError`} is thrown.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/uenum_8h.html#afc60c150cda05c0284b29d154d6486e6 `uenum_next`} and 
     *      {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/uenum_8h.html#afde1d761cfe211d150edc3f17948ec74 `uenum_unext`}
     * 
     * @returns {String | 0} the next string in the enumeration, or the pure integer 0 if there are no more
     */
    Next() {
        switch this.mode {
            case "UTF-8":
                ptr := DllCall("icu.dll\uenum_next", "ptr", this, "int*", &length := 0, "uint*", &stat := 0, "cdecl ptr")
            case "UTF-16":
                ptr := DllCall("icu.dll\uenum_unext", "ptr", this, "int*", &length := 0, "uint*", &stat := 0, "cdecl ptr")
            default:
                throw ValueError("Invalid enumeration mode", -1, this.mode)
        }

        ICUError.ThrowFor(stat)
        return ptr == 0 ? 0 : StrGet(ptr, length, this.mode)
    }

    /**
     * Supports native for-loop enumeration
     * 
     * @see {@link https://www.autohotkey.com/docs/v2/lib/Enumerator.htm Enumerator Object | AutoHotkey v2}
     * 
     * @param {VarRef<String>} output output variable
     * @returns {Integer} This method returns 1 (true) if successful or 0 (false) if there were no items remaining.
     */
    Call(&output) {
        output := this.Next()
        return output is String
    }

    /**
     * Returns the number of elements that the iterator traverses.
     * 
     * This is a convenience function. It can end up being very expensive as all the items might have to be 
     * pre-fetched (depending on the type of data being traversed). Use with caution and only when necessary.
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/uenum_8h.html#a1d9afd910e43a1a3899c5c1667ef01d8 `uenum_count`}
     * 
     * @returns {Integer} the number of elements that the iterator traverses
     */
    Count() {
        count := DllCall("icu.dll\uenum_count", "ptr", this, "uint*", &stat := 0, "cdecl int")
        ICUError.ThrowFor(stat)
        return count
    }

    /**
     * Resets the iterator to the current list of service IDs.
     * 
     * This re-establishes sync with the service and rewinds the iterator to start at the first element.
     * 
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/uenum_8h.html#a6de1f96ef374c9adbdbf0bd6fc9ccdd4 `uenum_reset`}
     */
    Reset() {
        DllCall("icu.dll\uenum_reset", "ptr", this, "uint*", &stat := 0, "cdecl")
        ICUError.ThrowFor(stat)
    }

    /**
     * Collect the in the enumerator into an Array,
     * @returns {Array<String>} the enumerated values 
     */
    Collect() {
        arr := []
        while (str := this.Next()) is String
            arr.Push(str)
        return arr
    }

    /**
     * Given an array of const char* strings (invariant chars only), return an `ICUEnumerator`.
     * 
     * String pointers from 0..count-1 must not be null. Do not free or modify either the string array or the 
     * characters it points to until this object has been destroyed.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/uenum_8h.html#a50e959b67901f37edb8be11c05cf7e6c `uenum_openCharStringsEnumeration`}
     * 
     * @param {Integer} arrPtr pointer to the string array
     * @param {Integer} count the number of elements in the array
     * @returns {ICUEnumerator} the enumerator 
     */
    static FromCharArray(arrPtr, count) {
        en := DllCall("icu.dll\uenum_openCharStringsEnumeration", 
            "ptr", arrPtr, 
            "int", count, 
            "uint*", 
            &stat := 0, 
            "cdecl ptr")

        ICUError.ThrowFor(stat)
        return ICUEnumerator(en, "UTF-8")
    }

    /**
     * Given an array of const UChar* strings (invariant chars only), return an `ICUEnumerator`.
     * 
     * String pointers from 0..count-1 must not be null. Do not free or modify either the string array or the 
     * characters it points to until this object has been destroyed.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/uenum_8h.html#a6b8f7ac8435095635fe51ce608010afe `uenum_openUCharStringsEnumeration`}
     * 
     * @param {Integer} arrPtr pointer to the string array
     * @param {Integer} count the number of elements in the array
     * @returns {ICUEnumerator} the enumerator 
     */
    static FromUCharArray(arrPtr, count) {
        en := DllCall("icu.dll\uenum_openUCharStringsEnumeration", 
            "ptr", arrPtr, 
            "int", count, 
            "uint*", 
            &stat := 0, 
            "cdecl ptr")

        ICUError.ThrowFor(stat)
        return ICUEnumerator(en, "UTF-16")
    }

    /**
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/uenum_8h.html#abcae42ba2a329894bcc3b37ad2a99a66 `uenum_dispose`}
     */
    __Delete() => DllCall("icu.dll\uenum_close", "ptr", this, "cdecl")
}