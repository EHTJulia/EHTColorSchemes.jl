# Contributing

Contributions follow the [ColPrac collaborative practices](https://github.com/SciML/ColPrac).

- Open focused pull requests with tests and documentation for public changes.
- Keep changes compatible with the Julia versions declared in `Project.toml`.
- Format Julia and Julia code blocks with [Runic.jl](https://github.com/fredrikekre/Runic.jl).
- Wait for CI and one approving review before merging.
- Do not modify bundled color tables without preserving their provenance and
  redistribution notices.

Before opening a pull request, run:

```julia
julia --project=. test/runtests.jl
julia --project=@runic -e 'using Runic; Runic.main(["--check", "src", "test", "docs"])'
```
