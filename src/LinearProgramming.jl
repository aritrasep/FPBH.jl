###############################################################################
# Linear programming helpers backed by JuMP/MathOptInterface.                  #
###############################################################################

mutable struct LPModel
    optimizer_factory::Any
    model::JuMP.Model
    variables::Vector{JuMP.VariableRef}
    objective_sense::Symbol
end

function LPModel(optimizer_factory=GLPK.Optimizer)
    model = JuMP.Model(optimizer_factory)
    JuMP.set_silent(model)
    LPModel(optimizer_factory, model, JuMP.VariableRef[], :Min)
end

function set_variable_bound!(variable::JuMP.VariableRef, lower::Real, upper::Real)
    if isfinite(lower)
        JuMP.set_lower_bound(variable, lower)
    end
    if isfinite(upper)
        JuMP.set_upper_bound(variable, upper)
    end
    nothing
end

linear_expression(variables::Vector{JuMP.VariableRef}, coefficients) =
    sum(coefficients[j] * variables[j] for j in eachindex(coefficients))

constraint_expression(variables::Vector{JuMP.VariableRef}, indices, coefficients) =
    sum(coefficients[k] * variables[indices[k]] for k in eachindex(indices))

function add_lp_constraint!(lp::LPModel, indices, coefficients, lower::Real, upper::Real)
    expr = isempty(indices) ? 0.0 : constraint_expression(lp.variables, indices, coefficients)
    if isfinite(lower) && isfinite(upper)
        if lower == upper
            JuMP.@constraint(lp.model, expr == lower)
        else
            JuMP.@constraint(lp.model, lower <= expr <= upper)
        end
    elseif isfinite(lower)
        JuMP.@constraint(lp.model, expr >= lower)
    elseif isfinite(upper)
        JuMP.@constraint(lp.model, expr <= upper)
    end
    lp
end

function set_lp_objective!(lp::LPModel, objective)
    sense = lp.objective_sense == :Max ? JuMP.MAX_SENSE : JuMP.MIN_SENSE
    JuMP.@objective(lp.model, sense, linear_expression(lp.variables, objective))
    lp
end

function build_lp_model(
    optimizer_factory,
    A,
    variable_lower_bounds,
    variable_upper_bounds,
    objective,
    constraint_lower_bounds,
    constraint_upper_bounds,
    sense::Symbol,
)
    lp = LPModel(optimizer_factory)
    lp.objective_sense = sense
    _, n = size(A)
    lp.variables = [JuMP.@variable(lp.model, base_name = "x_$j") for j in 1:n]
    for j in 1:n
        set_variable_bound!(lp.variables[j], variable_lower_bounds[j], variable_upper_bounds[j])
    end
    for i in 1:size(A, 1)
        row = A[i, :]
        indices = findall(!iszero, row)
        add_lp_constraint!(lp, indices, row[indices], constraint_lower_bounds[i], constraint_upper_bounds[i])
    end
    set_lp_objective!(lp, objective)
end

function optimize_lp!(lp::LPModel)
    JuMP.optimize!(lp.model)
    lp
end

lp_solution(lp::LPModel) = JuMP.value.(lp.variables)
lp_objective_value(lp::LPModel) = JuMP.objective_value(lp.model)
lp_variable_count(lp::LPModel) = length(lp.variables)
lp_constraint_count(lp::LPModel) =
    JuMP.num_constraints(lp.model; count_variable_in_set_constraints = false)

function lp_status(lp::LPModel)
    termination = JuMP.termination_status(lp.model)
    termination == MOI.OPTIMAL ? :Optimal : Symbol(termination)
end
