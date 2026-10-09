# Activate a local environment if it exists.
#   Reference: https://discourse.julialang.org/t/what-is-in-your-startup-jl/18228/20
if isfile("Project.toml") && isfile("Manifest.toml")
    import Pkg
    Pkg.activate(".")
end

if isinteractive()
    # Load default packages.
    using About
    using Infiltrator
    using OhMyREPL
    OhMyREPL.colorscheme!("OneDark")
    using Revise
    using ShareAdd
    using TerminalPager
    using UseAll

    # Make a temporary environment available to install packages into during a working REPL session.
    #   Reference: https://discourse.julialang.org/t/tip-macro-to-install-use-package-in-temporary-environment
    insert!(LOAD_PATH, 2, mktempdir())

    # Automatically load the packages necessary to execute common commands when needed.
    #   Reference: https://discourse.julialang.org/t/ann-shareadd-jl-making-easy-to-import-packages-from-multiple-environments/121261/3
    using BasicAutoloads: register_autoloads
    register_autoloads([
        ["data, mapping, visual, draw"]     => :(isdefined(Main, :data) || @usingany AlgebraOfGraphics),
        ["Aqua"]                            => :(@usingany Aqua),
        ["@chain"]                          => :(@usingany Chain),
        ["@b", "@be"]                       => :(@usingany Chairmarks),
        ["CSV"]                             => :(@usingany CSV),
        ["ascend", "descend", "@descend"]   => :(@usingany Cthulhu),
        ["DataFrame"]    		            => :(isdefined(Main, :DataFrame) || @usingany DataFramesMeta),
        ["Dates", "Date", "DateTime"]       => :(@usingany Dates),
        ["print_explicit_imports"]          => :(@usingany ExplicitImports),
        ["eye"]                             => :(@usingany Eyeball),
        ["Faker"]                           => :(@usingany Faker),
        ["load", "save"]                    => :(@usingany FileIO, JLD2),
        ["browse"]                          => :(@usingany FloatingTableView),
        ["format"]                          => :(@usingany Format),
        ["Figure", "lines", "scatter"]      => :(isdefined(Main, :Figure) || @usingany GLMakie),
        ["latexify", "@L_str"]              => :(@usingany Latexify, LaTeXStrings),
        ["create_registry", "register"]     => :(@usingany LocalRegistry),
        ["mwe", "@mwe"]                     => :(@usingany MinimalWorkingExamples),
        ["OrderedDict", "LittleDict"]       => :(@usingany OrderedCollections),
        ["gogui"]                           => :(@usingany PackageMaker),
        ["plot"]                            => :(isdefined(Main, :plot) || @usingany Plots),
        ["Pluto"]                           => :(@usingany Pluto),
        ["PrecompileAfterUpdate"]           => :(@usingany PrecompileAfterUpdate),
        ["mean", "std", "median"]           => :(@usingany Statistics),
        [
            "@u_str", "@ud_str", "inch", "mm", "lb", "kg", "lbf", "°F", "°C", "psi", "ksi", "kPa",
            "MPa", "bar", "atm", "STEEL_DENSITY", "cylinder_volume", "shell_volume", "percent_error",
        ]                                   => :(isdefined(Main, Symbol("@u_str")) || @usingany VesselUnits),
        ["@variables", "@parameters"]       => :(@usingany Symbolics, Nemo),
        ["@test", "@testset"]               => :(@usingany Test),
        ["TestEnv"]                         => :(@usingany TestEnv),
        ["XLSX"]                            => :(@usingany XLSX),
    ])
end
