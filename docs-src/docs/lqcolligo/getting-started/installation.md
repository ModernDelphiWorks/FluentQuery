---
title: Installation
sidebar_position: 1
---

# Installation

## Via Boss (recommended)

[Boss](https://github.com/HashLoad/boss) is the standard package manager for Delphi. Install LQ-Colligo with:

```sh
boss install ModernDelphiWorks/LQ-Colligo
```

## Via PubPascal

LQ-Colligo is listed on the [PubPascal package portal](https://www.pubpascal.dev/packages/lq-colligo). Follow the portal's instructions to add it to your project.

## Manual installation

1. Clone or download the repository from [github.com/ModernDelphiWorks/LQ-Colligo](https://github.com/ModernDelphiWorks/LQ-Colligo).
2. Add the `Source\` directory to your project's search path in the Delphi IDE (Project → Options → Delphi Compiler → Search path).
3. Add `LQColligo` to your `uses` clause.

## Search path entries

The minimum required path entry is:

```
<install-root>\Source
```

## Unit to add to uses

For in-memory collections, add only:

```delphi
uses
  LQColligo;
```

For database queries (`ILQColligoQueryable<T>`), also add:

```delphi
uses
  LQColligo,
  LQColligo.Queryable;
```

## Supply-chain transparency

A machine-readable **SBOM** (CycloneDX) is published on the package portal — [pubpascal.dev/packages/lq-colligo](https://www.pubpascal.dev/packages/lq-colligo). The security disclosure policy is in [SECURITY.md](https://github.com/ModernDelphiWorks/LQ-Colligo/blob/main/SECURITY.md).
