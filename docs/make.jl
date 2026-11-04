using Documenter
using EHTColorSchemes

const DOCS_DIR = @__DIR__
const REPO_DIR = normpath(joinpath(DOCS_DIR, ".."))
const PROFILE_DIR = joinpath(DOCS_DIR, "profiles")
const SOURCE_DIR = joinpath(DOCS_DIR, ".documenter-src")
const STAGE_DIR = joinpath(DOCS_DIR, ".docs-stage")
const ASSET_DIR = joinpath(DOCS_DIR, "assets")
const PLOTTING_ASSET_DIR = joinpath(DOCS_DIR, "plotting", "assets")
const TUTORIAL_ASSET_DIR = joinpath(DOCS_DIR, "tutorial", "assets")
const BUILD_DIR = joinpath(REPO_DIR, ".docs-build")
const PYTHONPLOT_CONDA_DIR = get(
    ENV, "EHT_DOCS_PYTHONPLOT_CONDA",
    "@ehtcolorschemes-pythonplot"
)
const CORE_PROFILES = ("unicode", "makie")
const ALL_PROFILES = ("unicode", "makie", "plots", "gadfly", "winston", "pyplot", "pythonplot")

function selected_profiles(argument)
    argument == "core" && return CORE_PROFILES
    argument == "all" && return ALL_PROFILES
    startswith(argument, "backend=") || error("use core, all, or backend=<name>")
    name = split(argument, "=", limit = 2)[2]
    name in ALL_PROFILES || error("unknown backend: $name")
    return (name,)
end

function julia(profile, expression)
    project = joinpath(PROFILE_DIR, profile)
    return `$(Base.julia_cmd()) --startup-file=no --project=$project -e $expression`
end

function profile_environment(profile)
    variables = Pair{String, String}["EHT_DOCS_REPO" => REPO_DIR]
    for name in ("JULIA_DEPOT_PATH", "JULIA_PKG_OFFLINE")
        haskey(ENV, name) && push!(variables, name => ENV[name])
    end
    profile == "pythonplot" &&
        push!(variables, "JULIA_CONDAPKG_ENV" => PYTHONPLOT_CONDA_DIR)
    return variables
end

function prepare_profile(profile)
    manifest = joinpath(PROFILE_DIR, profile, "Manifest.toml")
    isfile(manifest) && return
    expression = "using Pkg; Pkg.develop(path=ENV[\"EHT_DOCS_REPO\"]); Pkg.instantiate()"
    return run(addenv(julia(profile, expression), profile_environment(profile)...))
end

function run_profile(profile)
    script = joinpath(PROFILE_DIR, profile, "run.jl")
    command = `$(Base.julia_cmd()) --startup-file=no --project=$(dirname(script)) $script $STAGE_DIR`
    return run(addenv(command, profile_environment(profile)...))
end

function required_outputs(profile)
    profile == "unicode" && return ("unicodeplots.txt", "unicodeplots.svg")
    profile == "makie" && return (
        "blackhole-imageviz.png", "afmhot-multipanel.png",
        "afmhot-gradient.png", "family-comparison.png", "eht-palettes.png",
        "makie-seismic-ur.png",
    )
    profile == "winston" && return ("winston.png", "winston-smooth.png")
    profile == "pyplot" && return ("pyplot.png",)
    profile == "pythonplot" && return ("pythonplot.png",)
    profile == "plots" && return ("plots-contour.png", "plots-palette.png")
    return ("$profile.png",)
end

function validate_profile(profile)
    for name in required_outputs(profile)
        path = joinpath(STAGE_DIR, name)
        isfile(path) && filesize(path) > 0 || error("$profile did not create $name")
    end
    return
end

function profile_result(profile)
    marker = joinpath(STAGE_DIR, "$profile-unavailable.txt")
    return isfile(marker) ? "unavailable — " * strip(read(marker, String)) : "passed"
end

function write_status(statuses)
    lines = ["# Plotting profile status", ""]
    for (profile, result) in statuses
        push!(lines, "- `$profile`: $result")
    end
    write(joinpath(STAGE_DIR, "profile-status.md"), join(lines, "\n") * "\n")
    return ENV["EHT_DOCS_PROFILE_STATUS"] = join(lines[3:end], "\n")
end

function prepare_assets(profiles)
    isdir(STAGE_DIR) && rm(STAGE_DIR; recursive = true)
    isdir(ASSET_DIR) && rm(ASSET_DIR; recursive = true)
    isdir(PLOTTING_ASSET_DIR) && rm(PLOTTING_ASSET_DIR; recursive = true)
    isdir(TUTORIAL_ASSET_DIR) && rm(TUTORIAL_ASSET_DIR; recursive = true)
    mkpath(STAGE_DIR)
    mkpath(ASSET_DIR)
    mkpath(PLOTTING_ASSET_DIR)
    mkpath(TUTORIAL_ASSET_DIR)
    statuses = Dict{String, String}()
    for profile in profiles
        try
            prepare_profile(profile)
            run_profile(profile)
            validate_profile(profile)
            statuses[profile] = profile_result(profile)
        catch error
            statuses[profile] = "failed — " * sprint(showerror, error)
        end
    end
    write_status(statuses)
    for name in readdir(STAGE_DIR)
        cp(joinpath(STAGE_DIR, name), joinpath(ASSET_DIR, name); force = true)
    end
    for name in (
            "unicodeplots.svg", "plots-contour.png", "plots-palette.png", "gadfly.png",
            "makie-seismic-ur.png", "eht-palettes.png", "winston.png", "winston-smooth.png",
            "pyplot.png", "pythonplot.png",
        )
        source = joinpath(STAGE_DIR, name)
        isfile(source) && cp(source, joinpath(PLOTTING_ASSET_DIR, name); force = true)
    end
    for name in ("blackhole-imageviz.png", "family-comparison.png", "afmhot-multipanel.png")
        source = joinpath(STAGE_DIR, name)
        isfile(source) && cp(source, joinpath(TUTORIAL_ASSET_DIR, name); force = true)
    end
    return statuses
end

function publish_staged_assets()
    build_assets = joinpath(BUILD_DIR, "assets")
    mkpath(build_assets)
    for name in readdir(STAGE_DIR)
        source = joinpath(STAGE_DIR, name)
        isfile(source) && cp(source, joinpath(build_assets, name); force = true)
    end
    return
end

function prepare_documenter_source()
    isdir(SOURCE_DIR) && rm(SOURCE_DIR; recursive = true)
    mkpath(SOURCE_DIR)
    for page in ("index.md", "plotting.md", "tutorial.md", "api.md")
        cp(joinpath(DOCS_DIR, page), joinpath(SOURCE_DIR, page); force = true)
    end
    for section in ("plotting", "tutorial")
        source = joinpath(DOCS_DIR, section, "assets")
        isdir(source) || continue
        destination = joinpath(SOURCE_DIR, section, "assets")
        mkpath(dirname(destination))
        cp(source, destination; force = true)
    end
    return
end

profile = isempty(ARGS) ? "core" : only(ARGS)
try
    statuses = prepare_assets(selected_profiles(profile))
    prepare_documenter_source()
    makedocs(;
        sitename = "EHTColorSchemes.jl", source = SOURCE_DIR, build = BUILD_DIR,
        clean = true, remotes = nothing, checkdocs = :none,
        pages = [
            "Home" => "index.md",
            "Tutorials" => [
                "Plotting with EHTColorSchemes" => "plotting.md",
                "Using with EHTJulia" => "tutorial.md",
            ],
            "API" => "api.md",
        ]
    )
    publish_staged_assets()
    any(result != "passed" for result in values(statuses)) &&
        error("one or more plotting profiles did not pass; see the generated documentation status")
finally
    isdir(SOURCE_DIR) && rm(SOURCE_DIR; recursive = true)
    isdir(ASSET_DIR) && rm(ASSET_DIR; recursive = true)
    isdir(STAGE_DIR) && rm(STAGE_DIR; recursive = true)
    isdir(PLOTTING_ASSET_DIR) && rm(PLOTTING_ASSET_DIR; recursive = true)
    isdir(TUTORIAL_ASSET_DIR) && rm(TUTORIAL_ASSET_DIR; recursive = true)
end
