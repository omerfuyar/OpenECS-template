# OpenECS template

Template of a tool made with [OpenECS](https://github.com/omerfuyar/OpenECS): a preset, a plugin in Lua and a plugin in C, a test, and a guide that goes through each part. Press "Use this template" on GitHub to make your own repository from it.

The tool is a board of notes beside a small panel in C. Unpack an [OpenECS release](https://github.com/omerfuyar/OpenECS/releases) into `OpenECS/`, then:

``` shell
./build.sh !!! todo remove this
OpenECS/OpenECS --fresh --preset preset.lua
```

[GUIDE.md](GUIDE.md) explains the preset, plugins, panels, drawing, settings, keys, saved state, plugins in C, your editor's setup, tests, and how to ship your tool.

## Documents

- [GUIDE.md](GUIDE.md): how to make a tool from this template.
- [AGENTS.md](AGENTS.md): instructions for AI agents working in this repository.
- [LICENSE.md](LICENSE.md): the license, zlib.
