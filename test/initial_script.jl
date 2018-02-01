using Modof, JuMP, FPBH

model = ModoModel()
@variable(model, x[1:4], Bin)
objective!(model, 1, :Min, x[1] + x[2] + x[3] + x[4])
objective!(model, 2, :Max, x[1] + x[2] + x[3] + x[4])
@constraint(model, x[1] + x[2] + x[3] + x[4] <= 3)

@time solution = fpbh(model)

nondominated_frontier = wrap_sols_into_array(solution)
nondominated_frontier[:, 2] = -1.0*nondominated_frontier[:, 2]
#println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(nondominated_frontier))")

model = ModoModel()
@variable(model, x[1:4], Bin)
objective!(model, 1, :Min, x[1] + x[2] + x[3] + x[4])
objective!(model, 2, :Max, x[1] + x[2] + x[3] + x[4])
objective!(model, 3, :Min, x[1] + 2x[2] + 3x[3] + 4x[4])
@constraint(model, x[1] + x[2] + x[3] + x[4] <= 3)

@time solution = fpbh(model)

nondominated_frontier = wrap_sols_into_array(solution)
nondominated_frontier[:, 2] = -1.0*nondominated_frontier[:, 2]
#println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(nondominated_frontier))")

model = ModoModel()
@variable(model, x[1:2], Bin)
@variable(model, y[1:2] >= 0.0)
objective!(model, 1, :Min, x[1] + x[2] + y[1] + y[2])
objective!(model, 2, :Max, x[1] + x[2] + y[1] + y[2])
@constraint(model, x[1] + x[2] <= 1) 
@constraint(model, 2.72y[1] + 7.39y[2] >= 1) 

@time solution = fpbh(model)

nondominated_frontier = wrap_sols_into_array(solution)
nondominated_frontier[:, 2] = -1.0*nondominated_frontier[:, 2]
#println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(nondominated_frontier))")

model = ModoModel()
@variable(model, x[1:2], Bin)
@variable(model, y[1:2] >= 0.0)
objective!(model, 1, :Min, x[1] + x[2] + y[1] + y[2])
objective!(model, 2, :Max, x[1] + x[2] + y[1] + y[2])
objective!(model, 3, :Min, x[1] + 2x[2] + y[1] + 2y[2])
@constraint(model, x[1] + x[2] <= 1) 
@constraint(model, 2.72y[1] + 7.39y[2] >= 1)
 
@time solution = fpbh(model)

nondominated_frontier = wrap_sols_into_array(solution)
nondominated_frontier[:, 2] = -1.0*nondominated_frontier[:, 2]
#println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(nondominated_frontier))")
