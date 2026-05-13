# [1.6.0](https://github.com/dropecho/dropecho.testing/compare/1.5.3...1.6.0) (2026-05-13)


### Features

* **runner:** add verbose/show_headers defines to control test output ([#4](https://github.com/dropecho/dropecho.testing/issues/4)) ([3aa7faa](https://github.com/dropecho/dropecho.testing/commit/3aa7faa6fe3996be81501a3a2e8a6ac535d33b84))

## [1.5.3](https://github.com/dropecho/dropecho.testing/compare/1.5.2...1.5.3) (2026-05-13)


### Bug Fixes

* **runner:** prefer mono over dotnet for CS test execution on non-Windows ([#3](https://github.com/dropecho/dropecho.testing/issues/3)) ([da0f96e](https://github.com/dropecho/dropecho.testing/commit/da0f96eecb5fd28c0ba40f63cc37fb790bdbb8a6))

## [1.5.2](https://github.com/dropecho/dropecho.testing/compare/1.5.1...1.5.2) (2026-05-13)


### Bug Fixes

* **runner:** detect platform and use dotnet/mono for CS test execution ([557937f](https://github.com/dropecho/dropecho.testing/commit/557937f2dd2e5a0b09ce0b3a371cfc1abeea7607))

## [1.5.1](https://github.com/dropecho/dropecho.testing/compare/1.5.0...1.5.1) (2026-05-13)


### Bug Fixes

* **runner:** use space-separated args instead of = syntax for haxe flags ([dc4fa0d](https://github.com/dropecho/dropecho.testing/commit/dc4fa0df72a81978991f4914282947560b9c9191))

# [1.5.0](https://github.com/dropecho/dropecho.testing/compare/1.4.0...1.5.0) (2026-05-13)


### Bug Fixes

* Use direct haxe compile in test script instead of haxelib run ([9d3949c](https://github.com/dropecho/dropecho.testing/commit/9d3949cc1d340ea91bd58f0e06d042801fb556af))


### Features

* Add tests for hxml parsing and document instrument as peer dep ([41d626b](https://github.com/dropecho/dropecho.testing/commit/41d626b02ccdc11fe75ead51d890659235e08832))

# [1.4.0](https://github.com/dropecho/dropecho.testing/compare/1.3.0...1.4.0) (2026-05-13)


### Features

* Finish instrumentation/coverage wiring in CLI runner ([d4c1cd0](https://github.com/dropecho/dropecho.testing/commit/d4c1cd08ae4c34fedce8f56ac76e117d23da0230))

# [1.3.0](https://github.com/dropecho/dropecho.testing/compare/1.2.0...1.3.0) (2025-01-24)


### Features

* Add ability to use profiling with instrument lib. ([bb41e0b](https://github.com/dropecho/dropecho.testing/commit/bb41e0b4904da2ed04f53e8a8791010434549993))

# [1.2.0](https://github.com/dropecho/dropecho.testing/compare/1.1.5...1.2.0) (2025-01-24)


### Features

* Add ability to use instrument lib with test runners. ([7839351](https://github.com/dropecho/dropecho.testing/commit/783935175b9c1176fd8490bdcfa0a5dae55210aa))

## [1.1.5](https://github.com/dropecho/dropecho.testing/compare/1.1.4...1.1.5) (2024-06-05)


### Bug Fixes

* Make cpp tests work. ([1eb2766](https://github.com/dropecho/dropecho.testing/commit/1eb2766d6432a5edb002f72b58bcdead19a5360f))

## [1.1.4](https://github.com/dropecho/dropecho.testing/compare/1.1.3...1.1.4) (2023-07-07)


### Bug Fixes

* Fix issue with directories not currently working with semantic haxelib additional files. ([1c8ce46](https://github.com/dropecho/dropecho.testing/commit/1c8ce466a98ffd5e47d8cb3a6b3d60e67d07c8b5))
* Include tools in published haxelib. ([6460c06](https://github.com/dropecho/dropecho.testing/commit/6460c06a9650a3e7930cb2d1503fa169144fad5e))

## [1.1.3](https://github.com/dropecho/dropecho.testing/compare/1.1.2...1.1.3) (2023-07-07)


### Bug Fixes

* Actually fix main/run. ([dbaeeba](https://github.com/dropecho/dropecho.testing/commit/dbaeeba1aef6d65cd19da4f698e512909b25ed24))

## [1.1.2](https://github.com/dropecho/dropecho.testing/compare/1.1.1...1.1.2) (2023-07-07)


### Bug Fixes

* Fix issue with run script location in haxelib.json ([12af435](https://github.com/dropecho/dropecho.testing/commit/12af4355644f8e71925b5b5f51249fad1bb65224))

## [1.1.1](https://github.com/dropecho/dropecho.testing/compare/1.1.0...1.1.1) (2023-07-06)


### Bug Fixes

* Improve readme. ([8895625](https://github.com/dropecho/dropecho.testing/commit/8895625cfee2933d962430e8b419d76c7a221f86))

# [1.1.0](https://github.com/dropecho/dropecho.testing/compare/1.0.1...1.1.0) (2023-07-06)


### Features

* Make testing return exit code (mostly for failure tracking). ([12dfcfd](https://github.com/dropecho/dropecho.testing/commit/12dfcfd1b827881520fcbac04b47a31369a5fa64))

## [1.0.1](https://github.com/dropecho/dropecho.testing/compare/1.0.0...1.0.1) (2022-12-27)


### Bug Fixes

* Fix issue with main run script in haxelib.json ([65c36c8](https://github.com/dropecho/dropecho.testing/commit/65c36c89666297712f4c85325fa15a65a24f2135))

# 1.0.0 (2022-12-26)


### Features

* Initial commit. ([647aad7](https://github.com/dropecho/dropecho.testing/commit/647aad7640b61932c8a921a165d71c867a039217))
