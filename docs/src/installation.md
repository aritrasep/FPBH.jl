# Installation: #

It is important to note that the whole ecosystem has been tested using [Julia v0.6.0](https://julialang.org/downloads/) and hence we can cannot guarantee whether it will work with previous versions of Julia. Thus, it is important that [Julia v0.6.0](https://julialang.org/downloads/) is properly installed and available on your system.

## If CPLEX is available: ##

[CPLEX](https://www-01.ibm.com/software/commerce/optimization/cplex-optimizer/) must be available in the local machine and [CPLEX.jl](https://github.com/JuliaOpt/CPLEX.jl) must be properly installed, otherwise the installation will fail. Once, `Julia v0.6.0` and `CPLEX.jl` has been properly installed, the following instructions in a **Julia** terminal will install **FPBHCPLEX.jl** and its dependencies (**Modof.jl**, **Modolib.jl**, **FPBH.jl** and **CPLEXExtensions.jl**) on the local machine:

```julia
Pkg.clone("https://github.com/aritrasep/FPBHCPLEX.jl")
Pkg.build("FPBHCPLEX")
```

In case `Pkg.build("FPBHCPLEX")` gives you an error on Linux, you may need to install the GMP library headers. For example, on Ubuntu/Debian and similar, give the following command from a terminal:

```
$ sudo apt-get install libgmp-dev
```

After that, restart the installation of the package with:

```
Pkg.build("FPBHCPLEX")
```

## If CPLEX is not available: ##

If [CPLEX](https://www-01.ibm.com/software/commerce/optimization/cplex-optimizer/) is not available, [FPBH.jl](https://github.com/aritrasep/FPBH.jl) can be installed instead of [FPBHCPLEX.jl](https://github.com/aritrasep/FPBHCPLEX.jl""https://github.com/aritrasep/FPBH.jl). Once, `Julia v0.6.0` has been properly installed, the following instructions in a **Julia** terminal will install **FPBH.jl** and its dependencies (**Modof.jl**, and **Modolib.jl**) on the local machine:

```julia
Pkg.clone("https://github.com/aritrasep/FPBH.jl")
Pkg.build("FPBH")
```

In case `Pkg.build("FPBH")` gives you an error on Linux, you may need to install the GMP library headers. For example, on Ubuntu/Debian and similar, give the following command from a terminal:

```
$ sudo apt-get install libgmp-dev
```

After that, restart the installation of the package with:

```
Pkg.build("FPBH")
```

None of the above will however install [pyModofSup.jl](https://github.com/aritrasep/pyModofSup.jl), which must be installed separately if desired.
