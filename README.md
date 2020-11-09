# intelligent-agents
BDI Agent Programming with AgentSpeak. Agents act and communicate within an environment where they must collect resources and avoid obstacles. Implementation of A* search algorithm for navigation. The agents have a set amount of energy, which decreases with every move they make. The aim is to collect all the resources in the map, before the energy runs out. The agents have no knowledge of a map, and just have the ability to move, scan a radius (to see obstacles and resources), collect, and deposit. The agents can be programmed to speak to eachother and share information. The agents are controlled through the code written in AgentSpeak, with Java used to perform utility operations such as navigation, updating coordinates, and more.

## How to run
The easiest way to run this project is to download the Jason IDE, and run the five scenarios within it.

### Requirements
- [Java JDK](https://www.oracle.com/uk/java/technologies/javase-downloads.html) 1.8 or greater is required.
- Download the latest version of [Jason](https://sourceforge.net/projects/jason/).

### Set up
1. Extract the files to a directory of your choice.
2. Navigate to the folder *jedit* and double click on *jedit.jar*.
3. Within the IDE navigate to *Plugins -> Plugins Options -> Jason*.
4. Set the *jason.jar* location.
5. Set the directory *libs* as the Ant libs.
6. Set the *jade.jar* location.

### Select a scenario
- Navigate to *File -> Open* and choose one of the .mas2j files in the github repository such as *scenario_1.mas2j*.
- Click the green arrow in the bottom right of the IDE to run the scenario.
- Click the red exclamation mark adjacent to the green arrow, to terminate the scenario.

#### Scenario 1
- A single agent is programmed to rotate around the map, scanning for gold every 5 steps. When gold is found, the agent collects as much as it can, remember the location, and return to deposit the gold at the base. The agent then continually returns to the gold deposit until it is empty, it will then continue this process until all gold has been collected.

#### Scenario 2
- There is again a single agent, but this time on the map there are obstacles. The agent uses an implementation of the A* search to move around the obstacles, it then marks where the obstacles are on its internal map. It should be noted that the agent starts with zero knowledge of the map and has to form that knowledge. Gold is again collected in a similar manner to scenario 1.

#### Scenario 3
- There are now two agents, gold, diamonds and obstacles. Each agent has been assigned at instantiation whether it will collect gold or diamonds. If an agent scans a resource it cannot collect, it will share that knowledge by sending the coordinates to the other agent. The other agent will then react accordingly and collect the resource. The implementation is such that agents share a map and update it to help eachother understand where obstacles are.

#### Scenario 4
- This is a more complex version of scenario 3. There are now four agents. The agents all communicate with eachother when they scan obstacles and resources. Now the closest appropriate agent will pick up a resouce that another agent has scanned, as well as the resources they scan and can pick up.

#### Scenario 5
- There are six agents in this scenario. The approach is very similar to scenario 4. Improvements could be made to how the agents communicate to make for a more efficient implementation. However, all resources are collected before the agent's collective energy runs out.

### File Descriptions
#### scenario_X.mas2j
These are files that specify the scenario that should be run. Open this file in the Jason IDE to load the respective scenario. Don't edit.

#### scenario.json
This is a JSON file that is used during the set up of the scenarios. Don't edit.

#### libs
This folder contains *rover.jar* which is where the whole environment of the scenarios is defined.

#### aiLibs
This folder contains all the Java classes that the agents use, such as updating coordinates, performing A* search navigation, adding obstacle coordinates, etc.

#### src/asl
This folder contains the agents written in AgentSpeak. Look at these files to understand how AgentSpeak works, and how the agents move and communicate with eachother. It different to tradiitional programming so might have a learning curve, be sure to use the resources I have laid out below. There are three agents to pick up gold, three agents to pick up diamonds, and a basic agent that is used during the first scenario.

### More information
For more information about getting started with Jason [see here](http://jason.sourceforge.net/mini-tutorial/getting-started/).

For more information about BDI (Belief, Desire, Intention) programming [see here](https://en.wikipedia.org/wiki/Belief%E2%80%93desire%E2%80%93intention_software_model).

Finally, for more information about AgentSpeak you may be interested in the book [Programming Multi-Agent Systems in AgentSpeak using Jason](https://dl.acm.org/doi/book/10.5555/1197104) by Rafael H. Bordini, Jomi Fred Hübner, and Michael Wooldridge, available [here](https://www.amazon.co.uk/Programming-Multi-agent-Systems-AgentSpeak-Technology/dp/0470029005/ref=sr_1_1?dchild=1&keywords=Programming+Multi-Agent+Systems+in+AgentSpeak+using+Jason&qid=1604889177&sr=8-1).

Alternatively, see these slides: http://jason.sourceforge.net/jBook/SlidesJason.pdf.


