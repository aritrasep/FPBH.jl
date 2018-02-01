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
# Scatter Solutions for Multiobjective and Biobjective              #
# Mixed Integer Programs by fixing the Binary Variables             #
#####################################################################

@inbounds function scatter_solutions_for_fph(instance::Union{MOLPInstance, BOLPInstance}, bin_var_ind::Vector{Int64}, starting_solutions::Union{Vector{MOPSolution}, Vector{BOPSolution}}, params)
    t0 = time()
    p = 2
    m, n = size(instance.A)
    instance2 = copy(instance)
    cont_var_ind = setdiff([1:size(instance.A)[2]...], bin_var_ind)
    instance2.v_lb = instance2.v_lb[cont_var_ind]
    instance2.v_ub = instance2.v_ub[cont_var_ind]
    if typeof(instance) == MOLPInstance
        p = size(instance.c)[1]
        instance2.c = instance2.c[:, cont_var_ind]
    else
        instance2.c1 = instance2.c1[cont_var_ind]
        instance2.c2 = instance2.c2[cont_var_ind]	
    end
    unique_bin_vars = Vector{Float64}[]
    for i in 1:length(starting_solutions)
        if starting_solutions[i].vars[bin_var_ind] in unique_bin_vars
        else
            push!(unique_bin_vars, starting_solutions[i].vars[bin_var_ind])
        end
    end
    num = minimum([ceil((10/p)*ceil(log2(n>=m?n:m)/log2(p))), ceil(100/p)])
    for i in 1:length(unique_bin_vars)
        if time()-t0 > params[:timelimit]
            break
        end
        cont_vars = instance2.A[:, bin_var_ind] * unique_bin_vars[i]
        instance3 = copy(instance2)
        instance3.A = instance2.A[:, cont_var_ind]
        instance3.cons_lb -= cont_vars
        instance3.cons_ub -= cont_vars
        tmp = generate_starting_solutions_for_fph(instance3, params[:solver], ceil(Int64, num/length(unique_bin_vars)), params[:timelimit] - time() + t0)
        for j in 1:length(tmp)
            vars = zeros(size(instance.A)[2])
            vars[cont_var_ind] = tmp[j].vars
            vars[bin_var_ind] = unique_bin_vars[i]
            tmp[j].vars = vars
            compute_objective_function_value!(tmp[j], instance)
            push!(starting_solutions, tmp[j])
        end
    end
    select_unique_sols(starting_solutions)
end

#####################################################################
# Local Search Operators                                            #
#####################################################################

#####################################################################
## ONE_OPT                                                         ##
#####################################################################

@inbounds function return_queue_for_local_search_operators(new_non_dom_sols_found::Union{Vector{MOPSolution}, Vector{BOPSolution}}, already_explored_non_dom_sols::Union{Vector{MOPSolution}, Vector{BOPSolution}})
    tmp = select_non_dom_sols([new_non_dom_sols_found..., already_explored_non_dom_sols...])
    ind1, ind2 = Int64[], Int64[]
    if typeof(already_explored_non_dom_sols[1]) == MOPSolution
        for i in 1:length(tmp)
            for j in 1:length(already_explored_non_dom_sols)
                if j in ind1
                    continue
                end
                if tmp[i].obj_vals == already_explored_non_dom_sols[j].obj_vals
                    push!(ind1, j)
                    break
                end
                if j == length(already_explored_non_dom_sols)
                    push!(ind2, i)
                end
            end
        end
    else
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
    end
    tmp[ind2], tmp
end

#####################################################################
### Multiobjective Mixed Binary Programs                          ###
#####################################################################

@inbounds function ONE_OPT(instance::MOLPInstance, bin_var_ind::Vector{Int64}, starting_solution::MOPSolution)
    slack = (instance.A * starting_solution.vars) - instance.cons_lb
    equality_cons = instance.cons_ub - instance.cons_lb
    order = sortrows(hcat(slack, collect(1:length(slack))))
    inds = Int64[]
    for i in bin_var_ind
        if starting_solution.vars[i] == 1.0
            if true in (instance.c[:, i] .> 0.0)
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
            if true in (instance.c[:, i] .< 0.0)
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
    non_dom_sols = MOPSolution[]
    
    for i in bin_var_ind
        if i in inds
            continue
        end
        tmp1 = copy(starting_solution.vars)
        tmp1[i] = 1.0-tmp1[i]
        tmp2 = MOPSolution(vars=tmp1)
        compute_objective_function_value!(tmp2, instance)
        push!(non_dom_sols, tmp2)
    end
    non_dom_sols
end

#####################################################################
### Multiobjective Pure Binary Programs                           ###
#####################################################################

@inbounds function ONE_OPT(instance::MOLPInstance, starting_solution::MOPSolution)
    slack = (instance.A * starting_solution.vars) - instance.cons_lb
    equality_cons = instance.cons_ub - instance.cons_lb
    order = sortrows(hcat(slack, collect(1:length(slack))))
    inds = Int64[]
    for i in 1:length(starting_solution.vars)
        if starting_solution.vars[i] == 1.0
            if true in (instance.c[:, i] .> 0.0)
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
            if true in (instance.c[:, i] .< 0.0)
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
    non_dom_sols = MOPSolution[]
    for i in 1:length(starting_solution.vars)
        if i in inds
            continue
        end
        tmp1 = copy(starting_solution.vars)
        tmp1[i] = 1.0-tmp1[i]
        tmp2 = MOPSolution(vars=tmp1)
        compute_objective_function_value!(tmp2, instance)
        push!(non_dom_sols, tmp2)
    end
    non_dom_sols
end

#####################################################################
### Biobjective Mixed Binary Programs                             ###
#####################################################################

@inbounds function ONE_OPT(instance::BOLPInstance, bin_var_ind::Vector{Int64}, starting_solution::BOPSolution)
    slack = (instance.A * starting_solution.vars) - instance.cons_lb
    equality_cons = instance.cons_ub - instance.cons_lb
    order = sortrows(hcat(slack, collect(1:length(slack))))
    inds = Int64[]
    for i in bin_var_ind
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
    non_dom_sols = BOPSolution[]
    for i in bin_var_ind
        if i in inds
            continue
        end
        tmp1 = copy(starting_solution.vars)
        tmp1[i] = 1.0-tmp1[i]
        tmp2 = BOPSolution(vars=tmp1)
        compute_objective_function_value!(tmp2, instance)
        push!(non_dom_sols, tmp2)
    end
    non_dom_sols
end

#####################################################################
### Biobjective Pure Binary Programs                              ###
#####################################################################

@inbounds function ONE_OPT(instance::BOLPInstance, starting_solution::BOPSolution)
    slack = (instance.A * starting_solution.vars) - instance.cons_lb
    equality_cons = instance.cons_ub - instance.cons_lb
    order = sortrows(hcat(slack, collect(1:length(slack))))
    inds = Int64[]
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
    non_dom_sols = BOPSolution[]
    for i in 1:length(starting_solution.vars)
        if i in inds
            continue
        end
        tmp1 = copy(starting_solution.vars)
        tmp1[i] = 1.0-tmp1[i]
        tmp2 = BOPSolution(vars=tmp1)
        compute_objective_function_value!(tmp2, instance)
        push!(non_dom_sols, tmp2)
    end
    non_dom_sols
end

#####################################################################
### Mixed Binary Programs                                         ###
#####################################################################

@inbounds function ONE_OPT(instance::Union{MOLPInstance, BOLPInstance}, bin_var_ind::Vector{Int64}, starting_solutions::Union{Vector{MOPSolution}, Vector{BOPSolution}}, params::Dict{Any,Any})
    t0 = time()
    starting_solutions = scatter_solutions_for_fph(instance, bin_var_ind, starting_solutions, params)
    percent_eq_cons = (size(instance.A)[1] - length(findn(instance.cons_ub-instance.cons_lb)))/(size(instance.A)[1])
    if percent_eq_cons >= 0.95 || params[:timelimit] <= (time()-t0) 
        return starting_solutions
    end
    sols_to_explore, non_dom_sols = starting_solutions, starting_solutions
    sols_to_explore = sols_to_explore[shuffle([1:length(sols_to_explore)...])]
    i = 1
    if typeof(starting_solutions[1]) == MOPSolution
        tmp = MOPSolution[]
    end
    if typeof(starting_solutions[1]) == BOPSolution
        tmp = BOPSolution[]
    end
    timelimit = params[:timelimit]
    while i <= length(sols_to_explore) && time()-t0 <= timelimit
        tmp2 = ONE_OPT(instance, bin_var_ind, sols_to_explore[i])
        if length(tmp2) >= 1
            push!(tmp, tmp2...)
        end
        i += 1
        if i == length(sols_to_explore)+1
            sols_to_explore, non_dom_sols = return_queue_for_local_search_operators(tmp, non_dom_sols)
            sols_to_explore = sols_to_explore[shuffle([1:length(sols_to_explore)...])]
            i = 1
        end
    end
    [non_dom_sols..., tmp...]
end

#####################################################################
### Pure Binary Programs                                          ###
#####################################################################

@inbounds function ONE_OPT(instance::Union{MOLPInstance, BOLPInstance}, starting_solutions::Union{Vector{MOPSolution}, Vector{BOPSolution}}, params::Dict{Any,Any})
    t0 = time()
    percent_eq_cons = (size(instance.A)[1] - length(findn(instance.cons_ub-instance.cons_lb)))/(size(instance.A)[1])
    if percent_eq_cons >= 0.95 || params[:timelimit] <= (time()-t0) 
        return starting_solutions
    end
    sols_to_explore, non_dom_sols = starting_solutions, starting_solutions
    sols_to_explore = sols_to_explore[shuffle([1:length(sols_to_explore)...])]
    i = 1
    if typeof(starting_solutions[1]) == MOPSolution
        tmp = MOPSolution[]
    end
    if typeof(starting_solutions[1]) == BOPSolution
        tmp = BOPSolution[]
    end
    timelimit = params[:timelimit]
    while i <= length(sols_to_explore) && time()-t0 <= timelimit
        tmp2 = ONE_OPT(instance, sols_to_explore[i])
        if length(tmp2) >= 1
            push!(tmp, tmp2...)
        end
        i += 1
        if i == length(sols_to_explore)+1
            sols_to_explore, non_dom_sols = return_queue_for_local_search_operators(tmp, non_dom_sols)
            sols_to_explore = sols_to_explore[shuffle([1:length(sols_to_explore)...])]
            i = 1
        end
    end
    [non_dom_sols..., tmp...]
end
