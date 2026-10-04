# mise android-sdk

The Android SDK command-line-tools plugin for [mise](https://mise.jdx.dev).

Installed `platform-tools`, `emulator`, and the highest installed semantic
`build-tools` version are added to `PATH`. To leave build-tools off `PATH`, use:

```toml
[tools]
android-sdk = { version = "13.0", build_tools = false }
```
