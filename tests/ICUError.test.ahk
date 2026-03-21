#Include ./YUnit/Assert.ahk
#Include ../common/ICUError.ahk

class ICUErrorTests {
    class GetName {
        GetName_WithErrorCode_GetsName() {
            Assert.Equals(ICUError.GetName(12), "U_ILLEGAL_CHAR_FOUND")
        }

        GetName_UnknownValue_GetsBogusString() {
            Assert.Equals(ICUError.GetName(-1), "[BOGUS UErrorCode]")
        }
    }

    class ThrowFor {
        ThrowFor_ByDefault_IgnoresWarnings() {
            ICUError.ThrowFor(-123)
        }

        ThrowFor_WarnTrue_ThrowsForWarning() {
            Assert.Throws(
                (*) => ICUError.ThrowFor(-123, true),
                ICUError
            )
        }

        ThrowFor_WarnTrue_IgnoresSuccesses() {
            ICUError.ThrowFor(0, true)
        }

        ThrowFor_WithSuccess_DoesNothing() {
            ICUError.ThrowFor(0)
        }
    }
}