# EHTColorSchemes.jl

EHTColorSchemes provides the 182 table-backed `ehtplot` color maps as standard
[`ColorSchemes.jl`](https://github.com/JuliaGraphics/ColorSchemes.jl)
`ColorScheme` objects.

```julia
using EHTColorSchemes
using ColorSchemes

scheme_names()
scheme = colorscheme(:afmhot_us)
scheme isa ColorScheme
scheme.colors
```

The exact table stems are returned by `scheme_names()` and are also registered
in `ColorSchemes.colorschemes`. `colorscheme` accepts either a `Symbol` or a
`String`. Each table contains 256 rows; channels are decoded as
`clamp(channel / 1023, 0, 1)` without interpolation or smoothing.

Install with:

```julia
using Pkg
Pkg.add("EHTColorSchemes")
```

The package core depends only on ColorSchemes.jl and Colors.jl. Plotting
libraries remain application-level dependencies. See the
[user tutorial](docs/tutorial.md) and [plotting guide](docs/plotting.md).

## License and source tables

EHTColorSchemes is distributed under the GNU General Public License, version
3.0. The full license text is in [LICENSE](LICENSE).

The 182 files in [`data/`](data/) are verbatim redistributions of the
`ehtplot/color/ctabs/` tables from
[liamedeiros/ehtplot](https://github.com/liamedeiros/ehtplot) (see, also, [Chan & Medeiros 2021, ascl:2106.038](https://ascl.net/2106.038)). Credit for
ehtplot and its color tables: **Chi-kwan Chan** and **Lia Medeiros**.
Their source and licensing notice is recorded in [`data/README.md`](data/README.md), and a
copy of the upstream GPLv3 text is included as
[`data/LICENSE-ehtplot-GPL-3.0.txt`](data/LICENSE-ehtplot-GPL-3.0.txt).
