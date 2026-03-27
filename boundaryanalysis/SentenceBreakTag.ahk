/**
 * Enum constants for the sentence break tags returned by getRuleStatus().
 * 
 * A range of values is defined for each category of sentence, to allow for further subdivisions of a category in 
 * future releases. Applications should check for tag values falling within the range, rather than for single 
 * individual values.
 * 
 * The numeric values of all of these constants are stable (will not change).
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#ad03d8e27f121bcf11eaed0a288786a71 `USentenceBreakTag`}
 */
class SentenceBreakTag {
    /**
     * Tag value for for sentences ending with a sentence terminator ('.', '?', '!', etc.) character, possibly 
     * followed by a hard separator (CR, LF, PS, etc.)
     */
    static TERM => 0

    /**
     * Upper bound for tags for sentences ended by sentence terminators.
     */
    static TERM_LIMIT => 100

    /**
     * Tag value for for sentences that do not contain an ending sentence terminator ('.', '?', '!', etc.) character, 
     * but are ended only by a hard separator (CR, LF, PS, etc.) or end of input.
     */
    static SEP => 0

    /**
     * Upper bound for tags for sentences ended by a separator.
     */
    static SEP_LIMIT => 200
}