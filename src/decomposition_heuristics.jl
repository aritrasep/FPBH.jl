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
# Bi-Objective Pure and Mixed Binary Programs                       #
#####################################################################

#####################################################################
## Modified Perpendicular Search Method                            ##
#####################################################################

@inbounds function return_queue_for_modified_perpendicular_search_method(new_non_dom_sols_found::Vector{BOPSolution}, already_explored_non_dom_sols::Vector{BOPSolution}, timelimit::Float64)
    t0 = time()
    tmp = select_and_sort_non_dom_sols([new_non_dom_sols_found..., already_explored_non_dom_sols...])
    pts_to_explore = Vector{Float64}[]
    last_obj_val2 = Inf
    for i in 1:length(tmp)
        if time() - t0 >= timelimit
            break
        end
        current_pt_already_explored = false
        if length(already_explored_non_dom_sols) >= 1
            j = 1
            while j <= length(already_explored_non_dom_sols)
                if tmp[i].obj_val1 == already_explored_non_dom_sols[j].obj_val1 && tmp[i].obj_val2 == already_explored_non_dom_sols[j].obj_val2
                    deleteat!(already_explored_non_dom_sols, j)
                    current_pt_already_explored = true
                else
                    j += 1
                end
            end
        end
        if !current_pt_already_explored
            if i == 1
                push!(pts_to_explore, [tmp[i].obj_val1, Inf])
            else
                push!(pts_to_explore, [tmp[i].obj_val1, tmp[i-1].obj_val2])
            end
            last_obj_val2 = tmp[i].obj_val2
        end
    end
    if last_obj_val2 != Inf
        push!(pts_to_explore, [Inf, last_obj_val2])
    end
    pts_to_explore = pts_to_explore[shuffle([1:length(pts_to_explore)...])]
    (pts_to_explore, tmp)
end

@inbounds function modified_perpendicular_search_method(instance::BOLPInstance, bin_var_ind::Vector{Int64}, pts_to_explore::Vector{Vector{Float64}}, params)
    t0 = time()
    non_dom_sols = BOPSolution[]
    sols_to_explore = BOPSolution[]
    pos1, pos2 = length(instance.cons_lb), length(instance.cons_lb)
    timelimit = params[:timelimit]
    while length(pts_to_explore) >= 1 && time()-t0 <= timelimit
        params[:timelimit] = (timelimit - (time()-t0))/length(pts_to_explore)
        if length(pts_to_explore) == 1 && pts_to_explore[1] == [Inf, Inf]
            params[:timelimit] = params[:timelimit] / 10.0
        end
        current_pt_to_explore = splice!(pts_to_explore, 1)
        for i in 1:2
            if current_pt_to_explore[i] != Inf
                if i == 1
                    instance.A = vcat(instance.A, -1.0*instance.c1')
                else
                    instance.A = vcat(instance.A, -1.0*instance.c2')
                end
                instance.cons_lb = vcat(instance.cons_lb, -1.0*current_pt_to_explore[i])
                instance.cons_ub = vcat(instance.cons_ub, Inf)
                pos2 += 1
            end
        end
        tmp = FPH(instance, bin_var_ind, params)
        if length(tmp) >= 1
            push!(sols_to_explore, tmp...)
        end
        if pos1 < pos2
            instance.A = instance.A[1:pos1,:]
            instance.cons_lb = instance.cons_lb[1:pos1]
            instance.cons_ub = instance.cons_ub[1:pos1]
            pos2 = pos1
        end
        if length(pts_to_explore) == 0 && length(sols_to_explore) >= 1
            pts_to_explore, non_dom_sols = return_queue_for_modified_perpendicular_search_method(sols_to_explore, non_dom_sols, (timelimit - (time()-t0))/3)
            sols_to_explore = BOPSolution[]
        end
    end
    params[:timelimit] = timelimit
    [non_dom_sols..., sols_to_explore...]
end

#####################################################################
## Parallel Modified Perpendicular Search Method                   ##
#####################################################################

@inbounds function parallel_modified_perpendicular_search_method(instance::BOLPInstance, bin_var_ind::Vector{Int64}, params)
    t0 = time()
    pts_to_explore = [[Inf, Inf]]
    non_dom_sols = BOPSolution[]
    sols_to_explore = BOPSolution[]
    procs_ = setdiff(procs(), myid())[1:params[:total_threads]]
    timelimit = params[:timelimit]
    tmp = fill(BOPSolution[], length(procs_))
    while length(pts_to_explore) >= 1 && time()-t0 <= timelimit
        params[:timelimit] = (timelimit - (time()-t0))/length(pts_to_explore)
        params[:timelimit] = params[:timelimit] * params[:total_threads]
        if length(pts_to_explore) == 1 && pts_to_explore[1] == [Inf, Inf]
            params[:timelimit] = params[:timelimit] / 10.0
        end
        @sync begin
            for i in 1:length(procs_)
                @async begin
                    if length(pts_to_explore) >= 1
                        tmp[i] = remotecall_fetch(FPH, procs_[i], copy(instance), bin_var_ind, splice!(pts_to_explore, 1), params)
                    end
                end
            end
        end
        for i in 1:length(procs_)
            if length(tmp[i]) >= 1
                push!(sols_to_explore, tmp[i]...)
            end
        end
        if length(pts_to_explore) == 0 && length(sols_to_explore) >= 1
            pts_to_explore, non_dom_sols = return_queue_for_modified_perpendicular_search_method(sols_to_explore, non_dom_sols, (timelimit - (time()-t0))/3)
            sols_to_explore = BOPSolution[]
        end
    end
    [non_dom_sols..., sols_to_explore...]
end

@inbounds function modified_perpendicular_search_method(instance::BOLPInstance, bin_var_ind::Vector{Int64}, params)
    pts_to_explore = [[Inf, Inf]]
    modified_perpendicular_search_method(instance, bin_var_ind, pts_to_explore, params)
end

@inbounds function MPSM(instance::BOLPInstance, bin_var_ind::Vector{Int64}, params)
    if params[:total_threads] == 1 && !params[:parallelism]
        modified_perpendicular_search_method(instance, bin_var_ind, params)
    else
        parallel_modified_perpendicular_search_method(instance, bin_var_ind, params)
    end
end

#####################################################################
# Multiobjective Pure or Mixed Binary Programs                      #
#####################################################################

#####################################################################
## Modified Full P Split Method                                    ##
#####################################################################

@inbounds function return_queue_for_modified_full_p_split_method(new_non_dom_sols_found::Vector{MOPSolution}, already_explored_non_dom_sols::Vector{MOPSolution}, timelimit::Float64)
    t0 = time()
    new_non_dom_sols_found = select_non_dom_sols(new_non_dom_sols_found)
    ind1, ind2 = Int64[], Int64[]
    for i in 1:length(already_explored_non_dom_sols)
        if time() - t0 > timelimit
            break
        end
        for j in 1:length(new_non_dom_sols_found)
            dom1, dom2 = check_dominance(already_explored_non_dom_sols[i].obj_vals, new_non_dom_sols_found[j].obj_vals)
            if dom2
                push!(ind2, j)
            end
            if dom1
                push!(ind1, i)
                break
            end
        end
    end
    already_explored_non_dom_sols = already_explored_non_dom_sols[setdiff([1:length(already_explored_non_dom_sols)...], ind1)]
    new_non_dom_sols_found = new_non_dom_sols_found[setdiff([1:length(new_non_dom_sols_found)...], ind2)]
    tmp = [new_non_dom_sols_found..., already_explored_non_dom_sols...]
    if time() - t0 > timelimit || length(new_non_dom_sols_found) == 0
        return (Vector{Float64}[], tmp)
    end
    
    #################################################################
    ## Removing Dominated Boxes                                    ##
    #################################################################
    
    p = length(tmp[1].obj_vals)
    pts_to_explore = [fill(Inf, p)]
    for i in 1:length(new_non_dom_sols_found)
        new_pts = Vector{Float64}[]
        j = 1
        while j <= length(pts_to_explore)
            if time() - t0 > timelimit
                break
            end
            dom1, dom2 = check_dominance(new_non_dom_sols_found[i].obj_vals, pts_to_explore[j])
            if dom2
                for k in 1:p
                    push!(new_pts, pts_to_explore[j])
                    new_pts[end][k] = new_non_dom_sols_found[i].obj_vals[k]
                end
                splice!(pts_to_explore, j)
            else
                j += 1
            end
        end
        if time() - t0 > timelimit
            if length(new_pts) > 0
                push!(pts_to_explore, new_pts...)
            end
            break
        end
        #############################################################
        ## Removing Smaller Boxes                                  ##
        #############################################################
        j = 1
        while j <= length(new_pts)-1
            if time() - t0 > timelimit
                break
            end
            k = j+1
            while k <= length(new_pts)
                if time() - t0 > timelimit
                    break
                end
                dom1, dom2 = check_dominance(new_pts[j], new_pts[k])
                if dom1
                    splice!(new_pts, k)
                else
                    k += 1
                    if dom2
                        splice!(new_pts, j)
                        break
                    end
                end
                if k == length(new_pts)+1
                    j += 1
                end
            end
        end
        if time() - t0 > timelimit
            if length(new_pts) > 0
                push!(pts_to_explore, new_pts...)
            end
            break
        end
        push!(pts_to_explore, new_pts...)
    end
    (pts_to_explore[shuffle([1:length(pts_to_explore)...])], tmp)
end

@inbounds function modified_full_p_split_method(instance::MOLPInstance, bin_var_ind::Vector{Int64}, pts_to_explore::Vector{Vector{Float64}}, params)
    t0 = time()
    p = size(instance.c)[1]
    non_dom_sols = MOPSolution[]
    sols_to_explore = MOPSolution[]
    pos1, pos2 = length(instance.cons_lb), length(instance.cons_lb)
    timelimit = params[:timelimit]
    while length(pts_to_explore) >= 1 && time()-t0 <= timelimit
        params[:timelimit] = (timelimit - (time()-t0))/length(pts_to_explore)
        if length(pts_to_explore) == 1 && pts_to_explore[1] == fill(Inf, size(instance.c)[1])
            params[:timelimit] = params[:timelimit] / 10.0
        end
        current_pt_to_explore = splice!(pts_to_explore, 1)
        for i in 1:p
            if current_pt_to_explore[i] != Inf
                instance.A = vcat(instance.A, -1.0*instance.c[i, :]')
                instance.cons_lb = vcat(instance.cons_lb, -1.0*current_pt_to_explore[i])
                instance.cons_ub = vcat(instance.cons_ub, Inf)
                pos2 += 1
            end
        end
        tmp = FPH(instance, bin_var_ind, params)
        if length(tmp) >= 1
            push!(sols_to_explore, tmp...)
        end
        if pos1 < pos2
            instance.A = instance.A[1:pos1,:]
            instance.cons_lb = instance.cons_lb[1:pos1]
            instance.cons_ub = instance.cons_ub[1:pos1]
            pos2 = pos1
        end
        if length(pts_to_explore) == 0 && length(sols_to_explore) >= 1
            pts_to_explore, non_dom_sols = return_queue_for_modified_full_p_split_method(sols_to_explore, non_dom_sols, (timelimit - (time()-t0))/3)
            sols_to_explore = MOPSolution[]
        end
    end
    params[:timelimit] = timelimit
    if length(non_dom_sols) >= 1 || length(sols_to_explore) >= 1
        select_non_dom_sols([non_dom_sols..., sols_to_explore...])
    else
        non_dom_sols
    end
end

#####################################################################
## Parallel Modified P Split Search Method                         ##
#####################################################################

@inbounds function parallel_modified_full_p_split_method(instance::MOLPInstance, bin_var_ind::Vector{Int64}, params)
    t0 = time()
    pts_to_explore = [fill(Inf, size(instance.c)[1])]
    non_dom_sols = MOPSolution[]
    sols_to_explore = MOPSolution[]
    procs_ = setdiff(procs(), myid())[1:params[:total_threads]]
    timelimit = params[:timelimit]
    tmp = fill(MOPSolution[], length(procs_))
    while length(pts_to_explore) >= 1 && time()-t0 <= timelimit
        params[:timelimit] = (timelimit - (time()-t0))/length(pts_to_explore)
        params[:timelimit] = params[:timelimit] * params[:total_threads]	
        if length(pts_to_explore) == 1 && pts_to_explore[1] == fill(Inf, size(instance.c)[1])
            params[:timelimit] = params[:timelimit] / 10.0
        end
        @sync begin
            for i in 1:length(procs_)
                @async begin
                    if length(pts_to_explore) >= 1
                        tmp[i] = remotecall_fetch(FPH, procs_[i], copy(instance), bin_var_ind, splice!(pts_to_explore, 1), params)
                    end
                end
            end
        end
        for i in 1:length(procs_)
            if length(tmp[i]) >= 1
                push!(sols_to_explore, tmp[i]...)
            end
        end
        if length(pts_to_explore) == 0 && length(sols_to_explore) >= 1
            pts_to_explore, non_dom_sols = return_queue_for_modified_full_p_split_method(sols_to_explore, non_dom_sols, (timelimit - (time()-t0))/3)
            sols_to_explore = MOPSolution[]
        end
    end
    params[:timelimit] = timelimit
    if length(non_dom_sols) >= 1 || length(sols_to_explore) >= 1
        select_non_dom_sols([non_dom_sols..., sols_to_explore...])
    else
        non_dom_sols
    end
end

@inbounds function modified_full_p_split_method(instance::MOLPInstance, bin_var_ind::Vector{Int64}, params)
    pts_to_explore = [fill(Inf, size(instance.c)[1])]
    modified_full_p_split_method(instance, bin_var_ind, pts_to_explore, params)
end

@inbounds function MFPSM(instance::MOLPInstance, bin_var_ind::Vector{Int64}, params)
    if params[:total_threads] == 1 && !params[:parallelism]
        modified_full_p_split_method(instance, bin_var_ind, params)
    else
        parallel_modified_full_p_split_method(instance, bin_var_ind, params)
    end
end
