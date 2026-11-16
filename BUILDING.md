# Building ShortcutsNoConfirm

The release is a rootless `iphoneos-arm64` Debian package containing `arm64` and `arm64e` binaries. Building successfully does not establish device compatibility.

## Tested environment

- macOS, Xcode 27.0 (`27A266a`), GNU Make 3.81, dpkg 1.23.11 and ldid 2.1.5.
- [Theos](https://github.com/theos/theos) commit `8167f59de02fd32cf45b16bfcb1330dfa5c9974c`, with submodules initialized.
- Patched `iPhoneOS16.5.sdk` from [theos/sdks](https://github.com/theos/sdks), commit `104bd6cc8924fcdef1cd9de0bd59d27b9272defb`, installed in `$THEOS/sdks/iPhoneOS16.5.sdk`.

Use [Theos's installation guide](https://theos.dev/docs/installation) to set up the tools and follow [Theos's rootless guidance](https://theos.dev/docs/rootless) when changing the build environment. No libraries beyond the SDK are needed.

## Compile

From this project's directory, after setting `THEOS` to your installation:

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
make clean package FINALPACKAGE=1
```

The Makefile defaults to rootless packaging, `arm64` and `arm64e`, SDK 16.5 and a deployment target of 16.5. Keep the package's exact `firmware (= 16.5.1)` dependency unless testing establishes support for another version.

The package is written to `packages/com.skfallin.shortcutsnoconfirm_0.1.0~beta2_iphoneos-arm64.deb`.

## Package checks

```sh
dpkg-deb -c packages/*.deb
dpkg-deb -f packages/*.deb Package Version Architecture Depends
lipo -info .theos/_/var/jb/Library/MobileSubstrate/DynamicLibraries/ShortcutsNoConfirm.dylib
```

Expected contents, all under `/var/jb`:

- `Library/MobileSubstrate/DynamicLibraries/ShortcutsNoConfirm.dylib` and `.plist`, filtered on the `com.apple.WorkflowKit` bundle.
- `Library/PreferenceLoader/Preferences/ShortcutsNoConfirm/Preferences.plist`, the Settings switch.

## Checking the hooks against a firmware

The class and selector names were checked against the iOS 16.5.1 (20F75) dyld shared cache with [ipsw](https://github.com/blacktop/ipsw) 3.1.749. To repeat the check, or to look at another build:

```sh
ipsw download ipsw --device iPhone14,5 --version 16.5.1 --dyld --dyld-arch arm64e -o fw
ipsw class-dump fw/20F75__iPhone14,5/dyld_shared_cache_arm64e WorkflowKit --headers -o headers
ipsw dsc disass fw/20F75__iPhone14,5/dyld_shared_cache_arm64e \
  --symbol '___53-[WFLinkConfirmationDialogViewController viewDidLoad]_block_invoke'
```

The last command shows the Yes button sending response code `1`. The same method was used for `WFInteractionDialogViewController` and for the `WFSecureConfirmationAlert` continue button.
