
/**
 * Enum for specifying basic types of converters.
 * @see {@link https://unicode-org.github.io/icu-docs/apidoc/released/icu4c/ucnv_8h.html#adb0b44c6bd828c9d4cc2defcbba0f902 `UConverterType`}
 */
class ConverterType {
    /** Unsupported or unrecognized converter type. */
    static UNSUPPORTED          => -1

    /**
     * Single-Byte Character Set. Each character is encoded as exactly one byte.
     * Covers encodings like {@link https://en.wikipedia.org/wiki/ISO/IEC_8859 ISO-8859} variants, 
     * Windows code pages, and similar 8-bit sets.
     * @see {@link https://en.wikipedia.org/wiki/SBCS Single-byte character set}
     */
    static SBCS                 => 0

    /**
     * Double-Byte Character Set. Each character is encoded as exactly two bytes.
     * Primarily used for CJK (Chinese, Japanese, Korean) legacy encodings.
     * @see {@link https://en.wikipedia.org/wiki/DBCS Double-byte character set}
     */
    static DBCS                 => 1

    /**
     * Multi-Byte Character Set. Characters may be encoded with a variable number of bytes
     * (typically 1 or 2). A superset of SBCS and DBCS, covering encodings like Shift-JIS
     * and EUC variants.
     * @see {@link https://en.wikipedia.org/wiki/Variable-width_encoding Variable-width encoding}
     */
    static MBCS                 => 2

    /**
     * {@link https://en.wikipedia.org/wiki/ISO/IEC_8859-1 ISO-8859-1} (Latin-1). A single-byte encoding 
     * covering Western European languages. The first 256 Unicode code points are a direct superset of this 
     * encoding.
     */
    static LATIN_1              => 3

    /**
     * UTF-8. A variable-width Unicode encoding using 1–4 bytes per code point.
     * ASCII-compatible and the dominant encoding for the web.
     * @see {@link https://www.rfc-editor.org/rfc/rfc3629 RFC 3629}
     */
    static UTF8                 => 4

    /**
     * UTF-16 Big Endian. Fixed-width for BMP characters (2 bytes), surrogate pairs for
     * supplementary characters (4 bytes), with the most significant byte first.
     * @see {@link https://unicode.org/faq/utf_bom.html Unicode UTF FAQ}
     */
    static UTF16_BigEndian      => 5

    /**
     * UTF-16 Little Endian. Fixed-width for BMP characters (2 bytes), surrogate pairs for
     * supplementary characters (4 bytes), with the least significant byte first.
     * @see {@link https://unicode.org/faq/utf_bom.html Unicode UTF FAQ}
     */
    static UTF16_LittleEndian   => 6

    /**
     * UTF-32 Big Endian. Fixed-width encoding using 4 bytes per code point,
     * with the most significant byte first.
     * @see {@link https://unicode.org/faq/utf_bom.html Unicode UTF FAQ}
     */
    static UTF32_BigEndian      => 7

    /**
     * UTF-32 Little Endian. Fixed-width encoding using 4 bytes per code point,
     * with the least significant byte first.
     * @see {@link https://unicode.org/faq/utf_bom.html Unicode UTF FAQ}
     */
    static UTF32_LittleEndian   => 8

    /**
     * {@link https://en.wikipedia.org/wiki/EBCDIC EBCDIC} Stateful (mixed-width). IBM's Extended 
     * Binary Coded Decimal Interchange Code, used on IBM mainframes. The stateful variant supports 
     * both single- and double-byte characters via shift-in/shift-out control codes (e.g. IBM EBCDIC-JP).
     */
    static EBCDIC_STATEFUL      => 9

    /**
     * {@link https://en.wikipedia.org/wiki/ISO/IEC_2022 ISO 2022}. An encoding framework that uses escape 
     * sequences to switch between multiple character sets within a single byte stream, designed for 7-bit 
     * environments. Common variants include {@link https://www.ietf.org/rfc/rfc1468 ISO-2022-JP}, 
     * {@link https://datatracker.ietf.org/doc/html/rfc1557 ISO-2022-KR}, and 
     * {@link https://datatracker.ietf.org/doc/html/rfc1922 ISO-2022-CN}.
     */
    static ISO_2022             => 10

    /**
     * LMBCS Group 1 — Lotus Multi-Byte Character Set, Western European (cp850).
     * LMBCS encodes each character with a group-lead byte selecting one of several
     * single- or double-byte code pages; group 1 covers Western European Latin characters.
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia} and {@link https://github.com/unicode-org/icu/blob/main/icu4c/source/common/ucnv_lmb.cpp ICU ucnv_lmb.cpp}
     */
    static LMBCS_1              => 11    ; LMBCS_1 is the last with an explicit value in `ucnv.h`

    /**
     * LMBCS Group 2 — Greek (cp851 / cp869).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_2              => 12

    /**
     * LMBCS Group 3 — Hebrew (cp1255 / Windows-1255).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_3              => 13

    /**
     * LMBCS Group 4 — Arabic (cp1256 / Windows-1256).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_4              => 14

    /**
     * LMBCS Group 5 — Cyrillic (cp1251 / Windows-1251).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_5              => 15

    /**
     * LMBCS Group 6 — Central/Eastern European Latin (cp852).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_6              => 16

    /**
     * LMBCS Group 8 — Turkish (cp1254 / Windows-1254).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_8              => 17

    /**
     * LMBCS Group 11 — Thai (cp874 / Windows-874).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_11             => 18

    /**
     * LMBCS Group 16 — Japanese (cp932 / Windows-932, Shift-JIS variant).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_16             => 19

    /**
     * LMBCS Group 17 — Korean (cp949 / Windows-949, EUC-KR variant).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_17             => 20

    /**
     * LMBCS Group 18 — Traditional Chinese (cp950 / Windows-950, Big5 variant).
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_18             => 21

    /**
     * LMBCS Group 19 — Simplified Chinese (cp936 / Windows-936, GBK variant).
     * The last defined LMBCS group; see {@link ConverterType.LMBCS_LAST}.
     * @see {@link https://en.wikipedia.org/wiki/Lotus_Multi-Byte_Character_Set Lotus Multi-Byte Character Set | Wikipedia}
     */
    static LMBCS_19             => 22

    /** Alias for the last LMBCS group ({@link ConverterType.LMBCS_19}). */
    static LMBCS_LAST           => ConverterType.LMBCS_19

    /**
     * HZ. A 7-bit encoding for Simplified Chinese (GB 2312) mixed with ASCII,
     * using `~{` / `~}` escape sequences to delimit Chinese text. Defined in RFC 1843.
     * @see {@link https://datatracker.ietf.org/doc/html/rfc1843 RFC 1843} and {@link https://en.wikipedia.org/wiki/HZ_(character_encoding) HZ encoding | Wikipedia}
     */
    static HZ                   => 23

    /**
     * SCSU — Standard Compression Scheme for Unicode. Compresses Unicode text using
     * dynamically positioned windows, typically achieving ~1 byte per character for
     * Latin and ~2 bytes for CJK. Defined in Unicode Technical Standard #6.
     * @see {@link https://www.unicode.org/reports/tr6/ UTS #6: SCSU} and {@link https://en.wikipedia.org/wiki/Standard_Compression_Scheme_for_Unicode SCSU | Wikipedia}
     */
    static SCSU                 => 24

    /**
     * ISCII — Indian Script Code for Information Interchange. An 8-bit encoding for the
     * writing systems of India (Devanagari, Bengali, Tamil, Telugu, Gujarati, Gurmukhi,
     * Kannada, Malayalam, Odia). Characters with the same phonetic value share code points
     * across scripts. Largely superseded by Unicode.
     * @see {@link https://en.wikipedia.org/wiki/Indian_Script_Code_for_Information_Interchange ISCII | Wikipedia}
     */
    static ISCII                => 25

    /**
     * US-ASCII. 7-bit encoding covering the 128 basic Latin characters (letters, digits,
     * punctuation, and control codes). The foundation of most modern encodings.
     * @see {@link https://datatracker.ietf.org/doc/html/rfc20 RFC 20}
     */
    static US_ASCII             => 26

    /**
     * UTF-7. A 7-bit Unicode encoding using Base64-style shifted sequences for non-ASCII
     * characters, designed for transport through ASCII-only channels (e.g. older email).
     * Largely obsolete; UTF-8 is preferred. Defined in RFC 2152.
     * @see {@link https://datatracker.ietf.org/doc/html/rfc2152 RFC 2152} and {@link https://en.wikipedia.org/wiki/UTF-7 UTF-7 | Wikipedia}
     */
    static UTF7                 => 27

    /**
     * BOCU-1 — Binary Ordered Compression for Unicode. A MIME-compatible compression
     * encoding that encodes most code points in 1–3 bytes while preserving lexicographic
     * sort order, making it suitable for databases and sorted string lists.
     * @see {@link https://unicode.org/reports/tr40/ UTS #40: BOCU-1} and {@link https://en.wikipedia.org/wiki/BOCU-1 BOCU-1 | Wikipedia}
     */
    static BOCU1                => 28

    /**
     * UTF-16 with BOM. Auto-detects byte order from a leading Byte Order Mark (U+FEFF);
     * defaults to big-endian when no BOM is present. Use {@link ConverterType.UTF16_BigEndian}
     * or {@link ConverterType.UTF16_LittleEndian} for explicit byte order.
     * @see {@link https://unicode.org/faq/utf_bom.html Unicode UTF & BOM FAQ}
     */
    static UTF16                => 29

    /**
     * UTF-32 with BOM. Auto-detects byte order from a leading Byte Order Mark (U+FEFF);
     * defaults to big-endian when no BOM is present. Use {@link ConverterType.UTF32_BigEndian}
     * or {@link ConverterType.UTF32_LittleEndian} for explicit byte order.
     * @see {@link https://unicode.org/faq/utf_bom.html Unicode UTF & BOM FAQ}
     */
    static UTF32                => 30

    /**
     * CESU-8 — Compatibility Encoding Scheme for UTF-16: 8-Bit. Similar to UTF-8, but
     * supplementary characters (U+10000–U+10FFFF) are encoded as two 3-byte sequences
     * representing a UTF-16 surrogate pair. Intended for internal system use only, not
     * external data exchange.
     * @see {@link https://unicode.org/reports/tr26/ UTR #26: CESU-8} and {@link https://en.wikipedia.org/wiki/CESU-8 CESU-8 | Wikipedia}
     */
    static CESU8                => 31

    /**
     * IMAP Mailbox encoding. A modified UTF-7 variant (per RFC 3501 §5.1.3) for encoding
     * non-ASCII characters in IMAP mailbox names. Printable ASCII (except `&`) is literal;
     * `&` is escaped as `&-`; other characters use Base64-encoded UTF-16BE shifted sequences.
     * @see {@link https://datatracker.ietf.org/doc/html/rfc3501#section-5.1.3 RFC 3501 §5.1.3}
     */
    static IMAP_MAILBOX         => 32

    /**
     * X11 Compound Text. An X Consortium encoding used for inter-client text exchange
     * (selections, window properties, X resources) in X11. Uses ISO-2022-style escape
     * sequences to switch between ISO-8859 variants and CJK character sets.
     * @see {@link https://www.x.org/releases/X11R7.6/doc/xorg-docs/specs/CTEXT/ctext.html X11 Compound Text Specification}
     */
    static COMPOUND_TEXT        => 33
}
