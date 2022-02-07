
In this series of posts we'll explore why and how to use containers in embedded systems.
we'll do small demos with a Jetson Nano device, that you can easely reproduce in other devices (like a raspbery pi) or just follow along

In this first post, we'll see the fundamentals of containers and present our "hello world" demo that we'll use throught the series.


containers are popular still not popular in the embedded system world, but this scenario is changing fast. Our goal with this series is twofold:
* For you that still don't use containers, to give you a headstart in conceptual understanding and code to be rehused in your work;
* For you that already use containers, to discuss best practices and tooling to ease your work.



# What are embedded systems
Dedicated processing system within a larger mechanical or electricalsystem

ABS controller, smart frige processor, aviation autopilot

# What are containers

method for packaging, distributing, and running applications

technology to isolate processes of the operating system

dedicated namespace, memory, and networking views, insulating it from the rest of the system

Container instances share the operating system kernel of their host system, so they
can’t run a different OS. Containers can, however, run different distributions of the
same OS—for example, CentOS Linux on one and Ubuntu Linux on another

"container" and "container engine" are abstract concepts, and there are specific softwares that implement them. The most well known container engine is called docker, and from now on I'll use both term as synonyms.




# Why use containers


Advantages of containers in the contex of embedded systems:
* **Simplify software development**: different developers can work in the same system with less interference between them. Each containers can have different dependencies installed, have different toolchains and be built independly, etc.
* **Simplify testing**: each container is an isolated system, so you spend less time worring about the surrounding configurations. For the same reason, you can easely test the system in several different underlying configurations, something that in a non-container environment would probably require to use several different devices.
* **Ease remote (over-the-air) updates**: you can store all container images in a central repostiory and update the application (or just part of the application) simply by stoping and starting a new container instance.
* **Quicker device setup**: setting up a fresh device requires only to install docker. Even when the OS is patched, updated, or maybe completely replaced, the setup proceadure will likely remain unchanged.


Disadvanteges:
* **Increase in resource usage**: containers do have an overhead comparing with using just the OS. If your device is already on the limit of its performance, you may have to reconsider using containers.
* **Container-capable device**: containers require a device capable of running containers (dããã), that basically means a device with linux. This may sound trivial to some software developers, but many embedded devices use only a RTOS (real time operating system) or no OS at all.
* **Complexity and learning curve**: you probably already have a well defined tooling to build your system, like Yocto, and to start using containers will add one more layer of complexity to this workflow. Also, you may need to manage several containers running on the same device, configure the workflows for building the container images, and so on.

# Our little demo
blink led

we'll demonstrate the isolation feature of containers by breaking the traditional "blink led" example into two independent modules. The modules are completely indendent, could easely be developed by different persons, and could even be written in different programming languages.

docker-compose to orquestrate two containers


# Conclusion and next steps

We have seen the basics of containers and how this techonolgy can be useful to embedded systems, but there is still a lot to be explored. In the next post we will see the usage of a machine learning platform, specifically Azure IoT, to manage embedded systems built with containers.
stay tuned ;) 

# References
https://www.embedded.com/why-the-future-of-embedded-software-lies-in-containers/

https://blog.savoirfairelinux.com/en-ca/2020/containers-on-linux-embedded-systems/

https://embeddedbits.org/using-containers-on-embedded-linux/

How Linux Containers can Help to Manage Development Environments for IoT and Embedded Systems. Yan Vugenfirer & Dmitry Fleytman. https://www.youtube.com/watch?v=F61MM_uuI5A 