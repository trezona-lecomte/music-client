module Tests where

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)

import String


all : Test
all =
    suite "A Test Suite"
        [ test "Addition" (assertEqual (3 + 7) 10)
        , test "String.left" (assertEqual "a" (String.left 1 "abcdefg"))
        ]
