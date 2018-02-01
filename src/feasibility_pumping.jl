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
## Generate new starting solutions when a cycle is detected        ##
#####################################################################

@inbounds function generate_integer_starting_solutions_for_fph(current_vars::Vector{Int64}, strt_sol::Vector{Float64}, tabu_list::Vector{Vector{Int64}})
    status = true
    tmp = zeros(length(strt_sol))
    tmp[current_vars] = 1.0
    diff = abs.(tmp-strt_sol)
    sorting_list = zeros(length(diff), 2)
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
    vars_to_return = findn(tmp)
    if vars_to_return in tabu_list
        status = false
    else
        return (vars_to_return, status)
    end
    tmp = zeros(length(strt_sol))
    tmp[current_vars] = 1.0
    iterations = 1
    iteration_limit = size(sorting_list)[1]
    while iterations <= iteration_limit
        tmp2 = tmp
        #inds_to_flip = unique(rand(1:size(sorting_list)[1], rand(round(Int64, (size(sorting_list)[1]/4)):round(Int64, 3*(size(sorting_list)[1]/4)),1)[1]))
        inds_to_flip = unique(rand(1:size(sorting_list)[1], rand(round(Int64, (size(sorting_list)[1]/2)):(size(sorting_list)[1]-1),1)[1]))
        tmp2[inds_to_flip] = 1-tmp2[inds_to_flip]
        iterations += 1
        if findn(tmp2) in tabu_list
            continue
        else
            tmp = tmp2
            break
        end
    end
    vars_to_return = findn(tmp)
    if vars_to_return in tabu_list
        status = false
    end
    (vars_to_return, status)
end

#####################################################################
# Objective Feasibility Pump                                        #
#####################################################################

#####################################################################
## General Version for any Solver through MathProgBase for BOMIP   ##
#####################################################################

#####################################################################
### Mixed Binary Programs                                         ###
#####################################################################

@inbounds function objective_feasibility_pump(instance::Union{MOLPInstance, BOLPInstance}, model::MathProgBase.AbstractMathProgModel, bin_var_ind::Vector{Int64}, starting_solution::Union{MOPSolution, BOPSolution}, tabu_list::Vector{Vector{Int64}}, α::Float64)
    iterations = 0
    iteration_limit = round(Int64, sqrt(maximum([MathProgBase.numvar(model), MathProgBase.numconstr(model)])))
    strt_sol = starting_solution.vars
    current_bin_vars = Int64[]
    obj_coeffs = Float64[]
    status, found_feasible_sol = true, false
    while iterations <= iteration_limit
        current_bin_vars = findn(round.(strt_sol[bin_var_ind]))
        if current_bin_vars in tabu_list
            current_bin_vars, status = generate_integer_starting_solutions_for_fph(current_bin_vars, strt_sol[bin_var_ind], tabu_list)
        end
        if !status
            break
        end
        if typeof(instance) == MOLPInstance
            tmp = instance.c[1, :]
            for i in 2:size(instance.c)[1]
                tmp += instance.c[i, :]
            end
        else
            tmp = instance.c1 + instance.c2
        end
        tmp = tmp/norm(tmp)
        obj_coeffs = zeros(size(instance.A)[2])
        obj_coeffs[bin_var_ind] = 1.0
        obj_coeffs[bin_var_ind[current_bin_vars]] = -1.0
        obj_coeffs = (1.0-α)*obj_coeffs + α*tmp
        MathProgBase.setobj!(model, obj_coeffs)
        MathProgBase.optimize!(model)
        try
            strt_sol = MathProgBase.getsolution(model)
        catch
            break
        end
        if all(isinteger, strt_sol[bin_var_ind])
            found_feasible_sol = true
            break
        end
        push!(tabu_list, current_bin_vars)
        iterations += 1
    end
    if found_feasible_sol
        #println("------------------------")
        #println("Feasibile Solution Found")
        #println("------------------------")
        if typeof(instance) == MOLPInstance
            tmp2 = MOPSolution(vars=strt_sol)
        else
            tmp2 = BOPSolution(vars=strt_sol)
        end
        compute_objective_function_value!(tmp2, instance)
        return ([tmp2], tabu_list)
    else
        if typeof(instance) == MOLPInstance
            return (MOPSolution[], tabu_list)
        else
            return (BOPSolution[], tabu_list)
        end
    end
end

@inbounds function objective_feasibility_pump(instance::Union{MOLPInstance, BOLPInstance}, model::MathProgBase.AbstractMathProgModel, bin_var_ind::Vector{Int64}, starting_solution::Union{MOPSolution, BOPSolution}, tabu_list::Vector{Vector{Int64}})
    if typeof(instance) == MOLPInstance
        p = size(instance.c)[1]
        sols = MOPSolution[]
    else
        p = 2
        sols = BOPSolution[]
    end
    α = [exp(i) for i in 1:p]
    insert!(α, 1, 0.0)
    α /= sum(α)
    for i in 1:length(α)
        tmp, tabu_list = objective_feasibility_pump(instance, model, bin_var_ind, starting_solution, tabu_list, α[i])
        if length(tmp) >= 1
            push!(sols, tmp...)
        end
    end
    sols, tabu_list
end

#####################################################################
### Pure Binary Programs                                          ###
#####################################################################

@inbounds function objective_feasibility_pump(instance::Union{MOLPInstance, BOLPInstance}, model::MathProgBase.AbstractMathProgModel, starting_solution::Union{MOPSolution, BOPSolution}, tabu_list::Vector{Vector{Int64}}, α::Float64)
    iterations = 0
    iteration_limit = round(Int64, sqrt(maximum([MathProgBase.numvar(model), MathProgBase.numconstr(model)])))
    strt_sol = starting_solution.vars
    current_bin_vars = Int64[]
    obj_coeffs = Float64[]
    status, found_feasible_sol = true, false
    while iterations <= iteration_limit
        current_bin_vars = findn(round.(strt_sol))
        if current_bin_vars in tabu_list
            current_bin_vars, status = generate_integer_starting_solutions_for_fph(current_bin_vars, strt_sol, tabu_list)
        end
        if !status
            break
        end
        if typeof(instance) == MOLPInstance
            tmp = instance.c[1, :]
            for i in 2:size(instance.c)[1]
                tmp += instance.c[i, :]
            end
        else
            tmp = instance.c1 + instance.c2
        end
        tmp = tmp/norm(tmp)
        obj_coeffs = ones(length(strt_sol))
        obj_coeffs[current_bin_vars] = -1.0
        obj_coeffs = (1.0-α)*obj_coeffs + α*tmp
        MathProgBase.setobj!(model, obj_coeffs)
        MathProgBase.optimize!(model)
        try
            strt_sol = MathProgBase.getsolution(model)
        catch
            break
        end
        if all(isinteger, strt_sol)
            found_feasible_sol = true
            break
        end
        push!(tabu_list, current_bin_vars)
        iterations += 1
    end
    if found_feasible_sol
        #println("------------------------")
        #println("Feasibile Solution Found")
        #println("------------------------")
        if typeof(instance) == MOLPInstance
            tmp2 = MOPSolution(vars=strt_sol)
        else
            tmp2 = BOPSolution(vars=strt_sol)
        end
        compute_objective_function_value!(tmp2, instance)
        return ([tmp2], tabu_list)
    else
        if typeof(instance) == MOLPInstance
            return (MOPSolution[], tabu_list)
        else
            return (BOPSolution[], tabu_list)
        end
    end
end

@inbounds function objective_feasibility_pump(instance::Union{MOLPInstance, BOLPInstance}, model::MathProgBase.AbstractMathProgModel, starting_solution::Union{MOPSolution, BOPSolution}, tabu_list::Vector{Vector{Int64}})
    if typeof(instance) == MOLPInstance
        p = size(instance.c)[1]
        sols = MOPSolution[]
    else
        p = 2
        sols = BOPSolution[]
    end
    α = [exp(i) for i in 1:p]
    insert!(α, 1, 0.0)
    α /= sum(α)
    for i in 1:length(α)
        tmp, tabu_list = objective_feasibility_pump(instance, model, starting_solution, tabu_list, α[i])
        if length(tmp) >= 1
            push!(sols, tmp...)
        end
    end
    sols, tabu_list
end

#####################################################################
# Normal Feasibility Pump                                           #
#####################################################################

#####################################################################
## General Version for any Solver through MathProgBase for BOMIP   ##
#####################################################################

#####################################################################
### Mixed Binary Programs                                         ###
#####################################################################

@inbounds function feasibility_pump(instance::Union{MOLPInstance, BOLPInstance}, model::MathProgBase.AbstractMathProgModel, bin_var_ind::Vector{Int64}, starting_solution::Union{MOPSolution, BOPSolution}, tabu_list::Vector{Vector{Int64}})
    iterations = 0
    iteration_limit = round(Int64, sqrt(maximum([MathProgBase.numvar(model), MathProgBase.numconstr(model)])))
    strt_sol = starting_solution.vars
    current_bin_vars = Int64[]
    obj_coeffs = Float64[]
    status, found_feasible_sol = true, false
    while iterations <= iteration_limit
        current_bin_vars = findn(round.(strt_sol[bin_var_ind]))
        if current_bin_vars in tabu_list
            current_bin_vars, status = generate_integer_starting_solutions_for_fph(current_bin_vars, strt_sol[bin_var_ind], tabu_list)
        end
        if !status
            break
        end
        obj_coeffs = zeros(size(instance.A)[2])
        obj_coeffs[bin_var_ind] = 1.0
        obj_coeffs[bin_var_ind[current_bin_vars]] = -1.0
        MathProgBase.setobj!(model, obj_coeffs)
        MathProgBase.optimize!(model)
        try
            strt_sol = MathProgBase.getsolution(model)
        catch
            break
        end
        if all(isinteger, strt_sol[bin_var_ind])
            found_feasible_sol = true
            break
        end
        push!(tabu_list, current_bin_vars)
        iterations += 1
    end
    if found_feasible_sol
        #println("------------------------")
        #println("Feasibile Solution Found")
        #println("------------------------")
        if typeof(instance) == MOLPInstance
            tmp2 = MOPSolution(vars=strt_sol)
        else
            tmp2 = BOPSolution(vars=strt_sol)
        end
        compute_objective_function_value!(tmp2, instance)
        return ([tmp2], tabu_list)
    else
        if typeof(instance) == MOLPInstance
            return (MOPSolution[], tabu_list)
        else
            return (BOPSolution[], tabu_list)
        end
    end
end

#####################################################################
### Pure Binary Programs                                          ###
#####################################################################

@inbounds function feasibility_pump(instance::Union{MOLPInstance, BOLPInstance}, model::MathProgBase.AbstractMathProgModel, starting_solution::Union{MOPSolution, BOPSolution}, tabu_list::Vector{Vector{Int64}})
    iterations = 0
    iteration_limit = round(Int64, sqrt(maximum([MathProgBase.numvar(model), MathProgBase.numconstr(model)])))
    strt_sol = starting_solution.vars
    current_bin_vars = Int64[]
    obj_coeffs = Float64[]
    status, found_feasible_sol = true, false
    while iterations <= iteration_limit
        current_bin_vars = findn(round.(strt_sol))
        if current_bin_vars in tabu_list
            current_bin_vars, status = generate_integer_starting_solutions_for_fph(current_bin_vars, strt_sol, tabu_list)
        end
        if !status
            break
        end
        obj_coeffs = ones(length(strt_sol))
        obj_coeffs[current_bin_vars] = -1.0
        MathProgBase.setobj!(model, obj_coeffs)
        MathProgBase.optimize!(model)
        try
            strt_sol = MathProgBase.getsolution(model)
        catch
            break
        end
        if all(isinteger, strt_sol)
            found_feasible_sol = true
            break
        end
        push!(tabu_list, current_bin_vars)
        iterations += 1
    end
    if found_feasible_sol
        #println("------------------------")
        #println("Feasibile Solution Found")
        #println("------------------------")
        if typeof(instance) == MOLPInstance
            tmp2 = MOPSolution(vars=strt_sol)
        else
            tmp2 = BOPSolution(vars=strt_sol)
        end
        compute_objective_function_value!(tmp2, instance)
        return ([tmp2], tabu_list)
    else
        if typeof(instance) == MOLPInstance
            return (MOPSolution[], tabu_list)
        else
            return (BOPSolution[], tabu_list)
        end
    end
end

#####################################################################
## Defining different versions of FPH using Multiple Dispatch      ##
#####################################################################

@inbounds function FPH(instance::Union{MOLPInstance, BOLPInstance}, model::MathProgBase.AbstractMathProgModel, bin_var_ind::Vector{Int64}, starting_solutions::Union{Vector{MOPSolution}, Vector{BOPSolution}}, params)
    t0 = time()
    if typeof(instance) == MOLPInstance
        sols = MOPSolution[]
    else
        sols = BOPSolution[]
    end
    tabu_list = Vector{Int64}[]
    i = 1
    starting_solutions = starting_solutions[shuffle([1:length(starting_solutions)...])]
    while i <= length(starting_solutions) && (time()-t0) <= params[:timelimit]
        if params[:obj_fph]
            tmp, tabu_list = objective_feasibility_pump(instance, model, bin_var_ind, starting_solutions[i], tabu_list)
        else
            tmp, tabu_list = feasibility_pump(instance, model, bin_var_ind, starting_solutions[i], tabu_list)
        end
        if length(tmp) >= 1
            push!(sols, tmp...)
        end
        i += 1
    end
    if params[:local_search] && length(sols) >= 1
        timelimit = params[:timelimit]
        params[:timelimit] -= (time()-t0)
        if params[:timelimit] > 0.0
            sols = ONE_OPT(instance, bin_var_ind, sols, params)
        end
        params[:timelimit] = timelimit
    end
    select_non_dom_sols(sols)
end

@inbounds function FPH(instance::Union{MOLPInstance, BOLPInstance}, model::MathProgBase.AbstractMathProgModel, starting_solutions::Union{Vector{MOPSolution}, Vector{BOPSolution}}, params)
    t0 = time()
    if typeof(instance) == MOLPInstance
        sols = MOPSolution[]
    else
        sols = BOPSolution[]
    end
    tabu_list = Vector{Int64}[]
    starting_solutions = starting_solutions[shuffle([1:length(starting_solutions)...])]
    i = 1
    while i <= length(starting_solutions) && (time()-t0) <= params[:timelimit]
        if params[:obj_fph]
            tmp, tabu_list = objective_feasibility_pump(instance, model, starting_solutions[i], tabu_list)
        else
            tmp, tabu_list = feasibility_pump(instance, model, starting_solutions[i], tabu_list)
        end
        if length(tmp) >= 1
            push!(sols, tmp...)
        end
        i += 1
    end
    if params[:local_search] && length(sols) >= 1
        timelimit = params[:timelimit]
        params[:timelimit] -= (time()-t0)
        if params[:timelimit] > 0.0
            sols = ONE_OPT(instance, sols, params)
        end
        params[:timelimit] = timelimit
    end
    select_non_dom_sols(sols)
end

@inbounds function FPH(instance::Union{MOLPInstance, BOLPInstance}, bin_var_ind::Vector{Int64}, params)
    t0 = time()
    timelimit = params[:timelimit]
    params[:timelimit] = (timelimit - time() + t0)/3
    starting_solutions = generate_starting_solutions_for_fph(instance, params)
    if length(starting_solutions) == 0
        if typeof(instance) == MOLPInstance
            return MOPSolution[]
        end
        if typeof(instance) == BOLPInstance
            return BOPSolution[]
        end
    end
    model = MathProgBase.LinearQuadraticModel(params[:solver])
    if typeof(instance) == MOLPInstance
        MathProgBase.loadproblem!(model, instance.A, zeros(size(instance.A)[2]), ones(size(instance.A)[2]), instance.c[1, :], instance.cons_lb, instance.cons_ub, :Min)
    end
    if typeof(instance) == BOLPInstance
        MathProgBase.loadproblem!(model, instance.A, zeros(size(instance.A)[2]), ones(size(instance.A)[2]), instance.c1, instance.cons_lb, instance.cons_ub, :Min)
    end
    params[:timelimit] = timelimit - time() + t0
    if length(bin_var_ind) == size(instance.A)[2]
        non_dom_sols = FPH(instance, model, starting_solutions, params)
    else
        non_dom_sols = FPH(instance, model, bin_var_ind, starting_solutions, params)
    end
    params[:timelimit] = timelimit
    non_dom_sols
end

@inbounds function FPH(instance::MOLPInstance, bin_var_ind::Vector{Int64}, pt_to_explore::Vector{Float64}, params)
    for i in 1:size(instance.c)[1]
        if pt_to_explore[i] != Inf
            instance.A = vcat(instance.A, -1.0*instance.c[i, :]')
            instance.cons_lb = vcat(instance.cons_lb, -1.0*pt_to_explore[i])
            instance.cons_ub = vcat(instance.cons_ub, Inf)	
        end
    end
    FPH(instance, bin_var_ind, params)
end

@inbounds function FPH(instance::BOLPInstance, bin_var_ind::Vector{Int64}, pt_to_explore::Vector{Float64}, params)
    for i in 1:2
        if pt_to_explore[i] != Inf
            if i == 1
                instance.A = vcat(instance.A, -1.0*instance.c1')
            else
                instance.A = vcat(instance.A, -1.0*instance.c2')
            end
            instance.cons_lb = vcat(instance.cons_lb, -1.0*pt_to_explore[i])
            instance.cons_ub = vcat(instance.cons_ub, Inf)
        end
    end
    FPH(instance, bin_var_ind, params)
end

@inbounds function FPH(instance::Union{MOLPInstance, BOLPInstance}, bin_var_ind::Vector{Int64}, pts_to_explore::Vector{Vector{Float64}}, params)
    if typeof(instance) == MOLPInstance
        sols = MOPSolution[]
    else
        sols = BOPSolution[]
    end
    for i in 1:length(pts_to_explore)
        tmp = FPH(instance, bin_var_ind, pts_to_explore[i], params)
        if length(tmp) >= 1
            push!(sols, tmp...)
        end
    end
    select_non_dom_sols(sols)
end
