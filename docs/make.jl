using Documenter
using FPBH

makedocs(
    modules = [FPBH],
    doctest = false,
    format = Documenter.HTML(),
    sitename = "FPBH",
    authors = "Aritra Pal",
    pages = [
        "Home" => "index.md",
        "Installation" => "installation.md",
        "Getting Started" => "getting_started.md",
        "Advanced Features" => "advanced.md",
        "Solving Instances from Literature" => "solving_instances_from_literature.md",
    ],
)

deploydocs(repo = "github.com/aritrasep/FPBH.jl.git")
