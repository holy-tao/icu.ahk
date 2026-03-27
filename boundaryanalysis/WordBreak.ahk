
/**
 * Enum constants for the word break tags returned by getRuleStatus().
 * 
 * A range of values is defined for each category of word, to allow for further subdivisions of a category in future 
 * releases. Applications should check for tag values falling within the range, rather than for single individual 
 * values.
 * 
 * The numeric values of all of these constants are stable (will not change).
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ubrk_8h.html#af9836cc79482f82ac12eefb1f70b14b9 `UWordBreak`}
 */
class WordBreak {
    /**
     * Tag value for "words" that do not fit into any of other categories.
     * 
     * Includes spaces and most punctuation.
     */
    NONE => 0

    /**
     * Upper bound for tags for uncategorized words.
     */
    NONE_LIMIT => 100

    /**
     * Tag value for words that appear to be numbers, lower limit.
     */
    NUMBER => 100

    /**
     * Tag value for words that appear to be numbers, upper limit.
     */
    NUMBER_LIMIT => 200

    /**
     * Tag value for words that contain letters, excluding hiragana, katakana or ideographic characters, lower limit.
     */
    LETTER => 200

    /**
     * Tag value for words containing letters, upper limit
     */
    LETTER_LIMIT => 300

    /**
     * Tag value for words containing kana characters, lower limit.
     */
    KANA => 300

    /**
     * Tag value for words containing kana characters, upper limit.
     */
    KANA_LIMIT => 400

    /**
     * Tag value for words containing ideographic characters, lower limit.
     */
    IDEO => 400

    /**
     * Tag value for words containing ideographic characters, upper limit.
     */
    IDEO_LIMIT => 500
}