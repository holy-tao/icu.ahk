#Requires AutoHotkey >=v2.0

/**
 * Constants for normalization modes.
 * 
 * For details about standard Unicode normalization forms and about the algorithms which are also used with custom 
 * mapping tables see http://www.unicode.org/unicode/reports/tr15/
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/unorm2_8h.html#a3cf189b046fe90ca167d2294275f4ab5 `UNormalization2Mode`}
 */
class UNormalization2Mode {
    /**
     * Decomposition followed by composition.
     * 
     * Same as standard NFC when using an "nfc" instance. Same as standard NFKC when using an "nfkc" instance.
     * @type {Integer}
     */
    static COMPOSE => 0

    /**
     * Map, and reorder canonically. 
     * 
     * Same as standard NFD when using an "nfc" instance. Same as standard NFKD when using an "nfkc" instance.
     * @type {Integer}
     */
    static DECOMPOSE => 1

    /**
     * "Fast C or D" form.
     * 
     * If a string is in this form, then further decomposition without reordering would yield the same form as
     * `DECOMPOSE`. Text in "Fast C or D" form can be processed efficiently with data tables that are "canonically
     * closed", that is, that provide equivalent data for equivalent text, without having to be fully normalized. Not
     * a standard Unicode normalization form. Not a unique form: Different FCD strings can be canonically equivalent.
     * For details see http://www.unicode.org/notes/tn5/#FCD
     * @type {Integer}
     */
    static FCD => 2

    /**
     * Compose only contiguously.
     * 
     * Also known as "FCC" or "Fast C Contiguous". The result will often but not always be in NFC. The result will 
     * conform to FCD which is useful for processing. Not a standard Unicode normalization form. For details see 
     * http://www.unicode.org/notes/tn5/#FCC
     * @type {Integer}
     */
    static COMPOSE_CONTIGUOUS => 3
}