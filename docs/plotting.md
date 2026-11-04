# Plotting with EHTColorSchemes

EHTColorSchemes returns standard `ColorSchemes.ColorScheme` values. See the
[ColorSchemes.jl documentation](https://juliagraphics.github.io/ColorSchemes.jl/)
for its general API and the upstream
[`ehtplot` colormap notebook](https://github.com/liamedeiros/ehtplot/blob/docs/docs/COLORMAPS.ipynb)
for map provenance and transformations. Every example below uses exact table
colors from this package in its own plotting environment and process.

## UnicodePlots.jl

```julia
using EHTColorSchemes
using UnicodePlots

scheme = colorscheme(:copper_u)
UnicodePlots.truecolors!()
plot = heatmap([sin(x) * cos(y) for x in 1:20, y in 1:20];
    title = "copper_u",
    colormap = [(color.r, color.g, color.b) for color in scheme.colors])
show(IOContext(stdout, :color => true), MIME("text/plain"), plot)
```

```@eval
using Markdown
isfile(joinpath(pwd(), "plotting", "assets", "unicodeplots.svg")) ? Markdown.parse("![UnicodePlots copper_u terminal rendering](assets/unicodeplots.svg)") : Markdown.parse("_This backend was not run by the selected documentation profile._")
```

## Plots.jl

The ColorSchemes.jl guide demonstrates a filled contour and a multi-series
palette separately. This profile uses the same plot types with `hot_u` and
`cubehelix_u`.

### Filled contour

```julia
using EHTColorSchemes
using Plots

x = 1:0.3:20
scheme = colorscheme(:hot_u)
fig = contour(x, x, (x, y) -> sin(x) + cos(y);
    fill = true, c = cgrad(scheme.colors), title = "hot_u")
savefig(fig, "plots-contour.png")
```

```@eval
using Markdown
isfile(joinpath(pwd(), "plotting", "assets", "plots-contour.png")) ? Markdown.parse("![Plots filled contour using hot_u](assets/plots-contour.png)") : Markdown.parse("_This backend was not run by the selected documentation profile._")
```

### Multi-series palette

```julia
using EHTColorSchemes
using Plots

scheme = colorscheme(:cubehelix_u)
palette = get.(Ref(scheme), range(0.05, 0.85; length = 20))
fig = plot(Plots.fakedata(100, 20); w = 4,
    background_color = :white, palette,
    title = "cubehelix_u")
savefig(fig, "plots-palette.png")
```

```@eval
using Markdown
isfile(joinpath(pwd(), "plotting", "assets", "plots-palette.png")) ? Markdown.parse("![Plots multi-series palette using cubehelix_u](assets/plots-palette.png)") : Markdown.parse("_This backend was not run by the selected documentation profile._")
```

## Gadfly

```julia
using Cairo, ColorSchemes, EHTColorSchemes, Gadfly

scheme = colorscheme(:gnuplot2_u)
x = repeat(collect(1:20), inner = [20])
y = repeat(collect(1:20), outer = [20])
fig = plot(x = x, y = y, color = x + y, Geom.rectbin,
    Scale.ContinuousColorScale(p -> ColorSchemes.get(scheme, p)))
draw(PNG("gadfly.png", 800px, 600px), fig)
```

```@eval
using Markdown
isfile(joinpath(pwd(), "plotting", "assets", "gadfly.png")) ? Markdown.parse("![Gadfly gnuplot2_u](assets/gadfly.png)") : Markdown.parse("_This backend was not run by the selected documentation profile._")
```

## Makie

The ColorSchemes.jl pattern passes a table's `colors` vector directly to the
`colormap` keyword. `seismic_ur` is the generated reverse of the exact
`seismic_u` table.

```julia
using CairoMakie
using EHTColorSchemes

coordinates = LinRange(-1, 1, 100)
scheme = colorscheme(:seismic_ur)
fig = Figure(; size = (900, 650))
axis = Axis(fig[1, 1], title = "seismic_ur")
image!(axis, coordinates .* coordinates'; colormap = scheme.colors)
save("makie-seismic-ur.png", fig)
```

```@eval
using Markdown
isfile(joinpath(pwd(), "plotting", "assets", "makie-seismic-ur.png")) ? Markdown.parse("![Makie matrix image using seismic_ur](assets/makie-seismic-ur.png)") : Markdown.parse("_This backend was not run by the selected documentation profile._")
```

The table catalog is generated from the public inventory. Numbered variants
are omitted only to keep this overview legible.

```julia
catalog_names = filter(name -> !occursin(r"_\d", String(name)), scheme_names())
rows = cld(length(catalog_names), 2)
fig = Figure(; size = (1500, 40 * rows + 100))
for (index, name) in enumerate(catalog_names)
    row, column = mod1(index, rows), cld(index, rows)
    axis = Axis(fig[row, column], title = String(name))
    image!(axis, reshape(colorscheme(name).colors, :, 1))
    hidedecorations!(axis)
end
save("eht-palettes.png", fig)
```

```@eval
using Markdown
isfile(joinpath(pwd(), "plotting", "assets", "eht-palettes.png")) ? Markdown.parse("![Makie EHTColorSchemes catalog](assets/eht-palettes.png)") : Markdown.parse("_This backend was not run by the selected documentation profile._")
```

## Winston

The [ColorSchemes.jl Winston guide](https://juliagraphics.github.io/ColorSchemes.jl/dev/plotting/#Winston)
has direct-table and densely sampled examples. Both use `gnuplot2_u` here.

```julia
using EHTColorSchemes
using Winston

scheme = colorscheme(:gnuplot2_u)
Winston.colormap(scheme.colors)
Winston.imagesc(reshape(1:10000, 100, 100))
Winston.savefig("winston.png")
```

```@raw html
<img src="../assets/winston.png" alt="Winston direct gnuplot2_u table"/>
```

```julia
using ColorSchemes

smooth = [ColorSchemes.get(scheme, value) for value in 0:0.001:1]
Winston.colormap(smooth)
Winston.imagesc(reshape(1:10000, 100, 100))
Winston.savefig("winston-smooth.png")
```

```@raw html
<img src="../assets/winston-smooth.png" alt="Winston densely sampled gnuplot2_u table"/>
```

## PyPlot

This profile follows the [ColorSchemes.jl PyPlot 3D surface example](https://juliagraphics.github.io/ColorSchemes.jl/dev/plotting/#PyPlot)
with `Blues_lusr`, the generated reverse of `Blues_lus`.

```julia
using EHTColorSchemes
using PyPlot

scheme = colorscheme(:Blues_lusr)
n = 100
x = range(-3, 3; length = n); y = range(-3, 3; length = n)
xgrid, ygrid = repeat(x', n, 1), repeat(y, 1, n)
z = [2 * sin(x[i]) * 2 * cos(y[j]) for i in 1:n, j in 1:n]
fig = figure("pyplot_surfaceplot", figsize = (7, 5))
axis = fig.add_subplot(1, 1, 1; projection = "3d")
axis.plot_surface(xgrid, ygrid, z; rstride = 2, cstride = 2,
    edgecolors = "k", cmap = ColorMap(scheme.colors), alpha = 0.8, linewidth = 0.25)
savefig("pyplot.png", bbox_inches = "tight", pad_inches = 0)
close(fig)
```

```@raw html
<img src="../assets/pyplot.png" alt="PyPlot 3D surface using Blues_lusr"/>
```

## PythonPlot

PythonPlot uses PythonCall rather than PyCall. It uses the same 3D surface
data, `plot_surface` arguments, and `ColorMap(Blues_lusr.colors)` as the
PyPlot example. Julia's semicolon keyword syntax is required for PythonCall
method calls. Its isolated CondaPkg environment provides Matplotlib.

```julia
ENV["MPLBACKEND"] = "Agg"
using EHTColorSchemes
using PythonPlot

scheme = colorscheme(:Blues_lusr)
n = 100
x = range(-3, 3; length = n); y = range(-3, 3; length = n)
xgrid, ygrid = repeat(x', n, 1), repeat(y, 1, n)
z = [2 * sin(x[i]) * 2 * cos(y[j]) for i in 1:n, j in 1:n]
fig = figure("pythonplot_surfaceplot", figsize = (7, 5))
axis = fig.add_subplot(1, 1, 1; projection = "3d")
axis.plot_surface(xgrid, ygrid, z; rstride = 2, cstride = 2,
    edgecolors = "k", cmap = ColorMap(scheme.colors), alpha = 0.8, linewidth = 0.25)
fig.savefig("pythonplot.png", bbox_inches = "tight", pad_inches = 0)
plotclose(fig)
```

```@raw html
<img src="../assets/pythonplot.png" alt="PythonPlot 3D surface using Blues_lusr"/>
```
