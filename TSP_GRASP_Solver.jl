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
                dist[i,j]=round(sqrt((coord[i,1]-coord[j,1])^2+(coord[i,2]-coord[j,2])^2),digits=0)
            end
        end
    end
    return dist
end


#GRASP
function findNext(visited, curDist, bound::Int64)  #GRASP find nearest N cities, (n == bound)
    indexedDist = []
    neighbors = [] #store n neighbors

    for i in 1:length(curDist) #sort cities by distance
        append!(indexedDist, [(curDist[i],i)])
    end
    sortedDist = sort(indexedDist, by = first)
    for j in 1:length(curDist) #find neighbors
        if bound == 0
            break
        end
        if visited[sortedDist[j][2]] == 0 #make sure the neighbor not visited
            append!(neighbors, sortedDist[j][2])
            bound -= 1
        end
    end
    neighborIndex = rand(1 : length(neighbors))
    return neighbors[neighborIndex]
end

function GRASP_findRoute(dist, dim, k)
    visited = zeros(Int32,dim)
    route = zeros(Int32,dim)
    next = rand(1:dim)  #index of next city to visit
    visited[next] = 1
    route[1] = next
    for i in 2:dim
        index = findNext(visited, dist[next, : ], k)
        println("index: "* string(index))
        next = index
        route[i] = next
        visited[next] = 1
    end
    cost = getCost(route, dist)
    return route, cost
end


function getCost(route, dist)
    totalDist = 0
    for i in 1:length(route)-1
        totalDist += dist[route[i], route[i+1]]
    end
    totalDist += dist[route[length(route)], 1] #closed circle
    return totalDist
end



#local search
function getCandidate(route)
    candidate = copy(route)
    stop = false
    i = rand(1:length(candidate))
    j = rand(1:length(candidate))
    if i > j
        i, j = j, i
    end
    candidate[i : j] = reverse(candidate[i:j])
    return candidate
end

function Local_search(dist, route, attemptsNum)
    count = 0
    route_optimal = copy(route)
    minCost = getCost(route, dist)
    startTime = time_ns()
    while round( (time_ns()-startTime)/1e9,digits=3) < 3 #serach time limitation
        candidate_route = getCandidate(route_optimal)
        cost_local = getCost(candidate_route, dist)
        if cost_local < minCost
            route_optimal = copy(candidate_route)
            minCost = cost_local
            count = 0
        else
            count += 1
        end
    end
    return route_optimal, minCost
end

function TSP_Solver(filename)
    #prepare data
    coord, dim = readInstance(filename)
    dist = getDistanceMatrix(coord, dim)
    startTime = time_ns()

    #initial solution
    initroute = findPathGreedy(dist)
    greedy_solution = getCost(initroute, dist)
    final_route, final_solution = GRASP_findRoute(dist, dim, initroute, 3)

    #repeat
    while round((time_ns()-startTime)/1e9,digits=3) < 60   #while not terminate

        #GreedyRandomizedConstruction
        route, cost = GRASP_findRoute(dist, dim, final_route, 3)

        #LocalSearch
        local_route, local_cost = Local_search(dist, route, 10)

        #if Cost < bestCost 
        if local_cost < final_solution
            final_solution = local_cost
            final_route = local_route
            println(final_solution)
        end
    end
    println(final_route)
    println(final_solution)
end

# parameters record
#01 set
#   GRASP_findRoute(dist, dim, final_route, 3)
#   Local_search(dist, route, 10)
#   time 60s
