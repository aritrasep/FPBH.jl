using DelimitedFiles

const _MODOF_AVAILABLE = let
    try
        @eval import Modof
        true
    catch
        false
    end
end

has_modof() = _MODOF_AVAILABLE

if _MODOF_AVAILABLE
    const BOOInstance = getfield(Modof, :BOOInstance)
    const BOBPInstance = getfield(Modof, :BOBPInstance)
    const BOIPInstance = getfield(Modof, :BOIPInstance)
    const BOLPInstance = getfield(Modof, :BOLPInstance)
    const BOMBLPInstance = getfield(Modof, :BOMBLPInstance)
    const BOMILPInstance = getfield(Modof, :BOMILPInstance)

    const MOOInstance = getfield(Modof, :MOOInstance)
    const MOBPInstance = getfield(Modof, :MOBPInstance)
    const MOIPInstance = getfield(Modof, :MOIPInstance)
    const MOLPInstance = getfield(Modof, :MOLPInstance)
    const MOMBLPInstance = getfield(Modof, :MOMBLPInstance)
    const MOMILPInstance = getfield(Modof, :MOMILPInstance)

    const BOPSolution = getfield(Modof, :BOPSolution)
    const MOPSolution = getfield(Modof, :MOPSolution)
    const ModoModel = getfield(Modof, :ModoModel)

    lprelaxation(args...) = Modof.lprelaxation(args...)
    convert_ip_into_bp(args...) = Modof.convert_ip_into_bp(args...)
    convert_bp_sol_into_ip_sol(args...) = Modof.convert_bp_sol_into_ip_sol(args...)
    read_an_instance_from_a_jump_model(args...) = Modof.read_an_instance_from_a_jump_model(args...)
    read_an_instance_from_a_lp_or_a_mps_file(args...) = Modof.read_an_instance_from_a_lp_or_a_mps_file(args...)

    compute_objective_function_value!(args...) = Modof.compute_objective_function_value!(args...)
    select_unique_sols(args...) = Modof.select_unique_sols(args...)
    select_non_dom_sols(args...) = Modof.select_non_dom_sols(args...)
    sort_non_dom_sols(args...) = Modof.sort_non_dom_sols(args...)
    select_and_sort_non_dom_sols(args...) = Modof.select_and_sort_non_dom_sols(args...)
    check_dominance(args...) = Modof.check_dominance(args...)
    check_feasibility(args...) = Modof.check_feasibility(args...)

    wrap_sols_into_array(args...) = Modof.wrap_sols_into_array(args...)
    write_nondominated_frontier(args...) = Modof.write_nondominated_frontier(args...)
    write_nondominated_sols(args...) = Modof.write_nondominated_sols(args...)

    objective!(args...) = Modof.objective!(args...)
else
    abstract type BOOInstance end
    abstract type MOOInstance end

    mutable struct BOPSolution
        vars::Vector{Float64}
        obj_val1::Float64
        obj_val2::Float64
    end
    BOPSolution(; vars=Float64[], obj_val1=Inf, obj_val2=Inf) =
        BOPSolution(Float64.(vars), Float64(obj_val1), Float64(obj_val2))

    mutable struct MOPSolution
        vars::Vector{Float64}
        obj_vals::Vector{Float64}
    end
    MOPSolution(; vars=Float64[], obj_vals=Float64[]) =
        MOPSolution(Float64.(vars), Float64.(obj_vals))

    mutable struct BOLPInstance <: BOOInstance
        A
        v_lb::Vector{Float64}
        v_ub::Vector{Float64}
        c1::Vector{Float64}
        c2::Vector{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
    end

    mutable struct MOLPInstance <: MOOInstance
        A
        v_lb::Vector{Float64}
        v_ub::Vector{Float64}
        c::Matrix{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
    end

    mutable struct BOBPInstance <: BOOInstance
        A
        c1::Vector{Float64}
        c2::Vector{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
    end

    mutable struct BOMBLPInstance <: BOOInstance
        A
        v_lb::Vector{Float64}
        v_ub::Vector{Float64}
        c1::Vector{Float64}
        c2::Vector{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
        bin_var_ind::Vector{Int64}
    end

    mutable struct MOBPInstance <: MOOInstance
        A
        c::Matrix{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
    end

    mutable struct MOMBLPInstance <: MOOInstance
        A
        v_lb::Vector{Float64}
        v_ub::Vector{Float64}
        c::Matrix{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
        bin_var_ind::Vector{Int64}
    end

    mutable struct BOIPInstance <: BOOInstance
        A
        v_lb::Vector{Float64}
        v_ub::Vector{Float64}
        c1::Vector{Float64}
        c2::Vector{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
    end

    mutable struct BOMILPInstance <: BOOInstance
        A
        v_lb::Vector{Float64}
        v_ub::Vector{Float64}
        c1::Vector{Float64}
        c2::Vector{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
    end

    mutable struct MOIPInstance <: MOOInstance
        A
        v_lb::Vector{Float64}
        v_ub::Vector{Float64}
        c::Matrix{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
    end

    mutable struct MOMILPInstance <: MOOInstance
        A
        v_lb::Vector{Float64}
        v_ub::Vector{Float64}
        c::Matrix{Float64}
        cons_lb::Vector{Float64}
        cons_ub::Vector{Float64}
    end

    const ModoModel = JuMP.Model

    function objective!(args...)
        throw(ArgumentError("objective! requires Modof.jl for multi-objective JuMP modeling. Use instance-based fpbh APIs or install Modof.jl."))
    end

    function compute_objective_function_value!(solution::BOPSolution, instance::Union{BOLPInstance, BOBPInstance, BOMBLPInstance, BOIPInstance, BOMILPInstance})
        solution.obj_val1 = dot(instance.c1, solution.vars)
        solution.obj_val2 = dot(instance.c2, solution.vars)
        return solution
    end

    function compute_objective_function_value!(solution::MOPSolution, instance::Union{MOLPInstance, MOBPInstance, MOMBLPInstance, MOIPInstance, MOMILPInstance})
        solution.obj_vals = vec(instance.c * solution.vars)
        return solution
    end

    function check_dominance(v1::Vector{Float64}, v2::Vector{Float64}; atol::Float64=1.0e-9)
        dom1 = all(v1 .<= (v2 .+ atol)) && any(v1 .< (v2 .- atol))
        dom2 = all(v2 .<= (v1 .+ atol)) && any(v2 .< (v1 .- atol))
        return (dom1, dom2)
    end

    check_dominance(v1::Tuple, v2::Tuple) = check_dominance(collect(v1), collect(v2))

    function select_unique_sols(sols::Vector{BOPSolution})
        seen = Set{Tuple{Vararg{Float64}}}()
        out = BOPSolution[]
        for s in sols
            key = Tuple(s.vars)
            if key ∉ seen
                push!(seen, key)
                push!(out, s)
            end
        end
        return out
    end

    function select_unique_sols(sols::Vector{MOPSolution})
        seen = Set{Tuple{Vararg{Float64}}}()
        out = MOPSolution[]
        for s in sols
            key = Tuple(s.vars)
            if key ∉ seen
                push!(seen, key)
                push!(out, s)
            end
        end
        return out
    end

    function select_non_dom_sols(sols::Vector{BOPSolution})
        if isempty(sols)
            return BOPSolution[]
        end
        out = BOPSolution[]
        for (i, s) in enumerate(sols)
            dominated = false
            vi = [s.obj_val1, s.obj_val2]
            for (j, t) in enumerate(sols)
                if i == j
                    continue
                end
                vt = [t.obj_val1, t.obj_val2]
                _, dom2 = check_dominance(vi, vt)
                if dom2
                    dominated = true
                    break
                end
            end
            if !dominated
                push!(out, s)
            end
        end
        return select_unique_sols(out)
    end

    function select_non_dom_sols(sols::Vector{MOPSolution})
        if isempty(sols)
            return MOPSolution[]
        end
        out = MOPSolution[]
        for (i, s) in enumerate(sols)
            dominated = false
            for (j, t) in enumerate(sols)
                if i == j
                    continue
                end
                _, dom2 = check_dominance(s.obj_vals, t.obj_vals)
                if dom2
                    dominated = true
                    break
                end
            end
            if !dominated
                push!(out, s)
            end
        end
        return select_unique_sols(out)
    end

    sort_non_dom_sols(sols::Vector{BOPSolution}) = sort(sols, by=s -> (s.obj_val1, s.obj_val2))
    sort_non_dom_sols(sols::Vector{MOPSolution}) = sort(sols, by=s -> s.obj_vals)

    select_and_sort_non_dom_sols(sols::Vector{BOPSolution}) = sort_non_dom_sols(select_non_dom_sols(sols))
    select_and_sort_non_dom_sols(sols::Vector{MOPSolution}) = sort_non_dom_sols(select_non_dom_sols(sols))

    check_feasibility(sols, _) = sols

    function lprelaxation(instance::BOBPInstance)
        n = size(instance.A, 2)
        lp = BOLPInstance(instance.A, zeros(n), ones(n), instance.c1, instance.c2, instance.cons_lb, instance.cons_ub)
        return lp, collect(1:n)
    end

    function lprelaxation(instance::MOBPInstance)
        n = size(instance.A, 2)
        lp = MOLPInstance(instance.A, zeros(n), ones(n), instance.c, instance.cons_lb, instance.cons_ub)
        return lp, collect(1:n)
    end

    function lprelaxation(instance::BOMBLPInstance)
        lp = BOLPInstance(instance.A, instance.v_lb, instance.v_ub, instance.c1, instance.c2, instance.cons_lb, instance.cons_ub)
        return lp, copy(instance.bin_var_ind)
    end

    function lprelaxation(instance::MOMBLPInstance)
        lp = MOLPInstance(instance.A, instance.v_lb, instance.v_ub, instance.c, instance.cons_lb, instance.cons_ub)
        return lp, copy(instance.bin_var_ind)
    end

    function convert_ip_into_bp(::Union{BOIPInstance, BOMILPInstance, MOIPInstance, MOMILPInstance}, ::Float64)
        throw(ArgumentError("Integer-to-binary reformulation is not available without Modof.jl. Install Modof.jl or provide binary/mixed-binary instances directly."))
    end

    function convert_bp_sol_into_ip_sol(::Any, ::Any, ::Any)
        throw(ArgumentError("Binary-to-integer conversion is not available without Modof.jl."))
    end

    function read_an_instance_from_a_jump_model(::JuMP.Model)
        throw(ArgumentError("fpbh(model::JuMP.Model) requires Modof.jl for multi-objective parsing."))
    end

    function read_an_instance_from_a_lp_or_a_mps_file(::String, ::Vector{Symbol})
        throw(ArgumentError("fpbh(filename, sense) requires Modof.jl for LP/MPS parsing."))
    end

    function wrap_sols_into_array(sols::Vector{BOPSolution})
        if isempty(sols)
            return zeros(0, 2)
        end
        out = zeros(length(sols), 2)
        for i in eachindex(sols)
            out[i, 1] = sols[i].obj_val1
            out[i, 2] = sols[i].obj_val2
        end
        return out
    end

    function wrap_sols_into_array(sols::Vector{MOPSolution})
        if isempty(sols)
            return zeros(0, 0)
        end
        p = length(sols[1].obj_vals)
        out = zeros(length(sols), p)
        for i in eachindex(sols)
            out[i, :] .= sols[i].obj_vals
        end
        return out
    end

    function write_nondominated_frontier(sols, filename::String)
        writedlm(filename, wrap_sols_into_array(sols))
        return
    end

    function write_nondominated_sols(sols::Vector{BOPSolution}, filename::String)
        if isempty(sols)
            writedlm(filename, zeros(0, 0))
            return
        end
        data = hcat([s.vars for s in sols]...)'
        writedlm(filename, data)
        return
    end

    function write_nondominated_sols(sols::Vector{MOPSolution}, filename::String)
        if isempty(sols)
            writedlm(filename, zeros(0, 0))
            return
        end
        data = hcat([s.vars for s in sols]...)'
        writedlm(filename, data)
        return
    end
end

