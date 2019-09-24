# Barca

:zap: Barca hastens Carthage packages like lightning.

## Overview

Barca enables to build Carthage packages as Static Frameworks.

Barca injects build settings to each packages before building.

## Installation

### Mint

```
$ mint run giginet/Barca
```

## Usage

### Config

For example, your project have following `Cartfile`.

```
github "ReactiveX/RxSwift" ~> 5.0.0
github "giginet/Crossroad" ~> 3.0.0
```

Place `Barca.toml` on your project root.
You have to specify Framework types for each packages.


Some packages contains multiple modules. (e.g. RxSwift)
You can treat them like followings.

```toml
[packages.RxSwift]
RxCocoa = "static"
RxSwift = "static"
RxRelay = "static"
RxTest = "dynamic"
RxBlocking = "dynamic"

[packages.Crossroad]
Crossroad = "static"
```

### Workflow

```console
$ carthage bootstrap --no-build
$ barca apply --project-root /path/to/your/project/directory
RxSwift:
    ⚡Modified RxSwift to Static Framework
    ⚡Modified RxCocoa to Static Framework
    ⚡Modified RxRelay to Static Framework
    ⚡Modified RxTest to Dynamic Framework
    ⚡Modified RxBlocking to Dynamic Framework
Crossroad:
    ⚡Modified Crossroad to Static Framework
$ carthage build
```

### Settings

```toml
git_path = "/path/to/git/executable"

[packages.SomePackage]
Target1 = "dynamic"
Target2 = "static"
```
