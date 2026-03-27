
/**
 * Enumeration of the possible types of text boundaries.
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#a026dec40289da8261d787daf3baa588b `UBreakIteratorType`}
 */
class BreakIteratorType {
    /** 
     * Character breaks
     * */
    static CHARACTER => 0

    /**
     * Wordk breaks.
     */
    static WORD => 1

    /**
     * Line breaks.
     */
    static LINE => 2

    /**
     * Sentence breaks.
     */
    static SENTENCE => 3

    /**
     * Title Case breaks The iterator created using this type locates title boundaries as described for Unicode 3.2 only.
     * @deprecated Use the word break iterator for titlecasing for Unicode 4 and later.
     */
    static TITLE => 4

    /**
     * One more than the highest normal UBreakIteratorType value.
     * @deprecated The numeric value may change over time, see ICU ticket #12420.
     */
    static COUNT => 5
}