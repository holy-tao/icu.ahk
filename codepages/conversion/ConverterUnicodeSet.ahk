
/**
 * Selectors for Unicode sets that can be returned by `GetUnicodeSet`
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#a402221896b6d7153b14a5ff8dadde806 `UConverterUnicodeSet`}
 */
class ConverterUnicodeSet {
    static ROUNDTRIP                => 0
    static ROUNDTRIP_AND_FALLBACK   => 1
}