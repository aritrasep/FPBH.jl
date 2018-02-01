if !("Modolib" in keys(Pkg.installed()))
	Pkg.clone("https://github.com/aritrasep/Modolib.jl")
	Pkg.build("Modolib")
end
