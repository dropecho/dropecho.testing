## A haxe library for automated testing.

This library is a "wrapper" on buddy and utest.
It allows you to use either one, but auto scan a testing directory and
include those tests.

## Usage
Currently expects a folder struct like:

test.hxml
test/
test/someFileTests.hx
test/other/otherTests.hx

test files must end in Tests to be discovered.

## TODO:

finish writing the documentation.
