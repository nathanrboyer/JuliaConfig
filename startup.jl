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
    using Printf  # required for `error` function
    using Revise
    using ShareAdd
    using TerminalPager

    # Make a temporary environment available to install packages into during a working REPL session.
    #   Reference: https://discourse.julialang.org/t/tip-macro-to-install-use-package-in-temporary-environment
    insert!(LOAD_PATH, 2, mktempdir())

    # Custom function definitions
    @doc """
        exportall(mod::Module)

    Export all names from a Module `mod` so they can be tested without explicit `export` statements.
    Reference: https://discourse.julialang.org/t/how-to-use-vscode-and-repl-to-write-and-test-a-package/78818/20
    """
    function exportall(mod)
        for n in names(mod, all = true)
            if Base.isidentifier(n) && n ∉ (Symbol(mod), :eval)
                @eval mod export $n
            end
        end
    end

    @doc """
        cylinder_volume(d, l)
        cylinder_volume(; d, l)

    Compute the volume of a cylinder with diameter `d` and length `l`.
    """
    cylinder_volume(d, l) = pi * d^2 / 4 * l
    cylinder_volume(; d, l) = cylinder_volume(d, l)

    @doc """
        shell_volume(outer_diameter, inner_diameter, length)

    Compute the volume of a cylindrical shell.
    """
    shell_volume(outer_diameter, inner_diameter, length) =
        cylinder_volume(outer_diameter, length) - cylinder_volume(inner_diameter, length)
    shell_volume(; OD, ID, L) = shell_volume(OD, ID, L)

    @doc """
        error(x1, x2, ref=:avg)

    Compute the percent error between values `x1` and `x2` relative to reference value `ref`.
    When `ref` argument is omitted, it defaults to `:avg` as defined below.

    # Arguments
    - `x1`: first value
    - `x2`: second value
    - `ref`: reference value
        - `:first`: compute error relative to `x1`
        - `:second`: compute error relative to `x2`
        - `:min`: compute error relative to the smaller of `x1` and `x2` (largest error)
        - `:max`: compute error relative to the larger of `x1` and `x2` (smallest error)
        - `:avg`: compute error relative to the average of `x1` and `x2` (intermediate error)
    """
    function error(x1, x2, ref)
        if ref in (:first, :x1)
            err = (x2 - x1) / x1
        elseif ref in (:second, :x2)
            err = (x1 - x2) / x2
        elseif ref in (:min, :minimum)
            err = abs(x2 - x1) / min(x1, x2)
        elseif ref in (:max, :maximum)
            err = abs(x2 - x1) / max(x1, x2)
        elseif ref in (:avg, :average)
            avg = (x1 + x2) / 2
            err = abs(x2 - x1) / avg
        else
            throw(ArgumentError("`error` function undefined for `ref` value `$ref`"))
        end
        @eval @printf "%.3g %%\n" 100err
        return err
    end
    error(x1, x2; ref=:avg) = error(x1, x2, ref)

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
        ["@u_str", "Unitful", "inch", "mm",
         "psi", "lb", "lbf", "kg",
         "STEEL_DENSITY"]                   => :(
                                                    isdefined(Main, Symbol("@u_str")) || (
                                                        @usingany StructuralUnits;
                                                        const mm = Unitful.mm;
                                                        const psi = Unitful.psi;
                                                        const lb = Unitful.lb;
                                                        const lbf = Unitful.lbf;
                                                        const kg = Unitful.kg;
                                                        const STEEL_DENSITY = 0.28lb/inch^3;
                                                        Unitful.preferunits(inch);
                                                        Unitful.preferunits(lb);
                                                    )
                                                ),
        ["@variables", "@parameters"]       => :(@usingany Symbolics, Nemo),
        ["@test", "@testset"]               => :(@usingany Test),
        ["TestEnv"]                         => :(@usingany TestEnv),
        ["XLSX"]                            => :(@usingany XLSX),
    ])
end
