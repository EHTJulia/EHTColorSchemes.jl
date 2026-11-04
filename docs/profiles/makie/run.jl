using CairoMakie
using Downloads
using EHTColorSchemes
using VLBISkyModels

stage = only(ARGS)
mkpath(stage)
cache = get(ENV, "EHT_DOCS_CACHE", joinpath(tempdir(), "ehtcolorschemes-docs"))
fits_path = get(ENV, "EHT_DOCS_FITS", joinpath(cache, "jason_mad_eofn.fits"))
if !isfile(fits_path)
    mkpath(dirname(fits_path))
    Downloads.download(
        "https://raw.githubusercontent.com/EHTJulia/ScatteringOptics.jl/main/docs/src/data/jason_mad_eofn.fits",
        fits_path,
    )
end
filesize(fits_path) > 0 || error("FITS input is empty: $fits_path")
image = load_fits(fits_path, IntensityMap)
scheme = colorscheme(:afmhot_us)

figure = imageviz(image; size = (600, 500), colormap = scheme.colors)
save(joinpath(stage, "blackhole-imageviz.png"), figure)

values = extrema(parent(image))
names = (
    :afmhot_u, :afmhot_10u, :afmhot_30u, :afmhot_50u,
    :afmhot_us, :afmhot_10us, :afmhot_30us, :afmhot_50us,
)
all(name in scheme_names() for name in names) || error("missing afmhot table")
figure = Figure(; size = (1100, 1500))
axes = [Axis(figure[i, j], xreversed = true, aspect = 1) for i in 1:4, j in 1:2]
for (axis, name) in zip(vec(axes), names)
    image!(axis, image; colormap = colorscheme(name).colors, colorrange = values)
    axis.title = String(name)
end
hidedecorations!.(axes)
save(joinpath(stage, "afmhot-multipanel.png"), figure)

gradient = reshape(scheme.colors, :, 1)
figure = Figure(; size = (900, 180))
axis = Axis(figure[1, 1], title = "afmhot_us — exact table colors")
image!(axis, gradient)
hidedecorations!(axis)
save(joinpath(stage, "afmhot-gradient.png"), figure)

seismic = colorscheme(:seismic_ur)
coordinates = LinRange(-1, 1, 100)
values_2d = coordinates .* coordinates'
figure = Figure(; size = (900, 650))
axis = Axis(figure[1, 1], title = "seismic_ur")
image!(axis, values_2d; colormap = seismic.colors)
save(joinpath(stage, "makie-seismic-ur.png"), figure)

family_names = (:afmhot_u, :gnuplot2_u, :cubehelix_u, :hot_u, :gist_heat_u, :copper_u)
figure = Figure(; size = (1500, 900))
axes = [Axis(figure[i, j], xreversed = true, aspect = 1) for i in 1:2, j in 1:3]
for (axis, name) in zip(vec(axes), family_names)
    image!(axis, image; colormap = colorscheme(name).colors, colorrange = values)
    axis.title = String(name)
end
hidedecorations!.(axes)
save(joinpath(stage, "family-comparison.png"), figure)

catalog_names = filter(name -> !occursin(r"_\d", String(name)), scheme_names())
rows = cld(length(catalog_names), 2)
figure = Figure(; size = (1500, 40 * rows + 100))
for (index, name) in enumerate(catalog_names)
    row = mod1(index, rows)
    column = cld(index, rows)
    catalog_axis = Axis(figure[row, column], title = String(name))
    image!(catalog_axis, reshape(colorscheme(name).colors, :, 1))
    hidedecorations!(catalog_axis)
end
save(joinpath(stage, "eht-palettes.png"), figure)
