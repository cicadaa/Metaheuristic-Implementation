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


function initialize_solution(dist)
    dim = length(dist[1, : ])
    visited = zeros(Int32,dim)
    vistsequence = zeros(Int32,dim)
    visited[1] = 1
    vistsequence[1] = 1
    next = 1    #next city to visit
    index = 0   #store temporary index

    for i in 2:dim
        minDist = sum(dist[next, :]) # give a large initial value
        for j in 1:dim
            if visited[j] == 0
                if 0< dist[next,j] <= minDist
                    minDist = dist[next,j]
                    index = j
                end
            end
        end
        next = index
        vistsequence[i] = index
        visited[next] = 1
    end
    return vistsequence
end

function accept(candidate_cost, ref_cost, accept_probability)
    randGenerator = rand(Float32, 1)
    randNum = randGenerator[1]

    if candidate_cost < ref_cost || randNum < accept_probability
        return true
    end
    return false
end

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


function SA_Solver(file , alpha, T)
    coord, dim = readInstance(file)
    dist = getDistanceMatrix(coord, dim)
    ref_s = initialize_solution(dist)
    ref_cost = minCost = getCost(ref_s, dist)
    minsolution = ref_s
    startTime = time_ns()

    while round( (time_ns()-startTime)/1e9,digits=3) < 60
        s = getCandidate(ref_s)
        s_cost = getCost(s, dist)
        accept_probability = exp(-abs(s_cost - ref_cost) / T)
        if accept(s_cost, ref_cost, accept_probability)
            ref_cost, ref_s = s_cost, s
            if  s_cost < minCost
                minCost, minsolution = s_cost, s
                println(minCost)

            end
        end
        T = T * alpha
    end
    println(minCost)
    println(minsolution)
end
