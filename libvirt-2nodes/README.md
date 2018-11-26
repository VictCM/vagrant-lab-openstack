### Virtualbox-based 3-nodes Openstack Kolla lab

For this lab we want to run a distributed system configuration - having 3 nodes (2 controllers, one compute) deployed from a simple node running Kolla and libvirt as virtualization engine, which enables us to benefit from nested virtualization.

At the moment the public network using neutron external interface does not work. It seems to be related to the underlying macvlan driver in use to share the physical interface.

## physical architecture

```
                                 ┌─────────────────────────────────────────────────────────────────────────────────┐
                                 │       Vagrant generated virtual infrastructure on a physical server             │
                                 │ ┌────────────────┐ ┌────────────────┐ ┌────────────────┐   ┌────────────────┐   │
                                 │ │ 192.168.50.75  │ │ 192.168.50.76  │ │ 192.168.50.77  │   │ 192.168.50.78  │   │
                                 │ ├────────────────┤ ├────────────────┤ ├────────────────┤   ├────────────────┤   │
                                 │ │                │ │                │ │                │   │                │   │
                                 │ │                │ │                │ │                │   │                │   │
                                 │ │  deploy        │ │ controller01   │ │ controller02   │   │ compute01      │   │
                                 │ │                │ │                │ │                │   │                │   │
                                 │ │                │ │                │ │                │   │                │   │
                                 │ └─────┬──────┬───┘ └─┬──────┬──────┬┘ └─┬──────┬──────┬┘   └─┬──────┬──────┬┘   │
                                 │       │eth0  │       │eth0  │eth1  │    │eth0  │eth1  │      │eth0  │eth1  │    │
                                 │       └───┬──┘       └──┬───┴──┬───┘    └──┬───┴──┬───┘      └──┬───┴──┬───┘    │
                                 └──────┬────┼─────────────┼──────┼───────────┼──────┼─────────────┼──────┼───┬────┘
                                        │    │             │      │           │      │             │      │   │     
┌────────────────────────┐              │    └─────────────┴──────┴──────┬────┴──────┴─────────────┴──────┘   │     
│                        │              │                          ┌─────┴─────┐                              │     
│     Router             │              └──────────────────────────┤  ens18f1  ├──────────────────────────────┘     
│                        │                                         └─────┬─────┘                                    
│     192.168.50.253/24  │                                               │                                          
│                        ├───────────────────────────────────────────────┴──────────────────────────────────────────
│                        │                                                                                          
└────────────────────────┘                                                                                          
```

## logical architecture

```
                                   ┌───────────────────────────┐       ┌───────────────────────────┐                  
                                   │                           │       │                           │                  
                                   │     Openstack web/API     │       │     Openstack VMs         │                  
                                   │                           │       │                           │                  
                                   │     192.168.50.68/24      │       │   192.168.50.150-170/24   │                  
                                   │                           │       │   ┌───────────┐           │                  
                                   │                           │       │   │ physnet1  │           │                  
                                   └───────────┬───────────────┘       └───┴─────┬─────┴───────────┘                  
┌────────────────────────┐                     │                                 │                                    
│                        │                     │                                 │                                    
│     Router             │                     │                                 │                                    
│                        │                     │                                 │                                    
│     192.168.50.253/24  ├─────────────────────┴─────────────────────────────────┴────────────────────────────────────
│                        │                                                                                            
│                        │                                                                                            
└────────────────────────┘                                                                                            
```

## how to run

```
vagrant up
```

## how to access

The floating IP address is currently set at 192.168.50.68, with labuser/labpassword. The public network is automatically configured. 
