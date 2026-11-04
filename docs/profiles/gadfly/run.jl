using Cairo
using ColorSchemes
using EHTColorSchemes
using Fontconfig
using Gadfly

stage = only(ARGS)
mkpath(stage)
scheme = colorscheme(:gnuplot2_u)
scheme isa ColorSchemes.ColorScheme || error("expected a ColorScheme")
x = repeat(collect(1:20), inner = [20])
y = repeat(collect(1:20), outer = [20])
figure = plot(
    x = x, y = y, color = x + y, Geom.rectbin,
    Scale.ContinuousColorScale(p -> ColorSchemes.get(scheme, p))
)
draw(PNG(joinpath(stage, "gadfly.png"), 800px, 600px), figure)
