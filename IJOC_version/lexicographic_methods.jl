###############################################################################
#                                                                             #
#  This file is part of the julia module for Multi Objective Optimization     #
#  (c) Copyright 2017 by Aritra Pal, Hadi Charkhgard                          #
#                                                                             #
#  Permission is granted for academic research use.  For other uses,          #
#  contact the authors for licensing options.                                 #
#                                                                             #
#  Use at your own risk. I make no guarantees about the correctness or        #          
#  usefulness of this code.                                                   #
#                                                                             #
###############################################################################

#####################################################################
# Lexicographic Method                                              #
#####################################################################

#####################################################################
## Bi Objective Optimization Instance                              ##
#####################################################################

"""
	lex_min{T<:BOOInstance}(instance::T, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, warmstart::Bool=true)
	
 Lexicographic Minimization of a `BOOInstance`.
"""
function lex_min{T<:BOOInstance}(instance::T, solver::MathProgBase.SolverInterface.AbstractMathProgSolver=CplexSolver(CPX_PARAM_EPGAP=0.00001), warmstart::Bool=true)
	non_dom_sols::Vector{BOOSolution} = BOOSolution[]
	tmp = BOOSolution()
	for i in 1:2
		model = MathProgBase.LinearQuadraticModel(solver)
		@match typeof(instance) begin
			BOBPInstance => MathProgBase.loadproblem!(model, instance.A, zeros(size(instance.A)[2]), ones(size(instance.A)[2]), instance.c1, instance.cons_lb, instance.cons_ub, :Min)
			_ => MathProgBase.loadproblem!(model, instance.A, instance.v_lb, instance.v_ub, instance.c1, instance.cons_lb, instance.cons_ub, :Min)
		end
		if typeof(instance) != BOLPInstance
			@match typeof(instance) begin
				BOBPInstance => MathProgBase.setvartype!(model, fill(:Bin, MathProgBase.numvar(model)))
				BOIPInstance => MathProgBase.setvartype!(model, fill(:Int, MathProgBase.numvar(model)))
				_ => MathProgBase.setvartype!(model, instance.var_types)
			end
		end
		if i == 1
			tmp = lex_min(instance.c1, instance.c2, model, warmstart)
		else
			tmp = lex_min(instance.c2, instance.c1, model, warmstart)
		end
		if tmp == "Problem Infeasible"
			continue
		else
			compute_objective_function_value!(tmp, instance)	
			push!(non_dom_sols, tmp)
		end
	end
	non_dom_sols
end

function lex_min{T<:Number}(c1::Vector{T}, c2::Vector{T}, model::MathProgBase.AbstractMathProgModel, warmstart::Bool=true)
	for i in 1:2
		if i == 1
			MathProgBase.setobj!(model, c1)
		else
			if warmstart
				MathProgBase.setwarmstart!(model, MathProgBase.getsolution(model))
			end
			inds = findn(c1)
			MathProgBase.addconstr!(model, inds, c1[inds], -Inf, MathProgBase.getobjval(model))
			MathProgBase.setobj!(model, c2)
		end
		MathProgBase.optimize!(model)
		if MathProgBase.status(model) != :Optimal
			return "Problem Infeasible"
		end
	end
	return BOOSolution(vars=MathProgBase.getsolution(model))
end
