# Compatibility Layer

This directory isolates compatibility adapters for different major/minor versions of downstream dependencies (primarily the `dio` HTTP client).

## Structure
- `lib/src/compatibility/README.md` (this file)
- Future version adapters will reside in subfolders (e.g. `dio_v6/`) when breaking changes are introduced by the upstream client.

## Philosophy
- **Isolate version differences:** Core features (`mock`, `record`, `network`, etc.) must not concern themselves with differences in Interceptor parameters, Exception signatures, or Adapter mappings across major package upgrades.
- **Zero dead-code:** Do not write adapters until a breaking change is actually introduced by the upstream package. Keep the codebase lean and compile-time fast.
