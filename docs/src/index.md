# FPBH: A Feasibility Pump based Heuristic for Multi-objective Mixed Integer Linear Programming #

This is a LP based heuristic for computing an approximate nondominated frontier of a Multi-objective Mixed Integer Linear Program. Important characteristics of this heuristic are:

FPBH targets **Julia 1.10+**.

1. Can solve any (both structured and unstructured) multiobjective mixed integer linear problem. The following problem classes are supported:
    1. Objectives: 2 or more linear objectives
    2. Constraints: 0 or more linear (both inequality and equality) constraints
    3. Variables:
        1. Binary
        2. Integer variables (via reformulation into binary variables)
        3. Continuous + Binary
        4. Continuous + Integer variables (via reformulation into binary variables)
2. A multiobjective mixed integer linear instance can be provided as a input in 4 ways:
    1. ModoModel - an extension of JuMP Model
    2. LP file format
    3. MPS file format
    4. Matrix Format ( Advanced )
3. **Any linear programming solver supported by MathOptInterface (MOI) can be used. No mixed integer programming solver is required**. First-phase tested solver support includes:
    1. [GLPK.jl](https://github.com/jump-dev/GLPK.jl)
    2. [Clp.jl](https://github.com/jump-dev/Clp.jl)
4. All parameters are already tuned, only timelimit is required.
5. Supports parallelization

## Contents: ##

```@contents
Pages = ["installation.md", "getting_started.md", "advanced.md", "solving_instances_from_literature.md"]
```

## Supporting and Citing: ##

The software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use [Modof.jl](https://github.com/aritrasep/Modof.jl), [Modolib.jl](https://github.com/aritrasep/Modolib.jl), [FPBH.jl](https://github.com/aritrasep/FPBH.jl), [FPBHCPLEX.jl](https://github.com/aritrasep/FPBHCPLEX.jl) or [pyModofSup.jl](https://github.com/aritrasep/pyModofSup.jl) software as part of your research, teaching, or other activities, we would be grateful if you could cite:

1. [Pal, A. and Charkhgard, H., A Feasibility Pump and Local Search Based Heuristic for Bi-objective Pure Integer Linear Programming](http://www.optimization-online.org/DB_FILE/2017/03/5902.pdf).
2. [Pal, A. and Charkhgard, H., FPBH.jl: A Feasibility Pump based Heuristic for Multi-objective Mixed Integer Linear Programming in Julia](http://www.optimization-online.org/DB_FILE/2017/09/6195.pdf)

## Contributions ##

This package is written and maintained by [Aritra Pal](https://github.com/aritrasep). Please fork and send a pull request or create a [GitHub issue](https://github.com/aritrasep/FPBH.jl/issues) for bug reports or feature requests.
