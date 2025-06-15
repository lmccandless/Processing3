# TowerDefenseDemo

A minimal tower defense example built with Processing. It demonstrates using a GPU
based flow field shader for enemy pathfinding. Enemies spawn in waves and move
around obstacles towards a base. A simple UI lets you pick a turret type and
place towers by clicking.

* Select turrets with number keys **1-3** and click to place them.
* Each tower blocks the path field and attacks nearby enemies.
* Waves of enemies spawn automatically and pathfind to the base location.

The sketch is not a full game but shows how a flow field can control many
entities at once while interacting with towers and obstacles.
