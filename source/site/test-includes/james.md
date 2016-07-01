---
title: Cisco Application Centric Infastructure Programmability

version: V1.0 

copyright: Copyright &copy; 2016 by Cisco Systems, Inc. All Rights Reserved.

publisher: "Cisco Systems"

publisher_address: "170 West Tasman Dr., San Jose, CA 95134, USA"

comments: "support.cisco.com"

titlePage: ON

tableOfContents: ON

tocAccordian: OFF

rightPanel: ON

leftPanel: ON

documentSearch: ON

toc_selectors: "h1,h2,h3"

language_tabs:
  - python: Python
  - http: HTTP
  
toc_footers:

---
# Introduction to ACI Programmability

The Cisco ACI programmability model allows complete programmatic access to the application centric infrastructure. With this access, customers can integrate network deployment into management and monitoring tools and deploy new workloads programmatically. 

ACI Fabric is configured using an abstract policy model on the Cisco Application Policy Infrastructure Controller (APIC). The APIC has a very rich and complete object model that is accessible through a programmatic REST API. The API accepts and returns HTTP or HTTPS messages that contain JavaScript Object Notation (JSON) or Extensible Markup Language (XML) documents. You can use any programming language to generate the messages and the JSON or XML documents that contain the API methods or managed object (MO) descriptions. 

In addition to standard REST interface, Cisco provides several open source tools/frameworks to automate and program the APIC: ACItoolkit, Cobra (Python), ACIrb (Ruby), Puppet, Ansible etc. 

This section introduces the user to some basic APIC configuration use cases such as Physical domain config, VLAN pool creation and Tenant config.

# Configuration

## Physical Domain


> ACI REST

```
# : Configure Physical domain and Attach VLAN pool to it

POST URL: http://APIC-IP/api/node/mo/uni.json
Content-Type: application/json
Cache-Control: no-cache
POST BODY :
{
    "physDomP": {
        "attributes": {
			"name": "test_phy_dmn",
			"dn": "uni/phys-test_phy_dmn"
		},
		"children": [
			{
				"infraRsVlanNs": {
					"attributes": {
						"tDn": "uni/infra/vlanns-[test_vlan]-dynamic"
					}
				}
			}
        ]
    }
}
```


> Python

```python
"""
It logs in to the APIC and will create the physical domain.
"""
import acitoolkit.acitoolkit as aci

# Define static values to pass (edit these if you wish to set differently)
DEFAULT_PHY_DOMAIN_NAME = 'test_phy_dmn'


def main():
    """
    Main create tenant routine
    :return: None
    """
    # Get all the arguments
    description = 'It logs in to APIC and will create the physical domain.'
    creds = aci.Credentials('apic', description)
    creds.add_argument('-p', '--phy_domain', 
                       help='The name of physical domain',
                       default=DEFAULT_PHY_DOMAIN_NAME)
    args = creds.get()

    # Login to the APIC
    session = aci.Session(args.url, args.login, args.password)
    resp = session.login()
    if not resp.ok:
        print('%% Could not login to APIC')

    # Create the physical Domain
    phy_dmn = aci.PhysDomain(args.phy_domain)

    # Push the physical domain to the APIC
    resp = session.push_to_apic(phy_dmn.get_url(),
                                phy_dmn.get_json())
    if not resp.ok:
        print('%% Error: Could not push configuration to APIC')
        print(resp.text)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
```


The physical domain profile, which stores the physical resources (ports and port-channels) and encapsulate resources (VLAN/VXLAN) that should be used for endpoint groups associated with this domain. The following example shows the creation of the physical domain by attaching AEP and VLAN pools.

## VLAN Pool


> ACI REST

```
Configure VLAN Pool with vlan range

POST URL: http://APIC-IP/api/node/mo/uni/infra/vlanns-[test_vlan]-dynamic.json
Content-Type: application/json
Cache-Control: no-cache
POST BODY :
{
    "fvnsVlanInstP":{
        "attributes":{
            "name":"test_vlan"
        },
        "children":[
            {
                "fvnsEncapBlk":{
                    "attributes":{
                        "from":"vlan-222",
                        "to":"vlan-223"
                    }
                }
            }
        ]
    }
}
```


> Python

```python
"""
It logs in to the APIC and will create the vlan pool.
"""
import acitoolkit.acitoolkit as aci

# Define static values to pass (edit these if you wish to set differently)
DEFAULT_VLAN_NAME = 'test_vlan'


def main():
    """
    Main create tenant routine
    :return: None
    """
    # Get all the arguments
    description = 'It logs in to the APIC and will create the vlan pool.'
    creds = aci.Credentials('apic', description)
    creds.add_argument('-v', '--vlan', help='The name of vlan pool',
                       default=DEFAULT_VLAN_NAME)
    args = creds.get()

    # Login to the APIC
    session = aci.Session(args.url, args.login, args.password)
    resp = session.login()
    if not resp.ok:
        print('%% Could not login to APIC')

    # Create the VLAN pool
    vlan_pool = aci.NetworkPool(args.vlan, 'vlan', '222', '223', 'dynamic')

    # Push the VLAN pool to the APIC
    resp = session.push_to_apic(vlan_pool.get_url(),
                                vlan_pool.get_json())
    if not resp.ok:
        print('%% Error: Could not push configuration to APIC')
        print(resp.text)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
```


The VLAN range namespace policy, which defines for ID ranges used for VLAN encapsulation. The following example creates a pool of VLANs.

## Tenant Configuration

> ACI REST

```
Script:
-------

#Configure a tenant

POST URL: http://APIC-IP/api/mo/uni.json
Content-Type: application/json
Cache-Control: no-cache
POST BODY :
{
    "fvTenant": {
        "attributes": {
            "name": "test_tenant"
        }
    }
}


Sandbox:
--------

Setup postman Code snippet:
In order to execute the ACI-REST from postman the login needs to be performed first. The cookie would get generated
and stored for subsequent execution.

POST-URL : http://APIC-IP/api/aaaLogin.json
Content-Type: application/json
POST BODY :
{
	"aaaUser" : {
		"attributes" : {
			"name" : "APIC_USER",
			"pwd" : "APIC_PASSWORD"
		}
	}
}

Executing ACI-REST using postman for first time:
```


> Python

```python
"""
It logs in to the APIC and will create the tenant.
"""
import acitoolkit.acitoolkit as aci

# Define static values to pass (edit these if you wish to set differently)
DEFAULT_TENANT_NAME = 'test_tenant'


def main():
    """
    Main create tenant routine
    :return: None
    """
    # Get all the arguments
    description = 'It logs in to the APIC and will create the tenant.'
    creds = aci.Credentials('apic', description)
    creds.add_argument('-t', '--tenant', help='The name of tenant',
                       default=DEFAULT_TENANT_NAME)
    
    args = creds.get()

    # Login to the APIC
    session = aci.Session(args.url, args.login, args.password)
    resp = session.login()
    if not resp.ok:
        print('%% Could not login to APIC')

    # Create the Tenant
    tenant = aci.Tenant(args.tenant)

    # Push the tenant to the APIC
    resp = session.push_to_apic(tenant.get_url(),
                                tenant.get_json())
    if not resp.ok:
        print('%% Error: Could not push configuration to APIC')
        print(resp.text)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass
		
		
		
Sandbox:
--------
# Installation

## Environment

Required

* Python 2.7+
* [setuptools package](https://pypi.python.org/pypi/setuptools)

## Downloading

If you have git installed, clone the repository

    git clone https://github.com/datacenter/acitoolkit.git

## Installing

After downloading, install using setuptools.

    cd acitoolkit
    python setup.py install

If you plan on modifying the actual toolkit files, you should install the developer environment that will link the package installation to your development directory.

    cd acitoolkit
    python setup.py develop


# ACI Toolkit Samples #

This directory contains sample scripts that use the python library.

### Set up ###

In order to use the examples in this directory, it is important to set the PYTHONPATH variable to include the path to the ACI toolkit or have installed the acitoolkit using setup.py.

### credentials.py ###

Many of the samples in this directory use the file credentials.py to login to the APIC.  Before running, edit the credentials.py with the username, password, and IP address for your environment.

## To execute the sample files

    1.	cd samples
    2.	vi example.py (Copy the script here)
    3.	Execute the script. example: python example.py
```


The VLAN range namespace policy, which defines for ID ranges used for VLAN encapsulation. Following example creates a pool of VLANs.

