# AGENTS.md

Instructions for AI agents working in this repository. Read this file fully before doing anything.

This repository is the template of OpenECS's tools. OpenECS's [AGENTS.md](https://github.com/omerfuyar/OpenECS/blob/dev/AGENTS.md) applies here in full: how to work with the owner, the boundaries, git and writing documents. Read it first. This file names only what is different here.

A tool made from this template is its owner's own repository; its owner may keep, change or remove this file.

## Where things are

| Path                   | What it holds                                                              |
| ---------------------- | -------------------------------------------------------------------------- |
| [README.md](README.md) | Short introduction, and how to run the tool.                               |
| [GUIDE.md](GUIDE.md)   | The guide: how to make a tool from the template, one part at a time.       |
| `preset.lua`           | The tool's preset.                                                         |
| `plugins/`             | The tool's plugins, one folder each.                                       |
| `test.lua`             | The tool's test.                                                           |
| `build.sh`             | Builds the plugins in C.                                                   |
| `.github/`             | Checks and rulesets.                                                       |
| `LICENSE.md`           | The license, zlib.                                                         |

OpenECS's OVERVIEW.md and DESIGN.md hold how OpenECS works. Read them before you propose or change anything.

## Differences

- The template follows OpenECS's `dev`: a change to OpenECS's plugin interface changes the template in the same piece of work, so its test passes.
- The template is not released with OpenECS: its `main` is what "Use this template" copies. `dev` is merged into `main` with a pull request that the owner reviews.
- The guide is for people who start a tool. It explains each part the first time it appears, and links to OpenECS's documents for the details, so one source of truth stays in OpenECS.
- The files' comments explain what OpenECS does with each part, as the examples' comments do (OpenECS DESIGN.md, section 17.6).
