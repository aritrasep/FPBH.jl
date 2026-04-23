module MathProgBaseCompat

using JuMP
import MathOptInterface as MOI

export AbstractMathProgModel
export LinearQuadraticModel
export SolverInterface
export OptimizerFactory
export normalize_solver
export addconstr!
export getobjval
export getsolution
export loadproblem!
export numconstr
export numvar
export optimize!
export setobj!
export status

abstract type AbstractMathProgModel end

module SolverInterface
abstract type AbstractMathProgSolver end
end

struct OptimizerFactory <: SolverInterface.AbstractMathProgSolver
    optimizer::Any
end

mutable struct LinearQuadraticModel <: AbstractMathProgModel
    solver::OptimizerFactory
    model::JuMP.Model
    vars::Vector{JuMP.VariableRef}
    nvar::Int
    nconstr::Int
    sense::Symbol
end

function normalize_solver(solver)
    if solver isa SolverInterface.AbstractMathProgSolver
        return solver
    end
    return OptimizerFactory(solver)
end

function _new_model(factory::OptimizerFactory)
    return JuMP.Model(factory.optimizer)
end

function LinearQuadraticModel(solver)
    factory = normalize_solver(solver)
    m = _new_model(factory)
    return LinearQuadraticModel(factory, m, JuMP.VariableRef[], 0, 0, :Min)
end

function _linexpr(vars::Vector{JuMP.VariableRef}, inds::Vector{Int}, coeffs::Vector{Float64})
    expr = JuMP.AffExpr(0.0)
    for (k, idx) in enumerate(inds)
        coeff = coeffs[k]
        if coeff != 0.0
            JuMP.add_to_expression!(expr, coeff, vars[idx])
        end
    end
    return expr
end

function _full_linexpr(A, vars::Vector{JuMP.VariableRef}, row::Int)
    n = length(vars)
    expr = JuMP.AffExpr(0.0)
    @inbounds for j in 1:n
        coeff = Float64(A[row, j])
        if coeff != 0.0
            JuMP.add_to_expression!(expr, coeff, vars[j])
        end
    end
    return expr
end

function _add_bounded_constraint!(model::LinearQuadraticModel, expr, lb::Float64, ub::Float64)
    lb_finite = isfinite(lb)
    ub_finite = isfinite(ub)
    if lb_finite && ub_finite
        if isapprox(lb, ub; atol=1e-10, rtol=0.0)
            JuMP.@constraint(model.model, expr == lb)
            model.nconstr += 1
        else
            JuMP.@constraint(model.model, expr >= lb)
            JuMP.@constraint(model.model, expr <= ub)
            model.nconstr += 2
        end
        return
    end
    if lb_finite
        JuMP.@constraint(model.model, expr >= lb)
        model.nconstr += 1
    end
    if ub_finite
        JuMP.@constraint(model.model, expr <= ub)
        model.nconstr += 1
    end
end

function loadproblem!(model::LinearQuadraticModel, A, v_lb, v_ub, c, cons_lb, cons_ub, sense::Symbol)
    jump_model = _new_model(model.solver)
    n = size(A, 2)
    m = size(A, 1)

    vars = JuMP.@variable(jump_model, x[1:n])

    @inbounds for j in 1:n
        lb = Float64(v_lb[j])
        ub = Float64(v_ub[j])
        if isfinite(lb)
            JuMP.set_lower_bound(vars[j], lb)
        end
        if isfinite(ub)
            JuMP.set_upper_bound(vars[j], ub)
        end
    end

    compat_model = LinearQuadraticModel(model.solver, jump_model, collect(vars), n, 0, sense)

    @inbounds for i in 1:m
        expr = _full_linexpr(A, compat_model.vars, i)
        _add_bounded_constraint!(compat_model, expr, Float64(cons_lb[i]), Float64(cons_ub[i]))
    end

    coeffs = Float64.(vec(c))
    setobj!(compat_model, coeffs)

    model.model = compat_model.model
    model.vars = compat_model.vars
    model.nvar = compat_model.nvar
    model.nconstr = compat_model.nconstr
    model.sense = compat_model.sense
    return
end

function setobj!(model::LinearQuadraticModel, obj)
    coeffs = Float64.(vec(obj))
    if length(coeffs) != length(model.vars)
        throw(DimensionMismatch("Objective length $(length(coeffs)) does not match number of variables $(length(model.vars))."))
    end

    expr = JuMP.AffExpr(0.0)
    @inbounds for i in eachindex(model.vars)
        coeff = coeffs[i]
        if coeff != 0.0
            JuMP.add_to_expression!(expr, coeff, model.vars[i])
        end
    end

    JuMP.set_objective_function(model.model, expr)
    if model.sense == :Max
        JuMP.set_objective_sense(model.model, MOI.MAX_SENSE)
    else
        JuMP.set_objective_sense(model.model, MOI.MIN_SENSE)
    end
    return
end

optimize!(model::LinearQuadraticModel) = JuMP.optimize!(model.model)

function getsolution(model::LinearQuadraticModel)
    ps = JuMP.primal_status(model.model)
    if ps in (MOI.FEASIBLE_POINT, MOI.NEARLY_FEASIBLE_POINT)
        return JuMP.value.(model.vars)
    end
    throw(ErrorException("No primal solution is available."))
end

getobjval(model::LinearQuadraticModel) = JuMP.objective_value(model.model)
numvar(model::LinearQuadraticModel) = model.nvar
numconstr(model::LinearQuadraticModel) = model.nconstr

function addconstr!(model::LinearQuadraticModel, inds, coeffs, lb, ub)
    i = Int.(vec(inds))
    c = Float64.(vec(coeffs))
    if length(i) != length(c)
        throw(DimensionMismatch("Constraint indices and coefficients have different lengths."))
    end
    expr = _linexpr(model.vars, i, c)
    _add_bounded_constraint!(model, expr, Float64(lb), Float64(ub))
    return
end

function status(model::LinearQuadraticModel)
    ts = JuMP.termination_status(model.model)
    if ts == MOI.OPTIMAL
        return :Optimal
    end
    if ts == MOI.INFEASIBLE
        return :Infeasible
    end
    if ts == MOI.TIME_LIMIT
        return :TimeLimit
    end
    return :Unknown
end

end
