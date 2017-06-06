# pathFlowing
A pixel based path finding algorithim with two seperate implementations. 
There is a GPU/glsl shader version and a CPU version. The path finders are imlpemented on
the CPU for both examples, this limits the number of entities that can be path'd per frame to
several thousand. Still, it's far more efficient than traditional approaches such as A*. There 
is only one target(mouse location) included in this example but multiple targets are just as easy. 

 Toggle between CPU/GPU flow field engines with (q) key.
 
 -/+ gpu shader passes with (1/2) keys.

  Toggle 60fps frame rate lock with (a) key.

![alt text](https://kek.gg/i/7SmDmT.png)