using EHTColorSchemes
using Plots

stage = only(ARGS)
mkpath(stage)
scheme = colorscheme(:cubehelix_u)
palette = get.(Ref(scheme), range(0.05, 0.85; length = 20))
figure = plot(
    Plots.fakedata(100, 20); w = 4,
    background_color = :white, palette,
    title = "cubehelix_u"
)
savefig(figure, joinpath(stage, "plots-palette.png"))
