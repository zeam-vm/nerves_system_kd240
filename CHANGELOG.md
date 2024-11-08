# Changelog

This project does NOT follow semantic versioning. The version increases as
follows:

1. Major version updates are breaking updates to the build infrastructure.
   These should be very rare.
2. Minor version updates are made for every major Buildroot release. This
   may also include Erlang/OTP and Linux kernel updates. These are made four
   times a year shortly after the Buildroot releases.
3. Patch version updates are made for Buildroot minor releases, Erlang/OTP
   releases, and Linux kernel updates. They're also made to fix bugs and add
   features to the build infrastructure.

## v0.1.0

This is the first public release.

* Fixes
  * When `Nerves.Runtime.revert/0` was executed with a USB storage device inserted,
    usb0 was assigned to the USB storage, causing the revert to fail.
    This issue has been fixed.

## v0.0.2

This is a major Buildroot and toolchain update.

* Updated dependencies
  * [nerves_system_br v1.29.0](https://github.com/nerves-project/nerves_system_br/releases/tag/v1.29.0)
  * [Buildroot 2024.08](https://lore.kernel.org/buildroot/87frqcj3nw.fsf@dell.be.48ers.dk/T/)
  * [Erlang/OTP 27.1.1](https://erlang.org/download/OTP-27.1.1.README)

## v0.0.1

This is the initial Nerves System release for the Kria KD240.

* Primary constituent project versions
  * [nerves_system_br v1.20.6](https://github.com/nerves-project/nerves_system_br/releases/tag/v1.20.6)
  * [nerves_toolchain_aarch64_nerves_linux_gnu-linux_aarch64-13.2.0](https://github.com/nerves-project/toolchains/releases/tag/v13.2.0)
