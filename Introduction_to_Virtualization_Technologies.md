### Virtualization

### Bare bone installation
Before virtualization an application was deployed on single hardware.
This approach had several downfalls:
  - application was not used to the full capabilities
  - if we wanted to scale up new hardware had to be purchased
  - slow deployment
  - hard to migrate from one vendor to another as we had to consider dependencies
  - big costs


![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/pre_virtualization.png)

### Hypervisor virtualization
To address this limitation Hypervisor-based Virtualization was introduced.
Each application was deployed within a Virtual Machine(VM) with it's own operation system(OS), memory, CPU, storage etc.
Still each application had to have it's own kernel. While this approach was
better it still had some limitations as it lacked full portability.

Benefits:
  - cost efficient
  - Easy to scale

Limitations:
  - Kernel Resource Duplication
  - Application Portability Issue

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/hypervisor.png)

### Container based Virtualization

Container based virtualization addresses the hypervisor based virtualization. This type of virtualization introduces another abstract level,
The Container Engine level. In Hypervisor mode virtualization happens at hardware level, and for the container based, the virtualization happens at OS level.
One kernel will be used among different containers.
Within a container only the specific application binaries/libraries will be used, no extra software, no OS.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/hyper_vs_container.png)

### Docker
![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/container_virt.png)
