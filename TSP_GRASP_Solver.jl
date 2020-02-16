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

#GRASP find neighbors
# function RandomGenerator(range)
#     # println(seed) #use time stamp as seed
#     #Random.seed!(seed)
#     return rand(range[1]:range[2])
# end

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

    neighborIndex = rand(1 : length(neighbors))
    # println(neighborIndex)
    return neighbors[neighborIndex] # println("neighbor" * string(neighbors[neighborIndex]))
end

function findRoute(dist)
    dim = length(dist[1, : ])
    visitedCity = Set{Int64}()
    route = zeros(Int32,dim)
    route[1] = 1
    next = 1    #index of next city to visit
    push!(visitedCity, next)
    k = 5   #bound for random find k nearest neighbors
    for i in 2:dim
        index = findNext(visitedCity, dist[next, : ], k) # println("index: "* string(index))
        next = index
        route[i] = next
        push!(visitedCity, next)
    end
    return route
end

function getCost(route, dist)
    totalDist = 0
    for i in 1:length(route)-1
        totalDist += dist[route[i], route[i+1]] # println(string(route[i]) * " : " * string(route[i+1]))
    end
    totalDist += dist[route[length(route)], 1] #closed circle
    return totalDist # println(string(route[length(route)]) * " : " * "1")
end



#local search part
function getCandidate(route)
    candidate = copy(route)
    stop = false
    # while stop == false
    i = rand(1:length(candidate))
    j = rand(1:length(candidate))
    # println("i:"*string(i)*" j:"*string(j))
    if i < j
        i, j = j, i
    end
    candidate[i : j] = reverse(candidate[i:j])
    return candidate
end

function Local_search(dist, route, attemptsNum)
    count = 0
    route_local = copy(route)
    minCost = getCost(route, dist)
    while count < attemptsNum
        # println("finding candidate")
        candidate_route = getCandidate(route_local)
        # println("get cost")
        cost_local = getCost(candidate_route, dist)
        if cost_local < minCost
            # println("..")
            route_local = copy(candidate_route)
            minCost = cost_local
            count = 0
        else
            # println("..")
            count += 1
        end
    end
    return route_local, minCost
end

function TSP_Solver(filename)
    coord, dim = readInstance(filename)
    dist = getDistanceMatrix(coord, dim)
    route = [1, 3, 9, 5, 6, 7, 8, 2, 10, 4]#findRoute(dist)
    local_route, local_result = Local_search(dist, route, 100)
    println("local_minima")
    println(local_result)
    # println(dist)
    # return dist, route
end

#
# function GRASP_search()
