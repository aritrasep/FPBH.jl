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
# Local Search Operators                                            #
#####################################################################

#####################################################################
## Binary Bi-Objective Binary Programs                             ##
#####################################################################

function return_queue_for_local_search_operators(new_non_dom_sols_found::Vector{BOOSolution}, already_explored_non_dom_sols::Vector{BOOSolution})
	tmp = select_non_dom_sols([new_non_dom_sols_found..., already_explored_non_dom_sols...])
	ind1::Vector{Int64}, ind2::Vector{Int64} = Int64[], Int64[]
	for i in 1:length(tmp)
		for j in 1:length(already_explored_non_dom_sols)
			if j in ind1
				continue
			end
			if tmp[i].obj_val1 == already_explored_non_dom_sols[j].obj_val1 && tmp[i].obj_val2 == already_explored_non_dom_sols[j].obj_val2
				push!(ind1, j)
				break
			end
			if j == length(already_explored_non_dom_sols)
				push!(ind2, i)
			end
		end
	end
	tmp[ind2], tmp
end

function local_search_operator_1(instance::BOBPInstance, starting_solution::BOOSolution)
	slack::Vector{Float64} = (instance.A * starting_solution.vars) - instance.cons_lb
	equality_cons::Vector{Float64} = instance.cons_ub - instance.cons_lb
	order::Array{Float64, 2} = sortrows(hcat(slack, collect(1:length(slack))))
	inds::Vector{Int64} = Int64[]
	for i in 1:length(starting_solution.vars)
		if starting_solution.vars[i] == 1.0
			if instance.c1[i] > 0.0 || instance.c2[i] > 0.0
				for j in order[:,2]
					if equality_cons[round(Int64,j)] == 0.0
						if instance.A[round(Int64,j), i] != 0.0
							push!(inds, i)
							break
						end
					else
						if instance.A[round(Int64,j), i] > slack[round(Int64,j)]
							push!(inds, i)
							break
						end
					end
				end
			else
				push!(inds, i)
			end
		else
			if instance.c1[i] < 0.0 || instance.c2[i] < 0.0
				for j in order[:,2]
					if equality_cons[round(Int64,j)] == 0.0
						if instance.A[round(Int64,j), i] != 0.0
							push!(inds, i)
							break
						end
					else
						if instance.A[round(Int64,j), i] + slack[round(Int64,j)] < 0.0
							push!(inds, i)
							break
						end
					end
				end
			else
				push!(inds, i)
			end
		end
	end
	non_dom_sols::Vector{BOOSolution} = BOOSolution[]
	for i in 1:length(starting_solution.vars)
		if i in inds
			continue
		end
		tmp1 = copy(starting_solution.vars)
		tmp1[i] = 1-tmp1[i]
		tmp2 = BOOSolution(vars=tmp1)
		compute_objective_function_value!(tmp2, instance)
		push!(non_dom_sols, tmp2)
	end
	select_non_dom_sols(non_dom_sols)
end

function local_search_operator_1(instance::BOBPInstance, starting_solutions::Vector{BOOSolution}, timelimit::Float64=60.0)
	t0::Float64 = time()
	percent_eq_cons::Float64 = (size(instance.A)[1] - length(findn(instance.cons_ub-instance.cons_lb)))/(size(instance.A)[1])
	if percent_eq_cons >= 0.95 || timelimit <= (time()-t0) 
		return starting_solutions
	end
	sols_to_explore::Vector{BOOSolution}, non_dom_sols::Vector{BOOSolution} = deepcopy(starting_solutions), deepcopy(starting_solutions)
	i::Int64 = 1
	tmp::Vector{BOOSolution} = BOOSolution[]
	while i <= length(sols_to_explore) && (time()-t0) <= timelimit
		tmp2 = local_search_operator_1(instance, sols_to_explore[i])
		if length(tmp2) >= 1
			push!(tmp, tmp2...)
		end
		i += 1
		if i == length(sols_to_explore)+1
			sols_to_explore, non_dom_sols = return_queue_for_local_search_operators(tmp, non_dom_sols)
			i = 1
		end
	end
	non_dom_sols
end
