
#=
import Pkg; 

using  Pkg
Pkg.activate(".") 


Pkg.add("DataFrames")

Pkg.add("Random")
Pkg.add("CSV")
Pkg.add("JSON")

Pkg.add("JSON3")

Pkg.add("StringEncodings")

Pkg.add("DataStructures")


Pkg.add("StatsBase") 
Pkg.add("Distributions") 

Pkg.add("BenchmarkTools")

Pkg.add("IndexedTables")

Pkg.add("Humanize")

Pkg.add("Nettle")

Pkg.update()
Pkg.status()   
pkg"status"
pkg"update"
=#


using  Pkg
Pkg.activate(".") 


Pkg.status()   

println( "...using librerie")
using DataFrames,DataStructures, Random, CSV, JSON, JSON3, StringEncodings, StatsBase, Distributions, BenchmarkTools
using IndexedTables

using Humanize, Nettle
                                 




