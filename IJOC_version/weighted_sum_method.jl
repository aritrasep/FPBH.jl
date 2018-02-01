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
# Weighted Sum Method                                               #
#####################################################################

#####################################################################
## Multi Objective Instances                                       ##
#####################################################################

#####################################################################
## Bi Objective Instances                                          ##
#####################################################################

@inbounds function compute_weights(solution1::BOOSolution, solution2::BOOSolution)
	[solution1.obj_val2-solution2.obj_val2, solution2.obj_val1-solution1.obj_val1]
end

function weighted_sum_method(instance::BOLPInstance, num::Number, solver::MathProgBase.SolverInterface.AbstractMathProgSolver)	
	non_dom_sols::Vector{BOOSolution} = lex_min(instance, solver, false)
	if length(non_dom_sols) <= 1
		return non_dom_sols
	end
	blocks_to_explore=Queue(Vector{Int64})
	enqueue!(blocks_to_explore, [1,2])
	count::Int64 = 2
	model = MathProgBase.LinearQuadraticModel(solver)
	while length(blocks_to_explore) >= 1 && count < num
		current_block_to_explore = dequeue!(blocks_to_explore)
		weights = compute_weights(non_dom_sols[current_block_to_explore[1]], non_dom_sols[current_block_to_explore[2]])
		if count == 2
			MathProgBase.loadproblem!(model, instance.A, instance.v_lb, instance.v_ub, (weights[1]*instance.c1) + (weights[2]*instance.c2), instance.cons_lb, instance.cons_ub, :Min)
		else
			MathProgBase.setobj!(model, (weights[1]*instance.c1) + (weights[2]*instance.c2))
		end
		MathProgBase.optimize!(model)
		current_solution = MathProgBase.getsolution(model)
		if current_solution != non_dom_sols[current_block_to_explore[1]].vars && current_solution != non_dom_sols[current_block_to_explore[2]].vars
			tmp = BOOSolution(vars=current_solution)
			compute_objective_function_value!(tmp, instance)
			push!(non_dom_sols, tmp)
			enqueue!(blocks_to_explore, [current_block_to_explore[1], length(non_dom_sols)])
			enqueue!(blocks_to_explore, [length(non_dom_sols), current_block_to_explore[2]])
			count += 1
		end
	end
	select_non_dom_sols(non_dom_sols)
end

"""
	weighted_sum_method(instance::BOLPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver)
	
 Weighted Sum Minimization of a `BOLPInstance`.
"""
function weighted_sum_method(instance::BOLPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, k::Number=1)
	m::Int64, n::Int64 = size(instance.A)
	num::Int64 = n>=m?n:m
	num = k*minimum([5*ceil(Int64, log2(num+1)), 50])
	weighted_sum_method(instance, num, solver)
end
