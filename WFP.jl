using Graphs, Luxor, Colors

#***** Instance reader *********************************************************
# Arguments:
#     filename::String  The full path of the instance file
# Returns:
#     Jobs::Int64  The number of jobs
#     JTasks::Int64 The number of tasks per job
#     Tasks::Int64 The total number of tasks
#     Ships::Int64 The total numbre of ships
#     duration::Array{Int64,1} The duration of each task
#     ship::Array{Int64,1} The ship assigned to each task
#     LFT::Int64 The schedule deadline
#     job_task::Array{Int64,2}, Matrix Jobs x JTasks representing the task ID
#     pred::Array{Int64,1} The precedessor of a task (0 is none)
#     job::Array{Int64,1} The job a task belongs to
#*******************************************************************************
function readInstance(filename)
    file = open(filename)
    line = readline(file)
    while(!eof(file) && line[1]=='#')
        line = readline(file)
    end
    LFT = parse(Int64,line)

    # read instance size
    Jobs, Ships = parse.(Int64,split(readline(file)))
    # the number of tasks per job cooresponds to the numbre of ships
    JTasks = Ships
    #tatal number of tasks
    Tasks = Jobs*Ships

    duration = zeros(Int64,Tasks)
    ship = zeros(Int64,Tasks)

    # read tasks
    for i in 1:Jobs
        data = parse.(Int64,split(readline(file)))
        # read ship assignment
        for j in 1:Ships
            ship[(i-1)*Jobs+j] = data[j*2-1]+1
        end
        # read duration
        for j in 1:Ships
            duration[(i-1)*Jobs+j]=data[j*2]
        end
    end
    close(file)

    # Matrix to indetify task ID given a job and a task sequence in the job
    job_task = reshape([i for i in 1:Tasks],(Jobs,JTasks))'

    # pred = #TODO: create the pred array

    # job = #TODO: create the job array

    return Jobs,JTasks,Tasks,Ships,duration,ship, LFT, job_task, pred, job
end

#***** Schedule generator ******************************************************
#
# Given a solution as an order of tasks in a
#
# Arguments:
#     solution::Array{Int64,2}  A solution represented by a matrix. For each
#                               ship the matrix represents a list of consecutive
#                               tasks. E.g. solution[1,2] is the second task to
#                               be executed with ship 1.
#     Jobs::Int64  The number of jobs
#     JTasks::Int64 The number of tasks per job
#     Tasks::Int64 The total number of tasks
#     Ships::Int64 The total numbre of ships
#     duration::Array{Int64,1} The duration of each task
#     ship::Array{Int64,1} The ship assigned to each task
#     job_task::Array{Int64,2}, Matrix Jobs x JTasks representing the task ID
#     pred::Array{Int64,1} The precedessor of a task (0 is none)
#
# Returns:
#     tStart::Array{In64,1} The start time of each task
#     tEnd::Array{In64,1} The finishing time of each task
#     makespan::Int64 The maskepan of the schedule, or -1 if the solution is
#                     infeasible
#*******************************************************************************
function getSchedule(solution,Jobs,JTasks,Tasks,Ships,duration,ship, job_task, pred)

    g = simple_graph(Tasks)
    if is_cyclic(g)
        return nothing,nothing,-1
    end
    for i in 1:Jobs
        for j in 2:JTasks
            add_edge!(g,job_task[i,j-1],job_task[i,j])
        end
    end
    for s in 1:Ships
        for i in 2:Jobs
            add_edge!(g,solution[s,i-1],solution[s,i])
        end
    end

    tStart = zeros(Int64,Tasks)
    tEnd   = zeros(Int64,Tasks)
    nextTime = ones(Int64,Ships)
    sorted_tasks = topological_sort_by_dfs(g)
    for task in sorted_tasks
        tStart[task] = pred[task]==0 ? nextTime[ship[task]] : max(nextTime[ship[task]],tEnd[pred[task]]+1)
        tEnd[task] = tStart[task]+duration[task]-1
        nextTime[ship[task]]=tEnd[task]+1
    end
    makespan = maximum(tEnd)
    return tStart, tEnd, makespan
end

#***** Solution viewer *********************************************************
#
# Generates a visualization of a solution. The image is saved on a file and
# previewd in the current envoronment.
#
# Arguments:
#     tStart::Array{In64,1} The start time of each task
#     tEnd::Array{In64,1} The finishing time of each task
#     ship::Array{Int64,1} The ship assigned to each task
#     job::Array{Int64,1} The job a task belongs to
#     Tasks::Int64 The total number of tasks
#     Ships::Int64 The total numbre of ships
#     filename::String The output file (default="out.pdf")
#     allowPreview::Bool Flag to turn ON/OFF the preview of the generated image
#
#*******************************************************************************
function drawSolution(tStart,tEnd,ship,job,Tasks,Ships,filename="out.pdf", allowPreview=true)
    border = 50
    xMax = maximum(tEnd)+border*2
    makespan = maximum(tEnd)
    yMax = (Ships*100)+border*2
    xMin = 0
    yMin = 0


    job_color = collect(Colors.color_names)
    Drawing((xMax-xMin),(yMax-yMin),filename)

    background("white")
    sethue("black")

    #draw axis
    arrow(Point(border/2,yMax-border),Point(border/2,border/2))
    arrow(Point(border/2,yMax-border),Point(xMax-border/2,yMax-border))
    setline(1)
    for i in 1:Ships
        line(Point(border/2,(i-1)*100+border-5),Point(xMax-border/2,(i-1)*100+border-5),:stroke)
        text("Ship $i",Point(border/2-5,((i-1)*100+border-5)+60),angle=-1.6,)
    end

    #draw ticks
    for i in 0:50:makespan
        line(Point(i+border,yMax-border),Point(i+border,yMax-border+5),:stroke)
        text("$i",Point(i+border,yMax-border+15),halign=:center)
    end
    #draw makespan
    sethue("red")
    line(Point(makespan+border,border-5),Point(makespan+border,yMax-border+5),:stroke)
    text("$makespan",Point(makespan+border,border-10),halign=:center)

    for i in 1:Tasks
        setopacity(0.5)
        sethue(job_color[job[i]+32][1])
        rect(tStart[i]+border,(ship[i]-1)*100+border,tEnd[i]-tStart[i],90,:fill)
        sethue("black")
        setopacity(1)
        rect(tStart[i]+border,(ship[i]-1)*100+border,tEnd[i]-tStart[i],90,:stroke)
        text("$i",Point(tStart[i]+border+(tEnd[i]-tStart[i])/2,(ship[i]-1)*100+border+45),halign=:center)
    end

    finish()
    if allowPreview
        preview()
    end
end
