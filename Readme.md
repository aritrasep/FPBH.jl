# FPBH: A Feasibility Pump based Heuristic for Multi-objective Mixed Integer Linear Programming #

**Build Status:** 
[![Build Status](https://travis-ci.org/aritrasep/FPBH.jl.svg?branch=master)](https://travis-ci.org/aritrasep/FPBH.jl)

**Documentation:**
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://aritrasep.github.io/FPBH.jl/docs/build/)

**DOI:** 
[![DOI](https://zenodo.org/badge/84245385.svg)](https://zenodo.org/badge/latestdoi/84245385)

This is a LP based heuristic for computing an approximate nondominated frontier of a Multi-objective Mixed Integer Linear Program. Important characteristics of this heuristic are:

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
3. **Any linear programming solver supported by MathProgBase.jl can be used. No mixed integer programming solver is required**. [FPBH.jl](https://github.com/aritrasep/FPBH.jl) automatically installs [GLPK](https://github.com/JuliaOpt/GLPKMathProgInterface.jl) and [Clp](https://github.com/JuliaOpt/Clp.jl) by default. If the user desires to use any other LP solver, it must be separately installed. [FPBH.jl](https://github.com/aritrasep/FPBH.jl) has been successfully tested with:
    1. [GLPK - v4.61](https://github.com/JuliaOpt/GLPKMathProgInterface.jl)
    2. [Clp - v1.16](https://github.com/JuliaOpt/Clp.jl)
    3. [SCIP - v4.0.0](https://github.com/SCIP-Interfaces/SCIP.jl)
    4. [Gurobi - v7.5](https://github.com/JuliaOpt/Gurobi.jl)
    5. [CPLEX - v12.7](https://github.com/JuliaOpt/CPLEX.jl). If [CPLEX](https://github.com/JuliaOpt/CPLEX.jl) is available, we highly recommend using [FPBHCPLEX.jl](https://github.com/aritrasep/FPBHCPLEX.jl) instead.
4. All parameters are already tuned, only timelimit is required.
5. Supports parallelization

## Supporting and Citing: ##

The software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use [Modof.jl](https://github.com/aritrasep/Modof.jl), [Modolib.jl](https://github.com/aritrasep/Modolib.jl), [FPBH.jl](https://github.com/aritrasep/FPBH.jl), [FPBHCPLEX.jl](https://github.com/aritrasep/FPBHCPLEX.jl) or [pyModofSup.jl](https://github.com/aritrasep/pyModofSup.jl) software as part of your research, teaching, or other activities, we would be grateful if you could cite:

1. [Pal, A. and Charkhgard, H., A Feasibility Pump and Local Search Based Heuristic for Bi-objective Pure Integer Linear Programming](http://www.optimization-online.org/DB_FILE/2017/03/5902.pdf).
2. [Pal, A. and Charkhgard, H., FPBH.jl: A Feasibility Pump based Heuristic for Multi-objective Mixed Integer Linear Programming in Julia](http://www.optimization-online.org/DB_FILE/2017/09/6195.pdf)

## Contributions ##

This package is written and maintained by [Aritra Pal](https://github.com/aritrasep). Please fork and send a pull request or create a [GitHub issue](https://github.com/aritrasep/FPBH.jl/issues) for bug reports or feature requests.
