###############################################################################
#                                                                             #
#  This file is part of the julia module for Multi Objective Optimization     #
#  (c) Copyright 2017 by Aritra Pal, Hadi Charkhgard                          #
#                                                                             #
# This license is designed to guarantee freedom to share and change software  #
# for academic use, but restricting commercial firms from exploiting our      #
# knowhow for their benefit. The precise terms and conditions for using,      #
# copying, distribution, and modification follow. Permission is granted for   #
# academic research use. The license expires as soon as you are no longer a   # 
# member of an academic institution. For other uses, contact the authors for  #
# licensing options. Every publication and presentation for which work based  #
# on the Program or its output has been used must contain an appropriate      # 
# citation and acknowledgment of the authors of the Program.                  #
#                                                                             #
# The above copyright notice and this permission notice shall be included in  #
# all copies or substantial portions of the Software.                         #
#                                                                             #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         #
# DEALINGS IN THE SOFTWARE.                                                   #
#                                                                             #
###############################################################################

#####################################################################
# Starting Solution Creators                                        #
#####################################################################

#####################################################################
## Weighted Sum Method for Biobjective Linear Programs             ##
#####################################################################

@inbounds function compute_weights(solution1::BOPSolution, solution2::BOPSolution)
    [solution1.obj_val2-solution2.obj_val2, solution2.obj_val1-solution1.obj_val1]
end

#####################################################################
### General Version for any Solver using MathProgBase             ###
#####################################################################

@inbounds function lex_min{T<:Number}(c1::Vector{T}, c2::Vector{T}, model::MathProgBase.AbstractMathProgModel)
    MathProgBase.setobj!(model, c1)
    MathProgBase.optimize!(model)
    try
        inds = findn(c1)
        MathProgBase.addconstr!(model, inds, c1[inds], -Inf, MathProgBase.getobjval(model))
    catch
        return BOPSolution()
    end
    MathProgBase.setobj!(model, c2)
    MathProgBase.optimize!(model)
    BOPSolution(vars=MathProgBase.getsolution(model))
end

@inbounds function lex_min(instance::BOLPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver)
    non_dom_sols = BOPSolution[]
    tmp = BOPSolution()
    for i in 1:2
        model = MathProgBase.LinearQuadraticModel(solver)
        MathProgBase.loadproblem!(model, instance.A, instance.v_lb, instance.v_ub, instance.c1, instance.cons_lb, instance.cons_ub, :Min)
        if i == 1
            tmp = lex_min(instance.c1, instance.c2, model)
        else
            tmp = lex_min(instance.c2, instance.c1, model)
        end
        if length(tmp.vars) == 0
            continue
        else
            compute_objective_function_value!(tmp, instance)	
            push!(non_dom_sols, tmp)
        end
    end
    non_dom_sols
end

@inbounds function generate_starting_solutions_for_fph(instance::BOLPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, num::Int64, timelimit::Float64)	
    t0 = time()
    non_dom_sols = lex_min(instance, solver)
    if length(non_dom_sols) <= 1
        return non_dom_sols
    end
    blocks_to_explore = Queue(Vector{Int64})
    enqueue!(blocks_to_explore, [1,2])
    count = 2
    model = MathProgBase.LinearQuadraticModel(solver)
    MathProgBase.loadproblem!(model, instance.A, instance.v_lb, instance.v_ub, instance.c1, instance.cons_lb, instance.cons_ub, :Min)
    while length(blocks_to_explore) >= 1 && count < num && time()-t0 <= timelimit
        current_block_to_explore = dequeue!(blocks_to_explore)
        weights = compute_weights(non_dom_sols[current_block_to_explore[1]], non_dom_sols[current_block_to_explore[2]])
        MathProgBase.setobj!(model, (weights[1]*instance.c1) + (weights[2]*instance.c2))
        MathProgBase.optimize!(model)
        current_solution = MathProgBase.getsolution(model)
        if current_solution != non_dom_sols[current_block_to_explore[1]].vars && current_solution != non_dom_sols[current_block_to_explore[2]].vars
            tmp = BOPSolution(vars=current_solution)
            compute_objective_function_value!(tmp, instance)
            push!(non_dom_sols, tmp)
            enqueue!(blocks_to_explore, [current_block_to_explore[1], length(non_dom_sols)])
            enqueue!(blocks_to_explore, [length(non_dom_sols), current_block_to_explore[2]])
            count += 1
        end
    end
    select_unique_sols(non_dom_sols)
end

#####################################################################
## Multi-Objective Binary Programs                                 ##
#####################################################################

#####################################################################
### General Version for any Solver using MathProgBase             ###
#####################################################################

@inbounds function two_stage_method(instance::MOLPInstance, model::MathProgBase.AbstractMathProgModel, dir::Int64=1)
    MathProgBase.setobj!(model, vec(instance.c[dir, :]))
    MathProgBase.optimize!(model)
    tmp = Float64[]
    try
        tmp = MathProgBase.getsolution(model)
    catch
        return MOPSolution()
    end
    inds = findn(vec(instance.c[dir, :]))
    MathProgBase.addconstr!(model, inds, vec(instance.c[dir, inds]), -Inf, MathProgBase.getobjval(model))
    obj = vec(instance.c[1,:])
    for i in 1:length(obj)
        obj[i] += sum(instance.c[2:end,i])
    end
    MathProgBase.setobj!(model, obj)
    MathProgBase.optimize!(model)
    tmp = round.(MathProgBase.getsolution(model))
    tmp2 = MOPSolution(vars=tmp)
    compute_objective_function_value!(tmp2, instance)
    tmp2
end

@inbounds function compute_corner_points(instance::MOLPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver)
    non_dom_sols = MOPSolution[]
    for i in 1:size(instance.c)[1]
        model = MathProgBase.LinearQuadraticModel(solver)
        MathProgBase.loadproblem!(model, instance.A, instance.v_lb, instance.v_ub, instance.c[1, :], instance.cons_lb, instance.cons_ub, :Min)
        tmp = two_stage_method(instance, model, i)
        if length(tmp.vars) > 0
            push!(non_dom_sols, tmp)
        end
    end
    select_unique_sols(non_dom_sols)
end

@inbounds function generate_starting_solutions_for_fph(instance::MOLPInstance, solver::MathProgBase.SolverInterface.AbstractMathProgSolver, num::Int64, timelimit::Float64)	
    t0 = time()
    non_dom_sols = compute_corner_points(instance, solver)
    if length(non_dom_sols) <= 1
        return non_dom_sols
    end
    if num - length(non_dom_sols) >= 1
        p = size(instance.c)[1]
        λ = unique(abs.(randn(num-length(non_dom_sols), p)),1)
        λ = λ ./ [sum(λ[i,:]) for i in 1:size(λ)[1]]
        model = MathProgBase.LinearQuadraticModel(solver)
        MathProgBase.loadproblem!(model, instance.A, instance.v_lb, instance.v_ub, instance.c[1, :], instance.cons_lb, instance.cons_ub, :Min)
        for i in 1:size(λ)[1]
            if time()-t0 > timelimit
                break
            end
            tmp = λ[i, 1]*vec(instance.c[1, :])
            for j in 2:size(instance.c)[1]
                tmp += λ[i, j]*vec(instance.c[j, :])
            end
            MathProgBase.setobj!(model, tmp)
            MathProgBase.optimize!(model)
            try
                current_solution = CPLEX.get_solution(model)
                tmp2 = MOPSolution(vars=current_solution)
                compute_objective_function_value!(tmp2, instance)
                push!(non_dom_sols, tmp2)
            catch
            end
        end
    end
    select_unique_sols(non_dom_sols)
end

#####################################################################
# Computing Starting Solutions                                      #
#####################################################################

@inbounds function generate_starting_solutions_for_fph(instance::Union{MOLPInstance, BOLPInstance}, params)
    p = 2
    if typeof(instance) == MOBPInstance
        p = size(instance.c)[1]
    end
    m, n = size(instance.A)
    num = n>=m?n:m
    num = ceil(Int64, minimum([convert(Int64, (10/p)*ceil(log2(num)/log2(p))), convert(Int64, 100/p)]))
    generate_starting_solutions_for_fph(instance, params[:solver], num, params[:timelimit])
end
