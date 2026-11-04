using EHTColorSchemes
using Winston
using ColorSchemes

stage = only(ARGS)
mkpath(stage)
scheme = colorscheme(:gnuplot2_u)
Winston.colormap(scheme.colors)
Winston.imagesc(reshape(1:10000, 100, 100))
Winston.savefig(joinpath(stage, "winston.png"))

smooth = [ColorSchemes.get(scheme, value) for value in 0:0.001:1]
Winston.colormap(smooth)
Winston.imagesc(reshape(1:10000, 100, 100))
Winston.savefig(joinpath(stage, "winston-smooth.png"))
