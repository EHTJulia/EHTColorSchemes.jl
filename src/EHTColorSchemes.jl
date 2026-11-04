module EHTColorSchemes

using ColorSchemes
using Colors: RGB

export colorscheme, scheme_names

const _CTAB_DIR = joinpath(dirname(@__DIR__), "data")
# Keep the shipped file inventory deterministic so public names and registration
# order do not depend on filesystem enumeration.
const _CTAB_FILES = let
    files = filter(name -> endswith(name, ".ctab"), readdir(_CTAB_DIR))
    Tuple(Symbol(first(splitext(name))) => name for name in sort(files))
end
const _CTAB_NAMES = Tuple(first(pair) for pair in _CTAB_FILES)
# ehtplot's `r` convention reverses an existing table; generate it in memory so
# the package never duplicates or alters the upstream `.ctab` assets.
const _REVERSED_NAMES = Tuple(Symbol(string(name) * "r") for name in _CTAB_NAMES)
const _SCHEME_NAMES = (_CTAB_NAMES..., _REVERSED_NAMES...)
isempty(intersect(_CTAB_NAMES, _REVERSED_NAMES)) ||
    error("generated reverse color-scheme names collide with table names")

"""Return table-backed `ehtplot` names and generated exact reverse variants.

The first 182 names correspond to bundled `.ctab` files. Appending `r` to one
of those names selects its generated reverse color order without adding a file.
"""
scheme_names() = _SCHEME_NAMES

"""Load one 256-row integer RGB table as `Colors.RGB{Float64}` values."""
function _load_ctab(path::AbstractString)
    isfile(path) || throw(ArgumentError("color table file does not exist: $path"))
    lines = readlines(path)
    length(lines) == 256 || throw(ArgumentError("color table must contain exactly 256 rows"))
    result = Vector{RGB{Float64}}(undef, length(lines))
    for (index, line) in enumerate(lines)
        fields = split(strip(line))
        length(fields) == 3 || throw(ArgumentError("color table row $index must contain exactly 3 channels"))
        channels = try
            parse.(Int, fields)
        catch
            throw(ArgumentError("color table row $index must contain integer channels"))
        end
        # `.ctab` channels are 10-bit integers; preserve the upstream decoding
        # rule while guarding malformed out-of-range input.
        result[index] = RGB(clamp(channels[1] / 1023, 0, 1),
            clamp(channels[2] / 1023, 0, 1), clamp(channels[3] / 1023, 0, 1))
    end
    return result
end

function _table(name::Symbol)
    index = findfirst(pair -> first(pair) === name, _CTAB_FILES)
    index === nothing && throw(ArgumentError("unknown color scheme: $(repr(name))"))
    return _load_ctab(joinpath(_CTAB_DIR, last(_CTAB_FILES[index])))
end

"""Return the standard `ColorSchemes.ColorScheme` for a table or reverse name."""
function colorscheme(name::Symbol)
    name in _SCHEME_NAMES || throw(ArgumentError("unknown color scheme: $(repr(name))"))
    return ColorSchemes.colorschemes[name]
end

colorscheme(name::AbstractString) = colorscheme(Symbol(name))

function _register_colors(name::Symbol, colors, notes::AbstractString)
    if haskey(ColorSchemes.colorschemes, name)
        existing = ColorSchemes.colorschemes[name]
        # Reinitialization is safe only when another registration has identical
        # values; never silently replace an existing ColorSchemes entry.
        existing.colors == colors ||
            throw(ArgumentError("ColorSchemes entry $name has different colors"))
    else
        ColorSchemes.loadcolorscheme(name, colors, "EHT/ehtplot", notes)
    end
    return nothing
end

function _register_tables()
    for name in _CTAB_NAMES
        colors = _table(name)
        _register_colors(name, colors,
            "Source table $(name).ctab; integer channels divided by 1023 and clipped to [0, 1].")
        reverse_name = Symbol(string(name) * "r")
        _register_colors(reverse_name, reverse(colors),
            "Reverse of source table $(name).ctab; integer channels divided by 1023 and clipped to [0, 1].")
    end
    return nothing
end

function __init__()
    _register_tables()
end

end
