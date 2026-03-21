#Include YUnit\Assert.ahk
#Include ..\common\ICUEnumerator.ahk

; TODO add tests for UTF-8 enumerator variants

class ICUEnumeratorTests {
    ForLoopEnumeration_EnumeratesAllValues() {
        arr := ICUEnumeratorTests._MakeCharArray()
        enum := ICUEnumerator.FromUCharArray(arr, arr.Size // A_PtrSize)

        collected := []
        for(str in enum) {
            collected.Push(str)
        }

        Assert.ArraysEqual(collected, ["One", "Two", "Three", "Four", "Five"])
    }

    Collect_CollectsAllValues() {
        arr := ICUEnumeratorTests._MakeCharArray()
        enum := ICUEnumerator.FromUCharArray(arr, arr.Size // A_PtrSize)
        collected := enum.Collect()

        Assert.ArraysEqual(collected, ["One", "Two", "Three", "Four", "Five"])
    }

    Next_GetsNextValue() {
        arr := ICUEnumeratorTests._MakeCharArray()
        enum := ICUEnumerator.FromUCharArray(arr, arr.Size // A_PtrSize)

        Assert.Equals(enum.Next(), "One")
        Assert.Equals(enum.Next(), "Two")
        Assert.Equals(enum.Next(), "Three")
        Assert.Equals(enum.Next(), "Four")
        Assert.Equals(enum.Next(), "Five")

        ; Should return the pure integer 0 when exhausted
        Assert.Equals(enum.Next(), 0)
        Assert.Equals(enum.Next(), 0)
    }

    Reset_ResetsEnumerator() {
        arr := ICUEnumeratorTests._MakeCharArray()
        enum := ICUEnumerator.FromUCharArray(arr, arr.Size // A_PtrSize)

        Assert.Equals(enum.Next(), "One")
        Assert.Equals(enum.Next(), "Two")

        enum.Reset()

        Assert.Equals(enum.Next(), "One")
        Assert.Equals(enum.Next(), "Two")
        Assert.Equals(enum.Next(), "Three")
        Assert.Equals(enum.Next(), "Four")
        Assert.Equals(enum.Next(), "Five")

        ; Should return the pure integer 0 when exhausted
        Assert.Equals(enum.Next(), 0)
        Assert.Equals(enum.Next(), 0)
    }

    Count_ReturnsCount() {
        arr := ICUEnumeratorTests._MakeCharArray()
        enum := ICUEnumerator.FromUCharArray(arr, arr.Size // A_PtrSize)

        Assert.Equals(enum.Count(), 5)
    }

    static _MakeCharArray() {
        ; Using literals makes strings live for the length of the program and keeps their pointers constant,
        ; though we care less about that. These are always utf-16, need to StrPut to get utf-8 variants
        buf := Buffer(A_PtrSize * 5, 0)
        NumPut(
            "ptr", StrPtr("One"),
            "ptr", StrPtr("Two"),
            "ptr", StrPtr("Three"),
            "ptr", StrPtr("Four"),
            "ptr", StrPtr("Five"),
            buf)

        return buf
    }
}