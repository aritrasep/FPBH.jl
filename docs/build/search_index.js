var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#FPBH:-A-Feasibility-Pump-based-Heuristic-for-Multi-objective-Mixed-Integer-Linear-Programming-1",
    "page": "Home",
    "title": "FPBH: A Feasibility Pump based Heuristic for Multi-objective Mixed Integer Linear Programming",
    "category": "section",
    "text": "This is a LP based heuristic for computing an approximate nondominated frontier of a Multi-objective Mixed Integer Linear Program. Important characteristics of this heuristic are:Can solve any (both structured and unstructured) multiobjective mixed integer linear problem. The following problem classes are supported:\nObjectives: 2 or more linear objectives\nConstraints: 0 or more linear (both inequality and equality) constraints\nVariables:\nBinary\nInteger variables (via reformulation into binary variables)\nContinuous + Binary\nContinuous + Integer variables (via reformulation into binary variables)\nA multiobjective mixed integer linear instance can be provided as a input in 4 ways:\nModoModel - an extension of JuMP Model\nLP file format\nMPS file format\nMatrix Format ( Advanced )\nAny linear programming solver supported by MathProgBase.jl can be used. No mixed integer programming solver is required. FPBH.jl automatically installs GLPK and Clp by default. If the user desires to use any other LP solver, it must be separately installed. FPBH.jl has been successfully tested with:\nGLPK - v4.61\nClp - v1.16\nSCIP - v4.0.0\nGurobi - v7.5\nCPLEX - v12.7. If CPLEX is available, we highly recommend using FPBHCPLEX.jl instead.\nAll parameters are already tuned, only timelimit is required.\nSupports parallelization"
},

{
    "location": "index.html#Contents:-1",
    "page": "Home",
    "title": "Contents:",
    "category": "section",
    "text": "Pages = [\"installation.md\", \"getting_started.md\", \"advanced.md\", \"solving_instances_from_literature.md\"]"
},

{
    "location": "index.html#Supporting-and-Citing:-1",
    "page": "Home",
    "title": "Supporting and Citing:",
    "category": "section",
    "text": "The software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use Modof.jl, Modolib.jl, FPBH.jl, FPBHCPLEX.jl or pyModofSup.jl software as part of your research, teaching, or other activities, we would be grateful if you could cite:Pal, A. and Charkhgard, H., A Feasibility Pump and Local Search Based Heuristic for Bi-objective Pure Integer Linear Programming.\nPal, A. and Charkhgard, H., FPBH.jl: A Feasibility Pump based Heuristic for Multi-objective Mixed Integer Linear Programming in Julia"
},

{
    "location": "index.html#Contributions-1",
    "page": "Home",
    "title": "Contributions",
    "category": "section",
    "text": "This package is written and maintained by Aritra Pal. Please fork and send a pull request or create a GitHub issue for bug reports or feature requests."
},

{
    "location": "installation.html#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "installation.html#Installation:-1",
    "page": "Installation",
    "title": "Installation:",
    "category": "section",
    "text": "It is important to note that the whole ecosystem has been tested using Julia v0.6.0 and hence we can cannot guarantee whether it will work with previous versions of Julia. Thus, it is important that Julia v0.6.0 is properly installed and available on your system."
},

{
    "location": "installation.html#If-CPLEX-is-available:-1",
    "page": "Installation",
    "title": "If CPLEX is available:",
    "category": "section",
    "text": "CPLEX must be available in the local machine and CPLEX.jl must be properly installed, otherwise the installation will fail. Once, Julia v0.6.0 and CPLEX.jl has been properly installed, the following instructions in a Julia terminal will install FPBHCPLEX.jl and its dependencies (Modof.jl, Modolib.jl, FPBH.jl and CPLEXExtensions.jl) on the local machine:Pkg.clone(\"https://github.com/aritrasep/FPBHCPLEX.jl\")\nPkg.build(\"FPBHCPLEX\")In case Pkg.build(\"FPBHCPLEX\") gives you an error on Linux, you may need to install the GMP library headers. For example, on Ubuntu/Debian and similar, give the following command from a terminal:$ sudo apt-get install libgmp-devAfter that, restart the installation of the package with:Pkg.build(\"FPBHCPLEX\")"
},

{
    "location": "installation.html#If-CPLEX-is-not-available:-1",
    "page": "Installation",
    "title": "If CPLEX is not available:",
    "category": "section",
    "text": "If CPLEX is not available, FPBH.jl can be installed instead of FPBHCPLEX.jl. Once, Julia v0.6.0 has been properly installed, the following instructions in a Julia terminal will install FPBH.jl and its dependencies (Modof.jl, and Modolib.jl) on the local machine:Pkg.clone(\"https://github.com/aritrasep/FPBH.jl\")\nPkg.build(\"FPBH\")In case Pkg.build(\"FPBH\") gives you an error on Linux, you may need to install the GMP library headers. For example, on Ubuntu/Debian and similar, give the following command from a terminal:$ sudo apt-get install libgmp-devAfter that, restart the installation of the package with:Pkg.build(\"FPBH\")None of the above will however install pyModofSup.jl, which must be installed separately if desired."
},

{
    "location": "getting_started.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "getting_started.html#Getting-Started-1",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "section",
    "text": "using Modof, JuMP, FPBH, GLPKMathProgInterface, Clp"
},

{
    "location": "getting_started.html#Warm-Up-FPBH:-1",
    "page": "Getting Started",
    "title": "Warm Up FPBH:",
    "category": "section",
    "text": "FPBH.jl has four implementations, one each for biobjective pure binary, biobjective mixed binary, multiobjective pure binary and multiobjective mixed binary program. Thus, it is recommended that before fpbh is used for any actual instance, warmup_fpbh is used to compile all of the four implementations."
},

{
    "location": "getting_started.html#Using-Clp-as-the-underlying-LP-Solver-to-warm-up-FPBH-1",
    "page": "Getting Started",
    "title": "Using Clp as the underlying LP Solver to warm up FPBH",
    "category": "section",
    "text": "warmup_fpbh(lp_solver=ClpSolver(), threads=1)"
},

{
    "location": "getting_started.html#Using-JuMP-Extension:-1",
    "page": "Getting Started",
    "title": "Using JuMP Extension:",
    "category": "section",
    "text": "Providing the following multi-objective mixed integer linear program as a ModoModel:beginaligned min   x_1 + x_2 + y_1 + y_2  max   x_1 + x_2 + y_1 + y_2  min   x_1 + 2x_2 + y_1 + 2y_2  textst   x_1 + x_2 leq 1   y_1 + 2y_2 geq 1   x_1 x_2 in 0 1   y_1 y_2 geq 0 endalignedmodel = ModoModel()\n@variable(model, x[1:2], Bin)\n@variable(model, y[1:2] >= 0.0)\nobjective!(model, 1, :Min, x[1] + x[2] + y[1] + y[2])\nobjective!(model, 2, :Max, x[1] + x[2] + y[1] + y[2])\nobjective!(model, 3, :Min, x[1] + 2x[2] + y[1] + 2y[2])\n@constraint(model, x[1] + x[2] <= 1) \n@constraint(model, y[1] + 2y[2] >= 1)Note: Currently constant terms in the objective functions are not supported"
},

{
    "location": "getting_started.html#Using-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-1",
    "page": "Getting Started",
    "title": "Using GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "@time solutions = fpbh(model, timelimit=10.0)"
},

{
    "location": "getting_started.html#Writing-nondominated-frontier-to-a-file-1",
    "page": "Getting Started",
    "title": "Writing nondominated frontier to a file",
    "category": "section",
    "text": "write_nondominated_frontier(solutions, \"nondominated_frontier.txt\")"
},

{
    "location": "getting_started.html#Writing-nondominated-solutions-to-a-file-1",
    "page": "Getting Started",
    "title": "Writing nondominated solutions to a file",
    "category": "section",
    "text": "write_nondominated_sols(solutions, \"nondominated_solutions.txt\")"
},

{
    "location": "getting_started.html#Nondominated-frontier-1",
    "page": "Getting Started",
    "title": "Nondominated frontier",
    "category": "section",
    "text": "nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "getting_started.html#Hypervolume-of-the-nondominated-frontier-1",
    "page": "Getting Started",
    "title": "Hypervolume of the nondominated frontier",
    "category": "section",
    "text": "For this functionality, pyModofSup.jl must be properly installed.using pyModofSupcompute_hypervolume_of_a_discrete_frontier can be used for computing the hypervolume of a nondominated frontier, however all the objectives must be minimizations. nondominated_frontier[:, 2] = -1.0*nondominated_frontier[:, 2] # Converting the second objective function values into minimization \ncompute_hypervolume_of_a_discrete_frontier(nondominated_frontier)"
},

{
    "location": "getting_started.html#Plotting-the-nondominated-frontier-1",
    "page": "Getting Started",
    "title": "Plotting the nondominated frontier",
    "category": "section",
    "text": "For this functionality, pyModofSup.jl must be properly installed.using pyModofSupIt is important to note that the plotting functions only work through IJulia. For just viewing the nondominated frontier, one can use the following instructions in an IJulia cell:nondominated_frontier = wrap_sols_into_array(solutions)\nplt_discrete_non_dom_frntr([nondominated_frontier], [\"FPBH(GLPK)\"])(Image: )However, if the user desires to save the plot of the nondominated frontier to a file (\"Plot1.png\" in this case), they can use the following instructions in a julia terminal: nondominated_frontier = wrap_sols_into_array(solutions)\nplt_discrete_non_dom_frntr([nondominated_frontier], [\"FPBH(GLPK)\"], false, \"Plot1.png\")"
},

{
    "location": "getting_started.html#Using-CLP-instead-of-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-1",
    "page": "Getting Started",
    "title": "Using CLP instead of GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "@time solutions = fpbh(model, lp_solver=ClpSolver(), timelimit=10.0)"
},

{
    "location": "getting_started.html#Using-LP-File-Format-1",
    "page": "Getting Started",
    "title": "Using LP File Format",
    "category": "section",
    "text": "Providing the following multiobjective mixed integer linear program as a LP file:beginaligned min   x_1 + x_2 + y_1 + y_2  max   x_1 + x_2 + y_1 + y_2  min   x_1 + 2x_2 + y_1 + 2y_2  textst   x_1 + x_2 leq 1   y_1 + 2y_2 geq 1   x_1 x_2 in 0 1   y_1 y_2 geq 0 endaligned"
},

{
    "location": "getting_started.html#Format:-1",
    "page": "Getting Started",
    "title": "Format:",
    "category": "section",
    "text": "The first objective function should follow the convention of LP format of single objective optimization problem\nThe other objective functions should be added as constraints with RHS = 0, at the end of the constraint matrix in the respective order\nVariables and constraints should also follow the convention of LP format of single objective optimization problemwrite(\"Test.lp\", \"\\\\ENCODING=ISO-8859-1\n\\\\Problem name: TestLPFormat\n\nMinimize\n obj: x1 + x2 + x3 + x4\nSubject To\n c1: x1 + x2 <= 1\n c2: x3 + 2 x4 >= 1\n c3: x1 + x2 + x3 + x4  = 0\n c4: x1 + 2 x2 + x3 + 2 x4  = 0\nBinaries\n x1  x2 \nEnd\\n\") # Writing the LP file of the above multiobjective mixed integer program to Test.lp"
},

{
    "location": "getting_started.html#Using-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-2",
    "page": "Getting Started",
    "title": "Using GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "The sense of the first objective function is automatically detected from the LP file, however the senses of the rest of the objective functions should be provided in the proper order.@time solutions = fpbh(\"Test.lp\", [:Max, :Min], timelimit=10.0)"
},

{
    "location": "getting_started.html#Using-CLP-instead-of-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-2",
    "page": "Getting Started",
    "title": "Using CLP instead of GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "@time solutions = fpbh(\"Test.lp\", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0)"
},

{
    "location": "getting_started.html#Using-MPS-File-Format-1",
    "page": "Getting Started",
    "title": "Using MPS File Format",
    "category": "section",
    "text": "Providing the following multiobjective mixed integer linear program as a MPS file:beginaligned min   x_1 + x_2 + y_1 + y_2  max   x_1 + x_2 + y_1 + y_2  min   x_1 + 2x_2 + y_1 + 2y_2  textst   x_1 + x_2 leq 1   y_1 + 2y_2 geq 1   x_1 x_2 in 0 1   y_1 y_2 geq 0 endaligned"
},

{
    "location": "getting_started.html#Format:-2",
    "page": "Getting Started",
    "title": "Format:",
    "category": "section",
    "text": "The first objective function should follow the convention of MPS format of single objective optimization problem\nThe other objective functions should be added as constraints with RHS = 0, at the end of the constraint matrix in the respective order\nVariables and constraints should also follow the convention of MPS format of single objective optimization problemwrite(\"Test.mps\", \"NAME   TestMPSFormat\nROWS\n N  OBJ\n L  CON1\n G  CON2\n E  CON3\n E  CON4\nCOLUMNS\n    MARKER    'MARKER'                 'INTORG'\n    VAR1  CON1  1\n    VAR1  CON3  1\n    VAR1  CON4  1\n    VAR1  OBJ  1\n    VAR2  CON1  1\n    VAR2  CON3  1\n    VAR2  CON4  2\n    VAR2  OBJ  1\n    MARKER    'MARKER'                 'INTEND'\n    VAR3  CON2  1\n    VAR3  CON3  1\n    VAR3  CON4  1\n    VAR3  OBJ  1\n    VAR4  CON2  2\n    VAR4  CON3  1\n    VAR4  CON4  2\n    VAR4  OBJ  1\nRHS\n    rhs    CON1    1\n    rhs    CON2    1\n    rhs    CON3    0\n    rhs    CON4    0\nBOUNDS\n  UP BOUND VAR1 1\n  UP BOUND VAR2 1\n  PL BOUND VAR3\n  PL BOUND VAR4\nENDATA\\n\") # Writing the MPS file of the above multiobjective mixed integer program to Test.mps"
},

{
    "location": "getting_started.html#Using-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-3",
    "page": "Getting Started",
    "title": "Using GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "The sense of the first objective function is automatically detected from the MPS file, however the senses of the rest of the objective functions should be provided in the proper order.@time solutions = fpbh(\"Test.mps\", [:Max, :Min], timelimit=10.0)"
},

{
    "location": "getting_started.html#Using-CLP-instead-of-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-3",
    "page": "Getting Started",
    "title": "Using CLP instead of GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "@time solutions = fpbh(\"Test.mps\", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0)"
},

{
    "location": "getting_started.html#Using-the-Matrix-Format-Advanced-1",
    "page": "Getting Started",
    "title": "Using the Matrix Format - Advanced",
    "category": "section",
    "text": ""
},

{
    "location": "advanced.html#",
    "page": "Advanced Features",
    "title": "Advanced Features",
    "category": "page",
    "text": ""
},

{
    "location": "advanced.html#Advanced-Features:-1",
    "page": "Advanced Features",
    "title": "Advanced Features:",
    "category": "section",
    "text": ""
},

{
    "location": "advanced.html#Using-multiple-processors:-1",
    "page": "Advanced Features",
    "title": "Using multiple processors:",
    "category": "section",
    "text": "To use multiple processors for solving an instance, start julia with the requisite number of workers. For example: if you want to use at most 4 workers start julia as julia -p 4, followed by either of the following three commands in the terminal depending on the input format chosen:@time solutions = fpbh(model, lp_solver=ClpSolver(), timelimit=10.0, threads=4)@time solutions = fpbh(\"Test.lp\", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0, threads=4)@time solutions = fpbh(\"Test.mps\", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0, threads=4)"
},

{
    "location": "advanced.html#Tuning-parameters-1",
    "page": "Advanced Features",
    "title": "Tuning parameters",
    "category": "section",
    "text": "FPBH has 5 components:Component Default status Turn on Turn off\nFeasibility Pump OFF obj_fph=false obj_fph=true\nObjective Feasibility Pump ON obj_fph=true obj_fph=false\n1-OPT Local Search ON local_search=true local_search=false\nStage 1 ( Decomposition ) ON decomposition=true decomposition=false\nStage 2 ( Solution Polishing ) ON solution_polishing=true solution_polishing=false\nTime ratio dfrac23 - -Note: Time ratio is the maximum fraction of the total timelimit available to Stage 1. It can take any value between 0 and 1 (both included).For example: If the user wants to switch off objective feasibility pump and local search, and decrease the time ratio to 0.5, it can be done so as:@time solutions = fpbh(model, obj_fph=false, local_search=false, time_ratio=0.5, timelimit=10.0)"
},

{
    "location": "solving_instances_from_literature.html#",
    "page": "Solving Instances from Literature",
    "title": "Solving Instances from Literature",
    "category": "page",
    "text": ""
},

{
    "location": "solving_instances_from_literature.html#Solving-multiobjective-optimization-instances-from-literature-using-[Modolib.jl](https://github.com/aritrasep/Modolib.jl):-1",
    "page": "Solving Instances from Literature",
    "title": "Solving multiobjective optimization instances from literature using Modolib.jl:",
    "category": "section",
    "text": "using Modolib"
},

{
    "location": "solving_instances_from_literature.html#Biobjective-assignment-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Biobjective assignment problems:",
    "category": "section",
    "text": "instance, true_frontier = read_boap_hadi(10)@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Computing-quality-of-the-frontier-w.r.t.-true-frontier-without-normalization-1",
    "page": "Solving Instances from Literature",
    "title": "Computing quality of the frontier w.r.t. true frontier without normalization",
    "category": "section",
    "text": "hg, c, mc, ac, u = compute_quality_of_apprx_frontier(nondominated_frontier, true_frontier)\nprintln(\"\n    Hypervolume Gap = $hg % \n    Cardinality = $c % \n    Maximum Coverage = $mc \n    Average Coverage = $ac \n    Uniformity = $u\")"
},

{
    "location": "solving_instances_from_literature.html#Computing-quality-of-the-frontier-w.r.t.-true-frontier-with-normalization-1",
    "page": "Solving Instances from Literature",
    "title": "Computing quality of the frontier w.r.t. true frontier with normalization",
    "category": "section",
    "text": "hg, c, mc, ac, u = compute_quality_of_norm_apprx_frontier(nondominated_frontier, true_frontier)\nprintln(\"\n    Hypervolume Gap = $hg % \n    Cardinality = $c % \n    Maximum Coverage = $mc \n    Average Coverage = $ac \n    Uniformity = $u\")"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-true-frontier-1",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the true frontier",
    "category": "section",
    "text": "plt_discrete_non_dom_frntr([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"], false, \"Plot2.png\")(Image: Plot2.png)"
},

{
    "location": "solving_instances_from_literature.html#Biobjective-1-D-knapsack-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Biobjective 1-D knapsack problems:",
    "category": "section",
    "text": "instance, true_frontier = read_bokp_xavier1(\"2KP150-1A\")@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-true-frontier-2",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the true frontier",
    "category": "section",
    "text": "plt_discrete_non_dom_frntr([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"], false, \"Plot3.png\")(Image: Plot3.png)"
},

{
    "location": "solving_instances_from_literature.html#Biobjective-2-D-knapsack-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Biobjective 2-D knapsack problems:",
    "category": "section",
    "text": "instance, true_frontier = read_bokp_hadi(1)@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-true-frontier-3",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the true frontier",
    "category": "section",
    "text": "plt_discrete_non_dom_frntr([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"], false, \"Plot4.png\")(Image: Plot4.png)"
},

{
    "location": "solving_instances_from_literature.html#Biobjective-set-covering-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Biobjective set covering problems:",
    "category": "section",
    "text": "instance, true_frontier = read_boscp_xavier(100, 10, \"a\")@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-true-frontier-4",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the true frontier",
    "category": "section",
    "text": "plt_discrete_non_dom_frntr([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"], false, \"Plot5.png\")(Image: Plot5.png)"
},

{
    "location": "solving_instances_from_literature.html#Biobjective-set-packing-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Biobjective set packing problems:",
    "category": "section",
    "text": "instance, true_frontier = read_bospp_xavier(\"2mis100_300A\")@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-true-frontier-5",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the true frontier",
    "category": "section",
    "text": "plt_discrete_non_dom_frntr([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"], false, \"Plot6.png\")(Image: Plot6.png)"
},

{
    "location": "solving_instances_from_literature.html#Biobjective-mixed-binary-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Biobjective mixed binary problems:",
    "category": "section",
    "text": "instance, true_frontier = read_bomip_hadi(6)@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Quality-of-the-frontier-w.r.t.-true-frontier-without-normalization-1",
    "page": "Solving Instances from Literature",
    "title": "Quality of the frontier w.r.t. true frontier without normalization",
    "category": "section",
    "text": "hg, c, mc, ac, u = compute_quality_of_apprx_frontier(nondominated_frontier, true_frontier, true)\nprintln(\"\n    Hypervolume Gap = $hg % \n    Cardinality = $c % \n    Maximum Coverage = $mc \n    Average Coverage = $ac \n    Uniformity = $u\")"
},

{
    "location": "solving_instances_from_literature.html#Quality-of-the-frontier-w.r.t.-true-frontier-with-normalization-1",
    "page": "Solving Instances from Literature",
    "title": "Quality of the frontier w.r.t. true frontier with normalization",
    "category": "section",
    "text": "hg, c, mc, ac, u = compute_quality_of_norm_apprx_frontier(nondominated_frontier, true_frontier, true)\nprintln(\"\n    Hypervolume Gap = $hg % \n    Cardinality = $c % \n    Maximum Coverage = $mc \n    Average Coverage = $ac \n    Uniformity = $u\")"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-true-frontier-6",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the true frontier",
    "category": "section",
    "text": "plt_non_dom_frntr_bomip([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"], \"Plot7.png\")(Image: Plot7.png)"
},

{
    "location": "solving_instances_from_literature.html#Biobjective-uncapacitated-facility-location-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Biobjective uncapacitated facility location problems:",
    "category": "section",
    "text": "instance, true_frontier = read_bouflp_hadi(12)@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-true-frontier-7",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the true frontier",
    "category": "section",
    "text": "plt_non_dom_frntr_bomip([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"], \"Plot8.png\")(Image: Plot8.png)"
},

{
    "location": "solving_instances_from_literature.html#Triobjective-assignment-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Triobjective assignment problems:",
    "category": "section",
    "text": "instance, true_frontier = read_moap_kirlik(3, 5, 1)@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Computing-quality-of-the-frontier-w.r.t.-true-frontier-without-normalization-2",
    "page": "Solving Instances from Literature",
    "title": "Computing quality of the frontier w.r.t. true frontier without normalization",
    "category": "section",
    "text": "hg, c, mc, ac, u = compute_quality_of_apprx_frontier(nondominated_frontier, true_frontier)\nprintln(\"\n    Hypervolume Gap = $hg % \n    Cardinality = $c % \n    Maximum Coverage = $mc \n    Average Coverage = $ac \n    Uniformity = $u\")"
},

{
    "location": "solving_instances_from_literature.html#Computing-quality-of-the-frontier-w.r.t.-true-frontier-with-normalization-2",
    "page": "Solving Instances from Literature",
    "title": "Computing quality of the frontier w.r.t. true frontier with normalization",
    "category": "section",
    "text": "hg, c, mc, ac, u = compute_quality_of_norm_apprx_frontier(nondominated_frontier, true_frontier)\nprintln(\"\n    Hypervolume Gap = $hg % \n    Cardinality = $c % \n    Maximum Coverage = $mc \n    Average Coverage = $ac \n    Uniformity = $u\")"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-true-frontier-8",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the true frontier",
    "category": "section",
    "text": "plt_discrete_non_dom_frntr([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"],  false, \"Plot9.png\")(Image: Plot9.png)"
},

{
    "location": "solving_instances_from_literature.html#Triobjective-1-D-knapsack-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Triobjective 1-D knapsack problems:",
    "category": "section",
    "text": "instance, true_frontier = read_mokp_kirlik(3, 10, 1)@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-true-frontier-9",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the true frontier",
    "category": "section",
    "text": "plt_discrete_non_dom_frntr([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"], false, \"Plot10.png\")(Image: Plot10.png)"
},

{
    "location": "solving_instances_from_literature.html#Triobjective-mixed-binary-problems:-1",
    "page": "Solving Instances from Literature",
    "title": "Triobjective mixed binary problems:",
    "category": "section",
    "text": "instance, true_frontier = read_mombp_aritra(3, 320, 1)@time solutions = fpbh(instance, lp_solver=ClpSolver(), timelimit=10.0)nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "solving_instances_from_literature.html#Comparing-the-nondominated-frontier-of-FPBH-with-the-reference-frontier-1",
    "page": "Solving Instances from Literature",
    "title": "Comparing the nondominated frontier of FPBH with the reference frontier",
    "category": "section",
    "text": "plt_discrete_non_dom_frntr([true_frontier, nondominated_frontier], [\"True Frontier\", \"FPBH(Clp)\"], false, \"Plot11.png\")(Image: Plot11.png)"
},

]}
