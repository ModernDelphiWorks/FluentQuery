---
title: Installation
sidebar_position: 1
---

# Installation

## Via Boss (recommended)

[Boss](https://github.com/HashLoad/boss) is the standard package manager for Delphi. Install Colligo with:

```sh
boss install ModernDelphiWorks/Colligo
```

## Via PubPascal

Colligo is listed on the [PubPascal package portal](https://www.pubpascal.dev/packages/colligo). Follow the portal's instructions to add it to your project.

## Manual installation

1. Clone or download the repository from [github.com/ModernDelphiWorks/Colligo](https://github.com/ModernDelphiWorks/Colligo).
2. Add the `Source\` directory to your project's search path in the Delphi IDE (Project → Options → Delphi Compiler → Search path).
3. Add `Colligo` to your `uses` clause.

## Search path entries

The minimum required path entry is:

```
<install-root>\Source
```

## Unit to add to uses

For in-memory collections, add only:

```delphi
uses
  Colligo;
```

For database queries (`IColligoQueryable<T>`), also add:

```delphi
uses
  Colligo,
  Colligo.Queryable;
```

## Supply-chain transparency

A machine-readable **SBOM** (CycloneDX) is published on the package portal — [pubpascal.dev/packages/colligo](https://www.pubpascal.dev/packages/colligo). The security disclosure policy is in [SECURITY.md](https://github.com/ModernDelphiWorks/Colligo/blob/main/SECURITY.md).
