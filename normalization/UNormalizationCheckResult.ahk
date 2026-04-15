#Requires AutoHotkey >=v2.0 

/**
 * Result values for normalization quick check functions.
 * 
 * For details see http://www.unicode.org/reports/tr15/#Detecting_Normalization_Forms
 */
class UNormalizationCheckResult {
    /**
     * The input string is not in the normalization form.
     * @type {Integer}
     */
    static NO => 0

    /**
     * The input string is in the normalization form.
     * @type {Integer}
     */
    static YES => 1

    /**
     * The input string may or may not be in the normalization form.
     * 
     * This value is only returned for composition forms like NFC and FCC, when a backward-combining character is 
     * found for which the surrounding text would have to be analyzed further.
     * @type {Integer}
     */
    static MAYBE => 2
}