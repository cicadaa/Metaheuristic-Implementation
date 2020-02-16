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


function findPath(dist)
    dim = length(dist[1, : ])
    visited = zeros(Int32,dim)
    vistsequence = zeros(Int32,dim)
    visited[1] = 1     #start from city1, 1 means the city has been visited
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

function getCost(vistsequence, dist)
    totalDist = 0
    for i in 1:length(vistsequence)-1
        totalDist += dist[vistsequence[i], vistsequence[i+1]]
        # println(string(vistsequence[i]) * " : " * string(vistsequence[i+1]))
    end
    totalDist += dist[vistsequence[length(vistsequence)], 1] #closed circle
    # println(string(vistsequence[length(vistsequence)]) * " : " * "1")
    return totalDist
end

function TSP_Solver(filename)
    coord,dim = readInstance(filename)
    dist = getDistanceMatrix(coord, dim)
    vistsequence = findPath(dist)
    cost = getCost(vistsequence, dist)
    println(cost)
    #println(dist)
    return dist, vistsequence
end
