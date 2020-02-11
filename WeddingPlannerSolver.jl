

function readInstance(filename)
    f = open(filename)
    readline(f)
    #header line comment

    #read instance size data
    data = split(readline(f))
    G = parse(Int32,data[1]) # no. guests
    T = parse(Int32,data[2]) # no. tables
    S = parse(Int32,data[3]) # no. sits per table

    #read common interests data
    readline(f);readline(f) #empty line + header
    shared_interests = zeros(Int32,G,G)
    for g1 in 1:G
        data = parse.(Int32,split(readline(f)))
        for g2 in 1:G
            shared_interests[g1,g2] = data[g2]
        end
    end

    #read guests' data
    readline(f);readline(f) #empty line + header
    partner = zeros(Int32,G)
    gender = zeros(Int32,G)

    for g in 1:G
        data = split(readline(f))#read guest data
        partner[g] = parse(Int32,data[1])#read partner
        gender[g]=data[2]=="M" ? 0 : 1 #read gender Male 0, Female 1
        #TODO: read the list of guest that guest g knows.
    end
    close(f)
    return G, T, S, shared_interests, partner, gender

end

function initializeSolution(G::Int32, T::Int32, S::Int32)
    guest = zeros(Int32, T, S)
    for 
end

function getCost(guest, interest, partner)
