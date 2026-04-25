using Test
using FPBH
using GLPK
using Clp
using JuMP

@testset "FPBH.jl Julia 1 compatibility" begin
    A = [1.0 1.0 1.0 1.0]
    c1 = [1.0, 1.0, 1.0, 1.0]
    c2 = [2.0, 1.0, 3.0, 1.0]
    cons_lb = [-Inf]
    cons_ub = [3.0]

    inst_bi = if FPBH.has_modof()
        BOBPInstance(c1, c2, A, cons_lb, cons_ub)
    else
        BOBPInstance(A, c1, c2, cons_lb, cons_ub)
    end

    @testset "Biobjective binary path" begin
        sols_glpk = fpbh(
            inst_bi;
            lp_solver = GLPK.Optimizer,
            obj_fph = true,
            local_search = false,
            decomposition = false,
            solution_polishing = false,
            timelimit = 1.0,
        )
        @test sols_glpk isa Vector{BOPSolution}
        @test size(wrap_sols_into_array(sols_glpk), 2) == 2

        sols_clp = fpbh(
            inst_bi;
            lp_solver = Clp.Optimizer,
            obj_fph = true,
            local_search = false,
            decomposition = false,
            solution_polishing = false,
            timelimit = 1.0,
        )
        @test sols_clp isa Vector{BOPSolution}

        sols_parallel = fpbh(
            inst_bi;
            lp_solver = GLPK.Optimizer,
            obj_fph = true,
            local_search = false,
            decomposition = true,
            solution_polishing = false,
            parallelism = true,
            threads = 2,
            timelimit = 1.0,
        )
        @test sols_parallel isa Vector{BOPSolution}
    end

    @testset "Multiobjective binary path" begin
        c = [1.0 1.0 1.0 1.0; 2.0 1.0 3.0 1.0; 1.5 0.5 0.2 4.0]
        inst_multi = if FPBH.has_modof()
            MOBPInstance(c, A, cons_lb, cons_ub)
        else
            MOBPInstance(A, c, cons_lb, cons_ub)
        end
        sols = fpbh(
            inst_multi;
            lp_solver = GLPK.Optimizer,
            obj_fph = true,
            local_search = false,
            decomposition = false,
            solution_polishing = false,
            timelimit = 1.0,
        )
        @test sols isa Vector{MOPSolution}
        arr = wrap_sols_into_array(sols)
        @test size(arr, 2) in (0, size(c, 1))
    end

    @testset "Wrappers without Modof" begin
        if !FPBH.has_modof()
            m = Model()
            @test_throws ArgumentError fpbh(m)
            @test_throws ArgumentError fpbh("dummy.lp", [:Min])
            @test_throws ArgumentError warmup_fpbh()
        end
    end
end
