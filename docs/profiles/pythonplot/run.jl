ENV["MPLBACKEND"] = "Agg"

using EHTColorSchemes
using PythonPlot

stage = only(ARGS)
mkpath(stage)
scheme = colorscheme(:Blues_lusr)
n = 100
x = range(-3, 3; length = n)
y = range(-3, 3; length = n)
xgrid = repeat(x', n, 1)
ygrid = repeat(y, 1, n)
z = [2 * sin(x[i]) * 2 * cos(y[j]) for i in 1:n, j in 1:n]

fig = figure("pythonplot_surfaceplot", figsize = (7, 5))
axis = fig.add_subplot(1, 1, 1; projection = "3d")
axis.plot_surface(xgrid, ygrid, z;
    rstride = 2, cstride = 2, edgecolors = "k", cmap = ColorMap(scheme.colors),
    alpha = 0.8, linewidth = 0.25)
fig.savefig(joinpath(stage, "pythonplot.png"), bbox_inches = "tight", pad_inches = 0)
plotclose(fig)
