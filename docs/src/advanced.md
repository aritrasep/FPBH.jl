# Advanced Features: #

## Using multiple processors: ##

To use multiple processors for solving an instance, start `julia` with the requisite number of workers. For example: if you want to use at most `4 workers` start `julia` as `julia -p 4`, followed by either of the following three commands in the terminal depending on the input format chosen:

```julia
@time solutions = fpbh(model, lp_solver=ClpSolver(), timelimit=10.0, threads=4)
```

```julia
@time solutions = fpbh("Test.lp", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0, threads=4)
```

```julia
@time solutions = fpbh("Test.mps", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0, threads=4)
```

## Tuning parameters ##

`FPBH` has 5 components:

|Component|Default status|Turn on|Turn off|
|:-------:|:------------:|:-----:|:------:|
|Feasibility Pump|OFF|`obj_fph=false`|`obj_fph=true`|
|Objective Feasibility Pump|ON|`obj_fph=true`|`obj_fph=false`|
|1-OPT Local Search|ON|`local_search=true`|`local_search=false`|
|Stage 1 ( Decomposition )|ON|`decomposition=true`|`decomposition=false`|
|Stage 2 ( Solution Polishing )|ON|`solution_polishing=true`|`solution_polishing=false`|
|Time ratio|$\dfrac{2}{3}$|-|-|

**Note:** Time ratio is the maximum fraction of the total timelimit available to Stage 1. It can take any value between 0 and 1 (both included).

For example: If the user wants to switch off objective feasibility pump and local search, and decrease the time ratio to 0.5, it can be done so as:

```julia
@time solutions = fpbh(model, obj_fph=false, local_search=false, time_ratio=0.5, timelimit=10.0)
```
