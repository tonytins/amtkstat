<img title="" src="./assets/banner.svg" alt="" data-align="center" width="718">

Amtrak Status Boards, or AMTK Status, is a desktop front-end for accessing Dixieland Software's [station status boards](https://dixielandsoftware.net/Amtrak/solari/).

**WARNING: LARGE RESOLUTION.**

## 🗓️ Update Cycle

| Type         | Frequency            |
| ------------ | -------------------- |
| Minor Update | Every 3–6 months     |
| Patch Update | Monthly or as needed |
| Major Update | As needed            |

## 🖥️ Platform Support

| Target  | Windows | macOS  | Linux |
| ------- | ------- | ------ | ----- |
| x86_64  | ✅      | ⚠️[^1] | ✅    |
| aarch64 | ❌      | ✅     | ⚠️    |

- ✅ Tier 1
- ⚠️ Tier 2
- ❌ Unsupported

[^1]: [Rust 1.89](https://blog.rust-lang.org/2025/08/07/Rust-1.89.0/) downgrades AMD64 support after Apple and GitHub CI did the same.

## 🛡️ Support

- [x] Active Support
- [ ] Limited Support (Security patches only)
- [ ] Maintenance Mode (Dependency-only updates)
- [ ] Archived (No active work planned)

## 🧰 Prerequisites

Before you begin, ensure you have the latest versions of the following installed:

- [Rust](https://www.rust-lang.org/tools/install)
- [.NET 8.0](https://dotnet.microsoft.com/en-us/)
  - ASP.NET Workload (Windows)
  - `wasm-tools` Workload (macOS/Linux)

## 📓 Project Notes

### 🔍 Background

This was intended to solve a rather awkward dilemma. I turned a bunch of online Amtrak status boards made by Dixieland Software into PWAs (standalone web apps) for stations that I viewed on Virtual Railfan. While it was convenient (don't get me wrong) I had to create a new web app for each station, and it became rather overwhelming to constantly switch between them all. This front-end was intended to solve that mini-crisis by accessing all stations from a single application using a modern, cleaner interface. The original icons found in this project's first commit were used for those PWAs.

## 📄 License

I license this project under either the GPL-3.0 or the EUPL-1.2 license – your choice. See [LICENSE-GPL](LICNESE-GPL) or [LICENSE-EUPL](LICENSE-EUPL) for details.

## ⚠️ Disclaimer

_This project is not in any way affiliated with Amtrak or Dixieland Software._
