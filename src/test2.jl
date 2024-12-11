


datamatrix_ = Array{Float64}(undef, 3, 3, 2);

datamatrix_[:, :, 2] .= 0

datamatrix_[:,:,1] .= 4 .+ (7 - 4) * rand(3, 3)  

Flow_estimate = Matrix{Float64}(undef, 3, 3);

Flow_estimate[:,:] .= 2 .+ (8 - 2) * rand(3, 3)  

_C_1::Float64 = 0; sumflows_1::Float64 = 0;

_C_1 = sum(datamatrix_[:,:,1] .* Flow_estimate)
sumflows_1 = sum(Flow_estimate)

println("Compact c " , _C_1)
println("Compact sum " , sumflows_1)

_C_1::Float64 = 0; sumflows_1::Float64 = 0;

for i in 1:3
    for j in 1:3
        _C_1 = _C_1 + (datamatrix_[i, j, 1] * Flow_estimate[i, j])
        sumflows_1 = sumflows_1 + Flow_estimate[i, j];
    end
end

println(_C_1)
println(sumflows_1)


datamatrix_[2,2,1] = NaN

isfinite(datamatrix_[2,2,1])

Flow_estimate[1,2] = NaN

_C_1::Float64 = 0; 
sumflows_1::Float64 = 0;

function mycalc() 
    _C_1_::Float64 = 0; 
    sumflows_1_::Float64 = 0;
    for i in 1:3
        for j in 1:3
            if (isfinite(datamatrix_[i, j, 1]) && isfinite(Flow_estimate[i, j]))
                _C_1_ = _C_1_ + (datamatrix_[i, j, 1] * Flow_estimate[i, j])
                sumflows_1_ = sumflows_1_ + Flow_estimate[i, j];
            end
        end
   end
   return _C_1_ , sumflows_1_
end

@benchmark _C_1 , sumflows_1 =  mycalc()

        


_C_1 , sumflows_1 =  mycalc()

println(_C_1)
println(sumflows_1)


_C_1::Float64 = 0; sumflows_1::Float64 = 0;

@benchmark for i in 1:1
    _C_1 = sum(datamatrix_[:,:,1] .* Flow_estimate .* (isfinite.(datamatrix_[:,:,1]) .& isfinite.(Flow_estimate)))
    #sumflows_1 = sum(Flow_estimate .* isfinite.(Flow_estimate) .* isfinite.(datamatrix_[:, :, 1]) )
    sumflows_1 = sum(Flow_estimate .* (isfinite.(Flow_estimate) .& isfinite.(datamatrix_[:, :, 1])) )
end

println("Compact c " , _C_1)
println("Compact sum " , sumflows_1)



_C_1::Float64 = 0; sumflows_1::Float64 = 0;


_C_1 = sum(datamatrix_[:,:,1] .* Flow_estimate .* (isfinite.(datamatrix_[:,:,1]) .& isfinite.(Flow_estimate)))
    #sumflows_1 = sum(Flow_estimate .* isfinite.(Flow_estimate) .* isfinite.(datamatrix_[:, :, 1]) )
sumflows_1 = sum(Flow_estimate .* (isfinite.(Flow_estimate) .& isfinite.(datamatrix_[:, :, 1])) )


println("Compact c " , _C_1)
println("Compact sum " , sumflows_1)


_C_1::Float64 = 0; sumflows_1::Float64 = 0;

for i in 1:3
    for j in 1:3
        if (isfinite(datamatrix_[i, j, 1]) && isfinite(Flow_estimate[i, j]))
            _C_1 = _C_1 + (datamatrix_[i, j, 1] * Flow_estimate[i, j])
            sumflows_1 = sumflows_1 + Flow_estimate[i, j];
        end
    end
end


println(_C_1)
println(sumflows_1)


total_node = 16

delta_Flow_estimate = zeros(Float64, total_node, total_node)



delta_Flow_estimate .= rand(16,16)


delta_Flow_estimate .= 0.0




# Lista di nodi unici
node_unique = ["A", "B", "C", "D"]

# Creazione del dizionario
node_index = Dict(node => idx for (idx, node) in enumerate(node_unique))

# Ottieni l'indice di un nodo
println(node_index["C"])  # Output: 3

try
    println(node_index["C22"])  # Output: 3
catch eee
    println(eee)  # Output: 3
end


try
    println(node_index["C"])  # Output: 3
catch eee
    println(eee)  # Output: 3
end

# Lista di nodi
nodes = ["A", "D", "B"]

# Converti nodi in indici
indices = node_index[nodes]  # Output: [1, 4, 2]
println(indices)

# Esempio di costruzione di una matrice di adiacenza
adj_matrix = zeros(Int, length(node_unique), length(node_unique))
edges = [("A", "B"), ("B", "C"), ("C", "D")]

for (src, dest) in edges
    adj_matrix[node_index[src], node_index[dest]] = 1
end

println(adj_matrix)



total_flow::Float64, total_estimate::Float64, total_diff::Float64 = Float64(0.0), Float64(0.0), Float64(0.0);



pippo2::BigInt = 16^10

println(pippo2)

typeof(pippo2)