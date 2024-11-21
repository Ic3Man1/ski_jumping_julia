#import Pkg

#Pkg.add("GLMakie")
#Pkg.add("DifferentialEquations")

include("functions.jl")

using DifferentialEquations
using GLMakie

fig = Figure(resolution = (1920, 1080))
ax1 = fig[1, 1] = Axis(fig,
    aspect = 2,
    title = "Ski Jumper's Trajectory",
    titlegap = 10, titlesize = 30,
    xlabel = "distance", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "height", ygridwidth = 2, yticks = LinearTicks(20)
)

params_grid = SliderGrid(
    fig[1,2], 
    (label = "mass", range=50:1:120, format="{:.2f}", startvalue=70.), 
    tellheight = false,
    tellwidth = false
)

# Flight parameters
m = 70.0                      # Skier's mass (kg)
rho = 1.225                   # Air denity (kg/m^3)
A = 0.8                       # Skiers area (m^2)
cd = 0.5                      # Drag coefficient
cl = 1.0                      # Lift coefficient
g = 9.81                      # Acceleration of gravity (m/s^2)
phi = 7.0                     # Angle of the jump (degrees)
alpha = 30.0 * (pi / 180)     # Angle of attack (radians)
beta = 9.5 * (pi/180)         # Body to ski angle (radians)
gamma = 150.0 * (pi/180)       # Hip angle (radians)

# Initial conditions
v = 25.0                     # Jumper's speed (m/s)
vw = 0                     # Wind speed (m/s) do 3 m/s
v0 = v + vw                  # Take off speed (m/s)
vx0 = v0*cosd(phi)          # Take off speed in x-axis (m/s)
vy0 = v0*sind(phi)          # Take off speed in y-axis (m/s)
x0 = 0.0                     # Take off x-coordinate
y0 = 0.0                     # Take off y-coordiante

p1 = (m, rho, A, cd, cl, g, phi, alpha, vw)
u0 = [vx0, vy0, x0, y0]
t_sim = (0.0, 10.0)     # Length of simulation

# Ski jump hill parameters (Courchevel hill in Savoie)
w = 90.0        # Distance between the edge of the take off and the K point (meters)
beta_p = 35.5   # Angle of the hill at the P point (degrees)
beta_o = 5.9    # Angle at the base of the take off (degrees)
P_x = 71.26     # P point x coordiante
P_y = -38.25    # P point y coordiante

x_h = 0:0.1:150
params = (w, beta_p, beta_o, P_x, P_y)

prob1 = ODEProblem(skiers_flight1, u0, t_sim, p1)
sol1 = solve(prob1, Tsit5())

x_sim1 = []
y_sim1 = []

time = 0:0.1:10

filter_data(time, sol1, x_sim1, y_sim1, params)

lines!(ax1, x_sim1, y_sim1, color=:red, label = "angle of attack")
lines!(ax1, x_h, jump_hill(x_h, params), color=:black)
axislegend(ax1, position=:lb)
fig