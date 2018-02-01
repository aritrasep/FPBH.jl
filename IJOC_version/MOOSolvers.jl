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

VERSION >= v"0.5.0"

module MOOSolvers

export lex_min, weighted_sum_method, feasibility_pump_heuristic, FPH1, FPH2, modified_perpendicular_search_method, MPSM, parallel_modified_perpendicular_search_method, PMPSM, nsgaii

using MOOFramework, MathProgBase, Match, Combinatorics, DataStructures

global path = Pkg.dir("MOOAlgos.jl")
f = open("$(path)/deps/NSGA-II/run_nsga_ii.sh", "w")
write(f, "$(path)/deps/NSGA-II/nsga2r 0.5 <$(path)/deps/NSGA-II/Parameter.in & pid=\$!\n")
write(f, "for ((i=1; i<= \$1; i++))\n")
write(f, "do\n")
write(f, "if [ -e /proc/\$pid ]\n")
write(f, "then\n")
write(f, "sleep 0.001\n")
write(f, "else\n")
write(f, "break\n")
write(f, "fi\n")
write(f, "done\n")
write(f, "if [ -e /proc/\$pid ]\n")
write(f, "then\n")
write(f, "kill -9 \$pid\n")
write(f, "fi\n")
close(f)

include("./Algorithms/lexicographic_methods.jl")
include("./Algorithms/weighted_sum_method.jl")
include("./Algorithms/feasibility_pump_heuristic.jl")
include("./Algorithms/local_search_operators.jl")
include("./Algorithms/perpendicular_search_method.jl")
include("./Algorithms/nsga2.jl")

end
