
/**
 * Enum constants for the line break tags returned by getRuleStatus().
 * 
 * A range of values is defined for each category of word, to allow for further subdivisions of a category in future 
 * releases. Applications should check for tag values falling within the range, rather than for single individual 
 * values.
 * 
 * The numeric values of all of these constants are stable (will not change).
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a8de005c411b5e5306850f4246d1d7ccd `UlineBreakTag`}
 */
class LineBreakTag {
    /**
     * Tag value for soft line breaks, positions at which a line break is acceptable but not required
     */
    static SOFT => 0

    /**
     * Upper bound for soft line breaks.
     */
    static SOFT_LIMIT => 100

    /**
     * Tag value for a hard, or mandatory line break
     */
    static HARD => 100

    /**
     * Upper bound for hard line breaks.
     */
    static HARD_LIMIT => 200
}