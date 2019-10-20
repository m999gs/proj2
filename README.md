# Proj2 -> Gossip and Push-sum algorithm

## Team Members:
 Mohit Garg (UFID: ****-****)<br />
 Maharshi Rawal (UFID: ****-****)

## **Problem Statement**

Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so-called Asynchronous Gossip.


## **Installation and Run** 

***Make sure to install Elixir on your PC.***<br />
1. Unzip the zip archive and navigate to the extracted folder. <br/>
2. Open the Terminal/Command Prompt. <br />
3. Use **mix escript.build** to build the project. <br/>
4. Format of Arguments 

   (For Mac/Linux Users):    **$** ./proj2  argument1  argument2  argument3 <br />
   (For Windows Users): **$** escript proj2  argument1  argument2  argument3 <br />
   
   **Where:**<br />
     Argument 1 is the number of actors (or nodes) in the network **(Any number greater than 1)**<br />
     Argument 2 is the topology name **( full | line | rand2D | 3Dtorus | honeycomb | randhoneycomb )**<br />
     Argument 3 is the algorithm name **( gossip | push-sum )**<br />

**Example:** <br /><br />
  (Mac/Linux): **$** ./proj2 5000 line push-sum <br />
  Initializing push sum algorithm <br />
  Implementing line topology<br />
  Convergence Time: 366001 milliseconds<br />

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

## **Largest Network**
    
   Largest network tested:
   
   For Gossip Algorithm
   
    1. full  -  10,000
    
    2. line  - 10,000
    
    3. rand2D - 10,000
    
    4. 3Dtorus  - 1,00,000
    
    5. honeycomb - 50,000
    
    6. randhoneycomb - 1,50,000 
   
   For Push-sum Algorithm
   
    1. full  -  4,000
    
    2. line  - 4,000
    
    3. rand2D - 2,000
    
    4. 3Dtorus  - 5,000
    
    5. honeycomb - 5,000
    
    6. randhoneycomb - 5,000
