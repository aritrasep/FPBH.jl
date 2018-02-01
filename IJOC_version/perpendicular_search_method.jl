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
# Perpendicular Search Method                                       #
#####################################################################

#####################################################################
## Bi-Objective Binary Programs                                    ##
#####################################################################

#####################################################################
# Modified Perpendicular Search Method                              #
#####################################################################

#####################################################################
## Bi-Objective Binary Programs                                    ##
#####################################################################

function return_queue_for_modified_perpendicular_search_method(new_non_dom_sols_found::Vector{BOOSolution}, already_explored_non_dom_sols::Vector{BOOSolution}, Big_M::Float64 = 1.0e308)
	new_non_dom_sols_found = select_non_dom_sols(new_non_dom_sols_found)
	tmp = select_non_dom_sols([new_non_dom_sols_found..., already_explored_non_dom_sols...])
	ind::Vector{Int64} = zeros(Int64, length(new_non_dom_sols_found))
	for i in 1:length(new_non_dom_sols_found)
		count = 1
		for j in 1:length(already_explored_non_dom_sols)
			if new_non_dom_sols_found[i].obj_val1 == already_explored_non_dom_sols[j].obj_val1 && new_non_dom_sols_found[i].obj_val2 == already_explored_non_dom_sols[j].obj_val2
				count = 0
				break
			end
		end
		if count == 1
			for j in 1:length(tmp)
				if new_non_dom_sols_found[i].obj_val1 == tmp[j].obj_val1 && new_non_dom_sols_found[i].obj_val2 == tmp[j].obj_val2
					ind[i] = j
					break
				end
			end
		end
	end
	new_non_dom_sols_found = new_non_dom_sols_found[findn(ind)]
	ind = ind[findn(ind)]
	points_to_explore = Queue(Vector{Float64})
	for i in 1:length(ind)
		if ind[i] == 1
			enqueue!(points_to_explore, [tmp[ind[i]].obj_val1, Big_M])
		end
		if ind[i] != length(tmp)
			enqueue!(points_to_explore, [tmp[ind[i]+1].obj_val1, tmp[ind[i]].obj_val2])
		else
			enqueue!(points_to_explore, [Big_M, tmp[ind[i]].obj_val2])
		end
		if i > 1 && ind[i]-ind[i-1] > 1
			enqueue!(points_to_explore, [tmp[ind[i]].obj_val1, tmp[ind[i]-1].obj_val2])
		end
	end
	(points_to_explore, tmp)
end

function modified_perpendicular_search_method{T<:Number}(instance::BOBPInstance, subproblem_solver::Function, solver::MathProgBase.SolverInterface.AbstractMathProgSolver; timelimit::Float64=120.0, τ::T=1.0, Big_M::Float64 = 1.0e308)
	start_time::Float64 = time()
	non_dom_sols::Vector{BOOSolution} = BOOSolution[]
	pts_to_explore = Queue(Vector{Float64})
	enqueue!(pts_to_explore, [Big_M, Big_M])
	instance2::BOBPInstance = deepcopy(instance)
	instance2.A = vcat(instance2.A, -1instance2.c1', -1instance2.c2')
	instance2.cons_lb = vcat(instance2.cons_lb, -Inf, -Inf)
	instance2.cons_ub = vcat(instance2.cons_ub, Inf, Inf)
	sols_to_explore = BOOSolution[]
	while length(pts_to_explore) >= 1 && time()-start_time <= timelimit
		tmp = subproblem_solver(instance2, dequeue!(pts_to_explore), solver, τ, 0.125*timelimit)
		if length(tmp) >= 1
			push!(sols_to_explore, tmp...)
		end
		if length(pts_to_explore) == 0 && length(sols_to_explore) >= 1
			pts_to_explore, non_dom_sols = return_queue_for_modified_perpendicular_search_method(sols_to_explore, non_dom_sols, Big_M)
			sols_to_explore = BOOSolution[]
		end
	end
	non_dom_sols
end

function MPSM{T<:Number}(instance::BOBPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver; timelimit::Float64=120.0, τ::T=1.0, Big_M::Float64 = 1.0e308)
	modified_perpendicular_search_method(instance, FPH2, solver, timelimit = timelimit, τ = τ, Big_M = Big_M)
end

function parallel_modified_perpendicular_search_method{T<:Number}(instance::BOBPInstance, subproblem_solver::Function, solver::MathProgBase.SolverInterface.AbstractMathProgSolver; timelimit::Float64=120.0, τ::T=1.0, Big_M::Float64 = 1.0e308, nthreads::Int64=nprocs())
	start_time::Float64 = time()
	non_dom_sols::Vector{BOOSolution} = BOOSolution[]
	pts_to_explore = Queue(Vector{Float64})
	enqueue!(pts_to_explore, [Big_M, Big_M])
	instance2::BOBPInstance = deepcopy(instance)
	instance2.A = vcat(instance2.A, -1instance2.c1', -1instance2.c2')
	instance2.cons_lb = vcat(instance2.cons_lb, -Inf, -Inf)
	instance2.cons_ub = vcat(instance2.cons_ub, Inf, Inf)
	sols_to_explore = BOOSolution[]
	np::Int64 = nprocs()
	while length(pts_to_explore) >= 1 && time()-start_time <= timelimit
		tmp::Vector{Vector{BOOSolution}} = fill(BOOSolution[], nthreads)
		@sync begin
			for p=2:nthreads+1
				if p != myid() && p < np
            	    @async begin
            	    	if length(pts_to_explore) >= 1
            	    		tmp[p-1] = vcat(tmp[p-1], remotecall_fetch(subproblem_solver, p, instance2, dequeue!(pts_to_explore), solver, τ, 0.125*timelimit))
            	    	end
                    end
                end
            end
        end
        for i in 1:nthreads
        	if length(tmp[i]) >= 1
        		push!(sols_to_explore, tmp[i]...)
			end
		end
		if length(pts_to_explore) == 0 && length(sols_to_explore) >= 1
			pts_to_explore, non_dom_sols = return_queue_for_modified_perpendicular_search_method(sols_to_explore, non_dom_sols, Big_M)
			sols_to_explore = BOOSolution[]
		end
	end
	non_dom_sols
end

function PMPSM{T<:Number}(instance::BOBPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver; timelimit::Float64=120.0, τ::T=1.0, Big_M::Float64=1.0e308, nthreads::Int64=nprocs())
	parallel_modified_perpendicular_search_method(instance, FPH2, solver, timelimit = timelimit, τ = τ, Big_M = Big_M, nthreads = nthreads)
end
