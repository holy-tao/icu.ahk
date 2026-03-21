#Requires AutoHotkey v2.0

#DllLoad icu.dll

/**
 * Represents an Error raised by an ICU function, roughly wrapping the `UErrorCode` enum and related functions.
 * 
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/utypes_8h.html#a3343c1c8a8377277046774691c98d78c `UErrorCode`} and 
 *      {@link https://unicode-org.github.io/icu/userguide/dev/codingguidelines#details-about-icu-error-codes Details about ICU Error Codes | ICU Documentation}
 */
class ICUError extends Error {

    /**
     * Creates a new ICU Error from an ICU error code or traditional message string
     * @param {Integer | String} codeOrMsg the error code or an error message to display
     */
    __New(codeOrMsg, what?, extra?) {
        msg := IsInteger(codeOrMsg) ? 
            ICUError.GetName(codeOrMsg) "`n`nSee: https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/utypes_8h.html#a3343c1c8a8377277046774691c98d78c"
            : codeOrMsg
        
        super.__New(msg, what?, extra?)
    }

    /**
     * Gets the name of an error code - e.g. `U_INVALID_FORMAT_ERROR`.
     * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/utypes_8h.html#a1d0851a6f3368e9a0d070c7e09b6fc0f `u_errorName`}
     * 
     * @param {String} code the error code
     * @returns {String} The name of the error code. If `code` is not a valid error code, this is
     *          the string "[BOGUS UErrorCode]"
     */
    static GetName(code) => DllCall("icu.dll\u_errorName", "uint", code, "cdecl astr")

    /**
     * Check to see if `code` indicates success *or* a warning
     * @See {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/utypes_8h.html#a527f2c69e6b2e3b2c53ad8a99fb36711 `U_SUCCESS`}
     * 
     * @param {Integer} code the code to check 
     * @returns {Integer} 1 if code is success, 0 if it's a failure
     */
    static IsSuccess(code) => code <= 0

    /**
     * Check to see if `code` indicates a warning. Most warnings can be safely ignored, {@link ICUError.ThrowFor `ICUError.ThrowFor`}
     * ignores them unless explicitly told not to.
     * 
     * There is no equivalent C macro.
     * @see {@link https://unicode-org.github.io/icu/userguide/dev/codingguidelines#warning-codes Warning Codes | ICU Documentation}
     * 
     * @param {Integer} code the code to check 
     * @returns {Integer} ` if `code` is a warning, 0 otherwise
     */
    static IsWarning(code) => code < 0

    /**
     * Check to see if `code` indicates failure (that is, an error)
     * @See {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/utypes_8h.html#a4d202200b6aa6f3c965ea370e0c8155f `U_FAILURE`}
     * 
     * @param {Integer} code the code to check 
     * @returns {Integer} 1 if code is faillure, 0 if it's success
     */
    static IsError(code) => code > 0

    /**
     * Throws an `ICUError` if `code` indicates an error
     * 
     * @param {Integer} code the code to check 
     * @param {Boolean} warn if truthy, also throw if `code` indicates a {@link https://unicode-org.github.io/icu/userguide/dev/codingguidelines#warning-codes warning}
     */
    static ThrowFor(code, warn := false) {
        if this.IsError(code) || (warn && this.IsWarning(code))
            throw ICUError(code, -2)
    }
}