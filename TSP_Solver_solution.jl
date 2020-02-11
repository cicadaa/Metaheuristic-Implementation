
#***** Instance reader *********************************************************
# Arguments:
#     filename::String  The full path of the instance file
# Returns:
#     name::String  The name of the TSP instance
#     coord::Array{Float32,2} An array of coordinate pairs (x,y)
#     dim::Int32  The dimention of the coord array
#*******************************************************************************
function readInstance(filename)
    #open file for reading
    file = open(filename)
    #read the name of the instance
    name = split(readline(file))[2]
    #The next two lines are not interesting for us. Skip them
    readline(file);readline(file)
    #Read the size of the instance (the number of cities)
    dim = parse(Int32,split(readline(file))[2])
    #The next two lines are not interesting for us. Skip them
    readline(file);readline(file)
    #Create a Matrix (dim ⋅ 2) to hold the coordinates
    coord = zeros(Float32,dim,2)

    #TODO: Add your code to read all the coordinates
    for i in 1:dim
        data = parse.(Float32,split(readline(file)))
        coord[i,:]=data[2:3]
    end

    #Close the file
    close(file)
    #return the data we need
    return coord,dim
end

#***** Creates a distance matrix ***********************************************
# Arguments:
#     coord::Array{Float32,2}  An array of coordinate pairs (x,y)
#     dim::Int32  The dimention of the coord array
# Returns:
#     dist::Array{Float32,2} Distance matrix based on the straight line distance
#*******************************************************************************
function getDistanceMatrix(coord::Array{Float32,2},dim::Int32)
    dist = zeros(Float32,dim,dim)
    for i in 1:dim
       for j in 1:dim
            if i!=j
                dist[i,j]=round(sqrt((coord[i,1]-coord[j,1])^2+(coord[i,2]-coord[j,2])^2),digits=2)
            end
        end
    end

    visited = zeros(Int64,dim)
    visited[1] = 1

    vistsequence = zeros(Int32,dim)
    vistsequence[1] = 1
    totalDist = 0
    next = 1
    i = 1
    index = 0
    for i in 2:dim
        mindist =1000000
        for j in 1:dim
            if visited[j] == 0
                if 0< dist[next,j] <= mindist
                    mindist = dist[next,j]
                    index = j
                end
            end
        end
        next = index
        vistsequence[i] = index
        visited[next] = 1
        totalDist += mindist
    end
    return vistsequence,totalDist
end

function TSP_Solver(filename)
    coord,dim = readInstance(filename)
    vistsequence,totalDist = getDistanceMatrix(coord, dim)
    return totalDist,vistsequence

    # GetTotalDistance(dist, dim)
end
