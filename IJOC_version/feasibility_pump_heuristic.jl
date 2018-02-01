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
# Feasibility Pump Heuristic                                        #
#####################################################################

#####################################################################
## Binary Bi-Objective Binary Programs                             ##
#####################################################################

function fph_bobp_strategy2(current_vars::Vector{Int64}, strt_sol::Vector{Float64}, tabu_list::Vector{Vector{Int64}})
	tmp::Vector{Float64} = zeros(length(strt_sol))
	tmp[current_vars] = 1.0
	diff::Vector{Float64} = abs(tmp-strt_sol)
	sorting_list::Array{Float64,2} = zeros(length(diff), 2)
	sorting_list[:, 1], sorting_list[:, 2] = diff, collect(1:length(diff))
	sorting_list = sortrows(sorting_list[findn(sorting_list[:,1]),:], rev=true)
	iterations::Int64 = 1
	iteration_limit::Int64 = size(sorting_list)[1]
	while iterations <= iteration_limit
		tmp2 = deepcopy(tmp)
		#inds_to_flip = rand(1:size(sorting_list)[1], rand(round(Int64, (size(sorting_list)[1]/4)):round(Int64, 3*(size(sorting_list)[1]/4)),1)[1])
		inds_to_flip = unique(rand(1:size(sorting_list)[1], rand(round(Int64, (size(sorting_list)[1]/2)):(size(sorting_list)[1]-1),1)[1]))
		for i in inds_to_flip
			tmp2[i] = 1-tmp2[i]
		end
		iterations += 1
		if findn(tmp2) in tabu_list
			continue
		else
			tmp = deepcopy(tmp2)
			break
		end
	end
	vars_to_return::Vector{Int64} = findn(tmp)
	status::String = "Found New Starting Solution"
	if vars_to_return in tabu_list
		status = "Did not New Starting Solution"
	end
 	(vars_to_return, status)
end

function fph_bobp_strategy1(current_vars::Vector{Int64}, strt_sol::Vector{Float64}, tabu_list::Vector{Vector{Int64}})
	tmp::Vector{Float64} = zeros(length(strt_sol))
	tmp[current_vars] = 1.0
	diff::Vector{Float64} = abs(tmp-strt_sol)
	sorting_list::Array{Float64,2} = zeros(length(diff), 2)
	sorting_list[:, 1], sorting_list[:, 2] = diff, collect(1:length(diff))
	sorting_list = sortrows(sorting_list[findn(sorting_list[:,1]),:], rev=true)
	for i in 1:size(sorting_list)[1]
		tmp[round(Int64,sorting_list[i,2])] = 1-tmp[round(Int64,sorting_list[i,2])]
		if findn(tmp) in tabu_list
			continue
		else
			break
		end
	end
	vars_to_return::Vector{Int64} = findn(tmp)
	status::String = "Found New Starting Solution"
	if vars_to_return in tabu_list
		status = "Did not New Starting Solution"
	end
 	(vars_to_return, status)
end

function fph_bobp(model::MathProgBase.AbstractMathProgModel, starting_solution::BOOSolution, tabu_list::Vector{Vector{Int64}})
	iterations::Int64 = 0
	iteration_limit::Int64 = round(sqrt(maximum([MathProgBase.numvar(model), MathProgBase.numconstr(model)])))
	strt_sol::Vector{Float64} = starting_solution.vars
	status::String = "Found New Starting Solution"
	while iterations <= iteration_limit
		current_bin_vars = findn(round(strt_sol))
		if current_bin_vars in tabu_list
			current_bin_vars, status = fph_bobp_strategy1(current_bin_vars, strt_sol, tabu_list)
			if current_bin_vars in tabu_list
				current_bin_vars, status = fph_bobp_strategy2(current_bin_vars, strt_sol, tabu_list)
			end
		end
		if status != "Found New Starting Solution"
			break
		end
		obj_coeffs = ones(length(strt_sol))
		obj_coeffs[current_bin_vars] = -1.0
		MathProgBase.setobj!(model, obj_coeffs)
		MathProgBase.optimize!(model)
		if MathProgBase.status(model) == :Optimal
			strt_sol = MathProgBase.getsolution(model)
		else
			break
		end	
		if isinteger(strt_sol)
			break
		end
		push!(tabu_list, current_bin_vars)
		iterations += 1
	end
	if isinteger(strt_sol)
		#println("------------------------")
		#println("Feasibile Solution Found")
		#println("------------------------")
		return ([BOOSolution(vars=strt_sol)], tabu_list)
	else
		return (BOOSolution[], tabu_list)
	end
end	

function feasibility_pump_heuristic(instance::BOBPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, starting_solutions::Vector{BOOSolution}, local_search::Bool=true, timelimit::Float64=15.0)
	t0::Float64 = time()
	model = MathProgBase.LinearQuadraticModel(solver)
	MathProgBase.loadproblem!(model, instance.A, zeros(size(instance.A)[2]), ones(size(instance.A)[2]), instance.c1, instance.cons_lb, instance.cons_ub, :Min)
	sols::Vector{BOOSolution} = BOOSolution[]
	tabu_list::Vector{Vector{Int64}}=Vector{Int64}[]
	for i in 1:length(starting_solutions)
		tmp, tabu_list = fph_bobp(deepcopy(model), starting_solutions[i], tabu_list)
		if length(tmp) == 1
			compute_objective_function_value!(tmp[1], instance)
			push!(sols, tmp[1])
		end
	end
	try
		@match local_search begin
			false => return select_non_dom_sols(sols)
			_ => return local_search_operator_1(instance, select_non_dom_sols(sols), timelimit-(time()-t0))
		end
	catch
		return BOOSolution[]
	end
end

function feasibility_pump_heuristic{T<:Number}(instance::BOBPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, τ::T=1, local_search::Bool=true, timelimit::Float64=15.0)
	t0::Float64 = time()
	instance2 = convert_BOLPInstance(instance)
	starting_solutions::Vector{BOOSolution} = weighted_sum_method(instance2, solver, τ)
	if length(starting_solutions) == 0
		return BOOSolution[]
	end
	feasibility_pump_heuristic(instance, solver, starting_solutions, local_search, timelimit-(time()-t0))
end

function FPH1{T<:Number}(instance::BOBPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, τ::T=1, timelimit::Float64=15.0)
	feasibility_pump_heuristic(instance, solver, τ, false, timelimit)
end

function FPH1{T<:Number}(instance::BOBPInstance, current_pt::Vector{T}, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, τ::T=1, timelimit::Float64=15.0)
	instance.cons_lb[end-1:end] = -1current_pt
	feasibility_pump_heuristic(instance, solver, τ, false, timelimit)
end

function FPH2{T<:Number}(instance::BOBPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, τ::T=1, timelimit::Float64=15.0)
	feasibility_pump_heuristic(instance, solver, τ, true, timelimit)
end

function FPH2{T<:Number}(instance::BOBPInstance, current_pt::Vector{T}, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, τ::T=1, timelimit::Float64=15.0)
	instance.cons_lb[end-1:end] = -1current_pt
	feasibility_pump_heuristic(instance, solver, τ, true, timelimit)
end
