# Bluff Chess
This is the game project for 2110511 Game Programming class.

## How to play the game
### Prerequisite
- godot engine

### To play the game
1. Start the game server by run this command
```
godot --server
```
2. Connect the computers in the same network
3. In game peer, changing SERVER_IP and CLIENT_IP in lobby_client.gd
```
#  In /Scenes/lobby/lobby_client.gd

const SERVER_IP = "<SERVER_IP_ADDRESS>" #IP address where the server run on
const CLIENT_IP = "<CLIENT_IP_ADDRESS>" #IP address where the game will be played (IP of each player)
```
4. Start game by run this command
```
godot .
```
