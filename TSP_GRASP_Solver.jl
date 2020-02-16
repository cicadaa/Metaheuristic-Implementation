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

function findNext(visited, curDist, bound::Int64)
    indexedDist = []
    neighbors = [] #store n neighbors

    for i in 1:length(curDist) #sort cities by distance
        append!(indexedDist, [(i, curDist[i])])
    end
    sortedDist = sort(indexedDist, by = first)

    for j in 1:length(curDist) #find neighbors
        if bound == 0
            break
        end
        if !(sortedDist[j][1] in visited) #make sure the neighbor is not visited
            append!(neighbors, sortedDist[j][1])
            bound -= 1
        end
    end
    seed = parse(Int64, Dates.format(Dates.now(), "yyyymmddHHMMSS"))
    Random.seed!(seed)
    neighborIndex = rand(1:length(neighbors)) # generate random index to pick a neighbor
    return neighbors[neighborIndex] # println("neighbor" * string(neighbors[neighborIndex]))
end

function findPath(dist)
    dim = length(dist[1, : ])
    visited = zeros(Int32,dim)
    visitedCity = Set{Int64}()
    vistsequence = zeros(Int32,dim)
    vistsequence[1] = 1
    next = 1    #next city to visit
    push!(visitedCity, next)
    k = 2   #bound for random find k nearest neighbors
    for i in 2:dim
        index = findNext(visitedCity, dist[next, : ], k) # println("index: "* string(index))
        next = index
        vistsequence[i] = next
        push!(visitedCity, next)
    end
    return vistsequence
end

function getCost(vistsequence, dist)
    totalDist = 0
    for i in 1:length(vistsequence)-1
        totalDist += dist[vistsequence[i], vistsequence[i+1]] # println(string(vistsequence[i]) * " : " * string(vistsequence[i+1]))
    end
    totalDist += dist[vistsequence[length(vistsequence)], 1] #closed circle
    return totalDist # println(string(vistsequence[length(vistsequence)]) * " : " * "1")
end

function TSP_Solver(filename)
    coord,dim = readInstance(filename)
    dist = getDistanceMatrix(coord, dim)
    vistsequence = findPath(dist)
    cost = getCost(vistsequence, dist)
    println(cost)
    println(dist)
    return dist, vistsequence
end

# function Local_search()
#
# function GRASP_search()
