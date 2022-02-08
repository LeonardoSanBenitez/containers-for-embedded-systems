# Containers for embedded systems

In this series of posts we'll explore **why and how** to use containers in embedded systems, a combination that is still not common. Along the series we’ll use a **Jetson Nano** development kit to do small demonstrations (but you can easily reproduce them other devices like a raspbery pi), and all code and steps to reproduce them are in this repository.

**Our goal** with this series is two fold:

* For you that still don't use containers, to give you a head start in conceptual understanding and code to be rehused in your work;
* For you that already use containers, to discuss best practices and tooling to ease your work.

In this first post, we'll see the fundamentals of containers and present our "hello world" demo that we'll use throught the series. Fasten your belt, grab a coffee, and let’s start!



## What are embedded systems

Are dedicated processing systems within a larger mechanical or electrical system, usually an enclosed product sell as a whole. Some example are: ABS controller, smart fridge interface, aviation autopilot... you won’t buy those things separately, they are embedded larger products.

Embedded systems usually have strong requirements of performance, reliability, and production costs, posing unique challenges to developers and engineers. When these computing enabled devices are connected to the Internet we usually use the term Internet of Things, that also sounds much nicer ;)



## What are containers

Are a method for packaging, distributing, and running applications. Their main characteristic is that they can **isolate processes** from the operating system: dedicated memory, networking, namespaces, etc.

Sounds like a Virtual Machine, right? Yes, but one big difference is that containers share the operating system kernel of their host system, therefore they are lightweight. A direct consequence of that sharing is that containers can’t run a different OS (like running a linux container on top a windows host), an can at most run different distributions of the same OS (like running a CentOS container on top a Ubuntu host).

![img](images/docker.png)

> Difference between Virtual Machines and Containers (Source: Docker)

Some important concepts: a *container* is a running instance of this isolated environment, being managed by a *container engine*. A container is started having as a base an *image*, a binary file with everything bundled together. An image can be build from a *definition file*, a text description of what goes inside the container.

But "container" is just an abstract concept, and there are many softwares that implement it. The most well known container engine is called **docker**, and from now on I'll use both term as synonyms.



## Why use containers

There are many advantages in using containers for any application, but I want to highligh things that are specially relevant in the context of embedded systems:

* **Simplify software development**: different developers can work in the same system with less interference between them. Each containers can have different dependencies installed, have different toolchains, be built independently, etc.
* **Simplify testing**: each container is an isolated system, so you spend less time worrying about the configurations of your test setup. For the same reason, you can easily test the system in several different underlying configurations, something that in a non-container environment would probably require to use several different devices.
* **Ease remote (over-the-air) updates**: you can store all container images in a central repostiory and update the application (or just part of the application) simply by stoping and starting a new container instance.
* **Quicker device setup**: setting up a fresh device requires only to install docker. Even when the OS is patched, updated, or maybe completely replaced, the setup proceadure will likely remain unchanged.


As nothing is perfect, you need to be aware of some disadvantages:
* **Increase in resource usage**: containers do have an overhead comparing with using just the OS. If your device is already on the limit of its performance, you may have to reconsider using containers.
* **Container-capable device**: containers require a device capable of running containers (dããã), that basically means a device with linux. This may sound trivial to some software developers, but many embedded devices use only a RTOS (real time operating system) or no OS at all.
* **Complexity and learning curve**: you probably already have a well defined tooling to build your system, like Yocto, and to start using containers will add one more layer of complexity to this workflow. Also, you may need to manage several containers running on the same device, configure the workflows for building the container images, and so on.

# Our little demo
Guess what? IT’S A BLINK LED!

![gif](images/excellent.gif)

Okay, almost. We'll demonstrate the isolation feature of containers by breaking the traditional "blink led" example into two independent modules: one will read a button every one second and the the button’s state (pressed or not) to the second module, that will turn on the led if the button is pressed.

The communication happens over HTTP: the first module initiates the request and the second is a web server waiting for requests. The modules are completely independent, could easily be developed by different persons, be written in different programming languages, and even have its proprietary source code hidden from each other.

![gif](images/demo.gif)

> Demo with a button and led from Sparkfun, running on a jetson nano (inside the case).

docker-compose to orquestrate two containers


# Conclusion and next steps

We have seen the basics of containers and how this techonolgy can be useful to embedded systems, but there is still a lot to be explored. In the next post we will see how the usage of a **IoT platform**, specifically Azure IoT, to manage embedded systems built with containers.
Stay tuned ;) 

# References



marwendel

Docker documentation. https://docs.docker.com/get-started/resources/

https://www.embedded.com/why-the-future-of-embedded-software-lies-in-containers/

https://blog.savoirfairelinux.com/en-ca/2020/containers-on-linux-embedded-systems/

https://embeddedbits.org/using-containers-on-embedded-linux/

How Linux Containers can Help to Manage Development Environments for IoT and Embedded Systems. Yan Vugenfirer & Dmitry Fleytman. https://www.youtube.com/watch?v=F61MM_uuI5A 

