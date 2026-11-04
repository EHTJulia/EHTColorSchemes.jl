using EHTColorSchemes
using Plots

stage = only(ARGS)
mkpath(stage)
x = 1:0.3:20
scheme = colorscheme(:hot_u)
figure = contour(
    x, x, (x, y) -> sin(x) + cos(y);
    fill = true, c = cgrad(scheme.colors), title = "hot_u"
)
savefig(figure, joinpath(stage, "plots-contour.png"))
