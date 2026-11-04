package dropecho.testing;

/**
Main class for test builds. Set `--main dropecho.testing.AutoTest` and every `*Tests.hx`
class on the classpath runs with utest or buddy.
**/
@:build(dropecho.testing.IncludeTestsMacro.buildTests())
class AutoTest {}
