# API

```@docs
EHTColorSchemes.scheme_names
EHTColorSchemes.colorscheme
```

`scheme_names()` returns the 182 exact `ehtplot` table stems and 182 generated
reverse names as symbols. A reverse name appends `r` to the base name, such as
`Blues_lusr`; its colors are the base table in exact reverse order.
`colorscheme(name)` accepts a symbol or string and returns the corresponding
standard `ColorSchemes.ColorScheme` object.

The decoded table has 256 `Colors.RGB{Float64}` entries. Use the public
ColorSchemes.jl API for normalized lookup, resampling, and backend-specific
color handling.

## Available names

`scheme_names()` is the complete public inventory. Print or filter it to see
every name available in the running package:

```julia
names = scheme_names()
foreach(println, names)
filter(name -> startswith(String(name), "afmhot"), names)
colorscheme(:afmhot_us).colors
```

The following list is generated from `scheme_names()` during this documentation
build.

```@eval
using Markdown
using EHTColorSchemes
Markdown.parse("```text\n" * join(string.(EHTColorSchemes.scheme_names()), "\n") * "\n```")
```

## ehtplot suffixes

The bundled names preserve the transformations encoded in the local ehtplot
tables. The [ehtplot colormap notebook](https://github.com/liamedeiros/ehtplot/blob/docs/docs/COLORMAPS.ipynb),
[generation code](https://github.com/liamedeiros/ehtplot/blob/master/ehtplot/color/modify.py),
and [registration code](https://github.com/liamedeiros/ehtplot/blob/master/ehtplot/color/core.py)
are the primary sources for these meanings.

- `_u` marks an ehtplot table uniformized in CAM02-UCS lightness J′.
- `l`, or a number such as `30`, before `u` marks the configured lower-J′
  lifting adjustment. Only the names that appear in `scheme_names()` exist.
- `s` marks ehtplot's subsequent chroma symmetrization.
- `r` reverses the final table order. This package creates the exact reversal
  in memory for every bundled table and does not duplicate a `.ctab` file.

These are historical table suffixes, not a general transformation language.
The package does not infer missing suffix combinations.
