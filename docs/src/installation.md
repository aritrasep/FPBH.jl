# Installation

FPBH targets **Julia 1.10+** and uses standard `Project.toml` environments.

## Base installation

```julia
import Pkg
Pkg.add(url="https://github.com/aritrasep/FPBH.jl")
Pkg.instantiate()
```

## Solver setup

FPBH's first-class tested LP solvers are:

1. `GLPK.Optimizer`
2. `Clp.Optimizer`

Install either (or both) as needed:

```julia
import Pkg
Pkg.add("GLPK")
Pkg.add("Clp")
```

## Optional model and file parser bridge

`Modof.jl`, `Modolib.jl`, and `FPBHCPLEX.jl` are optional companion repositories. Install them explicitly only if your workflow uses the ModoModel/file parser bridge.
