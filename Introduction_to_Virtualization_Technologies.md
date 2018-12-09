### Virtualization

### Bare bone installation
Before virtualization an application was deployed on single hardware.
This approach had several downfalls:
  - application was not used to the full capabilities
  - if we wanted to scale up new hardware had to be purchased
  - slow deployment
  - hard to migrate from one vendor to another as we had to consider dependencies
  - big costs


![IMG]()

### Hypervisor virtualization
To address this limitation Hypervisor-based Virtualization was introduced.
Each application was deployed within a Virtual Machine(VM) with it's own operation system(OS).
Still each application had to have it's own kernel. While this approach was
better it still had some limitations as it lacked full portability.

Benefits:
  - cost efficient
  - Easy to scale

Limitations:
  - Kernel Resource Duplication
  - Application Portability Issue

![IMG]()

### Container based Virtualization

Container based virtualization addresses the former limitations. This type of virtualization introduces another abstract level,
The Container Engine level. In Hypervisor mode virtualization happens at hardware level, and for the new level the virtualization happens at OS level.
For the container based level there will be one Kernel used.
Within a container only the specific application binaries/libraries will be used, no extra needed software, not OS

![IMG]()

### Docker
![IMG]()
