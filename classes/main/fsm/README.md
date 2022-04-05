# ***Class fsm***

## ***Description***
A Finite State Machine (fsm) models a process flow that transitions between various States through triggered events.  

## ***Features***
- base class to model your own state machines.
- trigger events synchronously.
- trigger events asynchronously.
- handle events before or after the event was triggered.
- handle state transitions as a result of event before and after the state change.

## ***Credits***
All credit goes to the developers of MOOSE as they have created this class, I take no credit for the hard work they did. I've simply
reworked the code to be able to work without MOOSE. Many thanks to those that created it.

## Fields and Methods
---
### creates a new fsm object
> &rarr; @param #fsm self  
> &larr; @return #fsm
```lua
function fsm:new()
```
---
### sets the start state of the fsm
> &rarr; @param #fsm self  
> &rarr; @param #string State A string defining the start state
```lua
function fsm:setStartState(State)
```
---
### Add a new transition rule to the fsm
- ***note: A transition rule defines when and if the fsm can transition from a state towards another state upon a triggered event***  
> &rarr; @param #fsm self  
> &rarr; @param #table From Can contain a string indicating the From state or a table of strings containing multiple From states  
> &rarr; @param #string Event The Event name  
> &rarr; @param #string To The To state
```lua
function fsm:addTransition(From, Event, To)
```
---
### Returns a table of the transition rules defined within the fsm
> &rarr; @param #fsm self  
> &larr; @return #table Transitions
```lua
function fsm:getTransitions()
```
---
### Returns a table of the Subfsm rules defined within the fsm
> &rarr; @param #fsm self  
> &larr; @return #table Sub processes
```lua
function fsm:getProcesses()
```
---
### Adds an End state
> &rarr; @param #fsm self  
> &rarr; @param #string State The fsm state
```lua
function fsm:addEndState(State)
```
---
### Returns the End states
> &rarr; @param #fsm self  
> &larr; @return #table End states
```lua
function fsm:getEndStates()
```
---
### Adds a score for the fsm to be achieved
> &rarr; @param #fsm self  
> &rarr; @param #string State is the state of the process when the score needs to be given (See the relevant state descriptions of the process)  
> &rarr; @param #string ScoreText is a text describing the score that is given according the status  
> &rarr; @param #number Score is a number providing the score of the status  
> &larr; @return #fsm self
```lua
function fsm:addScore(State, ScoreText, Score)
```
---
### Adds a score for the fsm_PROCESS to be achieved
> &rarr; @param #fsm self  
> &rarr; @param #string From is the From State of the main process  
> &rarr; @param #string Event is the Event of the main process  
> &rarr; @param #string State is the state of the process when the score needs to be given (See the relevant state descriptions of the process)  
> &rarr; @param #string ScoreText is a text describing the score that is given according the status  
> &rarr; @param #number Score is a number providing the score of the status  
> &larr; @return #fsm self
```lua
function fsm:addScoreProcess(From, Event, State, ScoreText, Score)
```
---
### Returns a table with the scores defined
> &rarr; @param #fsm self  
> &larr; @return #table Scores
```lua
function fsm:getScores()
```
---
### Returns a table with the Subs defined
> &rarr; @param #fsm self  
> &larr; @return #table Sub processes
```lua
function fsm:getSubs()
```
---
### Load call backs
> &rarr; @param #fsm self  
> &rarr; @param #table CallBackTable Table of call backs
```lua
function fsm:loadCallBacks(CallBackTable)
```
---
### Event map
> &rarr; @param #fsm self  
> &rarr; @param #table Events Events  
> &rarr; @param #table EventStructure Event structure
```lua
function fsm:eventMap(Events, EventStructure)
```
---
### Sub maps
> &rarr; @param #fsm self  
> &rarr; @param #table subs Subs  
> &rarr; @param #table sub Sub  
> &rarr; @param #string name Name
```lua
function fsm:submap(subs, sub, name)
```
---
### Call handler
> &rarr; @param #fsm self  
> &rarr; @param #string step Step "onafter", "onbefore", "onenter", "onleave"  
> &rarr; @param #string trigger Trigger  
> &rarr; @param #table params Parameters  
> &rarr; @param #string EventName Event name  
> &larr; @return Value
```lua
function fsm:callHandler(step, trigger, params, EventName)
```
---
### Handler
> &rarr; @param #fsm self  
> &rarr; @param #string EventName Event name  
> &rarr; @param  Arguments
```lua
function fsm_handler(args)
```
---
### Delayed transition
> &rarr; @param #fsm self  
> &rarr; @param #string EventName Event name  
> &larr; @return #function Function
```lua
function fsm:delayedTransition(EventName)
```
---
### Create transition
> &rarr; @param #fsm self  
> &rarr; @param #string EventName Event name  
> &larr; @return #function Function
```lua
function fsm:createTransition(EventName)
```
---
### Go sub
> &rarr; @param #fsm self  
> &rarr; @param #string ParentFrom Parent from state  
> &rarr; @param #string ParentEvent Parent event name  
> &larr; @return #table Subs
```lua
function fsm:_gosub(ParentFrom, ParentEvent)
```
---
### Is end state
> &rarr; @param #fsm self  
> &rarr; @param #string Current Current state name  
> &larr; @return #table fsm parent  
> &larr; @return #string Event name
```lua
function fsm:_isendstate(Current)
```
---
### Add to map
> &rarr; @param #fsm self  
> &rarr; @param #table Map Map  
> &rarr; @param #table Event Event table
```lua
function fsm:addToMap(Map, Event)
```
---
### Get current state
> &rarr; @param #fsm self  
> &larr; @return #string Current fsm state
```lua
function fsm:getState()
```
---
### Get current state
> &rarr; @param #fsm self  
> &larr; @return #string Current fsm state
```lua
function fsm:getCurrentState()
    return selfcurrent
end
```
---
### Check if fsm is in state
> &rarr; @param #fsm self  
> &rarr; @param #string State State name  
> &rarr; @param #boolean If true, fsm is in this state
```lua
function fsm:is(State)
```
---
### Check if can do an event
> &rarr; @param #fsm self  
> &rarr; @param #string e Event name  
> &larr; @return #boolean If true, fsm can do the event  
> &larr; @return #string To state
```lua
function fsm:can(e)
```
---
### Check if cannot do an event
> &rarr; @param #fsm self  
> &rarr; @param #string e Event name  
> &larr; @return #boolean If true, fsm cannot do the event
```lua
function fsm:cannot(e)
```
---