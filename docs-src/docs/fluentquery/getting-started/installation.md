---
title: Installation
sidebar_position: 1
---

# Installation

## Via Boss (recommended)

[Boss](https://github.com/HashLoad/boss) is the standard package manager for Delphi. Install FluentQuery with:

```sh
boss install ModernDelphiWorks/FluentQuery
```

:::note
For historical registry reasons, the Boss manifest declares the package as **FluentQuery**. The command above uses the GitHub repository path directly, which is the canonical install method.
:::

## Via PubPascal

FluentQuery is listed on the [PubPascal package portal](https://www.pubpascal.dev/packages/fluentquery). Follow the portal's instructions to add it to your project.

## Manual installation

1. Clone or download the repository from [github.com/ModernDelphiWorks/FluentQuery](https://github.com/ModernDelphiWorks/FluentQuery).
2. Add the `Source\` directory to your project's search path in the Delphi IDE (Project → Options → Delphi Compiler → Search path).
3. Add `FluentQuery` to your `uses` clause.

## Search path entries

The minimum required path entry is:

```
<install-root>\Source
```

## Unit to add to uses

For in-memory collections, add only:

```delphi
uses
  FluentQuery;
```

For database queries (`IFluentQueryable<T>`), also add:

```delphi
uses
  FluentQuery,
  FluentQuery.Queryable;
```

## Supply-chain transparency

A machine-readable **SBOM** (CycloneDX) is published on the package portal — [pubpascal.dev/packages/fluentquery](https://www.pubpascal.dev/packages/fluentquery). The security disclosure policy is in [SECURITY.md](https://github.com/ModernDelphiWorks/FluentQuery/blob/main/SECURITY.md).
