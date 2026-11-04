using Test
using ColorSchemes
using Colors
using EHTColorSchemes

@testset "EHTColorSchemes" begin
    # The public inventory contains each immutable source table plus its
    # generated, in-memory reverse variant.
    names = scheme_names()
    @test names isa Tuple
    base_names = EHTColorSchemes._CTAB_NAMES
    reverse_names = EHTColorSchemes._REVERSED_NAMES
    @test length(base_names) == 182
    @test length(names) == 364
    @test length(unique(names)) == 364
    @test names == (base_names..., reverse_names...)
    @test all(name -> name in keys(ColorSchemes.colorschemes), names)

    # Source tables retain exact 10-bit decoding and ColorSchemes semantics.
    for name in base_names
        scheme = colorscheme(name)
        @test scheme isa ColorSchemes.ColorScheme
        @test length(scheme.colors) == 256
        @test all(
            color -> all(
                component -> isfinite(component) && 0 <= component <= 1,
                (red(color), green(color), blue(color))
            ), scheme.colors
        )
        @test scheme.colors == EHTColorSchemes._load_ctab(
            joinpath(
                EHTColorSchemes._CTAB_DIR, String(name) * ".ctab"
            )
        )
        @test ColorSchemes.get(scheme, 0.0) == first(scheme.colors)
        @test ColorSchemes.get(scheme, 1.0) == last(scheme.colors)
        @test ColorSchemes.resample(scheme, 256).colors == scheme.colors
    end

    # Every `r` name is an exact reversal, not an interpolated approximation.
    for (name, reverse_name) in zip(base_names, reverse_names)
        scheme = colorscheme(name)
        reversed = colorscheme(reverse_name)
        @test reversed isa ColorSchemes.ColorScheme
        @test reversed.colors == reverse(scheme.colors)
        @test length(reversed.colors) == 256
        @test all(
            color -> all(
                component -> isfinite(component) && 0 <= component <= 1,
                (red(color), green(color), blue(color))
            ), reversed.colors
        )
        @test ColorSchemes.get(reversed, 0.0) == first(reversed.colors)
        @test ColorSchemes.get(reversed, 1.0) == last(reversed.colors)
    end

    # Lookup accepts both public name forms, and registration rejects conflicts
    # while allowing repeated initialization with identical values.
    @test colorscheme(:afmhot_us) === colorscheme("afmhot_us")
    @test colorscheme(:seismic_ur) === colorscheme("seismic_ur")
    @test colorscheme(:afmhot_us).category == "EHT/ehtplot"
    @test occursin("afmhot_us.ctab", colorscheme(:afmhot_us).notes)
    @test occursin("Reverse", colorscheme(:afmhot_usr).notes)
    @test_nowarn EHTColorSchemes._register_tables()
    @test_throws ArgumentError EHTColorSchemes._register_colors(
        :afmhot_us,
        reverse(colorscheme(:afmhot_us).colors), "conflicting test colors"
    )
    @test_throws ArgumentError colorscheme(:missing)
    @test_throws ArgumentError colorscheme("missing")

    # Malformed source data must fail before it can be registered.
    malformed = joinpath(mktempdir(), "bad.ctab")
    open(malformed, "w") do io
        for _ in 1:255
            println(io, "0 0 0")
        end
    end
    @test_throws ArgumentError EHTColorSchemes._load_ctab(malformed)

    invalid = joinpath(mktempdir(), "invalid.ctab")
    open(invalid, "w") do io
        for index in 1:256
            println(io, index == 1 ? "not-an-integer 0 0" : "0 0 0")
        end
    end
    @test_throws ArgumentError EHTColorSchemes._load_ctab(invalid)
end
