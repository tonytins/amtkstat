<img title="" src="./assets/banner.svg" alt="" data-align="center" width="718">

Amtrak Status Boards, or AMTK Status, is a desktop front-end for accessing Dixieland Software's [station status boards](https://dixielandsoftware.net/Amtrak/solari/).

**WARNING: LARGE RESOLUTION.**

## 🗓️ Support & Update Cycle

| Type         | Frequency            | Notes                                    |
| ------------ | -------------------- | ---------------------------------------- |
| Minor Update | Every 3–6 months     | Small enhancements, non-breaking changes |
| Patch Update | Monthly or as needed | Bug fixes, security updates              |
| Major Update | As needed            | Framework upgrades, major refactors      |

## 🧘 Sustainability Practices

* 20% creative/recovery space built into development
* Mandatory cooldowns after major launches (minimum 1 week)
* Crisis Mode Activates if:
  * Critical vulnerabilities
  * Framework-breaking issue

## 🛡️ Support Levels

* [ ] Active Support
* [ ] Limited Support (Security patches only)
* [x] Maintenance Mode (Dependency-only updates)
* [ ] Archived (No active work planned)


## 🧰 Prerequisites

Before you begin, ensure you have the latest versions of the following installed:

- [Rust](https://www.rust-lang.org/tools/install)
- [.NET 8.0](https://dotnet.microsoft.com/en-us/)
  - ASP.NET Workload (Windows)
  - ``wasm-tools`` Workload (macOS/Linux)

## 📓 Project Notes

### 🔍 Background

This was intended to solve a rather awkward dilemma. I turned a bunch of online Amtrak status boards made by Dixieland Software into PWAs (standalone web apps) for stations that I viewed on Virtual Railfan. While it was convenient—don't get me wrong—I had to create a new web app for each station, and it became overwhelming to constantly switch between them all. This front-end was intended to solve that dilemma by accessing all stations from a single application using a modern, cleaner interface. The original icons found in this project's first commit were used for those PWAs.

## License

I license this project under either the GPL-3.0 or the EUPL-1.2 license – your choice. See [LICENSE-GPL](LICNESE-GPL) or [LICENSE-EUPL](LICENSE-EUPL) for details.

## Disclaimer

*This project is not in any way affiliated with Amtrak or Dixieland Software.*
