# Proj2 -> Gossip and Push-sum algorithm for creating Amazing Networks

## Team Members:
 Mohit Garg (UFID: 9013-4089)<br />
 Maharshi Rawal (UFID: 9990-8457)

## **PROBLEM**

Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so-called Asynchronous Gossip.

All the information is in project2.pdf file of this repository.

## **INSTALLATION AND RUN** 

***Make sure to install the Elixir on your PC.***<br />

Open the Terminal on your machine <br />

Step 1: **$** git clone https://github.com/m999gs/proj2.git  (for cloning the project on local machine) <br />

Step 2: **$** cd proj2/  <br />

Step 3: **$** mix escript.build <br />

Step 4(For Mac Users): **$** ./proj2 100 3Dtorus gossip <br />
Step 4(For Windows user): **$** escript proj2 100 3Dtorus gossip <br />


## Format of the arguments
   (For Mac Users):    **$** ./proj2  argument1  argument2  argument3 <br />
   (For Windows user): **$** escript proj2  argument1  argument2  argument3 <br />
   
   Where:<br />
     Argument 1 is the number of actors (or nodes) in the network **(Any number greater than 1)**<br />
     Argument 2 is the topology name **( full | line | rand2D | 3Dtorus | honeycomb | randhoneycomb )**<br />
     Argument 3 is the algorithm name **( gossip | push-sum )**<br />

**Example:** <br />
  **(base) Mohits-MacBook-Pro:proj2 mohitgarg$** ./proj2 5000 line push-sum <br />
  Initializing push sum algorithm <br />
  Implementing line topology<br />
  Convergence Time: 366001 milliseconds<br />
  **(base) Mohits-MacBook-Pro:proj2 mohitgarg$**<br />

## **Algorithms and Topologies Implemented**
  There are two algorithms in this project namely:
  
    1. gossip 
    
    2. push-sum 
  
  There are 6 Topologies in this Project to choose from:
  
    1. full  
    
    2. line 
    
    3. rand2D
    
    4. 3Dtorus 
    
    5. honeycomb 
    
    6. randhoneycomb 

## **LARGEST NETWORK**
    
   Largest network tested:
   
   For Gossip Algorithm
   1. Full -  10,000
   2. Line  - 10,000
   3. Rand 2D - 1,50,000
   4. 3D Torus - 1,00,000
   5. Honeycomb - 50,000
   6. Rand Honeycomb - 1,50,000 
   
   For Push-sum Algorithm
   1. Full -  10,000
   2. Line  - 5,000
   3. Rand 2D - 
   4. 3D Torus - 
   5. Honeycomb - 
   6. Rand Honeycomb -  
