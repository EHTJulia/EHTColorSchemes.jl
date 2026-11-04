# EHTColorSchemes.jl

EHTColorSchemes provides 182 table-backed color maps used by
[`ehtplot`](https://github.com/liamedeiros/ehtplot) for EHT and VLBI image
visualization. Each map is exposed as a standard
[`ColorSchemes.jl`](https://juliagraphics.github.io/ColorSchemes.jl/) object,
so applications can use the exact decoded table colors without adding a
plotting backend to this package.

The tables are verbatim copies of the upstream `ehtplot` `.ctab` files. For
the map families, transforms, and visual examples, see the upstream
[`ehtplot` colormap notebook](https://github.com/liamedeiros/ehtplot/blob/docs/docs/COLORMAPS.ipynb).

Every table also has an in-memory reverse variant whose name appends `r`, such
as `seismic_ur` for the reverse of `seismic_u`. Reverse variants are generated
from the loaded values; no additional `.ctab` files are stored.

The tutorials show backend use and an EHTJulia image workflow. The API page
documents the two public entry points: `scheme_names` and `colorscheme`.
