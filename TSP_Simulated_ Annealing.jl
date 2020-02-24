import Random
import Dates

function readInstance(filename)
    file = open(filename)
    name = split(readline(file))[2] #name of the instance
    readline(file);readline(file) #skip 2 lines
    dim = parse(Int32,split(readline(file))[2]) #the number of cities
    readline(file);readline(file) #skip 2 lines
    coord = zeros(Float32,dim,2) #coordinates
    for i in 1:dim
        data = parse.(Float32,split(readline(file)))
        coord[i,:]=data[2:3]
    end
    close(file)
    return coord,dim
end

function getDistanceMatrix(coord::Array{Float32,2},dim::Int32)
    dist = zeros(Float32,dim,dim)
    for i in 1:dim
       for j in 1:dim
            if i!=j
                dist[i,j]=round(sqrt((coord[i,1]-coord[j,1])^2+(coord[i,2]-coord[j,2])^2),digits=2)
            end
        end
    end
    return dist
end

function getCost(route, dist)
    totalDist = 0
    for i in 1:length(route)-1
        totalDist += dist[route[i], route[i+1]] # println(string(route[i]) * " : " * string(route[i+1]))
    end
    totalDist += dist[route[length(route)], 1] #closed circle
    return totalDist # println(string(route[length(route)]) * " : " * "1")
end

function initialize_solution()


function Simulated_Annealing()
    s0 = initialize_solution()
    t = startTime = time_ns()
    while round( (time_ns()-startTime)/1e9,digits=3) < 10
        s = findSolution
