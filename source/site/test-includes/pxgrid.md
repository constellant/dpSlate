---  

title: "pxGrid SDK Tutorial"  

version: "V2.0" 

copyright: "Copyright &copy; 2013-2016 Cisco Systems, Inc. All Rights Reserved."  

publisher: "Cisco Systems"  

comments: ""

publisher_address: "170 West Tasman Drive, San Jose, CA 95134 USA"  

titlePage: ON  

tableOfContents: ON  

tocAccordian: ON  

rightPanel: ON  

leftPanel: ON  

documentSearch: ON  

language_tabs:  
  - java: Java  
  - c: C  
  
  
toc_selectors: "h1,h2,h3,h4,h5"  
  
toc_footers:  

---  

# Introduction  


Cisco Platform Exchange Grid (pxGrid) enables multivendor, cross-platform network system collaboration among parts of the IT infrastructure such as security monitoring and detection systems, network policy platforms, asset and configuration management, identity and access management platforms, and virtually any other IT operations platform. When business or operational needs arise, ecosystem partners use pxGrid to exchange contextual information with Cisco products that support pxGrid.  

Cisco pxGrid provides a unified framework that enables ecosystem partners to integrate to pxGrid once, then share context either uni or bidirectionally with many platforms without the need to adopt platform-specific APIs. pxGrid is secure and customizable, enabling partners to share only what they want to share and consume only context relevant to their platform. Key features of pxGrid include:  

- Ability to control what context is shared and with which platforms. Because pxGrid is customizable, partners can "publish" only the specific contextual information they want to share and can control the partner platform that information gets shared with.  
- Bidirectional context sharing - pxGrid enables platforms to both share or publish context as well as consume or "subscribe to" context from specific platforms. These features are orchestrated and secured by the pxGrid server.  
- Ability to share context data in native formats - Contextual information shared via pxGrid is done in each platform's native data format.  
- Ability to connect to multiple platforms simultaneously - pxGrid enables platforms to publish only the context data relevant to partner platforms. Numerous context "topics" may be customized for a variety of partner platforms, yet always shared via the same reusable pxGrid framework. Furthermore, only sharing relevant data enables both publishing and subscribing platforms to scale their context sharing by eliminating excess, irrelevant data.  
- Integration with Cisco platforms - pxGrid provides a unified method of publishing or subscribing to relevant context with Cisco platforms that utilize pxGrid for 3rd party integrations.  

Currently, client libraries are available for the C and Java programming languages. This document focuses mainly on the Java API, but also gives some samples for the C API. For reference, the <a href="/site/pxgrid/documents/api-reference/index.gsp">Java API documentation</a> is also available as part of this SDK distribution.  

# Prerequisites  

This document is intended for developers and assumes:  

* You have an understanding of pxGrid concepts, refer to the <a href="/site/pxgrid/documents/technical-overview/">pxGrid Technical Overview</a>. 
* You have installed and set up ISE, refer to the pxGrid Testing and Configuration Guide under Documents for the appropriate version.
* You have unpackaged the SDK into a directory herein referred to as &lt;SDK_HOME&gt; and have successfully executed the sample scripts, refer to the pxGrid Testing and Configuration Guide under Documents for the appropriate version. 
* You have moderate experience with compiling and running Java programs. If you are coding in C, refer to <a href="/site/pxgrid/">pxGrid Coding in C</a>.

# Programming Environment  

As with any software programming project, you must first set up the programming environment with the appropriate dependencies. The details for this largely depend on the type of development tools being used. However, pxGrid provided its Java SDK as JAR files just like other Java-based systems.  
These need to be in your classpath for your code to compile. All libraries (including dependencies) are located in the directory &lt;SDK_HOME&gt;/lib. The SDK samples are located in separate &lt;SDK_HOME&gt;/samples/lib. However, if you are writing code that doesn't depend on samples source, you just need to include all JAR files in &lt;SDK_HOME&gt;/lib in your classpath.  

# Building a Sample Application  

In this tutorial we will create a basic pxGrid client that retrieves session information in real-time from ISE.  
Whenever wireless devices connect to or disconnect from the network, ISE will publish session notifications through pxGrid. Our simple application will receive these notifications and print relevant session information to the console. Of course, a real-world application will do more than just print session information. Having context from ISE, updated in real-time, applications can perform a virtually unlimited set of functions. However, we will keep things simple for the purpose of this tutorial. We will also show how to use other parts of the API such as querying for a specific session and downloading all active sessions at once. Having read the pxGrid Programming Guide, you are familiar with  

* [Configuring a pxGrid Connection](#configuring-a-pxgrid-connection)  
* [Connecting to the pxGrid Controller](#connecting-to-the-pxgrid-controller)  
* [Subscribing to Session Notifications](#subscribing-to-session-notifications)  
* [Querying for Specific Sessions](#querying-for-specific-sessions)  
* [Downloading All Sessions in Bulk](#downloading-all-sessions-in-bulk)  
* [Disconnecting from the pxGrid Controller](#disconnecting-from-the-pxgrid-controller)  

## Configuring a pxGrid Connection  

Refer to the Java and C language tabs and associated code in the right hand panel.  



```java  
// configure the connection properties

        TLSConfiguration config = new TLSConfiguration();
        config.setHosts(new String[]{"ise.my_server.com"});
        config.setUserName("my_client");
        config.setGroup(Group.SESSION.value());
        config.setKeystorePath("my_keystore.jks");
        config.setKeystorePassphrase("my_password");
        config.setTruststorePath("my_truststore.jks");
        config.setTruststorePassphrase("my_password");
```



```c  
int user_password_cb(char *buf, int size, int rwflag, void *user_data) {
    strncpy(buf, key_password, size);
    buf[size - 1] = '\0';
    return strlen(key_password);
}

void user_ssl_ctx_cb(pxgrid_connection *connection, void *_ssl_ctx, void *user_data) {
    SSL_CTX *ssl_ctx = _ssl_ctx;
    SSL_CTX_set_default_passwd_cb(ssl_ctx, user_password_cb);
    SSL_CTX_use_certificate_chain_file(ssl_ctx, "clientSample1.crt");
    SSL_CTX_use_PrivateKey_file(ssl_ctx, "clientSample1.key", SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, "rootSample.crt", NULL);
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);
}
```  

```output  
pxgrid_config *config;
pxgrid_config_create(&config);
const char *hostnames[] = { "ise.my_server.com" };
pxgrid_config_set_hosts(config, hostnames, 1);
pxgrid_config_set_user_name(config, "my_client");
pxgrid_config_set_description(config, "description of my_client");
pxgrid_config_set_ssl_context_cb(config, ssl_context_cb);
pxgrid_connection_set_ssl_ctx_cb(connection, user_ssl_ctx_cb);
```  


Before a pxGrid client can connect to the pxGrid Controller, a <a href="/site/pxgrid/documents/api-reference/">TLSConfiguration (for Java)</a> object needs to be instantiated and set with the appropriate properties. For C, refer to [session subscribe](#sessionSubscribeC). Most properties are used to set up the following security mechanisms. In the next few paragraphs we describe security in general to give context around why pxGrid needs certain properties.  

Internally, the pxGrid client library uses encryption at the transport layer (TLS with mutual authentication) in all communication with the pxGrid Controller. This requires a key store and a trust store. The key store contains the certificate/key pair that gets used during the TLS handshake between the pxGrid client and the pxGrid Controller. Currently the Java API only supports JKS key stores. You specify the key store location in the keystorePath property. You'll also need to set the keystorePassphrase property since key stores are password-protected. The trust store contains the certificate of the certificate authority (CA) that signed the pxGrid Controller certificate.  
If the CA certificate is part of a chain, be sure to add the entire chain to the trust store. Like with the key store, the trust store takes the form of a JKS file. You specify the trust store location in the truststorePath property.  

The property username is used to specify the name of the client trying to connect. This value must be unique for each client trying to connect. When you connect using a certain username for the first time, the certificate used in the TLS handshake is associated with the username on the pxGrid Controller. To connect again, the same certificate must be used. Otherwise, authentication will fail.  

Note: Refer to the following documents when testing self-signed certificates:

* For <a href="http://www.cisco.com/c/dam/en/us/td/docs/security/ise/how_to/HowTo-90-Self_signed_pxGridClient_selfsigned_pxGrid.pdf">self-signed certificates</a> 
* For <a href="http://www.cisco.com/c/dam/en/us/td/docs/security/ise/how_to/HowTo-89-CA_signed_pxGridISEnode_CAsigned_pxGridclient.pdf">CA-signed certificates</a>



pxGrid uses group-based authorization. When a client connects for the first time, the client is associated with a group. Currently pxGrid supports the following groups: Basic, Session, EPS, and ANC.  
Clients in the Basic group can only connect and perform very basic functions. Clients in the Session group can perform everything in the Basic group along with other actions such as subscribing to session notifications, querying for session information, and downloading session information in bulk. Clients in the EPS group can perform everything allowed in the Session group along with other actions such as quarantining an IP address and unquarantining an IP address. Note that by specifying the group property in the configuration, you are merely asking to register as a member of the group.  
Administrators have control over your group membership in the  administration console. The following summarizes the groups and access:  

Basic | Session | EPS | ANC  
----- | ------- | --- | ---  
connect only | connect, consumer session information | connect, consumer session information, invoke EPS actions | connect, consumer session information, invoke ANC actions  

For this tutorial, we specify Session as the group so we can later subscribe to session notifications.  

Other properties unrelated to security are part of the TLSConfiguration. Hosts refers to the pxGrid Controller hostnames. In a simple setup, there will be only one host. In a high-availability environment, there will be an active and a standby host. Specify the active hostname first and the standby hostname second. Finally, you can set a description. Although optional, this property will associate a more verbose description of your client with your account for the administrator to see.  


## Connecting to the pxGrid Controller  

Refer to the Java and C language tabs and sample code in the right hand panel.  



```java  
// establishing a connection with the pxGrid controller

GridConnection con = new GridConnection(config);
ReconnectionManager recon = new ReconnectionManager(con);
recon.setRetryMillisecond(2000);
recon.start();
```  



```c  
pxgrid_connection *connection = NULL;

pxgrid_connection_create( &connection );
pxgrid_connection_set_config(connection , config);
PXGRID_STATUS status = pxgrid_connection_connect(connection);
```  

Clients actually establish a connection with the pxGrid Controller by calling either the 'connect' method of the <a href="/site/pxgrid/documents/api-reference/index.gsp">GridConnection</a> class for Java or using the <a href="/site/pxgrid/documents/api-reference/index.gsp">ReconnectionManager</a> class for Java. For C and using the ReconnectionManager, refer to session_subscriber_reconnection.c in the SDK.


GridConnection.connect will establish the connection but won't provide fault tolerance. In the event the connection is broken, the client remains unconnected to the pxGrid Controller, unable to receive notifications, issue queries, or issue bulk download requests. For this reason we strongly recommend you use the ReconnectionManager.  
Like the GridConnection.connect, the ReconnectionManager will establish the connection but with the added benefit of fault tolerance. In the event the connection is broken, the ReconnectionManager will attempt to reconnect for you.  
The ReconnectionManager.setRetryMilliseconds method allows you to control the retry interval. Try to keep that value on the order of multiple seconds.  

If the client is connecting to the pxGrid Controller for the first time, an account is established on the pxGrid Controller. In pxGrid's auto-registration mode (set by administrator through the ISE web-based user interface), the client is allowed to communicate once the account is created. Whereas if auto registration mode is turned off, the node and authorization group assignment of the node remains in Pending Approval mode and not allowed to communicate over pxGrid until it is approved by the administrator.  


## Subscribing to Session Notifications  

Refer to the Java and C language tabs and sample code in the right hand panel.  


```java  
// creating a custom session notification handler

public class SampleNotificationHandler
    implements SessionDirectoryNotification
{
    @Override
    public void onChange(Session session) {
        System.out.println("received session: " + session.getGid());
    }
}
```  



```c  
static void message_callback(jw_dom_node *node, void *arg) {
	// execute logic here
}


pxgrid_capability *capability;
pxgrid_capability_create(&capability);
if(!capability) exit(EXIT_FAILURE);

const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
const char cap_name[] = "SessionDirectoryCapability";

pxgrid_capability_set_namespace(capability, ns_iden);
pxgrid_capability_set_name(capability, cap_name);
pxgrid_capability_subscribe(capability, connection);

const char sess_notif[] = "sessionNotification";
pxgrid_connection_register_notification_handler(connection,
	ns_iden,
	sess_notif,
	message_callback,
	NULL);
```  

ISE receives session updates from devices as they connect, authenticate, and disconnect from the network.  
As a client to pxGrid, ISE publishes these updates to pxGrid so other clients can receive real-time notification of this network activity. You can receive these notifications by performing two steps.  

First, create a custom implementation of <a href="/site/pxgrid/documents/api-reference/">SessionDirectoryNotification</a> for Java.
There is only one method to be concerned with, called 'onChange'. This method will get called internally by the pxGrid client library when session updates are received from the pxGrid controller. For the purposes of demonstration, the implementation below simply prints out the GID of the session. Your real-world implementation will obviously do much more. Keep in mind that you will need to build thread safety into your implementation.  
You can expect that 'onChange' will get called by multiple threads at the same time. Take this into account when writing your code.  


</br>
</br>
</br>





```java  
// creating a custom session notification handler  

SampleNotificationHandler handler = new SampleNotificationHandler();
SessionDirectoryFactory.registerNotification(con, handler);
```  

</br>
</br>
</br>
</br>



Second, create an instance of your handler and register the instance with your pxGrid connection using the <a href="/site/pxgrid/documents/api-reference/">SessionDirectoryFactory</a> class for Java as follows. For details refer to the sample source code in the Java and C language tabs in the right hand panel.  




> Create an instance of your handler and register the instance with your pxGrid connection using the SessionDirectoryFactory class  

```java  
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.core.SubnetContentFilter;
import com.cisco.pxgrid.model.net.Session;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;
import com.cisco.pxgrid.stub.identity.SessionDirectoryNotification;

/**
 * Demonstrates how to subscribe to session notifications generated by ISE
 */
public class SessionSubscribe {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		SubnetContentFilter filter = helper.promptIpFilters("Filters (ex. '1.0.0.0/255.0.0.0,1234::/16,...' or <enter> for no filter): ");

		if (filter != null) {
			SessionDirectoryFactory.registerNotification(grid, new SampleNotificationHandler(), filter);
		} else {
			SessionDirectoryFactory.registerNotification(grid, new SampleNotificationHandler());
		}

		helper.prompt("press <enter> to disconnect...");
		helper.disconnect();
	}

	public static class SampleNotificationHandler
		implements SessionDirectoryNotification {
		@Override
		public void onChange(Session session) {
			System.out.println("session notification: "); 
			SampleHelper.print(session);
			System.out.println(""); 
		}
	}
}
```  




```c  
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)


int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }

static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
	helper_print_jw_dom(node);
}

int main(int argc, char **argv) {
    PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE);
	} 
pxgrid_log_set_level(PXGRID_LOG_DEBUG);
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

    pxgrid_connection_connect(connection);
	    
	pxgrid_capability *capability;
	pxgrid_capability_create(&capability);
	 if(!capability) exit(EXIT_FAILURE);
    
    const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
    const char cap_name[] = "SessionDirectoryCapability";
    
    pxgrid_capability_set_namespace(capability, ns_iden);
	pxgrid_capability_set_name(capability, cap_name);

   pxgrid_capability_subscribe(capability, connection);
   
   const char sess_notif[] = "sessionNotification";
   
	pxgrid_connection_register_notification_handler(connection, ns_iden, sess_notif, message_callback, NULL);
	
	sleep(600);

	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
    helper_config_destroy(hconfig);
 	return 0;
}
```  


</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>

In addition to subscribing to session notifications, you can also subscribe to identity group notifications. The setup is similar to above. For details refer to the sample source code in the Java and C language tabs in the right hand panel.  

> Subscribe to identity group notifications  



```java  
package com.cisco.pxgrid.samples.ise;

import java.util.List;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.identity.IdentityGroupNotification;
import com.cisco.pxgrid.model.net.Group;
import com.cisco.pxgrid.model.net.User;
import com.cisco.pxgrid.stub.identity.IdentityGroupNotificationCallback;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;

/**
 * Demonstrates how to use an xGrid client to subscribe to identity group notifications.
 */	
public class UserIdentityGroupSubscribe {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		SessionDirectoryFactory.registerNotification(grid, new SampleNotificationHandler());

		helper.prompt("Press <enter> to disconnect...");
		helper.disconnect();
	}
	
	private static class SampleNotificationHandler implements IdentityGroupNotificationCallback {
		@Override
		public void handle(IdentityGroupNotification notf) {
			List<User> users = notf.getUsers();
			if (users != null) {
				for (User user : users) {
					System.out.println("user=" + user.getName());
					for (Group group : user.getGroupList().getObjects()) {
						System.out.println("group=" + group.getName());
					}
				}
			}
		}
		
	}

}
```  



```c  
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 
static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
	helper_print_jw_dom(node);
}

int main(int argc, char **argv) {
	PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE);
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

       
    pxgrid_connection_connect(connection);
	   

	pxgrid_capability *capability = NULL;
	pxgrid_capability_create(&capability);
    
    if(!capability) exit(EXIT_FAILURE);

    const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
    const char cap_name[] = "IdentityGroupCapability";
    
    pxgrid_capability_set_namespace(capability, ns_iden);
	pxgrid_capability_set_name(capability, cap_name);

	pxgrid_capability_subscribe(capability, connection);

    const char notif_name[] = "identityGroupNotification";
    
    pxgrid_connection_register_notification_handler(connection, ns_iden, notif_name, message_callback, NULL);

	sleep(600);

	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
    helper_config_destroy(hconfig);
 	return 0;
}
```  



## ANC Specific Details  

Refer to the ANC information and language tabs with sample code in the right hand panel.  



> ANC Notifications  


```java  
// creating a custom ANC notification handler

public class ANCNotificationHandlers {
  public static class CreatePolicyNotificationCallback implements NotificationCallback {
    @Override
    public void handle(BaseMsg message) {
      CreatePolicyNotification notf = (CreatePolicyNotification) message;
      System.out.println("\nCreatePolicyNotification:");
      System.out.println(policyToString(notf.getAncPolicy()));
    }
  }

  public static class UpdatePolicyNotificationCallback implements NotificationCallback {
    @Override
    public void handle(BaseMsg message) {
      UpdatePolicyNotification notf = (UpdatePolicyNotification) message;
      System.out.println("\nUpdatePolicyNotification:");
      System.out.println("Old policy: ");
      System.out.println(policyToString(notf.getAncOldPolicy()));
      System.out.println("New policy: ");
      System.out.println(policyToString(notf.getAncNewPolicy()));
    }
  }

  public static class DeletePolicyNotificationCallback implements NotificationCallback {
    @Override
    public void handle(BaseMsg message) {
      DeletePolicyNotification notf = (DeletePolicyNotification) message;
      System.out.println("\nDeletePolicyNotification:");
      System.out.println(policyToString(notf.getAncPolicy()));
    }
  }
}
```  



```c  
    void subscribe(pxgrid_connection *connection) {
    	const char ns_iden[] = "http://www.cisco.com/pxgrid/anc";
    	const char apply_endpoint_policy_notif[] = "ApplyEndpointPolicyNotification";
    	pxgrid_connection_register_notification_handler(connection, ns_iden, apply_endpoint_policy_notif, message_callback, NULL);
    	const char clear_endpoint_policy_notif[] = "ClearEndpointPolicyNotification";
    	pxgrid_connection_register_notification_handler(connection, ns_iden, clear_endpoint_policy_notif, message_callback, NULL);
    	const char create_policy_notif[] = "CreatePolicyNotification";
    	pxgrid_connection_register_notification_handler(connection, ns_iden, create_policy_notif, message_callback, NULL);
    	const char delete_policy_notif[] = "DeletePolicyNotification";
    	pxgrid_connection_register_notification_handler(connection, ns_iden, delete_policy_notif, message_callback, NULL);
    	const char update_policy_notif[] = "UpdatePolicyNotification";
    	pxgrid_connection_register_notification_handler(connection, ns_iden, update_policy_notif, message_callback, NULL);

    }

    void message_callback(jw_dom_node *node, void *arg) {
    	UNUSED(arg);
    	helper_print_jw_dom(node);
    }
```  

> ANC Actions  



```java  
public class ANCActions {
    ANCClient client = new ANCClient();
		ANCQuery query = client.createANCQuery(grid);

    ANCResult result = null;
    ANCResponse resp;
    ANCPolicy ancPolicy;

    case 1: //delete policy
      policyName = helper.prompt("Policy name (or <enter> to disconnect): ");
      if (policyName == null) break operationLoop;
      DeletePolicyRequest deletePolicyRequest = new DeletePolicyRequest();
      deletePolicyRequest.setName(policyName);
      resp = (ANCResponse)grid.query(capRef, deletePolicyRequest, MAX_GRID_TIME_OUT_IN_MILLI_SEC);
      result = resp.getAncResult();
      break;
    case 2: //get policy by name
      policyName = helper.prompt("Policy name (or <enter> to disconnect): ");
      if (policyName == null) break operationLoop;
      GetPolicyByNameRequest getPolicyByNameRequest = new GetPolicyByNameRequest();
      getPolicyByNameRequest.setName(policyName);
      resp = (ANCResponse)grid.query(capRef, getPolicyByNameRequest, MAX_GRID_TIME_OUT_IN_MILLI_SEC);
      result = resp.getAncResult();
      break;
    case 3: //retrieve all policies
      GetAllPoliciesRequest getAllPoliciesRequest = new GetAllPoliciesRequest();
      resp = (ANCResponse)grid.query(capRef, getAllPoliciesRequest, MAX_GRID_TIME_OUT_IN_MILLI_SEC);
      result = resp.getAncResult();
      break;
}
```  




```c  
 pxgrid_capability_create(&capability);
 pxgrid_capability_set_namespace(capability, "http://www.cisco.com/pxgrid/anc");
 pxgrid_capability_set_name(capability, "AdaptiveNetworkControlCapability");
 pxgrid_capability_subscribe(capability, connection);

case 1:
    helper_prompt("Policy name: ", policy_name);
    anc_deletePolicyRequest(connection, capability, policy_name);
    break;
case 2:
    helper_prompt("Policy name: ", policy_name);
    anc_getPolicyByName(connection, capability, policy_name);
    break;
case 3:
    anc_getAllPolicies(connection, capability);
    break;
```  


## Querying for Specific Sessions  

Refer to the Java and C language tabs and sample code in the right hand panel.  

> Querying for specific sessions  



```java  
// create query we'll use to make call

SessionDirectoryQuery query = SessionDirectoryFactory.createQuery(con);
InetAddress ip InetAddress.getByName("1.2.3.4");
Session session = query.getActiveSessionByIPAddress(ip);
System.out.println("received session: " + session.getGid());
```  


```c  
jw_err err;
jw_dom_ctx_type *ctx;
jw_dom_node *request;
jw_dom_node *ip_interface;
jw_dom_node *ip_address;
jw_dom_node *ip_address_text;
jw_dom_node *response;

if (!jw_dom_context_create(&ctx, &err)
   || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getActiveSessionByIPAddressRequest", &request, &err)
   || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}ipInterface", &ip_interface, &err)
   || !jw_dom_add_child(request, ip_interface, &err)
   || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}ipAddress", &ip_address, &err)
   || !jw_dom_add_child(ip_interface, ip_address, &err)
   || !jw_dom_text_create(ctx, ip, &ip_address_text, &err)
   || !jw_dom_add_child(ip_address, ip_address_text, &err)
   )
{
    jw_log_err(JW_LOG_ERROR, &err, "query");
    return;
}

PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
if (status == PXGRID_STATUS_OK) {
    helper_print_jw_dom(response);
	printf("*** queried\n");
}
else {
    printf("status=%s\n", pxgrid_status_get_message(status));
}
```  
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>

Perhaps there is a specific session you are interested in, and you only know a characteristic of the session such as an IP address. Through pxGrid, you can query ISE for the particular session. This and many other types of queries can be initiated using the <a href="/site/pxgrid/documents/api-reference">SessionDirectoryQuery</a> class. To retrieve a session by its IP address, provide the IP address to the getActiveSessionByIPAddress method as shown below.  

For details refer to the sample source code in the Java and C language tabs in the right hand panel.  

> Query ISE for a particular session using the SessionDirectoryQuery class  



```java  
package com.cisco.pxgrid.samples.ise;

import java.net.InetAddress;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.net.Session;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;
import com.cisco.pxgrid.stub.identity.SessionDirectoryQuery;

/**
 * Demonstrates how to query ISE for an active session by IP address
 */
public class SessionQueryByIp {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		SessionDirectoryQuery query = SessionDirectoryFactory
				.createSessionDirectoryQuery(grid);

		while (true) {
			String ip = helper.prompt("IP address (or <enter> to disconnect): ");
			if (ip == null)	break;

			Session session = query.getActiveSessionByIPAddress(InetAddress
					.getByName(ip));
			if (session != null) {
				SampleHelper.print(session);
			} else {
				System.out.println("session not found");
			}
		}
		helper.disconnect();
	}
}
```  



```c  
#include <stdlib.h>
#include <unistd.h>
#include "pxgrid.h"
#include "helper.h"
#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)
int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 static void query(pxgrid_connection *connection, pxgrid_capability *capability, char *ip) {
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *ip_interface;
	jw_dom_node *ip_address;
	jw_dom_node *ip_address_text;
	jw_dom_node *response;

    if (!jw_dom_context_create(&ctx, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getActiveSessionByIPAddressRequest", &request, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}ipInterface", &ip_interface, &err)
    	|| !jw_dom_add_child(request, ip_interface, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}ipAddress", &ip_address, &err)
    	|| !jw_dom_add_child(ip_interface, ip_address, &err)
    	|| !jw_dom_text_create(ctx, ip, &ip_address_text, &err)
    	|| !jw_dom_add_child(ip_address, ip_address_text, &err)
    	)
    {
    	jw_log_err(JW_LOG_ERROR, &err, "query");
    	return;
    }

    printf("***request=");
    helper_print_jw_dom(request);

    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
    if (status == PXGRID_STATUS_OK) {
        printf("***response=");
    	helper_print_jw_dom(response);
    }
    else {
    	printf("status=%s\n", pxgrid_status_get_message(status));
    }
}

int main(int argc, char **argv) {
   PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE);
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

   
    
    pxgrid_connection_connect(connection);
	
	pxgrid_capability *capability;
	pxgrid_capability_create(&capability);
    
    if(!capability) exit(EXIT_FAILURE);
    
    const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
    const char cap_name[] = "SessionDirectoryCapability";
    
	pxgrid_capability_set_namespace(capability, ns_iden);
	pxgrid_capability_set_name(capability, cap_name);

   
	pxgrid_capability_subscribe(capability, connection);

    char            ip_address_str[48]          = {0};
    char            ip_address[48]              = {0};
    char            ip_address_extra_str[48]    = {0};

    printf("Get active session for IP Address: ");
    fgets(ip_address_str, sizeof(ip_address_str), stdin);
    sscanf(ip_address_str, "%s%[^\n]", ip_address, ip_address_extra_str);

	query(connection, capability, ip_address);

    memset(ip_address_str, 0, sizeof(ip_address_str));
    memset(ip_address, 0, sizeof(ip_address));
    memset(ip_address_extra_str, 0, sizeof(ip_address_extra_str));

	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
    helper_config_destroy(hconfig);
	return 0;
}
```  


</br>
</br>
</br>
</br>
</br>
</br>

As you can see from the API documentation for Java for <a href="/site/pxgrid/documents/api-reference/">SessionDirectoryQuery</a>, you can initiate a wide range of queries related to the session directory. In pxGrid terminology, these queries are all part of the Session Directory capability. Other capabilities are also supported. For example, pxGrid supports the Endpoint Protection Service (EPS) capability. Queries for the EPS capabilities are wrapped into the class <a href="/site/pxgrid/documents/api-reference/index.gsp">EPSQuery</a> for ease of use. Using the API you can, for example, quarantine an IP address. You can also find queries related to the Identity Group capability by using the <a href="/site/pxgrid/documents/api-reference/index.gsp">IdentityGroupQuery</a> class. You can, for example, retrieve the identity groups associated with a user.  


## Dynamic Topics  

This feature enables a client to create and setup a topic and its metadata for sharing the desired information. A registered client, regardless of the authorization group, shall be able to request the grid controller to setup a new topic by providing appropriate metadata. The ISE admin shall have the ability to approve/deny the new topic request. There will not be an auto-approval for create topic requests. There shall be notifications for the approval/denial actions. Once the topic is setup, the clients shall be able to perform operations such as publish, subscribe, query and action.  

The following attributes will be stored in the Oracle DB as part of the new topic request:  

Topic name  - name of the new topic  
Operation name – Name of the operation, an operation can be a query or action  
Operation type  - Denotes the type of operation, an operation type can be ‘Query’ or ‘Action’  
User – Authorized client who initiated the new topic request  
Status – Status of the new topic request - Pending, Approved, and more  

Three authorization groups for publish, subscribe, and action operations on the topic will be setup as part of the topic initialization. The client who requested the creation of topic will be associated with the publish authorization group by default.  

&lt;topic-name&gt;\_PUBLISH: Clients belonging to this group will have permission to publish to the new topic.  
&lt;topic-name&gt;\_SUBSCRIBE: Clients belonging to this group will have permission to subscribe and execute queries on the new topic.  
&lt;topic-name&gt;\_ACTION: Clients belonging to this group will have permission to execute any actions on the new topic.  

The ISE admin will be able to associate multiple authorization groups for a client. Clients can belong to more than one authorization group.  



```java  

1. Propose and modify a new capability

public class ProposeCapability {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection con = helper.connectWithReconnectionManager();

        con.registerTopicChangeCallback(new SampleNotificationCallback());

		CoreClientStub coreClient = new CoreClientStub();
		CoreQuery query = coreClient.createCoreQuery(con);

		String isNew = helper.prompt("New capability? (y/n): " );
		String name = helper.prompt("Enter capability name: ");
		String version = helper.prompt("Enter capability version: ");
		String desc = helper.prompt("Enter capability description: ");		
		String platform = helper.prompt("Enter vendor platform: ");


		List<String> queries = new LinkedList<String>();
		while (true) {
			String queryStr = helper.prompt("Enter query name (<enter> to continue): ");
			if (queryStr == null) break;
			queries.add(queryStr);
		}

		List<String> actions = new LinkedList<String>();
		while (true) {
			String actionStr = helper.prompt("Enter action name (<enter> to continue): ");
			if (actionStr == null) break;
			actions.add(actionStr);
		}

		if ("y".equals(isNew)) {
	        System.out.println("Proposing new capability...");
	        query.proposeCapability(name, version, queries, actions, desc, platform);
		} else {
	        System.out.println("Updating capability...");
		    query.updateCapability(name, version, queries, actions, desc, platform);
		}

        // receive notifications until user presses <enter>
		helper.prompt("Press <enter> to disconnect...");
		helper.disconnect();
	}

    private static void handleCapabilityUpdate(CapabilityChangeType change, Capability cap) {
        System.out.println("change=" + change + "; capability=" + cap.getName() + ", version=" + cap.getVersion());
    }

    public static class SampleNotificationCallback implements NotificationCallback
    {
        @Override
        public void handle(BaseMsg message) {
            RegisteredCapabilityUpdateNotification notif = (RegisteredCapabilityUpdateNotification) message;
            for (Capability cap : notif.getCapabilities()) {
                handleCapabilityUpdate(notif.getChange(), cap);
           }
        }
    }

}

2. Query Registered Capabilities

GridConnection grid = helper.connectWithReconnectionManager();
grid.registerTopicChangeCallback(new SampleNotificationCallback());

// Query for all registered capabilities.
for (Capability cap : grid.getRegisteredCapabilitiesList()) {
    printCapabilityAndState("getList", CapabilityChangeType.CREATED, cap);
}


// Query a single capability specified by user.
while (true) {
    final String capNameAndVersion = helper.prompt("Capability name [, version] to query (or <enter> to quit) : ");
    if (capNameAndVersion == null || capNameAndVersion.isEmpty()) {
        break;
    }
    String[] input = capNameAndVersion.split(",");
    final String capName = input[0].trim();
    String capVersion = null;
    if (input.length > 1) {
        capVersion = input[1].trim();
    }

    RegisteredAndPendingStatus status = grid.getCapabilityStatus(capName, capVersion);

    if (status.getTopicStatus() != null) {
        printCapabilityAndState("topicStatus", status.getTopicStatus().getStatus(), status.getTopicStatus().getCapability());
    }
    if (status.getPendingStatus() != null) {
        printCapabilityAndState("pendingStatus", status.getPendingStatus().getStatus(), status.getPendingStatus().getCapability());
    }
}

helper.disconnect();
}


3. Multi-group Client
/*
 * Sample to demonstrate a client is able to perform actions on multiple topics
 * Creates ANC policy which requires client to have ANC group auth
 * Queries Session Directory for a given IP which requires Session group auth
 * Client should have both ANC and Session group membership
 */

public class MultiGroupClient {
	public static final String DEF_POLICY_NAME = "ANC"+System.currentTimeMillis();
	public static final String DEF_SESSION_IP = "1.1.1.2";
	public static final ANCAction DEF_ANC_POLICY_ACTION = ANCAction.PORT_BOUNCE;
	public static final String POLICY_NAME_PROP = "POLICY_NAME";
	public static final String SESSION_IP_PROP = "SESSION_IP";

	public static void main(String[] args) throws Exception {
	SampleHelper helper = new SampleHelper();
	GridConnection grid = helper.connectWithReconnectionManager();

	String policy = System.getProperty(POLICY_NAME_PROP);
	String sessionip = System.getProperty(SESSION_IP_PROP);

	//create ANC policy
	//if ANC policy name is not provided, a random policy name will be generated
	ANCClient client = new ANCClient();
	ANCQuery query = client.createANCQuery(grid);
	ANCPolicy ancPolicy= new ANCPolicy();
	ancPolicy.setName(policy!=null && !policy.isEmpty() ? policy:DEF_POLICY_NAME);
	ancPolicy.getActions().add(DEF_ANC_POLICY_ACTION);
	ANCResult ancResult = query.createPolicy(ancPolicy);

	System.out.println("Create ANC Policy: " + ancPolicy.getName() + " Result - " + ancResult);

	//query session directory for an IP
	//if IP is not provided, 1.1.1.2 will be used as default

	SessionDirectoryQuery sessionquery = SessionDirectoryFactory
			.createSessionDirectoryQuery(grid);

	sessionip = sessionip!=null && !sessionip.isEmpty() ? sessionip : DEF_SESSION_IP;
	Session session = sessionquery.getActiveSessionByIPAddress(InetAddress
			.getByName(sessionip));
	if (session != null) {
		SampleHelper.print(session);
	} else {
		System.out.println("Session " + sessionip + " not found");
	}

	helper.disconnect();
	}
}

```



```c  
1. Propose and modify a new capability

pxgrid_capability *capability;
pxgrid_capability_create(&capability);
  if(!capability) exit(EXIT_FAILURE);

helper_config * hconfig = helper_connection_get_helper_config(helper);

if (!hconfig)
  goto cleanup;

  const char ns_iden[] = "http://www.cisco.com/pxgrid/core";
pxgrid_capability_set_namespace(capability, ns_iden);

const char* cap_name = hconfig->cap_name;
const char* cap_version = hconfig->cap_version;

char* tf = NULL;
char *capquerynames[20];
int nCapQueries = 0;
tf = NULL;
tf = strtok(hconfig->cap_query ,",");
while (tf != NULL)
{
    capquerynames[nCapQueries] = strdup(tf);
    tf = strtok (NULL,",");	 
    nCapQueries++;
}

char *capactionnames[20];
int nCapActions = 0;
tf = NULL;
tf = strtok(hconfig->cap_action ,",");
while (tf != NULL)
{
    capactionnames[nCapActions] = strdup(tf);
    tf = strtok (NULL,",");	 
    nCapActions++;
}

const char* cap_description = hconfig->cap_description;
const char* cap_vendorplatform = hconfig->cap_vendorplatform;

status = pxgrid_capability_propose(capability, connection, cap_name, cap_version,
        (const char **) capquerynames, nCapQueries,
        (const char **) capactionnames, nCapActions,
        cap_description, cap_vendorplatform);

status = pxgrid_capability_modify(capability, connection, cap_name, cap_version,
        (const char **) capquerynames, nCapQueries,
        (const char **) capactionnames, nCapActions,
        cap_description, cap_vendorplatform);
if (status != PXGRID_STATUS_OK)
  {
      helper_print_error(status);
  }
else
{
  printf("capability: %s create request sent successfully\n", cap_name);
}


2. Query Registered Capabilities

static void get_all_capabilities(pxgrid_connection *connection) {
    PXGRID_STATUS status;

    printf("Registered Capabilities - \n");

    jw_dom_node *response = NULL;
    status = pxgrid_connection_query_capabilities(connection, &response);
    if (PXGRID_STATUS_OK == status) {
        if (NULL != response) {
            //helper_print_jw_dom(response);
            jw_dom_node *capability_el = jw_dom_get_first_element(response, capability_elname);
            print_capabilities(capability_el);

            // Free the response structure.
            jw_dom_context_destroy(jw_dom_get_context(response));
        }
    }
}

static void get_capability_status(pxgrid_connection *connection, const char *name,
                                                    const char *version) {
    printf("\n");
    PXGRID_STATUS status;

    jw_dom_node *response = NULL;
    status = pxgrid_connection_query_capability_status(connection, name, version, &response);
    if (PXGRID_STATUS_OK == status) {
        if (NULL != response) {
            //helper_print_jw_dom(response);
            jw_dom_node *status_el = jw_dom_get_first_element(response, status_elname);
            if (status_el) {
                jw_dom_node *pendingstatus_el = jw_dom_get_first_element(status_el, pendingstatus_elname);
                if (pendingstatus_el) {
                    printf("%s: ", pendingstatus_elname);
                    print_capability_status(pendingstatus_el);
                }

                jw_dom_node *topicstatus_el = jw_dom_get_first_element(status_el, topicstatus_elname);
                if (topicstatus_el) {
                    printf("%s: ", topicstatus_elname);
                    print_capability_status(topicstatus_el);
                }
            }

            // Free the response structure.
            jw_dom_context_destroy(jw_dom_get_context(response));
        }
    }
}

// Get and print all capabilities using core capability.
get_all_capabilities(connection);

char cap_query[128];
while (helper_prompt("\nCapability name[,version] to query (or <enter> to quit): ", cap_query)) {
    char *cap_name = NULL;
    char *cap_version = NULL;
    char *tf = NULL;

    tf = strtok(cap_query,",");
    cap_name = strdup(tf);
    tf = strtok (NULL,",");
if (tf != NULL)
    {
  cap_version = strdup(tf);
}

    // Get and print status for a single capability
    get_capability_status(connection, (const char *) cap_name, (const char *) cap_version);
}


3. Multi-group Client

pxgrid_capability *capability;
pxgrid_capability_create(&capability);

  if(!capability) exit(EXIT_FAILURE);

  const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
  const char cap_name[] = "SessionDirectoryCapability";

  pxgrid_capability_set_namespace(capability, ns_iden);
  pxgrid_capability_set_name(capability, cap_name);
  pxgrid_capability_subscribe(capability, connection);
  char ip_address[128];
  if (helper_prompt("\nip_address to query (or <enter> to quit): ", ip_address))
  session_query(connection, capability, ip_address);


  pxgrid_capability *anc_capability;
  pxgrid_capability_create(&anc_capability);

  if(!anc_capability) exit(EXIT_FAILURE);

  char namespacebuf[] = "http://www.cisco.com/pxgrid/anc";
  char namebuf[] = "AdaptiveNetworkControlCapability";

  pxgrid_capability_set_namespace(anc_capability, namespacebuf);
  pxgrid_capability_set_name(anc_capability, namebuf);
  pxgrid_capability_subscribe(anc_capability, connection);
  anc_getAllPolicies(connection, anc_capability);
```  

  

## Downloading All Sessions in Bulk  



```java  
// construct a date range and request those sessions

Calendar begin = Calendar.getInstance();
begin.set(Calendar.HOUR, begin.get(Calendar.HOUR) - 1);
Calendar end = Calendar.getInstance();

SessionDirectoryQuery query = SessionDirectoryFactory.createQuery(con);
SessionIterator iterator = query.getSessionsByTime(begin, end);
iterator.open();

Session session = iterator.next();
while (session != null) {
    System.out.println("received session: " + session.getGid());
    session = iterator.next();
}
```  

While subscribing to session notifications will give you the updated session state, you may at times need to retrieve all active sessions in ISE. If your application requires all session state you may want to initiate a bulk download query when a connection to pxGrid is  established. Once again, you can use the <a href="/site/pxgrid/documents/api-reference">SessionDirectoryQuery</a> class for Java for this purpose. A method called getSessionsByTime takes a time range in the form of two Calendar objects. The first specifies the beginning of the time interval, and the second specifies the end of the time interval. The example below uses a time interval of the last hour. Thus, the API returns all sessions active in the last hour.  
Keep in mind that your ISE server may have a large number of active sessions (perhaps hundreds of thousands). Whereas a simple query by IP address may take a few milliseconds, the bulk session download may take a few minutes if the number of sessions is large. So take caution in how you write your code to account for this (ensure nothing is waiting on the operation that can timeout, etc). Refer to the session download sample in the Java and C language tabs in the right hand panel for more information.  

> Session download sample  



```java  
package com.cisco.pxgrid.samples.ise;

import java.util.Calendar;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.core.SubnetContentFilter;
import com.cisco.pxgrid.model.net.Session;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;
import com.cisco.pxgrid.stub.identity.SessionDirectoryQuery;
import com.cisco.pxgrid.stub.identity.SessionIterator;

/**
 * Demonstrates how to use download all active sessions from ISE
 */
public class SessionDownload {
	public static void main(String [] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		SubnetContentFilter filters = helper.promptIpFilters("Filters (ex. '1.0.0.0/255.0.0.0,1234::/16...' or <enter> for no filter): ");
		Calendar start = helper.promptDate("Start time (ex. '2015-01-31 13:00:00' or <enter> for no start time): ");
		Calendar end = helper.promptDate("End time (ex. '2015-01-31 13:00:00' or <enter> for no end time): ");

		SessionDirectoryQuery sd = SessionDirectoryFactory.createSessionDirectoryQuery(grid);
		SessionIterator iterator = sd.getSessionsByTime(start, end, filters);
		iterator.open();

		int count = 0;
		Session s;
		while ((s = iterator.next()) != null) {
			SampleHelper.print(s);
			count++;
		}
		iterator.close();

		System.out.println("Session count=" + count);
		helper.disconnect();
	}
}
```  



```c  
/*
 * sessions_download.c
 */

#include "pxgrid.h"
#include "helper.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <jabberwerx/jabberwerx.h>
#include <openssl/ssl.h>

#define UNUSED(x) (void)(x)
#define REST_ERROR_SIZE 128

static void session_directory_service_query_get_host(pxgrid_connection *connection, char host[], size_t hostsize) { 
	jw_err err;
	jw_dom_ctx_type *ctx = NULL;
	jw_dom_node *request = NULL;
	jw_dom_node *response = NULL;
	
	/* validate input parameter */
	if(!host) {
		return;
	}
	host[0] = '\0';

	if(hostsize <= 1) {
		return;
	}

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getSessionDirectoryHostnamesRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid/admin", &err) ||
		!jw_dom_put_namespace(request, "ns5", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns6", "http://www.cisco.com/pxgrid/eps", &err) ||
		!jw_dom_put_namespace(request, "ns7", "http://www.cisco.com/pxgrid/netcap", &err) 
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "query");
		return;
	}	
	
	pxgrid_capability *capability = NULL; 
	pxgrid_capability_create(&capability);
    
    char ns[] = "http://www.cisco.com/pxgrid/identity";
    char name[] = "SessionDirectoryCapability";
    
	pxgrid_capability_set_namespace(capability, ns);
	pxgrid_capability_set_name(capability, name);
    
    
	pxgrid_capability_subscribe(capability, connection);
	
	
	PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** queried\n");
		if(response) {
			jw_dom_node *hostnames_node = jw_dom_get_first_element(response, "hostnames");
			jw_dom_node *hostname_node = jw_dom_get_first_element(hostnames_node, "hostname");
			if(hostname_node) {
				strncpy(host, jw_dom_get_first_text(hostname_node), hostsize - 1);
			}
		}
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
	pxgrid_capability_destroy(capability);
}

static jw_dom_node *_create_request() {
	jw_err err;
	jw_dom_ctx *ctx = NULL;
	jw_dom_node *request;
	jw_dom_node *time_window;
	jw_dom_node *begin_node, *end_node;
	jw_dom_node	*text_node;

	static char *dateFormat = "%Y-%m-%dT%H:%M:%SZ";
	time_t endTime = time(NULL), beginTime = endTime - 604800;

	char begin_string[50], end_string[50];
	strftime(begin_string, sizeof(begin_string), dateFormat, gmtime(&beginTime));
	strftime(end_string, sizeof(end_string), dateFormat, gmtime(&endTime));

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getSessionListByTimeRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}timeWindow", &time_window, &err) ||
		!jw_dom_add_child(request, time_window, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}begin", &begin_node, &err) ||
		!jw_dom_add_child(time_window, begin_node, &err) ||
		!jw_dom_text_create(ctx, begin_string, &text_node, &err) ||
		!jw_dom_add_child(begin_node, text_node, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}end", &end_node, &err) ||
		!jw_dom_add_child(time_window, end_node, &err) ||
		!jw_dom_text_create(ctx, end_string, &text_node, &err) ||
		!jw_dom_add_child(end_node, text_node, &err)
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "_create_request()");
        return NULL;
	}
	return request;
}

int _pem_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _ssl_ctx_cb(pxgrid_bulkdownload *bulkdownload, void *_ssl_ctx, void *user_data) {
    UNUSED(bulkdownload);
    SSL_CTX *ssl_ctx = _ssl_ctx;
    helper_config *hconfig = user_data;
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->bulk_server_cert_chain_filename, NULL);
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);
}



static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 //static const char bulkdownload_result_cb_user_data[] = "sessions_download_filtered";
 
int _on_log_cb(const char * format, va_list ap)
{
    int written = -1;
	char buffer[1024]={0};
	written = vsnprintf(buffer, 1023,format, ap);
   	FILE *fd = fopen("pxg_sample.log", "a+");
	if (fd != NULL)
	{
		fprintf(fd,"%s",buffer);
		fflush(fd);
	}
	fclose(fd);	
    return written;	
}


int main(int argc, char *argv[]) {
   PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_bulkdownload  *bulkdownload = NULL;
    pxgrid_connection *connection = NULL;
    bool bulkDownloadEverConnected = false;
    
    
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE); 
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

	pxgrid_log_set_callback(_on_log_cb);
	pxgrid_log_set_level(PXGRID_LOG_VERBOSE);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

        
    pxgrid_connection_connect(connection);

#define MAX_HOST_SIZE	256    
    char host[MAX_HOST_SIZE] = {0};
    session_directory_service_query_get_host(connection, host, MAX_HOST_SIZE);
    if(!host[0]) 
    {
        printf("Unable to get host name from session directory service\n");
        goto cleanup;
    }

	// Bulk download setup
	char url[128];
	sprintf(url, "https://%s/pxgrid/mnt/sd/getSessionListByTime", host);

	jw_dom_node * request = _create_request();
    pxgrid_config_set_bulk_server_cert_chain_filename(conn_config , hconfig->bulk_server_cert_chain_filename );
    
    
    pxgrid_bulkdownload_create(&bulkdownload, conn_config);
	if(!bulkdownload) 
	{
	    printf("Unable to create bulkdownload object\n");
		goto cleanup; 
	}
    pxgrid_bulkdownload_set_url(bulkdownload, url);
    pxgrid_bulkdownload_set_request(bulkdownload, request);
    pxgrid_bulkdownload_set_ssl_ctx_cb(bulkdownload, _ssl_ctx_cb);
    pxgrid_bulkdownload_set_ssl_ctx_cb_user_data(bulkdownload, hconfig);
    //pxgrid_bulkdownload_set_open_result_cb(bulkdownload, helper_pxgrid_bulkdownload_open_result_cb);
   // pxgrid_bulkdownload_set_open_result_cb_user_data(bulkdownload, (void*)&bulkDownloadEverConnected);
    status = pxgrid_bulkdownload_open(bulkdownload);
	if (status != PXGRID_STATUS_OK)	
    {
		helper_print_error(status);
		goto cleanup;
	}
    printf("*** bulkdownload opened\n");

	jw_dom_node *session_node = NULL;
	while (true) 
    {
		status = pxgrid_bulkdownload_next(bulkdownload, &session_node);
		
        if (status != PXGRID_STATUS_OK) break;
        if (!session_node) break;
        ise_session *session = NULL;
        ise_session_create(&session, session_node);
        ise_session_print(session);
        ise_session_destroy(session);
		jw_dom_context_destroy(jw_dom_get_context(session_node));
        session_node = NULL;
	}
    if (status == PXGRID_STATUS_REST_ERROR)
    {
        char desc[REST_ERROR_SIZE] ={0};
        pxgrid_bulkdownload_get_error_details(bulkdownload,desc,REST_ERROR_SIZE);
        printf(" Rest Error[%s]\n",desc);
    }
    else if (status != PXGRID_STATUS_OK)
    {
      helper_print_error(status);
    }
    
cleanup:
	if (request ) 
    {
        jw_dom_ctx *ctx = jw_dom_get_context(request);
        if(ctx) jw_dom_context_destroy(ctx);      
    }
    if (bulkdownload) {
        pxgrid_bulkdownload_close(bulkdownload);
        pxgrid_bulkdownload_destroy(&bulkdownload);
    }
    printf("*** bulkdownload closed\n");

   	if (connection) {
		pxgrid_connection_disconnect(connection);
		pxgrid_connection_destroy(connection);
	}
    printf("*** disconnected\n");

	if (conn_config) pxgrid_config_destroy(conn_config);
    if (hconfig) helper_config_destroy(hconfig);
  	return 0;
}
```  

</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>



Also, refer to the identity group download sample to learn how to download all identity groups.  

> Identity group download sample  



```java  
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.net.User;
import com.cisco.pxgrid.stub.identity.IdentityGroupQuery;
import com.cisco.pxgrid.stub.identity.Iterator;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;

/**
 * Demonstrates how to download all identity groups in ISE
 */
public class UserIdentityGroupDownload {
	public static void main(String [] args)	throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		IdentityGroupQuery sd = SessionDirectoryFactory.createIdentityGroupQuery(grid);
		Iterator<User> iterator = sd.getIdentityGroups();
		iterator.open();

		int count = 0;
		User s;
		while ((s = iterator.next()) != null) {
			System.out.println("user=" + s.getName() + " groups=" + s.getGroupList().getObjects().get(0).getName());
			count++;
		}
		iterator.close();

		System.out.println("User count=" + count);
		helper.disconnect();
	}
}
```  



```c  
/*
 * id_group_download.c
 */

#include "pxgrid.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <jabberwerx/jabberwerx.h>
#include <openssl/ssl.h>
#include "helper.h"

#define UNUSED(x) (void)(x)
#define REST_ERROR_SIZE 128
int _pem_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}

static void _ssl_ctx_cb(pxgrid_bulkdownload *bulkdownload, void *_ssl_ctx, void *user_data) {
    UNUSED(bulkdownload);
    SSL_CTX *ssl_ctx = _ssl_ctx;
    helper_config *hconfig = user_data;
    printf("_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->bulk_server_cert_chain_filename, NULL);
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 
static void session_directory_service_query_get_host(pxgrid_connection *connection, char host[], size_t hostsize) { 
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *response = NULL;
	
	/* validate input parameter */
	if(!host) {
		return;
	}
	host[0] = '\0';

	if(hostsize <= 1) {
		return;
	}

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getSessionDirectoryHostnamesRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid/admin", &err) ||
		!jw_dom_put_namespace(request, "ns5", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns6", "http://www.cisco.com/pxgrid/eps", &err) ||
		!jw_dom_put_namespace(request, "ns7", "http://www.cisco.com/pxgrid/netcap", &err) 
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "query");
		return;
	}	
	
	pxgrid_capability *capability; 
	pxgrid_capability_create(&capability);

    char namespacebuf[] = "http://www.cisco.com/pxgrid/identity";
    char namebuf[] = "SessionDirectoryCapability";

	pxgrid_capability_set_namespace(capability, namespacebuf);
	pxgrid_capability_set_name(capability, namebuf);
	pxgrid_capability_subscribe(capability, connection);
	
	
	PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** queried\n");
		if(response) {
			jw_dom_node *hostnames_node = jw_dom_get_first_element(response, "hostnames");
			jw_dom_node *hostname_node = jw_dom_get_first_element(hostnames_node, "hostname");
			if(hostname_node) {
				strncpy(host, jw_dom_get_first_text(hostname_node), hostsize - 1);
			}
		}
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
	pxgrid_capability_destroy(capability);
}

static jw_dom_node *_create_request() {
	jw_err err;
	jw_dom_ctx *ctx = NULL;
	jw_dom_node *request;

	static char *dateFormat = "%Y-%m-%dT%H:%M:%SZ";
	time_t endTime = time(NULL), beginTime = endTime - 604800;

	char begin_string[50], end_string[50];
	strftime(begin_string, sizeof(begin_string), dateFormat, gmtime(&beginTime));
	strftime(end_string, sizeof(end_string), dateFormat, gmtime(&endTime));

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getIdentityGroupListRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid", &err)
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "_create_request()");
        return NULL;
	}
	return request;
}

static const char bulkdownload_result_cb_user_data[] = "id_group_download";
int main(int argc, char *argv[]) 
{
	int   verbosity  = JW_LOG_TRACE;
	PXGRID_STATUS status = PXGRID_STATUS_UNKNOWN;
    pxgrid_connection *connection = NULL;
    pxgrid_config *config = NULL;
    pxgrid_bulkdownload *bulkdownload = NULL;
    jw_dom_node *request = NULL;
    helper_config *hconfig = NULL;

    helper_config_create(&hconfig, argc, argv);
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
        exit(EXIT_FAILURE); 
	} 
  	helper_pxgrid_config_create(hconfig , &config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

    pxgrid_connection_connect(connection);
    
#define MAX_HOST_SIZE	256    
    char host[MAX_HOST_SIZE] = {0};
    session_directory_service_query_get_host(connection, host, MAX_HOST_SIZE);
    if(!host[0]) 
    {
        printf("Unable to get host name from session directory service\n");
        goto cleanup;
    }

    //Bulk download setup
	char url[128];
    sprintf(url, "https://%s/pxgrid/mnt/sd/getIdentityGroups", host);

	request = _create_request();
   
	//helper_pxgrid_config_create(hconfig, &bulkdownload_config); 
	/* pxgrid_config_set_server_cert_chain_filename(bulkdownload_config, NULL, 0); */
	pxgrid_config_set_bulk_server_cert_chain_filename(config, hconfig->bulk_server_cert_chain_filename);

    pxgrid_bulkdownload_create(&bulkdownload, config);
	if(!bulkdownload) 
	{
	    printf("Unable to create bulkdownload object\n");
		goto cleanup; 
	}
    pxgrid_bulkdownload_set_url(bulkdownload, url);
    pxgrid_bulkdownload_set_request(bulkdownload, request);
    pxgrid_bulkdownload_set_ssl_ctx_cb(bulkdownload, _ssl_ctx_cb);
    pxgrid_bulkdownload_set_ssl_ctx_cb_user_data(bulkdownload, hconfig);
    
    status = pxgrid_bulkdownload_open(bulkdownload);
	if (status != PXGRID_STATUS_OK)	{
		helper_print_error(status);
		goto cleanup;
	}
    printf("*** bulkdownload open\n");
    
	jw_dom_node *user_node;
	while (true) {
		status = pxgrid_bulkdownload_next(bulkdownload, &user_node);
		if (status != PXGRID_STATUS_OK) break;
       
		if (!user_node) break;
        ise_identity_group *group;
        ise_identity_group_create(&group, user_node);
        ise_identity_group_print(group);
        ise_identity_group_destroy(group);
		jw_dom_context_destroy(jw_dom_get_context(user_node));
	}
     if (status == PXGRID_STATUS_REST_ERROR)
    {
        char desc[REST_ERROR_SIZE] ={0};
        pxgrid_bulkdownload_get_error_details(bulkdownload,desc,REST_ERROR_SIZE);
        printf(" Rest Error[%s]\n",desc);
    }
    else if (status != PXGRID_STATUS_OK)
    {
      helper_print_error(status);
    }
    
cleanup:
	if (request )
	{
		jw_dom_ctx *ctx = jw_dom_get_context(request);
		if(ctx) jw_dom_context_destroy(ctx);
	}
    if (bulkdownload) {
        pxgrid_bulkdownload_close(bulkdownload);
        pxgrid_bulkdownload_destroy(&bulkdownload);
    }
    printf("*** bulkdownload closed\n");

	if (connection) 
    {
		pxgrid_connection_disconnect(connection);
		pxgrid_connection_destroy(connection);
	}
    printf("*** disconnected\n");

	if (config) pxgrid_config_destroy(config);
    if (hconfig) helper_config_destroy(hconfig);
  
	return 0;
}
```  


## Disconnecting from the pxGrid Controller  



```java  
// disconnect from pxGrid. using the reconnection manager we only
// need to call stop.

recon.stop();
```  


```c  
pxgrid_connection_disconnect(connection);  
```

Previously you connected your client to the pxGrid Controller by starting the reconnection manager. To disconnect from the pxGrid Controller, all you need to do is stop the reconnection manager. If we had subscribed to session notifications on this pxGrid connection, then our notification handler will stop receiving notifications once the connection is dropped.  


# Troubleshooting  

Below is a list of common issues you may face when writing code to integrate with pxGrid.  

## Connection Errors  

* **After enabling pxGrid in ISE deployment, the pxGrid services UI page on ISE administrative node does not show any client or capability data.**   This error could occur if a connection could not be established between the ISE administrative node and pxGrid server. This can happen if the right certificates are not setup on the ISE administrative node for use for pxGrid connection. Make sure that on ISE administrative node, a system certificate to be used for pxGrid services is setup and also the corresponding CA certificate is set up in the trusted certificate that is trusted for authentication within ISE.  
* **Not able to establish connection from a pxGrid client node to pxGrid server due to javax.net.ssl.SSLHandshakeException: Received fatal alert: handshake_ failure.**   Handshake failure can happen if the certificate presented by the client program is invalid or  not trusted by ISE. Make sure that the certificate is not expired  and there are no timing issues between the pxGrid server and the pxGrid client node.  Also ensure that the  right intermediate/root CA certificate that signed the client certificate exists on the ISE server as Trusted Certificates.  
* **Not able to establish connection from pxGrid client node to pxGrid server due to "javax.net.ssl.SSLHandshakeException: java.security.cert.CertificateException: root certificate not trusted of ...".**   This can happen if pxGrid server certificate is not trusted by the pxGrid client node. Make sure that the trust store on the client contains the intermediate/root certificate of the certificate used by  pxGrid server.  
* **Not able to establish connection from pxGrid client node to pxGrid server due to "SASL authentication EXTERNAL failed: not-authorized:".**   Make sure that the certificate presented by the the pxGrid client node is the same as was used for the first time connection  establishment. pxGrid internally stores the certificate fingerprint for each client. If the fingerprint does not match, this error can be thrown. Also, make sure that the pxGrid client node is not in disabled state. This can be checked from the ISE pxGrid services page on ISE administrator node.  
* **Not able to establish connection from pxGrid client node to pxGrid server due to "SASL authentication EXTERNAL failed: not-authorized:".**   Make sure that the certificate presented by the the pxGrid client node is the same as was used for the first time connection  establishment. pxGrid internally stores the certificate fingerprint for each client. If the fingerprint does not match, this error can be thrown. Also, make sure that the pxGrid client node is not in disabled state. This can be checked from the ISE pxGrid services page on ISE administrator node.  

## Authorization Errors  

* **On subscribing to a capability or while invoking a query on a capability, a "Not Authorized" error is thrown by the GCL library.**   This can happen if the pxGrid client node is not part of the right authorization group that provides access to a capability. Please check authorization groups section to see the list of supported groups and access provided. Authorization group for a pxGrid client node can be changed from ISE pxGrid services page on ISE administrator node.  

## Query Errors  

* **On invoking a query on a capability, "No provider for this capability is available" error is thrown by the GCL library.**   This implies that there is no provider registered for this capability so pxGrid is not able to route the message. You can check the provider for a capability from ISE pxGrid services page on ISE administrator node. Make sure that the provider is online. For example, if you see this error on calling bulk download API or session query API,  it implies that the ISE MnT node which is the provider for session data may be down or is not able to establish connection to pxGrid server. If this error is seen for EndpointProtectionServiceCapability, make sure that EPS Service is enabled on ISE.  


# Sample Source Code  

<ul>
	<li>
		endpoint profile query
		(<a href="#endpointProfileQueryJava">Java</a>,
		<a href="#endpointProfileQueryC">C</a>)
	</li>
	<li>
		endpoint profile subscribe
		(<a href="#endpointProfileSubscribeJava">Java</a>,
		<a href="#endpointProfileSubscribeC">C</a>)
	</li>
	<li>
		eps quarantine
		(<a href="#epsQuarantineJava">Java</a>,
		<a href="#epsQuarantineC">C</a>)
	</li>
		<li>
		eps unquarantine
		(<a href="#epsUnquarantineJava">Java</a>,
		<a href="#epsUnquarantineC">C</a>)
	</li>
	<li>
		identity group download
		(<a href="#identityGroupDownloadJava">Java</a>,
		<a href="#identityGroupDownloadC">C</a>)
	</li>
	<li>
		identity group query
		(<a href="#identityGroupQueryJava">Java</a>,
		<a href="#identityGroupQueryC">C</a>)
	</li>
	<li>
		identity group subscribe
		(<a href="#identityGroupSubscribeJava">Java</a>,
		<a href="#identityGroupSubscribeC">C</a>)
		</li>
	<li>
		register
		(<a href="#registerJava">Java</a>)
	</li>
	<li>
		session download
		(<a href="#sessionDownloadJava">Java</a>,
		<a href="#sessionDownloadC">C</a>)
	</li>
	<li>
		session query
		(<a href="#sessionQueryJava">Java</a>,
		<a href="#sessionQueryC">C</a>)
	</li>
	<li>
		session subscribe
		(<a href="#sessionSubscribeJava">Java</a>,
		<a href="#sessionSubscribeC">C</a>)
	</li>
	<li>
		ANC Java Samples
		(<a href="#ancJavaSample1">Java</a>,
		<a href="#ancJavaSample2">Java</a>)
	</li>
	<li>
		ANC C Samples
		(<a href="#ancCSample1">C</a>,
		<a href="#ancCSample2">C</a>,
		<a href="#ancCSample3">C</a>,
		<a href="#ancCSample4">C</a>,
		<a href="#ancCSample5">C</a>)
	</li>
	<li>
		Dynamic Topic Java Samples
		(<a href="#dynamicTopicJavaSample1">Java</a>,
		<a href="#dynamicTopicJavaSample2">Java</a>,
		<a href="#dynamicTopicJavaSample3">Java</a>,
		<a href="#dynamicTopicJavaSample4">Java</a>)
	</li>
	<li>
	Dynamic Topic C Samples
		(<a href="#dynamicTopicCSample1">C</a>,
		<a href="#dynamicTopicCSample2">C</a>,
		<a href="#dynamicTopicCSample3">C</a>,
		<a href="#dynamicTopicCSample4">C</a>,
		<a href="#dynamicTopicCSample5">C</a>,
		<a href="#dynamicTopicCSample6">C</a>,
		<a href="#dynamicTopicCSample7">C</a>,
		<a href="#dynamicTopicCSample8">C</a>,
		<a href="#dynamicTopicCSample9">C</a>)
	</li>
</ul>  

<a name="endpointProfileQueryJava"></a>  

## endpoint profile query - Java  

```output
package com.cisco.pxgrid.samples.ise;

import java.util.Iterator;
import java.util.List;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.ise.metadata.EndpointProfile;
import com.cisco.pxgrid.stub.isemetadata.EndpointProfileClientStub;
import com.cisco.pxgrid.stub.isemetadata.EndpointProfileQuery;

public class EndpointProfileMetaDataQuery {
	public static void main(String[] args) throws Exception	{
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		EndpointProfileClientStub stub = new EndpointProfileClientStub(grid);
		EndpointProfileQuery query = stub.createEndpointProfileQuery();

		List<EndpointProfile> dps = query.getEndpointProfiles();
		if (dps != null) {
			EndpointProfile dp;
			for (Iterator<EndpointProfile> it = dps.iterator(); it.hasNext();) {
				dp = it.next();
				System.out.println("Endpoint Profile : id=" + dp.getId() + ", name=" +  dp.getName() + ", fqname " + dp.getFqname());
			}
		}
		helper.disconnect();
	}
}
```


<a name="endpointProfileQueryC"></a>  

## endpoint profile query - C  

```output
#include <stdlib.h>
#include <unistd.h>
#include "pxgrid.h"
#include "helper.h"
#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

static void query(pxgrid_connection *connection, pxgrid_capability *capability) {
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *response;

    if (!jw_dom_context_create(&ctx, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getEndpointProfileListRequest", &request, &err)
    	)
    {
    	jw_log_err(JW_LOG_ERROR, &err, "query");
    	return;
    }

    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	
	if (status == PXGRID_STATUS_OK)
	{
        jw_dom_node *profiles_node = jw_dom_get_first_child(response);
        jw_dom_node *profile_node = jw_dom_get_first_child(profiles_node);
        while (profile_node){
            ise_endpoint_profile *profile;
            ise_endpoint_profile_create(&profile, profile_node);
            ise_endpoint_profile_print(profile);
            ise_endpoint_profile_destroy(profile);
            profile_node = jw_dom_get_sibling(profile_node);
        }
		printf("*** queried\n");	
    }
    else {
    	printf("status=%s\n", pxgrid_status_get_message(status));
    }
     if(ctx)
        jw_dom_context_destroy(ctx);
}

int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }

int main(int argc, char **argv) {
    
	PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE); 
	}  
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

    pxgrid_connection_connect(connection);
   
   //--------------------------------------
	pxgrid_capability *capability = NULL;
	pxgrid_capability_create(&capability);
    
    char namespacebuf[] = "http://www.cisco.com/pxgrid/identity";
    char namebuf[] = "EndpointProfileMetaDataCapability";
    
	pxgrid_capability_set_namespace(capability, namespacebuf);
	pxgrid_capability_set_name(capability, namebuf);
	
	pxgrid_capability_subscribe(capability, connection);
	query(connection, capability);
    //---------------------------------------
	
	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
	pxgrid_config_destroy(conn_config);
    helper_config_destroy(hconfig);
   	return 0;
}
```


<a name="endpointProfileSubscribeJava"></a>  

## endpoint profile subscribe - Java  

```output
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.ise.metadata.EndpointProfile;
import com.cisco.pxgrid.model.ise.metadata.EndpointProfileChangedNotification;
import com.cisco.pxgrid.stub.isemetadata.EndpointProfileClientStub;
import com.cisco.pxgrid.stub.isemetadata.EndpointProfileNotification;

public class EndpointProfileMetaDataSubscribe {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();


		EndpointProfileClientStub stub = new EndpointProfileClientStub(grid);
		stub.registerNotification(new SampleNotificationCallback());
		
		helper.prompt("Press <enter> to disconnect...");
		helper.disconnect();
	}

	
	public static class SampleNotificationCallback implements EndpointProfileNotification
	{
		@Override
		public void handle(EndpointProfileChangedNotification notif) {
			EndpointProfile dp = notif.getEndpointProfile();
			System.out.println("EndpointProfileChangedNotification (changetype=" + notif.getChangeType() + ") Device profile : id="
					+ dp.getId() + ", name=" +
					dp.getName() + ", fqname=" + dp.getFqname());
					
		}
	}
}
```


<a name="endpointProfileSubscribeC"></a>  

## endpoint profile subscribe - C  

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 
static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
	jw_dom_node *type_node = jw_dom_get_first_element(node ,"changeType");
	jw_dom_node *profile_node = jw_dom_get_first_element(node ,"endpointProfile");
	
    if (profile_node){
		ise_endpoint_profile *profile;
        ise_endpoint_profile_create(&profile, profile_node);
        ise_endpoint_profile_print(profile);
		if(type_node)  ise_print_changetype( type_node );		
	    ise_endpoint_profile_destroy(profile);
    }	
}

int main(int argc, char **argv) 
{
	PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
			exit(EXIT_FAILURE); 
	}  
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

    // make a connection to given host
    pxgrid_connection_connect(connection);
    
    
	pxgrid_capability *capability = NULL;
	pxgrid_capability_create(&capability);
    
    char namespacebuf[] = "http://www.cisco.com/pxgrid/identity";
    char namebuf[] = "EndpointProfileMetaDataCapability";
    
	pxgrid_capability_set_namespace(capability, namespacebuf);
	pxgrid_capability_set_name(capability, namebuf);
    
	char notf_buf[] = 	"http://www.cisco.com/pxgrid/identity";
    char notf_hdl_buf[] ="endpointProfileChangedNotification";
	pxgrid_capability_subscribe(capability, connection);
	pxgrid_connection_register_notification_handler(connection, notf_buf, notf_hdl_buf, message_callback, NULL);
	
    sleep(600);
	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
	pxgrid_config_destroy(conn_config);
    helper_config_destroy(hconfig);
       
	return 0;
}
```



<a name="epsQuarantineJava"></a>

## eps quarantine - Java  

```output
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.stub.eps.EPSClientStub;
import com.cisco.pxgrid.stub.eps.EPSQuery;

/**
 * Demonstrates how to use a pxGrid client to invoke an Endpoint Protection
 * Service (EPS) quarantine by IP address in ISE.
 */
public class EPSQuarantine {
	public static void main(String[] args) throws Exception	{
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		EPSClientStub stub = new EPSClientStub();
		EPSQuery query = stub.createEPSQuery(grid);

		while (true) {
			String ip = helper.prompt("IP address (or <enter> to disconnect): ");
			if (ip == null) break;
			query.quarantineByIP(ip);
		}
		helper.disconnect();
	}
}
```


<a name="epsQuarantineC"></a>  

## eps quarantine - C  

```output
#include <stdlib.h>
#include <unistd.h>

#include <signal.h>

#include "pxgrid.h"
#include "helper.h"
#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)
/** Enumeration of EPS mitigation action types. */
typedef enum
{
	/**  exclusive lower bound */
	EPS_MA_MIN = 0,
	EPS_MA_QUARANTINE,
	EPS_MA_UNQUARANTINE,
#if 0
	EPS_MA_SHUTDOWN,
	EPS_MA_TERMINATE,
	EPS_MA_REAUTHENTICATE,
	EPS_MA_PORT_BOUNCE,
#endif
	/**  exclusive upper bound */
	EPS_MA_MAX
} eps_mitigation_action_type;

/** Enumeration of EPS mitigation action by. */
typedef enum
{
	/**  exclusive lower bound */
	EPS_MA_BY_MIN = 0,
	EPS_MA_BY_IP,
	EPS_MA_BY_MAC,
#if 0
	EPS_MA_BY_SESSION_ID,
#endif
	/**  exclusive upper bound */
	EPS_MA_BY_MAX
} eps_mitigation_action_by;

static int		gExitFlag		= 0;
static int		isSigKill		= 0;
static int		isSigTerm		= 0;


void signalHandler(int sig)
{
    switch (sig)
    {
          case SIGKILL:
              isSigKill = 1;
              break;
          case SIGTERM:
              isSigTerm = 1;
              break;
          default:
            break;
    }
    if((1 == isSigKill)||(1 == isSigTerm)) {
        gExitFlag = 1;
    }

}


int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 static void tls_failure_cb(pxgrid_connection *connection , void *user_data)
 {
    UNUSED(connection);
    printf("Invalid tls certificate presented!!!\n");
 }

static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
	helper_print_jw_dom(node);
}

static void mitigation_action_by_ip(pxgrid_connection *connection, pxgrid_capability *capability, eps_mitigation_action_type action_type, char *ip)
{
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *mitigation_action_node;
	jw_dom_node *mitigation_action_text_node; 
	jw_dom_node *ip_interface_node;
	jw_dom_node *ip_address_node;
	jw_dom_node *ip_address_text_node;
	jw_dom_node *response = NULL;
	
	char action_text[256] = {0};
	
	/* validate input parameter */
	if(!ip) {
		return;
	}

	switch (action_type)
	{    
		 case EPS_MA_QUARANTINE:
			sprintf(action_text, "%s", "quarantine");
			break;

		case EPS_MA_UNQUARANTINE:
			sprintf(action_text, "%s", "unquarantine");
			break;
            
		default:
			break;
	}

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}sendMitigationActionByIPRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid/admin", &err) ||
		!jw_dom_put_namespace(request, "ns5", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns6", "http://www.cisco.com/pxgrid/eps", &err) ||
		!jw_dom_put_namespace(request, "ns7", "http://www.cisco.com/pxgrid/netcap", &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}mitigationAction", &mitigation_action_node, &err) ||
		!jw_dom_add_child(request, mitigation_action_node, &err) ||
		!jw_dom_text_create(ctx, action_text, &mitigation_action_text_node, &err) ||
		!jw_dom_add_child(mitigation_action_node, mitigation_action_text_node, &err) || 
   		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}ipInterface", &ip_interface_node, &err) ||
		!jw_dom_add_child(request, ip_interface_node, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}ipAddress", &ip_address_node, &err) ||
		!jw_dom_add_child(ip_interface_node, ip_address_node, &err) ||
		!jw_dom_text_create(ctx, ip, &ip_address_text_node, &err) ||
		!jw_dom_add_child(ip_address_node, ip_address_text_node, &err)
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "mitigation_action_by_ip");
		return;
	}	
	printf("*** request\n");
	helper_print_jw_dom(request);
	
	PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** response\n");
		helper_print_jw_dom(response);	
		printf("*** queried\n");
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
} 

static void mitigation_action_by_mac(pxgrid_connection *connection, pxgrid_capability *capability, eps_mitigation_action_type action_type, char *mac)
{
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *mitigation_action_node;
	jw_dom_node *mitigation_action_text_node; 
	jw_dom_node *mac_interface_node;
	jw_dom_node *mac_address_text_node;
	jw_dom_node *response = NULL;
	
	char action_text[256] = {0};
	
	/* validate input parameter */
	if(!mac) {
		return;
	}

	switch (action_type)
	{    
		 case EPS_MA_QUARANTINE:
			sprintf(action_text, "%s", "quarantine");
			break;

		case EPS_MA_UNQUARANTINE:
			sprintf(action_text, "%s", "unquarantine");
			break;
            
		default:
			break;
	}

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}sendMitigationActionByMACRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid/admin", &err) ||
		!jw_dom_put_namespace(request, "ns5", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns6", "http://www.cisco.com/pxgrid/eps", &err) ||
		!jw_dom_put_namespace(request, "ns7", "http://www.cisco.com/pxgrid/netcap", &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}mitigationAction", &mitigation_action_node, &err) ||
		!jw_dom_add_child(request, mitigation_action_node, &err) ||
		!jw_dom_text_create(ctx, action_text, &mitigation_action_text_node, &err) ||
		!jw_dom_add_child(mitigation_action_node, mitigation_action_text_node, &err) || 
   		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}macInterface", &mac_interface_node, &err) ||
		!jw_dom_add_child(request, mac_interface_node, &err) ||
		!jw_dom_text_create(ctx, mac, &mac_address_text_node, &err) ||
		!jw_dom_add_child(mac_interface_node, mac_address_text_node, &err)
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "mitigation_action_by_mac");
		return;
	}	
	printf("*** request\n");
	helper_print_jw_dom(request);
	
	PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** response\n");
		helper_print_jw_dom(response);
		printf("*** queried\n");
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
} 

static void eps_service_do_mitigation_action(pxgrid_connection *connection, pxgrid_capability *capability, eps_mitigation_action_type action_type, eps_mitigation_action_by action_by, void *input_data)
{
	switch (action_by)
	{    
		 case EPS_MA_BY_IP:
			mitigation_action_by_ip(connection, capability, action_type, input_data);
			break;

		case EPS_MA_BY_MAC:
			mitigation_action_by_mac(connection, capability, action_type, input_data);
			break;
		default:
			break;
	}

}

#define MIN_FIELD_WIDTH_NUM			2
#define MIN_FIELD_WIDTH_ACTION_STR		32

/* action */
static void cli_print_mitigation_action_usage( )
{
	int bytes_written;
	printf ("\n\n|*************************************************|\n");
	printf ("|%n\t'%-*s'\t'%-*s'|\n", &bytes_written, MIN_FIELD_WIDTH_NUM,"NU", MIN_FIELD_WIDTH_ACTION_STR,"EPS ACTION");
	printf ("|*************************************************|\n");
	printf ("\t[%0*d]\t'%-*s'\n", MIN_FIELD_WIDTH_NUM,EPS_MA_QUARANTINE, MIN_FIELD_WIDTH_ACTION_STR,"EPS_MA_QUARANTINE");
	printf ("\t[%0*d]\t'%-*s'\n", MIN_FIELD_WIDTH_NUM,EPS_MA_UNQUARANTINE, MIN_FIELD_WIDTH_ACTION_STR,"EPS_MA_UNQUARANTINE");
	printf ("|*************************************************|\n");
	printf ("Enter EPS mitigation action [number]: ");
	fflush(stdout);
}

static unsigned int cli_get_mitigation_action_number( )
{
	char			act_num_str[16]			= {0};
	char			act_num_extra_str[16]		= {0};
	unsigned int		act_num				= EPS_MA_MIN; /* invalid value */
	int			act_done			= 0;
	do {
		memset(act_num_str, 0, sizeof(act_num_str));
		memset(act_num_extra_str, 0, sizeof(act_num_extra_str));
		
		cli_print_mitigation_action_usage();
		while ( fgets( act_num_str, sizeof(act_num_str), stdin ) != NULL )
		{
			if ( sscanf( act_num_str, "%i%[^\n]", &act_num, act_num_extra_str ) == 1 ) {
				/* validate */
				if((act_num > EPS_MA_MIN) && (act_num < EPS_MA_MAX)) {
					act_done = 1;
					break;
				}
			}
			/* Do some sort of error processing. */
			fprintf( stdout, "\nError reading EPS mitigation action number[%d]['%s'][act_done=%d], please try again.\n", act_num, act_num_str, act_done);
			act_num = EPS_MA_MIN;
			memset(act_num_str, 0, sizeof(act_num_str));
			memset(act_num_extra_str, 0, sizeof(act_num_extra_str));
			cli_print_mitigation_action_usage();
		}
	} while(0 == act_done);
	return act_num;
}

/* action by */
static void cli_print_mitigation_action_by_usage( )
{
	int bytes_written;
	printf ("\n\n|*************************************************|\n");
	printf ("|%n\t'%-*s'\t'%-*s'|\n", &bytes_written, MIN_FIELD_WIDTH_NUM,"NU", MIN_FIELD_WIDTH_ACTION_STR,"EPS ACTION BY");
	printf ("|*************************************************|\n");
	printf ("\t[%0*d]\t'%-*s'\n", MIN_FIELD_WIDTH_NUM,EPS_MA_BY_IP, MIN_FIELD_WIDTH_ACTION_STR,"EPS_MA_BY_IP");
	printf ("\t[%0*d]\t'%-*s'\n", MIN_FIELD_WIDTH_NUM,EPS_MA_BY_MAC, MIN_FIELD_WIDTH_ACTION_STR,"EPS_MA_BY_MAC");
	printf ("|*************************************************|\n");
	printf ("Enter EPS mitigation action by[number]: ");
	fflush(stdout);
}

static unsigned int cli_get_mitigation_action_by_number( )
{
	char			actby_num_str[16]			= {0};
	char			actby_num_extra_str[16]			= {0};
	unsigned int		actby_num				= EPS_MA_BY_MIN; /* invalid value */
	int			actby_done				= 0;
	do {
		memset(actby_num_str, 0, sizeof(actby_num_str));
		memset(actby_num_extra_str, 0, sizeof(actby_num_extra_str));
		
		cli_print_mitigation_action_by_usage();
		while ( fgets( actby_num_str, sizeof(actby_num_str), stdin ) != NULL )
		{
			if ( sscanf( actby_num_str, "%i%[^\n]", &actby_num, actby_num_extra_str ) == 1 ) {
				/* validate */
				if((actby_num > EPS_MA_BY_MIN) && (actby_num < EPS_MA_BY_MAX)) {
					actby_done = 1;
					break;
				}
			}
			/* Do some sort of error processing. */
			fprintf( stdout, "\nError reading EPS mitigation action by number[%d]['%s'][actby_done=%d], please try again.\n", actby_num, actby_num_str, actby_done);
			actby_num = EPS_MA_BY_MIN;
			memset(actby_num_str, 0, sizeof(actby_num_str));
			memset(actby_num_extra_str, 0, sizeof(actby_num_extra_str));
			cli_print_mitigation_action_by_usage();
		}
	} while(0 == actby_done);
	return actby_num;
}

int main(int argc, char **argv)
{
    
	PXGRID_STATUS 		status 			= PXGRID_STATUS_OK;
	pxgrid_connection	*connection		= NULL;
	pxgrid_config		*conn_config			= NULL;
	helper_config		*hconfig		= NULL;
	
	helper_config_create(&hconfig, argc, argv);
	if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
       	exit(EXIT_FAILURE); 
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
	pxgrid_config_set_user_group(conn_config, "EPS");
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

      
    pxgrid_connection_connect(connection);
   
	pxgrid_capability *capability = NULL;
	pxgrid_capability_create(&capability);

    char namespacebuf[] = "http://www.cisco.com/pxgrid/eps";
    char namebuf[] = "EndpointProtectionServiceCapability";

	pxgrid_capability_set_namespace(capability, namespacebuf);
	pxgrid_capability_set_name(capability, namebuf);
	
	status = pxgrid_capability_subscribe(capability, connection);
	if (PXGRID_STATUS_OK != status) {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	

	unsigned int		act_num				= EPS_MA_MIN;		/* invalid value */
	unsigned int		act_by_num			= EPS_MA_BY_MIN;	/* invalid value */
	char			input_data_str[512]		= {0};
	char			input_data[256]			= {0};
	char			input_data_extra_str[256]	= {0};

	do
	{
		act_num				= EPS_MA_MIN;		/* invalid value */
		act_num = cli_get_mitigation_action_number();
		act_by_num			= EPS_MA_BY_MIN;	/* invalid value */
		act_by_num = cli_get_mitigation_action_by_number();
		switch (act_by_num)
		{    
			 case EPS_MA_BY_IP:
				printf ("Enter Endpoint IP address: ");
				fflush(stdout);
				break;

			case EPS_MA_BY_MAC:
				printf ("Enter Endpoint MAC address: ");
				fflush(stdout);
				break;
			default:
				break;
		}

		memset(input_data, 0, sizeof(input_data));
		memset(input_data_extra_str, 0, sizeof(input_data_extra_str));
		while ( fgets( input_data_str, sizeof(input_data_str), stdin ) != NULL )
		{
			if ( sscanf( input_data_str, "%s%[^\n]", input_data, input_data_extra_str ) == 1 ) {
				break;
			}
			/* Do some sort of error processing */
			fprintf( stdout, "\nError reading input data['%s']['%s'], please try again.\n", input_data, input_data_extra_str);
			fflush(stdout);
			memset(input_data, 0, sizeof(input_data));
			memset(input_data_extra_str, 0, sizeof(input_data_extra_str));
		}
		eps_service_do_mitigation_action(connection, capability, (eps_mitigation_action_type)act_num, (eps_mitigation_action_by)act_by_num, input_data);
	}while(1 != gExitFlag);
	
	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
	pxgrid_config_destroy(conn_config);
	helper_config_destroy(hconfig);
    return 0;
}
```


<a name="epsUnquarantineJava"></a>  

## eps unquarantine - Java  

```output
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.stub.eps.EPSClientStub;
import com.cisco.pxgrid.stub.eps.EPSQuery;

/**
 * Demonstrates how to use a pxGrid client to invoke an Endpoint Protection
 * Service (EPS) unquarantine by MAC address in ISE.
 */
public class EPSUnquarantine {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		EPSClientStub stub = new EPSClientStub();
		EPSQuery query = stub.createEPSQuery(grid);

		while (true) {
			String mac = helper.prompt("MAC address (or <enter> to disconnect): ");
			if (mac == null)	break;
			query.unquarantineByMAC(mac);
		}
		helper.disconnect();
	}
}
```


<a name="epsUnquarantineC"></a>  

## eps unquarantine - C  

```output
#include <stdlib.h>
#include <unistd.h>

#include <signal.h>

#include "pxgrid.h"
#include "helper.h"
#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)
/** Enumeration of EPS mitigation action types. */
typedef enum
{
	/**  exclusive lower bound */
	EPS_MA_MIN = 0,
	EPS_MA_QUARANTINE,
	EPS_MA_UNQUARANTINE,
#if 0
	EPS_MA_SHUTDOWN,
	EPS_MA_TERMINATE,
	EPS_MA_REAUTHENTICATE,
	EPS_MA_PORT_BOUNCE,
#endif
	/**  exclusive upper bound */
	EPS_MA_MAX
} eps_mitigation_action_type;

/** Enumeration of EPS mitigation action by. */
typedef enum
{
	/**  exclusive lower bound */
	EPS_MA_BY_MIN = 0,
	EPS_MA_BY_IP,
	EPS_MA_BY_MAC,
#if 0
	EPS_MA_BY_SESSION_ID,
#endif
	/**  exclusive upper bound */
	EPS_MA_BY_MAX
} eps_mitigation_action_by;

static int		gExitFlag		= 0;
static int		isSigKill		= 0;
static int		isSigTerm		= 0;


void signalHandler(int sig)
{
    switch (sig)
    {
          case SIGKILL:
              isSigKill = 1;
              break;
          case SIGTERM:
              isSigTerm = 1;
              break;
          default:
            break;
    }
    if((1 == isSigKill)||(1 == isSigTerm)) {
        gExitFlag = 1;
    }

}


int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 static void tls_failure_cb(pxgrid_connection *connection , void *user_data)
 {
    UNUSED(connection);
    printf("Invalid tls certificate presented!!!\n");
 }

static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
	helper_print_jw_dom(node);
}

static void mitigation_action_by_ip(pxgrid_connection *connection, pxgrid_capability *capability, eps_mitigation_action_type action_type, char *ip)
{
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *mitigation_action_node;
	jw_dom_node *mitigation_action_text_node; 
	jw_dom_node *ip_interface_node;
	jw_dom_node *ip_address_node;
	jw_dom_node *ip_address_text_node;
	jw_dom_node *response = NULL;
	
	char action_text[256] = {0};
	
	/* validate input parameter */
	if(!ip) {
		return;
	}

	switch (action_type)
	{    
		 case EPS_MA_QUARANTINE:
			sprintf(action_text, "%s", "quarantine");
			break;

		case EPS_MA_UNQUARANTINE:
			sprintf(action_text, "%s", "unquarantine");
			break;
            
		default:
			break;
	}

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}sendMitigationActionByIPRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid/admin", &err) ||
		!jw_dom_put_namespace(request, "ns5", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns6", "http://www.cisco.com/pxgrid/eps", &err) ||
		!jw_dom_put_namespace(request, "ns7", "http://www.cisco.com/pxgrid/netcap", &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}mitigationAction", &mitigation_action_node, &err) ||
		!jw_dom_add_child(request, mitigation_action_node, &err) ||
		!jw_dom_text_create(ctx, action_text, &mitigation_action_text_node, &err) ||
		!jw_dom_add_child(mitigation_action_node, mitigation_action_text_node, &err) || 
   		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}ipInterface", &ip_interface_node, &err) ||
		!jw_dom_add_child(request, ip_interface_node, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}ipAddress", &ip_address_node, &err) ||
		!jw_dom_add_child(ip_interface_node, ip_address_node, &err) ||
		!jw_dom_text_create(ctx, ip, &ip_address_text_node, &err) ||
		!jw_dom_add_child(ip_address_node, ip_address_text_node, &err)
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "mitigation_action_by_ip");
		return;
	}	
	printf("*** request\n");
	helper_print_jw_dom(request);
	
	PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** response\n");
		helper_print_jw_dom(response);	
		printf("*** queried\n");
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
} 

static void mitigation_action_by_mac(pxgrid_connection *connection, pxgrid_capability *capability, eps_mitigation_action_type action_type, char *mac)
{
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *mitigation_action_node;
	jw_dom_node *mitigation_action_text_node; 
	jw_dom_node *mac_interface_node;
	jw_dom_node *mac_address_text_node;
	jw_dom_node *response = NULL;
	
	char action_text[256] = {0};
	
	/* validate input parameter */
	if(!mac) {
		return;
	}

	switch (action_type)
	{    
		 case EPS_MA_QUARANTINE:
			sprintf(action_text, "%s", "quarantine");
			break;

		case EPS_MA_UNQUARANTINE:
			sprintf(action_text, "%s", "unquarantine");
			break;
            
		default:
			break;
	}

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}sendMitigationActionByMACRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid/admin", &err) ||
		!jw_dom_put_namespace(request, "ns5", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns6", "http://www.cisco.com/pxgrid/eps", &err) ||
		!jw_dom_put_namespace(request, "ns7", "http://www.cisco.com/pxgrid/netcap", &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}mitigationAction", &mitigation_action_node, &err) ||
		!jw_dom_add_child(request, mitigation_action_node, &err) ||
		!jw_dom_text_create(ctx, action_text, &mitigation_action_text_node, &err) ||
		!jw_dom_add_child(mitigation_action_node, mitigation_action_text_node, &err) || 
   		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/eps}macInterface", &mac_interface_node, &err) ||
		!jw_dom_add_child(request, mac_interface_node, &err) ||
		!jw_dom_text_create(ctx, mac, &mac_address_text_node, &err) ||
		!jw_dom_add_child(mac_interface_node, mac_address_text_node, &err)
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "mitigation_action_by_mac");
		return;
	}	
	printf("*** request\n");
	helper_print_jw_dom(request);
	
	PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** response\n");
		helper_print_jw_dom(response);
		printf("*** queried\n");
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
} 

static void eps_service_do_mitigation_action(pxgrid_connection *connection, pxgrid_capability *capability, eps_mitigation_action_type action_type, eps_mitigation_action_by action_by, void *input_data)
{
	switch (action_by)
	{    
		 case EPS_MA_BY_IP:
			mitigation_action_by_ip(connection, capability, action_type, input_data);
			break;

		case EPS_MA_BY_MAC:
			mitigation_action_by_mac(connection, capability, action_type, input_data);
			break;
		default:
			break;
	}

}

#define MIN_FIELD_WIDTH_NUM			2
#define MIN_FIELD_WIDTH_ACTION_STR		32

/* action */
static void cli_print_mitigation_action_usage( )
{
	int bytes_written;
	printf ("\n\n|*************************************************|\n");
	printf ("|%n\t'%-*s'\t'%-*s'|\n", &bytes_written, MIN_FIELD_WIDTH_NUM,"NU", MIN_FIELD_WIDTH_ACTION_STR,"EPS ACTION");
	printf ("|*************************************************|\n");
	printf ("\t[%0*d]\t'%-*s'\n", MIN_FIELD_WIDTH_NUM,EPS_MA_QUARANTINE, MIN_FIELD_WIDTH_ACTION_STR,"EPS_MA_QUARANTINE");
	printf ("\t[%0*d]\t'%-*s'\n", MIN_FIELD_WIDTH_NUM,EPS_MA_UNQUARANTINE, MIN_FIELD_WIDTH_ACTION_STR,"EPS_MA_UNQUARANTINE");
	printf ("|*************************************************|\n");
	printf ("Enter EPS mitigation action [number]: ");
	fflush(stdout);
}

static unsigned int cli_get_mitigation_action_number( )
{
	char			act_num_str[16]			= {0};
	char			act_num_extra_str[16]		= {0};
	unsigned int		act_num				= EPS_MA_MIN; /* invalid value */
	int			act_done			= 0;
	do {
		memset(act_num_str, 0, sizeof(act_num_str));
		memset(act_num_extra_str, 0, sizeof(act_num_extra_str));
		
		cli_print_mitigation_action_usage();
		while ( fgets( act_num_str, sizeof(act_num_str), stdin ) != NULL )
		{
			if ( sscanf( act_num_str, "%i%[^\n]", &act_num, act_num_extra_str ) == 1 ) {
				/* validate */
				if((act_num > EPS_MA_MIN) && (act_num < EPS_MA_MAX)) {
					act_done = 1;
					break;
				}
			}
			/* Do some sort of error processing. */
			fprintf( stdout, "\nError reading EPS mitigation action number[%d]['%s'][act_done=%d], please try again.\n", act_num, act_num_str, act_done);
			act_num = EPS_MA_MIN;
			memset(act_num_str, 0, sizeof(act_num_str));
			memset(act_num_extra_str, 0, sizeof(act_num_extra_str));
			cli_print_mitigation_action_usage();
		}
	} while(0 == act_done);
	return act_num;
}

/* action by */
static void cli_print_mitigation_action_by_usage( )
{
	int bytes_written;
	printf ("\n\n|*************************************************|\n");
	printf ("|%n\t'%-*s'\t'%-*s'|\n", &bytes_written, MIN_FIELD_WIDTH_NUM,"NU", MIN_FIELD_WIDTH_ACTION_STR,"EPS ACTION BY");
	printf ("|*************************************************|\n");
	printf ("\t[%0*d]\t'%-*s'\n", MIN_FIELD_WIDTH_NUM,EPS_MA_BY_IP, MIN_FIELD_WIDTH_ACTION_STR,"EPS_MA_BY_IP");
	printf ("\t[%0*d]\t'%-*s'\n", MIN_FIELD_WIDTH_NUM,EPS_MA_BY_MAC, MIN_FIELD_WIDTH_ACTION_STR,"EPS_MA_BY_MAC");
	printf ("|*************************************************|\n");
	printf ("Enter EPS mitigation action by[number]: ");
	fflush(stdout);
}

static unsigned int cli_get_mitigation_action_by_number( )
{
	char			actby_num_str[16]			= {0};
	char			actby_num_extra_str[16]			= {0};
	unsigned int		actby_num				= EPS_MA_BY_MIN; /* invalid value */
	int			actby_done				= 0;
	do {
		memset(actby_num_str, 0, sizeof(actby_num_str));
		memset(actby_num_extra_str, 0, sizeof(actby_num_extra_str));
		
		cli_print_mitigation_action_by_usage();
		while ( fgets( actby_num_str, sizeof(actby_num_str), stdin ) != NULL )
		{
			if ( sscanf( actby_num_str, "%i%[^\n]", &actby_num, actby_num_extra_str ) == 1 ) {
				/* validate */
				if((actby_num > EPS_MA_BY_MIN) && (actby_num < EPS_MA_BY_MAX)) {
					actby_done = 1;
					break;
				}
			}
			/* Do some sort of error processing. */
			fprintf( stdout, "\nError reading EPS mitigation action by number[%d]['%s'][actby_done=%d], please try again.\n", actby_num, actby_num_str, actby_done);
			actby_num = EPS_MA_BY_MIN;
			memset(actby_num_str, 0, sizeof(actby_num_str));
			memset(actby_num_extra_str, 0, sizeof(actby_num_extra_str));
			cli_print_mitigation_action_by_usage();
		}
	} while(0 == actby_done);
	return actby_num;
}

int main(int argc, char **argv)
{
    
	PXGRID_STATUS 		status 			= PXGRID_STATUS_OK;
	pxgrid_connection	*connection		= NULL;
	pxgrid_config		*conn_config			= NULL;
	helper_config		*hconfig		= NULL;
	
	helper_config_create(&hconfig, argc, argv);
	if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
       	exit(EXIT_FAILURE); 
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
	pxgrid_config_set_user_group(conn_config, "EPS");
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

      
    pxgrid_connection_connect(connection);
   
	pxgrid_capability *capability = NULL;
	pxgrid_capability_create(&capability);

    char namespacebuf[] = "http://www.cisco.com/pxgrid/eps";
    char namebuf[] = "EndpointProtectionServiceCapability";

	pxgrid_capability_set_namespace(capability, namespacebuf);
	pxgrid_capability_set_name(capability, namebuf);
	
	status = pxgrid_capability_subscribe(capability, connection);
	if (PXGRID_STATUS_OK != status) {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	

	unsigned int		act_num				= EPS_MA_MIN;		/* invalid value */
	unsigned int		act_by_num			= EPS_MA_BY_MIN;	/* invalid value */
	char			input_data_str[512]		= {0};
	char			input_data[256]			= {0};
	char			input_data_extra_str[256]	= {0};

	do
	{
		act_num				= EPS_MA_MIN;		/* invalid value */
		act_num = cli_get_mitigation_action_number();
		act_by_num			= EPS_MA_BY_MIN;	/* invalid value */
		act_by_num = cli_get_mitigation_action_by_number();
		switch (act_by_num)
		{    
			 case EPS_MA_BY_IP:
				printf ("Enter Endpoint IP address: ");
				fflush(stdout);
				break;

			case EPS_MA_BY_MAC:
				printf ("Enter Endpoint MAC address: ");
				fflush(stdout);
				break;
			default:
				break;
		}

		memset(input_data, 0, sizeof(input_data));
		memset(input_data_extra_str, 0, sizeof(input_data_extra_str));
		while ( fgets( input_data_str, sizeof(input_data_str), stdin ) != NULL )
		{
			if ( sscanf( input_data_str, "%s%[^\n]", input_data, input_data_extra_str ) == 1 ) {
				break;
			}
			/* Do some sort of error processing */
			fprintf( stdout, "\nError reading input data['%s']['%s'], please try again.\n", input_data, input_data_extra_str);
			fflush(stdout);
			memset(input_data, 0, sizeof(input_data));
			memset(input_data_extra_str, 0, sizeof(input_data_extra_str));
		}
		eps_service_do_mitigation_action(connection, capability, (eps_mitigation_action_type)act_num, (eps_mitigation_action_by)act_by_num, input_data);
	}while(1 != gExitFlag);
	
	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
	pxgrid_config_destroy(conn_config);
	helper_config_destroy(hconfig);
    return 0;
}
```



<a name="identityGroupDownloadJava"></a>  

## identity group download - Java  

```output
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.net.User;
import com.cisco.pxgrid.stub.identity.IdentityGroupQuery;
import com.cisco.pxgrid.stub.identity.Iterator;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;

/**
 * Demonstrates how to download all identity groups in ISE
 */
public class UserIdentityGroupDownload {
	public static void main(String [] args)	throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		IdentityGroupQuery sd = SessionDirectoryFactory.createIdentityGroupQuery(grid);
		Iterator<User> iterator = sd.getIdentityGroups();
		iterator.open();

		int count = 0;
		User s;
		while ((s = iterator.next()) != null) {
			System.out.println("user=" + s.getName() + " groups=" + s.getGroupList().getObjects().get(0).getName());
			count++;
		}
		iterator.close();

		System.out.println("User count=" + count);
		helper.disconnect();
	}
}
```


<a name="identityGroupDownloadC"></a>  

## identity group download - C  

```output
/*
 * id_group_download.c
 */

#include "pxgrid.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <jabberwerx/jabberwerx.h>
#include <openssl/ssl.h>
#include "helper.h"

#define UNUSED(x) (void)(x)
#define REST_ERROR_SIZE 128
int _pem_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}

static void _ssl_ctx_cb(pxgrid_bulkdownload *bulkdownload, void *_ssl_ctx, void *user_data) {
    UNUSED(bulkdownload);
    SSL_CTX *ssl_ctx = _ssl_ctx;
    helper_config *hconfig = user_data;
    printf("_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->bulk_server_cert_chain_filename, NULL);
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 
static void session_directory_service_query_get_host(pxgrid_connection *connection, char host[], size_t hostsize) { 
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *response = NULL;
	
	/* validate input parameter */
	if(!host) {
		return;
	}
	host[0] = '\0';

	if(hostsize <= 1) {
		return;
	}

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getSessionDirectoryHostnamesRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid/admin", &err) ||
		!jw_dom_put_namespace(request, "ns5", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns6", "http://www.cisco.com/pxgrid/eps", &err) ||
		!jw_dom_put_namespace(request, "ns7", "http://www.cisco.com/pxgrid/netcap", &err) 
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "query");
		return;
	}	
	
	pxgrid_capability *capability; 
	pxgrid_capability_create(&capability);

    char namespacebuf[] = "http://www.cisco.com/pxgrid/identity";
    char namebuf[] = "SessionDirectoryCapability";

	pxgrid_capability_set_namespace(capability, namespacebuf);
	pxgrid_capability_set_name(capability, namebuf);
	pxgrid_capability_subscribe(capability, connection);
	
	
	PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** queried\n");
		if(response) {
			jw_dom_node *hostnames_node = jw_dom_get_first_element(response, "hostnames");
			jw_dom_node *hostname_node = jw_dom_get_first_element(hostnames_node, "hostname");
			if(hostname_node) {
				strncpy(host, jw_dom_get_first_text(hostname_node), hostsize - 1);
			}
		}
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
	pxgrid_capability_destroy(capability);
}

static jw_dom_node *_create_request() {
	jw_err err;
	jw_dom_ctx *ctx = NULL;
	jw_dom_node *request;

	static char *dateFormat = "%Y-%m-%dT%H:%M:%SZ";
	time_t endTime = time(NULL), beginTime = endTime - 604800;

	char begin_string[50], end_string[50];
	strftime(begin_string, sizeof(begin_string), dateFormat, gmtime(&beginTime));
	strftime(end_string, sizeof(end_string), dateFormat, gmtime(&endTime));

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getIdentityGroupListRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid", &err)
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "_create_request()");
        return NULL;
	}
	return request;
}

static const char bulkdownload_result_cb_user_data[] = "id_group_download";
int main(int argc, char *argv[]) 
{
	int   verbosity  = JW_LOG_TRACE;
	PXGRID_STATUS status = PXGRID_STATUS_UNKNOWN;
    pxgrid_connection *connection = NULL;
    pxgrid_config *config = NULL;
    pxgrid_bulkdownload *bulkdownload = NULL;
    jw_dom_node *request = NULL;
    helper_config *hconfig = NULL;

    helper_config_create(&hconfig, argc, argv);
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
        exit(EXIT_FAILURE); 
	} 
  	helper_pxgrid_config_create(hconfig , &config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

    pxgrid_connection_connect(connection);
    
#define MAX_HOST_SIZE	256    
    char host[MAX_HOST_SIZE] = {0};
    session_directory_service_query_get_host(connection, host, MAX_HOST_SIZE);
    if(!host[0]) 
    {
        printf("Unable to get host name from session directory service\n");
        goto cleanup;
    }

    //Bulk download setup
	char url[128];
    sprintf(url, "https://%s/pxgrid/mnt/sd/getIdentityGroups", host);

	request = _create_request();
   
	//helper_pxgrid_config_create(hconfig, &bulkdownload_config); 
	/* pxgrid_config_set_server_cert_chain_filename(bulkdownload_config, NULL, 0); */
	pxgrid_config_set_bulk_server_cert_chain_filename(config, hconfig->bulk_server_cert_chain_filename);

    pxgrid_bulkdownload_create(&bulkdownload, config);
	if(!bulkdownload) 
	{
	    printf("Unable to create bulkdownload object\n");
		goto cleanup; 
	}
    pxgrid_bulkdownload_set_url(bulkdownload, url);
    pxgrid_bulkdownload_set_request(bulkdownload, request);
    pxgrid_bulkdownload_set_ssl_ctx_cb(bulkdownload, _ssl_ctx_cb);
    pxgrid_bulkdownload_set_ssl_ctx_cb_user_data(bulkdownload, hconfig);
    
    status = pxgrid_bulkdownload_open(bulkdownload);
	if (status != PXGRID_STATUS_OK)	{
		helper_print_error(status);
		goto cleanup;
	}
    printf("*** bulkdownload open\n");
    
	jw_dom_node *user_node;
	while (true) {
		status = pxgrid_bulkdownload_next(bulkdownload, &user_node);
		if (status != PXGRID_STATUS_OK) break;
       
		if (!user_node) break;
        ise_identity_group *group;
        ise_identity_group_create(&group, user_node);
        ise_identity_group_print(group);
        ise_identity_group_destroy(group);
		jw_dom_context_destroy(jw_dom_get_context(user_node));
	}
     if (status == PXGRID_STATUS_REST_ERROR)
    {
        char desc[REST_ERROR_SIZE] ={0};
        pxgrid_bulkdownload_get_error_details(bulkdownload,desc,REST_ERROR_SIZE);
        printf(" Rest Error[%s]\n",desc);
    }
    else if (status != PXGRID_STATUS_OK)
    {
      helper_print_error(status);
    }
    
cleanup:
	if (request )
	{
		jw_dom_ctx *ctx = jw_dom_get_context(request);
		if(ctx) jw_dom_context_destroy(ctx);
	}
    if (bulkdownload) {
        pxgrid_bulkdownload_close(bulkdownload);
        pxgrid_bulkdownload_destroy(&bulkdownload);
    }
    printf("*** bulkdownload closed\n");

	if (connection) 
    {
		pxgrid_connection_disconnect(connection);
		pxgrid_connection_destroy(connection);
	}
    printf("*** disconnected\n");

	if (config) pxgrid_config_destroy(config);
    if (hconfig) helper_config_destroy(hconfig);
  
	return 0;
}
```



<a name="identityGroupQueryJava"></a>  

## identity group query - Java  

```output
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.net.Group;
import com.cisco.pxgrid.model.net.User;
import com.cisco.pxgrid.stub.identity.IdentityGroupQuery;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;

/**
 * Demonstrates how to use an xGrid client to query an identity group.
 */
public class UserIdentityGroupQuery {
	public static void main(String[] args) throws Exception	{
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		IdentityGroupQuery idGroupQuery = SessionDirectoryFactory.createIdentityGroupQuery(grid);

		while (true) {
			String user = helper.prompt("user name (or <enter> to disconnect): ");
			if (user == null) break;

			User u = idGroupQuery.getIdentityGroupByUser(user);
			if (u != null) {
				for (Group group : u.getGroupList().getObjects()) {
					System.out.println("group=" + group.getName());
				}
			} else {
				System.out.println("no groups associated with this user or no session activity associated with this user");
			}
		}
		helper.disconnect();
	}
}
```



<a name="identityGroupQueryC"></a>

## identity group query - C

```output
#include <stdlib.h>
#include <unistd.h>
#include "pxgrid.h"
#include "helper.h"
#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 
static void query(pxgrid_connection *connection, pxgrid_capability *capability, char *name) {
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *user_node;
	jw_dom_node *name_node;
	jw_dom_node *name_text;
	jw_dom_node *response = NULL;

    if (!jw_dom_context_create(&ctx, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getIdentityGroupRequest", &request, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}user", &user_node, &err)
    	|| !jw_dom_add_child(request, user_node, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}name", &name_node, &err)
    	|| !jw_dom_add_child(user_node, name_node, &err)
    	|| !jw_dom_text_create(ctx, name, &name_text, &err)
    	|| !jw_dom_add_child(name_node, name_text, &err)
    	)
    {
    	jw_log_err(JW_LOG_ERROR, &err, "query");
    	return;
    }
    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
    if (status == PXGRID_STATUS_OK) {
		jw_dom_node *id_gp_node = jw_dom_get_first_element(response, "user");
		if (id_gp_node) {
			ise_identity_group *id_group = NULL;
			ise_identity_group_create(&id_group, id_gp_node);
			ise_identity_group_print(id_group);
			ise_identity_group_destroy(id_group);
		}
        else {
            printf("No group found for this user\n");
        }
    }
    else {
    	printf("Error status=%s\n", pxgrid_status_get_message(status));
    }
}

int main(int argc, char **argv) {
	PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
        exit(EXIT_FAILURE); 
	}  
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

    pxgrid_connection_connect(connection);
	
	pxgrid_capability *capability = NULL;
	pxgrid_capability_create(&capability);
    if(!capability) exit(EXIT_FAILURE);
    
    
    const char cap_name[] = "IdentityGroupCapability";
    const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
    
    pxgrid_capability_set_namespace(capability, ns_iden);
	pxgrid_capability_set_name(capability, cap_name);

	pxgrid_capability_subscribe(capability, connection);
    
    
    char user[128];
    while (helper_prompt("User name (or <enter> to disconnect): ", user)) {
        query(connection, capability, user);
    }

	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
    helper_config_destroy(hconfig);
  	return 0;
}
```




<a name="identityGroupSubscribeJava"></a>  

## identity group subscribe - Java  

```output
package com.cisco.pxgrid.samples.ise;

import java.util.List;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.identity.IdentityGroupNotification;
import com.cisco.pxgrid.model.net.Group;
import com.cisco.pxgrid.model.net.User;
import com.cisco.pxgrid.stub.identity.IdentityGroupNotificationCallback;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;

/**
 * Demonstrates how to use an xGrid client to subscribe to identity group notifications.
 */	
public class UserIdentityGroupSubscribe {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		SessionDirectoryFactory.registerNotification(grid, new SampleNotificationHandler());

		helper.prompt("Press <enter> to disconnect...");
		helper.disconnect();
	}
	
	private static class SampleNotificationHandler implements IdentityGroupNotificationCallback {
		@Override
		public void handle(IdentityGroupNotification notf) {
			List<User> users = notf.getUsers();
			if (users != null) {
				for (User user : users) {
					System.out.println("user=" + user.getName());
					for (Group group : user.getGroupList().getObjects()) {
						System.out.println("group=" + group.getName());
					}
				}
			}
		}
		
	}

}
```




<a name="identityGroupSubscribeC"></a>  

## identity group subscribe - C  

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 
static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
	helper_print_jw_dom(node);
}

int main(int argc, char **argv) {
	PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE);
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

       
    pxgrid_connection_connect(connection);
	   

	pxgrid_capability *capability = NULL;
	pxgrid_capability_create(&capability);
    
    if(!capability) exit(EXIT_FAILURE);

    const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
    const char cap_name[] = "IdentityGroupCapability";
    
    pxgrid_capability_set_namespace(capability, ns_iden);
	pxgrid_capability_set_name(capability, cap_name);

	pxgrid_capability_subscribe(capability, connection);

    const char notif_name[] = "identityGroupNotification";
    
    pxgrid_connection_register_notification_handler(connection, ns_iden, notif_name, message_callback, NULL);

	sleep(600);

	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
    helper_config_destroy(hconfig);
 	return 0;
}
```




<a name="registerJava"></a>  

## register - Java  

```output
package com.cisco.pxgrid.samples.ise;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.ParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.TLSConfiguration;
import com.cisco.pxgrid.model.ise.Group;

/**
 * Demonstrates how to register a client with pxGrid.
 * 
 * @author jangwin
 *
 */

public class Register {
	protected static final Logger log = LoggerFactory.getLogger(Register.class);

	public static void main(String[] args)
		throws Exception
	{
		// collect command line parameters using helper class. custom implementations
		// will likely gather this information from a source other than command line.

		SampleProperties props = SampleProperties.load();
		SampleParameters params = new SampleParameters(props);
		params.appendCommonOptions();
		params.appendDescriptionOption();
		params.appendGroupOption();

		CommandLine line = null;
		try {
			line = params.process(args);
		} catch (IllegalArgumentException e) {
			params.printHelp("register");
			System.exit(1);
		} catch (ParseException e) {
			params.printHelp("register");
			System.exit(1);
		}

		String[] hostnames = params.retrieveHostnames(line);
		String username = params.retrieveUsername(line);
		String description = params.retrieveDescription(line);
		String keystoreFilename = params.retrieveKeystoreFilename(line);
		String keystorePassword = params.retrieveKeystorePassword(line);
		String truststoreFilename = params.retrieveTruststoreFilename(line);
		String truststorePassword = params.retrieveTruststorePassword(line);
		Group group = params.retrieveGroup(line);

		System.out.println("------- properties -------");
		System.out.println("version=" + props.getVersion());
		System.out.println("hostnames=" + SampleUtilities.hostnamesToString(hostnames));
		System.out.println("username=" + username);
		System.out.println("descriptipon=" + description);
		System.out.println("keystoreFilename=" + keystoreFilename);
		System.out.println("keystorePassword=" + keystorePassword);
		System.out.println("truststoreFilename=" + truststoreFilename);
		System.out.println("truststorePassword=" + truststorePassword);
		System.out.println("--------------------------");


		// check keystore

		if (!SampleUtilities.isValid(keystoreFilename, keystorePassword)) {
			System.err.println("unable to read keystore. please check the keystore filename and keystore password.");
			System.exit(1);
		}

		// check truststore

		if (!SampleUtilities.isValid(truststoreFilename, truststorePassword)) {
			System.err.println("unable to read truststore. please check the truststore filename and truststore password.");
			System.exit(1);
		}


		// set configuration

		TLSConfiguration config = new TLSConfiguration();
		config.setHosts(hostnames);
		config.setUserName(username);
		config.setDescription(description);
		config.setGroup(group.value());
		config.setKeystorePath(keystoreFilename);
		config.setKeystorePassphrase(keystorePassword);
		config.setTruststorePath(truststoreFilename);
		config.setTruststorePassphrase(truststorePassword);


		// initialize pxgrid connection

		System.out.println("registering...");
		GridConnection con = new GridConnection(config);
		con.addListener(new SampleConnectionListener());
		con.connect();
		System.out.println("done registering.");


		// disconnect from pxGrid

		con.disconnect();
	}
}
```



<a name="sessionDownloadJava"></a>  

## session download - Java  

```output
package com.cisco.pxgrid.samples.ise;

import java.util.Calendar;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.core.SubnetContentFilter;
import com.cisco.pxgrid.model.net.Session;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;
import com.cisco.pxgrid.stub.identity.SessionDirectoryQuery;
import com.cisco.pxgrid.stub.identity.SessionIterator;

/**
 * Demonstrates how to use download all active sessions from ISE
 */
public class SessionDownload {
	public static void main(String [] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		SubnetContentFilter filters = helper.promptIpFilters("Filters (ex. '1.0.0.0/255.0.0.0,1234::/16...' or <enter> for no filter): ");
		Calendar start = helper.promptDate("Start time (ex. '2015-01-31 13:00:00' or <enter> for no start time): ");
		Calendar end = helper.promptDate("End time (ex. '2015-01-31 13:00:00' or <enter> for no end time): ");

		SessionDirectoryQuery sd = SessionDirectoryFactory.createSessionDirectoryQuery(grid);
		SessionIterator iterator = sd.getSessionsByTime(start, end, filters);
		iterator.open();

		int count = 0;
		Session s;
		while ((s = iterator.next()) != null) {
			SampleHelper.print(s);
			count++;
		}
		iterator.close();

		System.out.println("Session count=" + count);
		helper.disconnect();
	}
}
```




<a name="sessionDownloadC"></a>  

## session download - C  

```output
/*
 * sessions_download.c
 */

#include "pxgrid.h"
#include "helper.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <jabberwerx/jabberwerx.h>
#include <openssl/ssl.h>

#define UNUSED(x) (void)(x)
#define REST_ERROR_SIZE 128

static void session_directory_service_query_get_host(pxgrid_connection *connection, char host[], size_t hostsize) { 
	jw_err err;
	jw_dom_ctx_type *ctx = NULL;
	jw_dom_node *request = NULL;
	jw_dom_node *response = NULL;
	
	/* validate input parameter */
	if(!host) {
		return;
	}
	host[0] = '\0';

	if(hostsize <= 1) {
		return;
	}

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getSessionDirectoryHostnamesRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid/admin", &err) ||
		!jw_dom_put_namespace(request, "ns5", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns6", "http://www.cisco.com/pxgrid/eps", &err) ||
		!jw_dom_put_namespace(request, "ns7", "http://www.cisco.com/pxgrid/netcap", &err) 
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "query");
		return;
	}	
	
	pxgrid_capability *capability = NULL; 
	pxgrid_capability_create(&capability);
    
    char ns[] = "http://www.cisco.com/pxgrid/identity";
    char name[] = "SessionDirectoryCapability";
    
	pxgrid_capability_set_namespace(capability, ns);
	pxgrid_capability_set_name(capability, name);
    
    
	pxgrid_capability_subscribe(capability, connection);
	
	
	PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** queried\n");
		if(response) {
			jw_dom_node *hostnames_node = jw_dom_get_first_element(response, "hostnames");
			jw_dom_node *hostname_node = jw_dom_get_first_element(hostnames_node, "hostname");
			if(hostname_node) {
				strncpy(host, jw_dom_get_first_text(hostname_node), hostsize - 1);
			}
		}
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
	pxgrid_capability_destroy(capability);
}

static jw_dom_node *_create_request() {
	jw_err err;
	jw_dom_ctx *ctx = NULL;
	jw_dom_node *request;
	jw_dom_node *time_window;
	jw_dom_node *begin_node, *end_node;
	jw_dom_node	*text_node;

	static char *dateFormat = "%Y-%m-%dT%H:%M:%SZ";
	time_t endTime = time(NULL), beginTime = endTime - 604800;

	char begin_string[50], end_string[50];
	strftime(begin_string, sizeof(begin_string), dateFormat, gmtime(&beginTime));
	strftime(end_string, sizeof(end_string), dateFormat, gmtime(&endTime));

	if (!jw_dom_context_create(&ctx, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getSessionListByTimeRequest", &request, &err) ||
		!jw_dom_put_namespace(request, "ns2", "http://www.cisco.com/pxgrid/identity", &err) ||
		!jw_dom_put_namespace(request, "ns3", "http://www.cisco.com/pxgrid/net", &err) ||
		!jw_dom_put_namespace(request, "ns4", "http://www.cisco.com/pxgrid", &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}timeWindow", &time_window, &err) ||
		!jw_dom_add_child(request, time_window, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}begin", &begin_node, &err) ||
		!jw_dom_add_child(time_window, begin_node, &err) ||
		!jw_dom_text_create(ctx, begin_string, &text_node, &err) ||
		!jw_dom_add_child(begin_node, text_node, &err) ||
		!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}end", &end_node, &err) ||
		!jw_dom_add_child(time_window, end_node, &err) ||
		!jw_dom_text_create(ctx, end_string, &text_node, &err) ||
		!jw_dom_add_child(end_node, text_node, &err)
		)
	{
		jw_log_err(JW_LOG_ERROR, &err, "_create_request()");
        return NULL;
	}
	return request;
}

int _pem_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _ssl_ctx_cb(pxgrid_bulkdownload *bulkdownload, void *_ssl_ctx, void *user_data) {
    UNUSED(bulkdownload);
    SSL_CTX *ssl_ctx = _ssl_ctx;
    helper_config *hconfig = user_data;
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->bulk_server_cert_chain_filename, NULL);
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);
}



static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 //static const char bulkdownload_result_cb_user_data[] = "sessions_download_filtered";
 
int _on_log_cb(const char * format, va_list ap)
{
    int written = -1;
	char buffer[1024]={0};
	written = vsnprintf(buffer, 1023,format, ap);
   	FILE *fd = fopen("pxg_sample.log", "a+");
	if (fd != NULL)
	{
		fprintf(fd,"%s",buffer);
		fflush(fd);
	}
	fclose(fd);	
    return written;	
}


int main(int argc, char *argv[]) {
   PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_bulkdownload  *bulkdownload = NULL;
    pxgrid_connection *connection = NULL;
    bool bulkDownloadEverConnected = false;
    
    
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE); 
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

	pxgrid_log_set_callback(_on_log_cb);
	pxgrid_log_set_level(PXGRID_LOG_VERBOSE);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

        
    pxgrid_connection_connect(connection);

#define MAX_HOST_SIZE	256    
    char host[MAX_HOST_SIZE] = {0};
    session_directory_service_query_get_host(connection, host, MAX_HOST_SIZE);
    if(!host[0]) 
    {
        printf("Unable to get host name from session directory service\n");
        goto cleanup;
    }

	// Bulk download setup
	char url[128];
	sprintf(url, "https://%s/pxgrid/mnt/sd/getSessionListByTime", host);

	jw_dom_node * request = _create_request();
    pxgrid_config_set_bulk_server_cert_chain_filename(conn_config , hconfig->bulk_server_cert_chain_filename );
    
    
    pxgrid_bulkdownload_create(&bulkdownload, conn_config);
	if(!bulkdownload) 
	{
	    printf("Unable to create bulkdownload object\n");
		goto cleanup; 
	}
    pxgrid_bulkdownload_set_url(bulkdownload, url);
    pxgrid_bulkdownload_set_request(bulkdownload, request);
    pxgrid_bulkdownload_set_ssl_ctx_cb(bulkdownload, _ssl_ctx_cb);
    pxgrid_bulkdownload_set_ssl_ctx_cb_user_data(bulkdownload, hconfig);
    //pxgrid_bulkdownload_set_open_result_cb(bulkdownload, helper_pxgrid_bulkdownload_open_result_cb);
   // pxgrid_bulkdownload_set_open_result_cb_user_data(bulkdownload, (void*)&bulkDownloadEverConnected);
    status = pxgrid_bulkdownload_open(bulkdownload);
	if (status != PXGRID_STATUS_OK)	
    {
		helper_print_error(status);
		goto cleanup;
	}
    printf("*** bulkdownload opened\n");

	jw_dom_node *session_node = NULL;
	while (true) 
    {
		status = pxgrid_bulkdownload_next(bulkdownload, &session_node);
		
        if (status != PXGRID_STATUS_OK) break;
        if (!session_node) break;
        ise_session *session = NULL;
        ise_session_create(&session, session_node);
        ise_session_print(session);
        ise_session_destroy(session);
		jw_dom_context_destroy(jw_dom_get_context(session_node));
        session_node = NULL;
	}
    if (status == PXGRID_STATUS_REST_ERROR)
    {
        char desc[REST_ERROR_SIZE] ={0};
        pxgrid_bulkdownload_get_error_details(bulkdownload,desc,REST_ERROR_SIZE);
        printf(" Rest Error[%s]\n",desc);
    }
    else if (status != PXGRID_STATUS_OK)
    {
      helper_print_error(status);
    }
    
cleanup:
	if (request ) 
    {
        jw_dom_ctx *ctx = jw_dom_get_context(request);
        if(ctx) jw_dom_context_destroy(ctx);      
    }
    if (bulkdownload) {
        pxgrid_bulkdownload_close(bulkdownload);
        pxgrid_bulkdownload_destroy(&bulkdownload);
    }
    printf("*** bulkdownload closed\n");

   	if (connection) {
		pxgrid_connection_disconnect(connection);
		pxgrid_connection_destroy(connection);
	}
    printf("*** disconnected\n");

	if (conn_config) pxgrid_config_destroy(conn_config);
    if (hconfig) helper_config_destroy(hconfig);
  	return 0;
}
```




<a name="sessionQueryJava"></a>  

## session query - Java  

```output
package com.cisco.pxgrid.samples.ise;

import java.net.InetAddress;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.net.Session;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;
import com.cisco.pxgrid.stub.identity.SessionDirectoryQuery;

/**
 * Demonstrates how to query ISE for an active session by IP address
 */
public class SessionQueryByIp {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		SessionDirectoryQuery query = SessionDirectoryFactory
				.createSessionDirectoryQuery(grid);

		while (true) {
			String ip = helper.prompt("IP address (or <enter> to disconnect): ");
			if (ip == null)	break;

			Session session = query.getActiveSessionByIPAddress(InetAddress
					.getByName(ip));
			if (session != null) {
				SampleHelper.print(session);
			} else {
				System.out.println("session not found");
			}
		}
		helper.disconnect();
	}
}
```



<a name="sessionQueryC"></a>  

## session query - C  

```output
#include <stdlib.h>
#include <unistd.h>
#include "pxgrid.h"
#include "helper.h"
#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)
int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }
 static void query(pxgrid_connection *connection, pxgrid_capability *capability, char *ip) {
	jw_err err;
	jw_dom_ctx_type *ctx;
	jw_dom_node *request;
	jw_dom_node *ip_interface;
	jw_dom_node *ip_address;
	jw_dom_node *ip_address_text;
	jw_dom_node *response;

    if (!jw_dom_context_create(&ctx, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getActiveSessionByIPAddressRequest", &request, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}ipInterface", &ip_interface, &err)
    	|| !jw_dom_add_child(request, ip_interface, &err)
   		|| !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}ipAddress", &ip_address, &err)
    	|| !jw_dom_add_child(ip_interface, ip_address, &err)
    	|| !jw_dom_text_create(ctx, ip, &ip_address_text, &err)
    	|| !jw_dom_add_child(ip_address, ip_address_text, &err)
    	)
    {
    	jw_log_err(JW_LOG_ERROR, &err, "query");
    	return;
    }

    printf("***request=");
    helper_print_jw_dom(request);

    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
    if (status == PXGRID_STATUS_OK) {
        printf("***response=");
    	helper_print_jw_dom(response);
    }
    else {
    	printf("status=%s\n", pxgrid_status_get_message(status));
    }
}

int main(int argc, char **argv) {
   PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE);
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

   
    
    pxgrid_connection_connect(connection);
	
	pxgrid_capability *capability;
	pxgrid_capability_create(&capability);
    
    if(!capability) exit(EXIT_FAILURE);
    
    const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
    const char cap_name[] = "SessionDirectoryCapability";
    
	pxgrid_capability_set_namespace(capability, ns_iden);
	pxgrid_capability_set_name(capability, cap_name);

   
	pxgrid_capability_subscribe(capability, connection);

    char            ip_address_str[48]          = {0};
    char            ip_address[48]              = {0};
    char            ip_address_extra_str[48]    = {0};

    printf("Get active session for IP Address: ");
    fgets(ip_address_str, sizeof(ip_address_str), stdin);
    sscanf(ip_address_str, "%s%[^\n]", ip_address, ip_address_extra_str);

	query(connection, capability, ip_address);

    memset(ip_address_str, 0, sizeof(ip_address_str));
    memset(ip_address, 0, sizeof(ip_address));
    memset(ip_address_extra_str, 0, sizeof(ip_address_extra_str));

	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
    helper_config_destroy(hconfig);
	return 0;
}
```




<a name="sessionSubscribeJava"></a>  

## session subscribe - Java  

```output
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.model.core.SubnetContentFilter;
import com.cisco.pxgrid.model.net.Session;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;
import com.cisco.pxgrid.stub.identity.SessionDirectoryNotification;

/**
 * Demonstrates how to subscribe to session notifications generated by ISE
 */
public class SessionSubscribe {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		SubnetContentFilter filter = helper.promptIpFilters("Filters (ex. '1.0.0.0/255.0.0.0,1234::/16,...' or <enter> for no filter): ");

		if (filter != null) {
			SessionDirectoryFactory.registerNotification(grid, new SampleNotificationHandler(), filter);
		} else {
			SessionDirectoryFactory.registerNotification(grid, new SampleNotificationHandler());
		}

		helper.prompt("press <enter> to disconnect...");
		helper.disconnect();
	}

	public static class SampleNotificationHandler
		implements SessionDirectoryNotification {
		@Override
		public void onChange(Session session) {
			System.out.println("session notification: "); 
			SampleHelper.print(session);
			System.out.println(""); 
		}
	}
}
```



<a name="sessionSubscribeC"></a>  

## session subscribe - C  

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)


int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }

static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
	helper_print_jw_dom(node);
}

int main(int argc, char **argv) {
    PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE);
	} 
pxgrid_log_set_level(PXGRID_LOG_DEBUG);
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

    pxgrid_connection_connect(connection);
	    
	pxgrid_capability *capability;
	pxgrid_capability_create(&capability);
	 if(!capability) exit(EXIT_FAILURE);
    
    const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
    const char cap_name[] = "SessionDirectoryCapability";
    
    pxgrid_capability_set_namespace(capability, ns_iden);
	pxgrid_capability_set_name(capability, cap_name);

   pxgrid_capability_subscribe(capability, connection);
   
   const char sess_notif[] = "sessionNotification";
   
	pxgrid_connection_register_notification_handler(connection, ns_iden, sess_notif, message_callback, NULL);
	
	sleep(600);

	pxgrid_connection_disconnect(connection);
	printf("*** disconnected\n");

	pxgrid_capability_destroy(capability);
	pxgrid_connection_destroy(connection);
    helper_config_destroy(hconfig);
 	return 0;
}
```



<a name="ancJavaSample1"></a>  

## ANC Java Sample 1  

```output
package com.cisco.pxgrid.samples.ise;

import java.util.List;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.anc.ANCClient;
import com.cisco.pxgrid.anc.ANCQuery;
import com.cisco.pxgrid.model.anc.ANCAction;
import com.cisco.pxgrid.model.anc.ANCPolicy;
import com.cisco.pxgrid.model.anc.ANCResult;

public class ANCActions {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection grid = helper.connectWithReconnectionManager();

		ANCClient client = new ANCClient();
		ANCQuery query = client.createANCQuery(grid);

		String policyName, mac, ip;
		ANCResult result = null;
		ANCPolicy ancPolicy;
		String actionVal;
		List<ANCAction> actionList;
		
		operationLoop:
		while (true) {
			System.out.println("Operation selection:");
			System.out.println("  1. ApplyEndpointPolicyByMAC");
			System.out.println("  2. ClearEndpointPolicyByMAC");
			System.out.println("  3. ApplyEndpointPolicyByIP");
			System.out.println("  4. ClearEndpointPolicyByIP");
			System.out.println("  5. GetEndpointByIP");
			System.out.println("  6. Subscribe");
			System.out.println("  7. CreatePolicy");
			System.out.println("  8. UpdatePolicy");
			System.out.println("  9. DeletePolicy");
			System.out.println("  10. GetPolicyByName");
			System.out.println("  11. GetAllPolicies");
			System.out.println("  12. GetEndPointByMAC");
			System.out.println("  13. GetAllEndpoints");
			System.out.println("  14. GetEndpointByPolicy");
			
			String value = helper.prompt("Enter number (or <enter> to disconnect): ");
			if (value == null) break;
			int operation;
			try {
			 operation = Integer.parseInt(value);
			}
			catch(NumberFormatException ex)
			{
				continue;
			}
			switch (operation) {
			case 1:
				policyName = helper.prompt("Policy name (or <enter> to disconnect): ");
				if (policyName == null) break operationLoop;
				mac = helper.prompt("MAC address (or <enter> to disconnect): ");
				if (mac == null) break operationLoop;
				result = query.applyEndpointPolicyByMAC(policyName, mac);
				break;
			case 2:
				mac = helper.prompt("MAC address (or <enter> to disconnect): ");
				if (mac == null) break operationLoop;
				result = query.clearEndpointPolicyByMAC(mac);
				break;
			case 3:
				policyName = helper.prompt("Policy name (or <enter> to disconnect): ");
				if (policyName == null) break operationLoop;
				ip = helper.prompt("IP address (or <enter> to disconnect): ");
				if (ip == null) break operationLoop;
				result = query.applyEndpointPolicyByIP(policyName, ip);
				break;
			case 4:
				ip = helper.prompt("IP address (or <enter> to disconnect): ");
				if (ip == null) break operationLoop;
				result = query.clearEndpointPolicyByIP(ip);
				break;
			case 5:
				ip = helper.prompt("IP address (or <enter> to disconnect): ");
				if (ip == null) break operationLoop;
				result = query.getEndpointByIP(ip);
				break;
			case 6:
				query.registerNotification(grid, new ANCNotificationHandlers.ApplyEndpointPolicyNotificationHandler());
				query.registerNotification(grid, new ANCNotificationHandlers.ClearEndpointPolicyNotificationHandler());
				query.registerNotification(grid, new ANCNotificationHandlers.CreatePolicyNotificationHandler());
				query.registerNotification(grid, new ANCNotificationHandlers.UpdatePolicyNotificationHandler());
				query.registerNotification(grid, new ANCNotificationHandlers.DeletePolicyNotificationHandler());
				helper.prompt("Press <enter> to disconnect: ");
				break operationLoop;
			case 7: //Create policy
				ancPolicy= new ANCPolicy();
				policyName = helper.prompt("Policy name (or <enter> to disconnect): ");
				if (policyName == null) break operationLoop;
				ancPolicy.setName(policyName);
				actionList = ancPolicy.getActions();
				int count;
				int actionValInt;
				actionLoop:
				while(true){
					System.out.println("ANC Actions:");
					count = 1;
					for (ANCAction c: ANCAction.values()) {
						System.out.println(count++ + ". " + c.name());
			        }
					System.out.println("0. End adding actions");
					actionVal = helper.prompt("Enter ANC action (or <enter> to disconnect): ");
					if (actionVal == null) break;
					actionValInt = Integer.parseInt(actionVal);
					ANCAction ancAction;
					switch(actionValInt){
					case 1: ancAction = ANCAction.QUARANTINE; break;
					case 2: ancAction = ANCAction.SHUT_DOWN; break;
					case 3: ancAction = ANCAction.PORT_BOUNCE; break;
					case 0:break actionLoop;
					default: System.out.println("Please enter the valid option");
					         continue;
					}
					actionList.add(ancAction);
				}
				result = query.createPolicy(ancPolicy);
				break;
			case 8: //update policy
				ancPolicy= new ANCPolicy();
				policyName = helper.prompt("Policy name (or <enter> to disconnect): ");
				if (policyName == null) break operationLoop;
				ancPolicy.setName(policyName);
				actionList = ancPolicy.getActions();
				actionLoop:
				while(true){
					System.out.println("ANC Actions:");
					count = 1;
					for (ANCAction c: ANCAction.values()) {
						System.out.println(count++ + ". " + c.name());
			        }
					System.out.println("0. End adding actions");
					actionVal = helper.prompt("Enter ANC action (or <enter> to disconnect): ");
					if (actionVal == null) break;
					actionValInt = Integer.parseInt(actionVal);
					ANCAction ancAction;
					switch(actionValInt){
					
					case 1: ancAction = ANCAction.QUARANTINE; break;
					case 2: ancAction = ANCAction.SHUT_DOWN; break;
					case 3: ancAction = ANCAction.PORT_BOUNCE; break;
					case 0:break actionLoop;
					default: System.out.println("Please enter the valid option");
					         continue;
					}
					actionList.add(ancAction);
				}
				result = query.updatePolicy(ancPolicy);
				break;	
			case 9: //delete policy	
				policyName = helper.prompt("Policy name (or <enter> to disconnect): ");
				if (policyName == null) break operationLoop;
				result = query.deletePolicy(policyName);
				break;
			case 10: //get policy by name
				policyName = helper.prompt("Policy name (or <enter> to disconnect): ");
				if (policyName == null) break operationLoop;
				result = query.retrievePolicyByName(policyName);
				break;
			case 11: //retrieve all policies
				result = query.retrieveAllPolicies();
				break;
			case 12: //get endpoint by MAC
				mac = helper.prompt("Enter MAC address (or <enter> to disconnect): ");
				if (mac == null) break operationLoop;
				result = query.getEndpointByMAC(mac);
				break;	
			case 13: //get all endpoints
				result = query.getAllEndpoints();
				break;	
			case 14: //get endpointByPolicy
				policyName = helper.prompt("Policy name (or <enter> to disconnect): ");
				if (policyName == null) break operationLoop;
				result = query.retrieveEndpointByPolicy(policyName);
				break;		
			default:
				System.out.println("Unknown selection");
				break operationLoop;
			}
			System.out.println("ANCResult=" + result);
		}
		helper.disconnect();
	}
}
```



<a name="ancJavaSample2"></a>  

## ANC Java Sample 2  

```output
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.anc.ApplyEndpointPolicyNotifHandler;
import com.cisco.pxgrid.anc.ClearEndpointPolicyNotifHandler;
import com.cisco.pxgrid.anc.CreatePolicyNotifHandler;
import com.cisco.pxgrid.anc.UpdatePolicyNotifHandler;
import com.cisco.pxgrid.anc.DeletePolicyNotifHandler;
import com.cisco.pxgrid.model.anc.ANCAction;
import com.cisco.pxgrid.model.anc.ANCEndpoint;
import com.cisco.pxgrid.model.anc.ANCPolicy;

/**
 * This class holds all ANC Notification Handlers
 * for subscribe 
 * 
 */
public class ANCNotificationHandlers {
	private static String printANCEndpoint(ANCEndpoint endpoint) {
		StringBuffer buffer = new StringBuffer();
		if(endpoint != null) {
			String mac;
			if((mac = endpoint.getMacAddress()) != null) {
				buffer.append("MAC Address=" + mac + " ");
			}
			String policy;
			if((policy = endpoint.getPolicyName()) != null) {
				buffer.append("Policy=" + policy + " ");
			}
			String ip;
			if((ip = endpoint.getIpAddress()) != null) {
				buffer.append(" IP Address=" + ip);	
			}
		}
		return buffer.toString();	
	}
	
	private static String printANCPolicy(ANCPolicy policy) {
		StringBuffer buffer = new StringBuffer();
		if (policy != null) {
			buffer.append("Policy=" + policy.getName() + " ");
			buffer.append("Action(s)=");
			for (ANCAction action : policy.getActions()) {
				buffer.append(action.name() + " ");
			}

		}
		return buffer.toString();
	}
	
	public static class ApplyEndpointPolicyNotificationHandler
	implements ApplyEndpointPolicyNotifHandler {

		@Override
		public void onChange(ANCEndpoint endpoint) {
			System.out.println("\nApply Endpoint Policy Notification:");
			System.out.println(printANCEndpoint(endpoint));
		}
	}
	
	public static class ClearEndpointPolicyNotificationHandler
	implements ClearEndpointPolicyNotifHandler {

		@Override
		public void onChange(ANCEndpoint endpoint) {
			System.out.println("\nClear Endpoint Policy Notification:");
			System.out.println(printANCEndpoint(endpoint));
		}
	}
	
	public static class CreatePolicyNotificationHandler
	implements CreatePolicyNotifHandler {

		@Override
		public void onChange(ANCPolicy policy) {
			System.out.println("\nCreatePolicyNotification:");
			System.out.println(printANCPolicy(policy));
		}
	}
	
	public static class UpdatePolicyNotificationHandler
	implements UpdatePolicyNotifHandler {

		@Override
		public void onChange(ANCPolicy oldPolicy, ANCPolicy newPolicy) {
			System.out.println("\nUpdatePolicyNotification:");
			System.out.println("Old policy: ");
			System.out.println(printANCPolicy(oldPolicy));
			System.out.println("New policy: ");
			System.out.println(printANCPolicy(newPolicy));
		}
	}
	
	public static class DeletePolicyNotificationHandler
	implements DeletePolicyNotifHandler {

		@Override
		public void onChange(ANCPolicy policy) {
			System.out.println("\nDeletePolicyNotification:");
			System.out.println(printANCPolicy(policy));
		}
	}
}
```



<a name="ancCSample1"></a>  

## ANC C Sample 1  

> ANC Actions

```output
#include <stdlib.h>
#include <unistd.h>

#include "pxgrid.h"
#include <openssl/ssl.h>

#include "anc_policy_crud.h"
#include "anc_endpoint_action.h"
#include "anc_endpoint_read.h"
#include "anc_subscribe.h"

#define UNUSED(x) (void)(x)
#define str(x) #x

PXGRID_STATUS       status          = PXGRID_STATUS_OK;
pxgrid_connection   *connection     = NULL;
pxgrid_config       *conn_config    = NULL;
helper_config       *hconfig        = NULL;
pxgrid_capability   *capability     = NULL;

typedef enum
{
    ANC_ACTION_EXIT = 0,
    ANC_APPLY_ENDPOINT_POLICY_BY_MAC,
    ANC_CLEAR_ENDPOINT_POLICY_BY_MAC,
    ANC_APPLY_ENDPOINT_POLICY_BY_IP,
    ANC_CLEAR_ENDPOINT_POLICY_BY_IP,
    ANC_SUBSCRIBE,
    ANC_CREATE_POLICY,
    ANC_UPDATE_POLICY,
    ANC_DELETE_POLICY,
    ANC_GET_POLICY_BY_NAME,
    ANC_GET_ALL_POLICIES,
    ANC_GET_ENDPOINT_BY_MAC,
    ANC_GET_ENDPOINT_BY_IP,
    ANC_GET_ALL_ENDPOINTS,
    ANC_GET_ENDPOINT_BY_POLICY,
    ANC_ACTION_MAX
} anc_operand;

int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}

static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
    printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }

static void _xgrid_connect(int argc, char **argv) {

    helper_config_create(&hconfig, argc, argv);
    if(!hconfig) 
    {
        printf("Unable to create hconfig object\n");
        exit(EXIT_FAILURE); 
    } 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_config_set_user_group(conn_config, "ANC");
    //Set grid timeout to be greater than ANC operation timeout
    pxgrid_config_set_send_timeout_seconds(conn_config, 75);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);  
    pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

    pxgrid_capability_create(&capability);

    char namespacebuf[] = "http://www.cisco.com/pxgrid/anc";
    char namebuf[] = "AdaptiveNetworkControlCapability";
    
    pxgrid_capability_set_namespace(capability, namespacebuf);
    pxgrid_capability_set_name(capability, namebuf);
      
    pxgrid_connection_connect(connection);
}

static void _xgrid_disconnect() {
    if (connection && pxgrid_connection_is_connected(connection)) {
        pxgrid_connection_disconnect(connection);
        printf("*** disconnected\n");
    }

    if (connection) pxgrid_connection_destroy(connection);
    if (conn_config) pxgrid_config_destroy(conn_config);
    if (hconfig) helper_config_destroy(hconfig);
    if (capability) pxgrid_capability_destroy(capability);
}

int main(int argc, char **argv)
{
    _xgrid_connect(argc, argv);

    pxgrid_capability_subscribe(capability, connection);

    char            anc_num_str[16]         = {0};
    char            anc_num_extra_str[16]   = {0};
    unsigned int    anc_num                 = ANC_ACTION_EXIT;

    char            policy_name_str[66]         = {0};
    char            policy_name[66]             = {0};
    char            policy_name_extra_str[66]   = {0};

    char            mac_address_str[24]         = {0};
    char            mac_address[24]             = {0};
    char            mac_address_extra_str[24]   = {0};

    char            ip_address_str[48]          = {0};
    char            ip_address[48]              = {0};
    char            ip_address_extra_str[48]    = {0};
    int             actions_chosen[NUM_ANC_ACTIONS];
    memset(actions_chosen, 0, NUM_ANC_ACTIONS*sizeof(int));

    do {
        anc_num = ANC_ACTION_EXIT;

        printf ("Choose ANC Action:\n");
        printf ("0. Exit\n");
        printf ("1. ApplyEndpointPolicyByMAC\n");
        printf ("2. ClearEndpointPolicyByMAC\n");
        printf ("3. ApplyEndpointPolicyByIP\n");
        printf ("4. ClearEndpointPolicyByIP\n");
        printf ("5. Subscribe\n");
        printf ("6. CreatePolicy\n");
        printf ("7. UpdatePolicy\n");
        printf ("8. DeletePolicy\n");
        printf ("9. GetPolicyByName\n");
        printf ("10. GetAllPolicies\n");
        printf ("11. GetEndPointByMAC\n");
        printf ("12. GetEndpointByIP\n");
        printf ("13. GetAllEndpoints\n");
        printf ("14. GetEndpointByPolicy\n");
        printf ("Enter action #:");

        fgets(anc_num_str, sizeof(anc_num_str), stdin);
        sscanf(anc_num_str, "%i%[^\n]", &anc_num, anc_num_extra_str);

        switch (anc_num) {
            case ANC_APPLY_ENDPOINT_POLICY_BY_MAC:
                printf("Policy name: ");
                fgets(policy_name_str, sizeof(policy_name_str), stdin);
                sscanf(policy_name_str, "%s%[^\n]", policy_name, policy_name_extra_str);

                printf("MAC Address: ");
                fgets(mac_address_str, sizeof(mac_address_str), stdin);
                sscanf(mac_address_str, "%s%[^\n]", mac_address, mac_address_extra_str);

                anc_apply_endpoint_policy_by_mac_request(connection, capability, policy_name, mac_address);
                break;
            case ANC_CLEAR_ENDPOINT_POLICY_BY_MAC:
                printf("MAC Address: ");
                fgets(mac_address_str, sizeof(mac_address_str), stdin);
                sscanf(mac_address_str, "%s%[^\n]", mac_address, mac_address_extra_str);

                anc_clear_endpoint_policy_by_mac_request(connection, capability, mac_address);
                break;
            case ANC_APPLY_ENDPOINT_POLICY_BY_IP:
                printf("Policy name: ");
                fgets(policy_name_str, sizeof(policy_name_str), stdin);
                sscanf(policy_name_str, "%s%[^\n]", policy_name, policy_name_extra_str);

                printf("IP Address: ");
                fgets(ip_address_str, sizeof(ip_address_str), stdin);
                sscanf(ip_address_str, "%s%[^\n]", ip_address, ip_address_extra_str);

                anc_apply_endpoint_policy_by_ip_request(connection, capability, policy_name, ip_address);
                break;
            case ANC_CLEAR_ENDPOINT_POLICY_BY_IP:
                printf("IP Address: ");
                fgets(ip_address_str, sizeof(ip_address_str), stdin);
                sscanf(ip_address_str, "%s%[^\n]", ip_address, ip_address_extra_str);

                anc_clear_endpoint_policy_by_ip_request(connection, capability, ip_address);
                break;
            case ANC_SUBSCRIBE:
                subscribe(connection);
                printf("Hit Enter to disconnect: ");
                char c=getchar();
                anc_num = ANC_ACTION_EXIT;
                break;
            case ANC_CREATE_POLICY:
                printf("Policy name: ");
                fgets(policy_name_str, sizeof(policy_name_str), stdin);
                sscanf(policy_name_str, "%s%[^\n]", policy_name, policy_name_extra_str);
                anc_action_prompt(actions_chosen);

                anc_createPolicyRequest(connection, capability, policy_name, actions_chosen);

                break;
            case ANC_UPDATE_POLICY:
                printf("Policy name: ");
                fgets(policy_name_str, sizeof(policy_name_str), stdin);
                sscanf(policy_name_str, "%s%[^\n]", policy_name, policy_name_extra_str);
                anc_action_prompt(actions_chosen);

                anc_updatePolicyRequest(connection, capability, policy_name, actions_chosen);
                break;
            case ANC_DELETE_POLICY:
                printf("Policy name: ");
                fgets(policy_name_str, sizeof(policy_name_str), stdin);
                sscanf(policy_name_str, "%s%[^\n]", policy_name, policy_name_extra_str);

                anc_deletePolicyRequest(connection, capability, policy_name);
                break;
            case ANC_GET_POLICY_BY_NAME:
                printf("Policy name: ");
                fgets(policy_name_str, sizeof(policy_name_str), stdin);
                sscanf(policy_name_str, "%s%[^\n]", policy_name, policy_name_extra_str);

                anc_getPolicyByName(connection, capability, policy_name);
                break;
            case ANC_GET_ALL_POLICIES:
                anc_getAllPolicies(connection, capability);
                break;
            case ANC_GET_ENDPOINT_BY_MAC:
                printf("MAC Address: ");
                fgets(mac_address_str, sizeof(mac_address_str), stdin);
                sscanf(mac_address_str, "%s%[^\n]", mac_address, mac_address_extra_str);

                anc_getEndpointByMACRequest(connection, capability, mac_address);
                break;
            case ANC_GET_ENDPOINT_BY_IP:
                printf("IP Address: ");
                fgets(ip_address_str, sizeof(ip_address_str), stdin);
                sscanf(ip_address_str, "%s%[^\n]", ip_address, ip_address_extra_str);

                anc_getEndpointByIPRequest(connection, capability, ip_address);
                break;
            case ANC_GET_ALL_ENDPOINTS:
                anc_getAllEndpointsRequest(connection, capability);
                break;
            case ANC_GET_ENDPOINT_BY_POLICY:
                printf("Policy name: ");
                fgets(policy_name_str, sizeof(policy_name_str), stdin);
                sscanf(policy_name_str, "%s%[^\n]", policy_name, policy_name_extra_str);

                anc_getEndpointByPolicyRequest(connection, capability, policy_name);
            default:
                printf("!!!!!!!! IMPLEMENTED\n");
                break;
        }

        memset(anc_num_str, 0, sizeof(anc_num_str));
        memset(anc_num_extra_str, 0, sizeof(anc_num_extra_str));

        memset(policy_name_str, 0, sizeof(policy_name_str));
        memset(policy_name, 0, sizeof(policy_name));
        memset(policy_name_extra_str, 0, sizeof(policy_name_extra_str));

        memset(mac_address_str, 0, sizeof(mac_address_str));
        memset(mac_address, 0, sizeof(mac_address));
        memset(mac_address_extra_str, 0, sizeof(mac_address_extra_str));

        memset(ip_address_str, 0, sizeof(ip_address_str));
        memset(ip_address, 0, sizeof(ip_address));
        memset(ip_address_extra_str, 0, sizeof(ip_address_extra_str));

        memset(actions_chosen, 0, NUM_ANC_ACTIONS*sizeof(int));
        

    } while(anc_num != ANC_ACTION_EXIT);

    _xgrid_disconnect();
    return 0;
}
```



<a name="ancCSample2"></a>  

## ANC C Sample 2  

> ANC Endpoint Action  

```output
#include "anc_endpoint_action.h"
#include "helper.h"


void anc_apply_endpoint_policy_by_mac_request(pxgrid_connection *connection, pxgrid_capability *capability, char *policy_name, char *mac_address) {
	jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *anc_policy_name;
    jw_dom_node *anc_policy_name_text;
    jw_dom_node *anc_mac_address;
    jw_dom_node *anc_mac_address_text;
    jw_dom_node *request;
    jw_dom_node *response;

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}applyEndpointPolicyByMACRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}policyName", &anc_policy_name, &err)
        || !jw_dom_add_child(request, anc_policy_name, &err)
        || !jw_dom_text_create(ctx, policy_name, &anc_policy_name_text, &err)
        || !jw_dom_add_child(anc_policy_name, anc_policy_name_text, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}macAddress", &anc_mac_address, &err)
        || !jw_dom_add_child(request, anc_mac_address, &err)
        || !jw_dom_text_create(ctx, mac_address, &anc_mac_address_text, &err)
        || !jw_dom_add_child(anc_mac_address, anc_mac_address_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** response\n");
		helper_print_jw_dom(response);	
		printf("*** queried\n");
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
}

void anc_apply_endpoint_policy_by_ip_request(pxgrid_connection *connection, pxgrid_capability *capability, char *policy_name, char *ip) {
	jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *anc_policy_name;
    jw_dom_node *anc_policy_name_text;
    jw_dom_node *anc_ip_identifier;
    jw_dom_node *anc_ip_address;
    jw_dom_node *anc_ip_address_text;
    jw_dom_node *request;
    jw_dom_node *response;

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}applyEndpointPolicyByIPRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}policyName", &anc_policy_name, &err)
        || !jw_dom_add_child(request, anc_policy_name, &err)
        || !jw_dom_text_create(ctx, policy_name, &anc_policy_name_text, &err)
        || !jw_dom_add_child(anc_policy_name, anc_policy_name_text, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}ipIdentifier", &anc_ip_identifier, &err)
        || !jw_dom_add_child(request, anc_ip_identifier, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}ipAddress", &anc_ip_address, &err)
        || !jw_dom_add_child(anc_ip_identifier, anc_ip_address, &err)
		|| !jw_dom_text_create(ctx, ip, &anc_ip_address_text, &err) 
		|| !jw_dom_add_child(anc_ip_address, anc_ip_address_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** response\n");
		helper_print_jw_dom(response);	
		printf("*** queried\n");
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
}

void anc_clear_endpoint_policy_by_mac_request(pxgrid_connection *connection, pxgrid_capability *capability, char *mac_address) {
	jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *anc_mac_address;
    jw_dom_node *anc_mac_address_text;
    jw_dom_node *request;
    jw_dom_node *response;

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}clearEndpointPolicyByMACRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}macAddress", &anc_mac_address, &err)
        || !jw_dom_add_child(request, anc_mac_address, &err)
        || !jw_dom_text_create(ctx, mac_address, &anc_mac_address_text, &err)
        || !jw_dom_add_child(anc_mac_address, anc_mac_address_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** response\n");
		helper_print_jw_dom(response);	
		printf("*** queried\n");
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}	
}

void anc_clear_endpoint_policy_by_ip_request(pxgrid_connection *connection, pxgrid_capability *capability, char *ip) {
	jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *anc_ip_identifier;
    jw_dom_node *anc_ip_address;
    jw_dom_node *anc_ip_address_text;
    jw_dom_node *request;
    jw_dom_node *response;

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}clearEndpointPolicyByIPRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}ipIdentifier", &anc_ip_identifier, &err)
        || !jw_dom_add_child(request, anc_ip_identifier, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}ipAddress", &anc_ip_address, &err)
        || !jw_dom_add_child(anc_ip_identifier, anc_ip_address, &err)
		|| !jw_dom_text_create(ctx, ip, &anc_ip_address_text, &err) 
		|| !jw_dom_add_child(anc_ip_address, anc_ip_address_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
	if (status == PXGRID_STATUS_OK) {
		printf("*** response\n");
		helper_print_jw_dom(response);	
		printf("*** queried\n");
	}	
	else {
		printf("status=%s\n", pxgrid_status_get_message(status));
	}
}
```







<a name="ancCSample3"></a>  

## ANC C Sample 3  

> ANC Endpoint Read  

```output
#include "helper.h"
#include "anc_endpoint_read.h"

PXGRID_STATUS anc_getEndpointByMACRequest(pxgrid_connection *connection, pxgrid_capability *capability, char *mac) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;
    
    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *mac_address;
    jw_dom_node *mac_address_text;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <getEndpointByMACRequest xmlns='http://www.cisco.com/pxgrid/anc'>
        <macAddress>00:0C:29:2E:41:4A</macAddress>
    </getEndpointByMACRequest>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}getEndpointByMACRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}macAddress", &mac_address, &err)
        || !jw_dom_add_child(request, mac_address, &err)
        || !jw_dom_text_create(ctx, mac, &mac_address_text, &err)
        || !jw_dom_add_child(mac_address, mac_address_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return PXGRID_STATUS_JW_ERROR;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    status = pxgrid_connection_query(connection, capability, request, &response);
    printf("status=%s\n", pxgrid_status_get_message(status));

    printf("***response\n");
    helper_print_jw_dom(response);

    if(ctx) jw_dom_context_destroy(ctx);

    return status;
}

PXGRID_STATUS anc_getEndpointByIPRequest(pxgrid_connection *connection, pxgrid_capability *capability, char *ip) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;
    
    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *ip_identifier;
    jw_dom_node *ip_address;
    jw_dom_node *ip_address_text;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <getEndpointByIPRequest xmlns='http://www.cisco.com/pxgrid/anc'>
        <ipIdentifier>
            <ipAddress xmlns='http://www.cisco.com/pxgrid'>10.23.23.2</ipAddress>
        </ipIdentifier>
    </getEndpointByIPRequest>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}getEndpointByIPRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}ipIdentifier", &ip_identifier, &err)
        || !jw_dom_add_child(request, ip_identifier, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}ipAddress", &ip_address, &err)
        || !jw_dom_add_child(ip_identifier, ip_address, &err)
        || !jw_dom_text_create(ctx, ip, &ip_address_text, &err)
        || !jw_dom_add_child(ip_address, ip_address_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return PXGRID_STATUS_JW_ERROR;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    status = pxgrid_connection_query(connection, capability, request, &response);
    printf("status=%s\n", pxgrid_status_get_message(status));

    printf("***response\n");
    helper_print_jw_dom(response);

    if(ctx) jw_dom_context_destroy(ctx);

    return status;
}

PXGRID_STATUS anc_getAllEndpointsRequest(pxgrid_connection *connection, pxgrid_capability *capability) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;
    
    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <getAllEndpointsRequest xmlns='http://www.cisco.com/pxgrid/anc'/>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}getAllEndpointsRequest", &request, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return PXGRID_STATUS_JW_ERROR;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    status = pxgrid_connection_query(connection, capability, request, &response);
    printf("status=%s\n", pxgrid_status_get_message(status));

    printf("***response\n");
    helper_print_jw_dom(response);

    if(ctx) jw_dom_context_destroy(ctx);

    return status;
}

PXGRID_STATUS anc_getEndpointByPolicyRequest(pxgrid_connection *connection, pxgrid_capability *capability, char *name) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;

    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *anc_policy_name;
    jw_dom_node *anc_policy_name_text;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <getEndpointByPolicyRequest xmlns='http://www.cisco.com/pxgrid/anc'>
        <name>xGridANCpolicy</name>
    </getEndpointByPolicyRequest>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}getEndpointByPolicyRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}name", &anc_policy_name, &err)
        || !jw_dom_add_child(request, anc_policy_name, &err)
        || !jw_dom_text_create(ctx, name, &anc_policy_name_text, &err)
        || !jw_dom_add_child(anc_policy_name, anc_policy_name_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return PXGRID_STATUS_JW_ERROR;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    status = pxgrid_connection_query(connection, capability, request, &response);
    printf("status=%s\n", pxgrid_status_get_message(status));

    printf("***response\n");
    helper_print_jw_dom(response);

    if(ctx) jw_dom_context_destroy(ctx);

    return status;
}
```



<a name="ancCSample4"></a>  

## ANC C Sample 4  

> ANC Policy 

```output
#include <string.h>
#include "anc_policy_crud.h"


PXGRID_STATUS anc_createPolicyRequest(pxgrid_connection *connection, pxgrid_capability *capability, char *name, int *actions) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;
    
    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *anc_policy;
    jw_dom_node *anc_policy_name;
    jw_dom_node *anc_policy_name_text;
    jw_dom_node *anc_policy_action;
    jw_dom_node *anc_policy_action_text;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <createPolicyRequest xmlns='http://www.cisco.com/pxgrid/anc'>
        <policy>
            <name xmlns='http://www.cisco.com/pxgrid/anc/'>xGrid ANC Policy</name>
            <action xmlns='http://www.cisco.com/pxgrid/anc/'>Quarantine</action>
            <action xmlns='http://www.cisco.com/pxgrid/anc/policy'>Provisioning</action>
        </policy>
    </createPolicyRequest>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}createPolicyRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}policy", &anc_policy, &err)
        || !jw_dom_add_child(request, anc_policy, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}name", &anc_policy_name, &err)
        || !jw_dom_add_child(anc_policy, anc_policy_name, &err)
        || !jw_dom_text_create(ctx, name, &anc_policy_name_text, &err)
        || !jw_dom_add_child(anc_policy_name, anc_policy_name_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return PXGRID_STATUS_JW_ERROR;
    }

    char *action;
    int i;
    for(i = 0; i < NUM_ANC_ACTIONS; i++)
    {
        if(actions[i] == 0) {continue;}
        else if(actions[i] == QUARANTINE) { action = POLICY_ACTION_STRING[QUARANTINE];}
        else if(actions[i] == REMEDIATE) { action = POLICY_ACTION_STRING[REMEDIATE];}
        else if(actions[i] == PROVISIONING) { action = POLICY_ACTION_STRING[PROVISIONING];}
        else if(actions[i] == SHUT_DOWN) { action = POLICY_ACTION_STRING[SHUT_DOWN];}
        else if(actions[i] == PORT_BOUNCE) { action = POLICY_ACTION_STRING[PORT_BOUNCE];}
        if (!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}action", &anc_policy_action, &err)
            || !jw_dom_add_child(anc_policy, anc_policy_action, &err)
            || !jw_dom_text_create(ctx, action, &anc_policy_action_text, &err)
            || !jw_dom_add_child(anc_policy_action, anc_policy_action_text, &err)) 
        {
            jw_log_err(JW_LOG_ERROR, &err, "query");
            return PXGRID_STATUS_JW_ERROR;
        }
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    status = pxgrid_connection_query(connection, capability, request, &response);
    printf("status=%s\n", pxgrid_status_get_message(status));

    printf("***response\n");
    helper_print_jw_dom(response);

    if(ctx) jw_dom_context_destroy(ctx);

    return status;
}

PXGRID_STATUS anc_updatePolicyRequest(pxgrid_connection *connection, pxgrid_capability *capability, char *name, int *actions) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;
    
    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *anc_policy;
    jw_dom_node *anc_policy_name;
    jw_dom_node *anc_policy_name_text;
    jw_dom_node *anc_policy_action;
    jw_dom_node *anc_policy_action_text;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <updatePolicyRequest xmlns='http://www.cisco.com/pxgrid/anc'>
        <policy>
            <name xmlns='http://www.cisco.com/pxgrid/anc'>xGrid ANC Policy</name>
            <action xmlns='http://www.cisco.com/pxgrid/anc'>Quarantine</action>
            <action xmlns='http://www.cisco.com/pxgrid/anc'>Remediate</action>
        </policy>
    </updatePolicyRequest>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}updatePolicyRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}policy", &anc_policy, &err)
        || !jw_dom_add_child(request, anc_policy, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}name", &anc_policy_name, &err)
        || !jw_dom_add_child(anc_policy, anc_policy_name, &err)
        || !jw_dom_text_create(ctx, name, &anc_policy_name_text, &err)
        || !jw_dom_add_child(anc_policy_name, anc_policy_name_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return PXGRID_STATUS_JW_ERROR;
    }

    char *action;
    int i;
    for(i = 0; i < NUM_ANC_ACTIONS; i++)
    {
        if(actions[i] == 0) {continue;}
        else if(actions[i] == QUARANTINE) { action = POLICY_ACTION_STRING[QUARANTINE];}
        else if(actions[i] == REMEDIATE) { action = POLICY_ACTION_STRING[REMEDIATE];}
        else if(actions[i] == PROVISIONING) { action = POLICY_ACTION_STRING[PROVISIONING];}
        else if(actions[i] == SHUT_DOWN) { action = POLICY_ACTION_STRING[SHUT_DOWN];}
        else if(actions[i] == PORT_BOUNCE) { action = POLICY_ACTION_STRING[PORT_BOUNCE];}
        if (!jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}action", &anc_policy_action, &err)
            || !jw_dom_add_child(anc_policy, anc_policy_action, &err)
            || !jw_dom_text_create(ctx, action, &anc_policy_action_text, &err)
            || !jw_dom_add_child(anc_policy_action, anc_policy_action_text, &err)) 
        {
            jw_log_err(JW_LOG_ERROR, &err, "query");
            return PXGRID_STATUS_JW_ERROR;
        }
        action = strtok (NULL, ",");
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    status = pxgrid_connection_query(connection, capability, request, &response);
    printf("status=%s\n", pxgrid_status_get_message(status));

    printf("***response\n");
    helper_print_jw_dom(response);

    if(ctx) jw_dom_context_destroy(ctx);

    return status;
}

PXGRID_STATUS anc_deletePolicyRequest(pxgrid_connection *connection, pxgrid_capability *capability, char * name) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;

    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *anc_policy_name;
    jw_dom_node *anc_policy_name_text;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <deletePolicyRequest xmlns='http://www.cisco.com/pxgrid/anc'>
        <name xmlns='http://www.cisco.com/pxgrid/anc'>xGridANCpolicy</name>
    </deletePolicyRequest>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}deletePolicyRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}name", &anc_policy_name, &err)
        || !jw_dom_add_child(request, anc_policy_name, &err)
        || !jw_dom_text_create(ctx, name, &anc_policy_name_text, &err)
        || !jw_dom_add_child(anc_policy_name, anc_policy_name_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return PXGRID_STATUS_JW_ERROR;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    status = pxgrid_connection_query(connection, capability, request, &response);
    printf("status=%s\n", pxgrid_status_get_message(status));

    printf("***response\n");
    helper_print_jw_dom(response);

    if(ctx) jw_dom_context_destroy(ctx);
    return status;
}

PXGRID_STATUS anc_getPolicyByName(pxgrid_connection *connection, pxgrid_capability *capability, char *name) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;

    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *anc_policy_name;
    jw_dom_node *anc_policy_name_text;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <getPolicyByNameRequest xmlns='http://www.cisco.com/pxgrid/anc'>
        <name xmlns='http://www.cisco.com/pxgrid/anc'>xGridANCpolicy</name>
    </getPolicyByNameRequest>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}getPolicyByNameRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}name", &anc_policy_name, &err)
        || !jw_dom_add_child(request, anc_policy_name, &err)
        || !jw_dom_text_create(ctx, name, &anc_policy_name_text, &err)
        || !jw_dom_add_child(anc_policy_name, anc_policy_name_text, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return PXGRID_STATUS_JW_ERROR;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    status = pxgrid_connection_query(connection, capability, request, &response);
    printf("status=%s\n", pxgrid_status_get_message(status));

    printf("***response\n");
    helper_print_jw_dom(response);

    if(ctx) jw_dom_context_destroy(ctx);

    return status;
}

PXGRID_STATUS anc_getAllPolicies(pxgrid_connection *connection, pxgrid_capability *capability) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;
    
    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <getAllPoliciesRequest xmlns='http://www.cisco.com/pxgrid/anc'/>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}getAllPoliciesRequest", &request, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return PXGRID_STATUS_JW_ERROR;
    }

    printf("***request\n");
    helper_print_jw_dom(request);

    status = pxgrid_connection_query(connection, capability, request, &response);
    printf("status=%s\n", pxgrid_status_get_message(status));

    printf("***response\n");
    helper_print_jw_dom(response);

    if(ctx) jw_dom_context_destroy(ctx);

    return status;
}
```



<a name="ancCSample5"></a>   

## ANC C Sample 5  

> ANC Subscribe

```output
#include "anc_subscribe.h"
#include "helper.h"

void subscribe(pxgrid_connection *connection) {
	const char ns_iden[] = "http://www.cisco.com/pxgrid/anc";
	const char apply_endpoint_policy_notif[] = "ApplyEndpointPolicyNotification";
	pxgrid_connection_register_notification_handler(connection, ns_iden, apply_endpoint_policy_notif, message_callback, NULL);
	const char clear_endpoint_policy_notif[] = "ClearEndpointPolicyNotification";
	pxgrid_connection_register_notification_handler(connection, ns_iden, clear_endpoint_policy_notif, message_callback, NULL);
	const char create_policy_notif[] = "CreatePolicyNotification";
	pxgrid_connection_register_notification_handler(connection, ns_iden, create_policy_notif, message_callback, NULL);
	const char delete_policy_notif[] = "DeletePolicyNotification";
	pxgrid_connection_register_notification_handler(connection, ns_iden, delete_policy_notif, message_callback, NULL);
	const char update_policy_notif[] = "UpdatePolicyNotification";
	pxgrid_connection_register_notification_handler(connection, ns_iden, update_policy_notif, message_callback, NULL);

}

void message_callback(jw_dom_node *node, void *arg) {
	UNUSED(arg);
	helper_print_jw_dom(node);
}
```



<a name="dynamicTopicJavaSample1"></a>  

## Dynamic Topic Java Sample 1  

> Propose capability

```output
package com.cisco.pxgrid.samples.ise;

import java.util.LinkedList;
import java.util.List;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.internal.NotificationCallback;
import com.cisco.pxgrid.model.core.BaseMsg;
import com.cisco.pxgrid.model.core.Capability;
import com.cisco.pxgrid.model.core.CapabilityChangeType;
import com.cisco.pxgrid.model.core.RegisteredCapabilityUpdateNotification;
import com.cisco.pxgrid.stub.core.CoreClientStub;
import com.cisco.pxgrid.stub.core.CoreQuery;

/**
 * Demonstrates how to use a pxGrid client to propose a new capability
 * to pxGrid administrator.
 */
public class ProposeCapability {
	public static void main(String[] args) throws Exception {
		SampleHelper helper = new SampleHelper();
		GridConnection con = helper.connectWithReconnectionManager();

        con.registerTopicChangeCallback(new SampleNotificationCallback());

		CoreClientStub coreClient = new CoreClientStub();
		CoreQuery query = coreClient.createCoreQuery(con);

		String isNew = helper.prompt("New capability? (y/n): " );
		String name = helper.prompt("Enter capability name: ");
		String version = helper.prompt("Enter capability version: ");
		String desc = helper.prompt("Enter capability description: ");		
		String platform = helper.prompt("Enter vendor platform: ");


		List<String> queries = new LinkedList<String>();
		while (true) {
			String queryStr = helper.prompt("Enter query name (<enter> to continue): ");
			if (queryStr == null) break;
			queries.add(queryStr);
		}

		List<String> actions = new LinkedList<String>();
		while (true) {
			String actionStr = helper.prompt("Enter action name (<enter> to continue): ");
			if (actionStr == null) break;
			actions.add(actionStr);
		}

		if ("y".equals(isNew)) {
	        System.out.println("Proposing new capability...");
	        query.proposeCapability(name, version, queries, actions, desc, platform);
		} else {
	        System.out.println("Updating capability...");
		    query.updateCapability(name, version, queries, actions, desc, platform);
		}

        // receive notifications until user presses <enter>
		helper.prompt("Press <enter> to disconnect...");
		helper.disconnect();
	}

    private static void handleCapabilityUpdate(CapabilityChangeType change, Capability cap) {
        System.out.println("change=" + change + "; capability=" + cap.getName() + ", version=" + cap.getVersion());
    }

    public static class SampleNotificationCallback implements NotificationCallback
    {
        @Override
        public void handle(BaseMsg message) {
            RegisteredCapabilityUpdateNotification notif = (RegisteredCapabilityUpdateNotification) message;
            for (Capability cap : notif.getCapabilities()) {
                handleCapabilityUpdate(notif.getChange(), cap);
           }
        }
    }

}
```



<a name="dynamicTopicJavaSample2"></a>  

## Dynamic Topic Java Sample 2  

> Core capability subscribe

```output
/**
 * Copyright (c) 2015 Cisco Systems, Inc.
 * All rights reserved.
 */
package com.cisco.pxgrid.samples.ise;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.internal.NotificationCallback;
import com.cisco.pxgrid.model.core.BaseMsg;
import com.cisco.pxgrid.model.core.BaseMsgReference;
import com.cisco.pxgrid.model.core.Capability;
import com.cisco.pxgrid.model.core.CapabilityChangeType;
import com.cisco.pxgrid.model.core.MethodPermissions;
import com.cisco.pxgrid.model.core.RegisteredAndPendingStatus;
import com.cisco.pxgrid.model.core.RegisteredCapabilityUpdateNotification;

/**
 * Sample class to demonstrate subscribing to Core Capability and registering for notifications
 */
public class CoreCapabilitySubscribe {
    public static void main(String[] args) throws Exception {
        SampleHelper helper = new SampleHelper();
        GridConnection grid = helper.connectWithReconnectionManager();
        grid.registerTopicChangeCallback(new SampleNotificationCallback());

        // Query for all registered capabilities.
        for (Capability cap : grid.getRegisteredCapabilitiesList()) {
            printCapabilityAndState("getList", CapabilityChangeType.CREATED, cap);
        }


        // Query a single capability specified by user.
        while (true) {
            final String capNameAndVersion = helper.prompt("Capability name [, version] to query (or <enter> to quit) : ");
            if (capNameAndVersion == null || capNameAndVersion.isEmpty()) {
                break;
            }
            String[] input = capNameAndVersion.split(",");
            final String capName = input[0].trim();
            String capVersion = null;
            if (input.length > 1) {
                capVersion = input[1].trim();
            }

            RegisteredAndPendingStatus status = grid.getCapabilityStatus(capName, capVersion);

            if (status.getTopicStatus() != null) {
                printCapabilityAndState("topicStatus", status.getTopicStatus().getStatus(), status.getTopicStatus().getCapability());
            }
            if (status.getPendingStatus() != null) {
                printCapabilityAndState("pendingStatus", status.getPendingStatus().getStatus(), status.getPendingStatus().getCapability());
            }
        }

        helper.disconnect();
    }

    private static void printCapabilityAndState(final String prefix, CapabilityChangeType status, Capability cap) {
        if (cap != null) {
            StringBuilder out = new StringBuilder();
            out.append(prefix).append(": status=").append(status);
            out.append(" capability=").append(cap.getName());
			out.append(", version=").append(cap.getVersion());
			out.append(cap.getDescription() != null && !cap.getDescription().isEmpty() ? ", description=" + cap.getDescription():"");
			out.append(cap.getVendorPlatform() != null && !cap.getVendorPlatform().isEmpty() ? ", platform=" + cap.getVendorPlatform():"");
			String delimiter = ", operations=";
			for(BaseMsgReference ref:cap.getQueryMethods()){
				out.append(delimiter).append(ref.getMethodName());
				out.append(ref.getMethodPermissions() == MethodPermissions.READ_ONLY ? "(R)" : "(W)" );
				delimiter = ", ";
			}
			System.out.println(out);
        } else {
            System.out.println(prefix + ": status=" + status);
        }
    }

    public static class SampleNotificationCallback implements NotificationCallback {
        @Override
        public void handle(BaseMsg msg) {
            RegisteredCapabilityUpdateNotification notif = (RegisteredCapabilityUpdateNotification) msg;
            for (Capability cap : notif.getCapabilities()) {
                 printCapabilityAndState("notification", notif.getChange(), cap);
            }
        }
    }
}
```



<a name="dynamicTopicJavaSample3"></a>  

## Dynamic Topic Java Sample 3  

> MultiGroupClient

```output
package com.cisco.pxgrid.samples.ise;

import java.net.InetAddress;

import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.anc.ANCClient;
import com.cisco.pxgrid.anc.ANCQuery;
import com.cisco.pxgrid.model.anc.ANCAction;
import com.cisco.pxgrid.model.anc.ANCPolicy;
import com.cisco.pxgrid.model.anc.ANCResult;
import com.cisco.pxgrid.model.net.Session;
import com.cisco.pxgrid.stub.identity.SessionDirectoryFactory;
import com.cisco.pxgrid.stub.identity.SessionDirectoryQuery;

/**
 * Sample to demonstrate a client is able to perform actions on multiple topics 
 * Creates ANC policy which requires client to have ANC group auth
 * Queries Session Directory for a given IP which requires Session group auth 
 * Client should have both ANC and Session group membership
 */

public class MultiGroupClient {
	public static final String DEF_POLICY_NAME = "ANC"+System.currentTimeMillis();
	public static final String DEF_SESSION_IP = "1.1.1.2";
	public static final ANCAction DEF_ANC_POLICY_ACTION = ANCAction.PORT_BOUNCE;
	public static final String POLICY_NAME_PROP = "POLICY_NAME";
	public static final String SESSION_IP_PROP = "SESSION_IP";
	
	public static void main(String[] args) throws Exception {
	SampleHelper helper = new SampleHelper();
	GridConnection grid = helper.connectWithReconnectionManager();
	 
	String policy = System.getProperty(POLICY_NAME_PROP);
	String sessionip = System.getProperty(SESSION_IP_PROP);
	
	//create ANC policy
	//if ANC policy name is not provided, a random policy name will be generated
	ANCClient client = new ANCClient();
	ANCQuery query = client.createANCQuery(grid);
	ANCPolicy ancPolicy= new ANCPolicy();
	ancPolicy.setName(policy!=null && !policy.isEmpty() ? policy:DEF_POLICY_NAME);
	ancPolicy.getActions().add(DEF_ANC_POLICY_ACTION);
	ANCResult ancResult = query.createPolicy(ancPolicy);
	
	System.out.println("Create ANC Policy: " + ancPolicy.getName() + " Result - " + ancResult);
	
	//query session directory for an IP
	//if IP is not provided, 1.1.1.2 will be used as default
	
	SessionDirectoryQuery sessionquery = SessionDirectoryFactory
			.createSessionDirectoryQuery(grid);

	sessionip = sessionip!=null && !sessionip.isEmpty() ? sessionip : DEF_SESSION_IP;
	Session session = sessionquery.getActiveSessionByIPAddress(InetAddress
			.getByName(sessionip));
	if (session != null) {
		SampleHelper.print(session);
	} else {
		System.out.println("Session " + sessionip + " not found");
	}
				
	helper.disconnect();
	}
}
```



<a name="dynamicTopicJavaSample4"></a>  

## Dynamic Topic Java Sample 4  

> Generic client

```output
/*******************************************************************************
 * Copyright (c) 2015 Cisco Systems, Inc.
 * All rights reserved.
 *******************************************************************************/

package com.cisco.pxgrid.samples.ise;

import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import com.cisco.pxgrid.CapabilityRef;
import com.cisco.pxgrid.GCLException;
import com.cisco.pxgrid.GridConnection;
import com.cisco.pxgrid.internal.NotificationCallback;
import com.cisco.pxgrid.internal.QueryCallback;
import com.cisco.pxgrid.model.core.BaseError;
import com.cisco.pxgrid.model.core.BaseMsg;
import com.cisco.pxgrid.model.core.GenericMessage;
import com.cisco.pxgrid.model.core.GenericMessageContent;
import com.cisco.pxgrid.model.core.GenericMessageContentType;
import com.cisco.pxgrid.model.core.GenericMessageType;
import com.cisco.pxgrid.util.GenericMessageBuilder;
import com.cisco.pxgrid.util.GenericMessageContentExtractor;

/**
 * @author anto
 *
 */
public class GenericClient {

    private static final String TOPIC_NAME        = "topic-name";
    private static final String CLIENT_MODE       = "client-mode";
    private static final String QUERY_NAME_SET    = "query-name-set";
    private static final String ACTION_NAME_SET   = "action-name-set";
    private static final String PUBLISH_DATA_SET  = "publish-data-set";
    private static final String REQUEST_DATA_SET  = "request-data-set";
    private static final String RESPONSE_DATA_SET = "response-data-set";
    private static final String SLEEP_INTERVAL    = "sleep-interval";
    private static final String ITERATIONS        = "iterations";

    enum ClientMode {
        PUBLISHER("publisher", "_Publish"), SUBSCRIBER("subscriber", "_Subscribe"), ACTION("action", "_Action");

        private String value;
        private String groupSuffix;

        ClientMode(String value, String groupSuffix) {
            this.value = value;
            this.groupSuffix = groupSuffix;
        }

        String groupName(String topicName) {
            return topicName + groupSuffix;
        }

        static ClientMode fromValue(String value) {
            ClientMode mode = null;

            for (ClientMode m : ClientMode.values()) {
                if (m.value.equalsIgnoreCase(value)) {
                    mode = m;
                    break;
                }
            }

            return mode;
        }
    }

    private String          topicName;
    private ClientMode      clientMode;
    private int             sleepInterval;
    private int             iterations;
    private Set<String>     queryNameSet    = new LinkedHashSet<String>();
    private Set<String>     actionNameSet   = new LinkedHashSet<String>();
    private Set<String>     publishDataSet  = new LinkedHashSet<String>();
    private Set<String>     requestDataSet  = new LinkedHashSet<String>();
    private Set<String>     responseDataSet = new LinkedHashSet<String>();

    private CapabilityRef   capRef;
    private SampleHelper    helper          = null;
    private GridConnection  gridConnection  = null;

    private ExecutorService taskExecutor    = null;

    public GenericClient() {
        super();
    }

    public void init(String[] args) {

        topicName = System.getProperty(TOPIC_NAME);
        if (topicName == null) {
            System.out.println("the " + TOPIC_NAME + " property is not valid - cannot proceed without topic name");
            throw new RuntimeException("property " + TOPIC_NAME + " must be specified");
        }
        capRef = new CapabilityRef(topicName);

        String clientModeStr = System.getProperty(CLIENT_MODE);
        clientMode = ClientMode.fromValue(clientModeStr);
        if (clientMode == null) {
            System.out.println("the " + CLIENT_MODE + " property is not valid - using " + ClientMode.SUBSCRIBER.value);
            clientMode = ClientMode.SUBSCRIBER;
        }

        sleepInterval = Integer.parseInt(System.getProperty(SLEEP_INTERVAL, "500"));
        iterations = Integer.parseInt(System.getProperty(ITERATIONS, "20"));

        String dataText = System.getProperty(QUERY_NAME_SET, "query-001,query-002,query-003");
        for (String d : dataText.split(",")) {
            queryNameSet.add(d);
        }

        dataText = System.getProperty(ACTION_NAME_SET, "act-001,act-002");
        for (String d : dataText.split(",")) {
            actionNameSet.add(d);
        }

        dataText = System.getProperty(PUBLISH_DATA_SET, "pub-data-001,pub-data-002");
        for (String d : dataText.split(",")) {
            publishDataSet.add(d);
        }

        dataText = System.getProperty(REQUEST_DATA_SET, "req-data-001,req-data-002");
        for (String d : dataText.split(",")) {
            requestDataSet.add(d);
        }

        dataText = System.getProperty(RESPONSE_DATA_SET, "resp-data-001,resp-data-002");
        for (String d : dataText.split(",")) {
            responseDataSet.add(d);
        }
        System.out.println("Initialized : " + displayString());
    }

    public String displayString() {
        StringBuilder builder = new StringBuilder();
        builder.append("GenericClient:");
        builder.append("\n\ttopicName=");
        builder.append(topicName);
        builder.append("\n\tclientMode=");
        builder.append(clientMode);
        builder.append("\n\tsleepInterval=");
        builder.append(sleepInterval);
        builder.append("\n\titerations=");
        builder.append(iterations);
        builder.append("\n\tqueryNameSet=");
        builder.append(queryNameSet);
        builder.append("\n\tactionNameSet=");
        builder.append(actionNameSet);
        builder.append("\n\tpublishDataSet=");
        builder.append(publishDataSet);
        builder.append("\n\trequestDataSet=");
        builder.append(requestDataSet);
        builder.append("\n\tresponseDataSet=");
        builder.append(responseDataSet);
        builder.append("\n");
        return builder.toString();
    }

    private static String displayMessage(BaseMsg msg) {
        String messageText = null;

        if (msg instanceof GenericMessage) {
            GenericMessage message = (GenericMessage) msg;

            StringBuilder builder = new StringBuilder("GenericMessage:");
            builder.append("\n  messageType=").append(message.getMessageType());
            builder.append("\n  capabilityName=").append(message.getCapabilityName());
            builder.append("\n  operationName=").append(message.getOperationName());

            builder.append("\n  body:");
            for (GenericMessageContent content : message.getBody()) {
                builder.append("\n    content:");
                builder.append("\n      contentTags=").append(content.getContentTags());
                builder.append("\n      contentType=").append(content.getContentType());
                builder.append("\n      value=");
                GenericMessageContentExtractor extractor = GenericMessageContentExtractor.newExtractor(content);
                switch (content.getContentType()) {
                case PLAIN_TEXT:
                    builder.append(extractor.extractPlainText());
                    break;

                default:
                    builder.append(extractor.extractRaw());
                    break;
                }
            }

            if (message.getError() != null) {
                builder.append("\n  error=").append(message.getError().getDescription());
            }
            messageText = builder.toString();
        } else {
            messageText = String.valueOf(msg);
        }

        return messageText;
    }

    private void runAsPublisher() throws Exception {
        gridConnection.registerRequestHandler(capRef, new MyRequestHandler());
        gridConnection.publishCapability(capRef);
        Future<?> f = taskExecutor.submit(new PublisherTask());
        f.get();
    }

    private void runAsActionClient() throws Exception {
        RequestTask task = new RequestTask("ACTION", actionNameSet, requestDataSet);
        Future<?> f = taskExecutor.submit(task);
        f.get();
    }

    private void runAsSubscriber() throws Exception {
        gridConnection.subscribeCapability(capRef, new MyNotificationHandler());
        RequestTask task = new RequestTask("QUERY", queryNameSet, requestDataSet);
        Future<?> f = taskExecutor.submit(task);
        f.get();
    }

    private void run() throws Exception {
        taskExecutor = Executors.newSingleThreadExecutor();

        System.setProperty(SampleHelper.PROP_GROUP, clientMode.groupName(topicName));
        helper = new SampleHelper();
        gridConnection = helper.connectWithReconnectionManager();

        switch (clientMode) {
        case PUBLISHER:
            runAsPublisher();
            break;

        case SUBSCRIBER:
            runAsSubscriber();
            break;

        case ACTION:
            runAsActionClient();
            break;

        default:
            break;
        }

        // sleep a bit longer to allow a few more messages
        Thread.sleep(sleepInterval * 4);

        // receive notifications until user presses <enter>
        helper.prompt("Press <enter> to disconnect...");
        helper.disconnect();

        taskExecutor.shutdown();
    }

    static class MyNotificationHandler implements NotificationCallback {

        @Override
        public void handle(BaseMsg message) {
            System.out.println("Received notification: " + displayMessage(message));
        }

    }

    class MyRequestHandler implements QueryCallback {
        private Iterator<String> respDataIt;

        MyRequestHandler() {
            respDataIt = responseDataSet.iterator();
        }

        private String getNextResponseData() {
            if (!respDataIt.hasNext()) {
                respDataIt = responseDataSet.iterator();
            }
            return respDataIt.next();
        }

        @Override
        public BaseMsg handle(BaseMsg message) {
            System.out.println("Received request: " + displayMessage(message));
            GenericMessage response = new GenericMessage();
            response.setCapabilityName(topicName);
            response.setMessageType(GenericMessageType.RESPONSE);

            if (message instanceof GenericMessage) {
                GenericMessage request = (GenericMessage) message;
                if (request.getMessageType() != GenericMessageType.REQUEST) {
                    BaseError error = new BaseError();
                    error.setDescription("Unable to handle the request received - GenericMessageType is not REQUEST");
                    response.setError(error);
                } else {

                    StringBuilder scratch = new StringBuilder("RESPONSE[");
                    scratch.append(System.currentTimeMillis()).append("]");
                    scratch.append(getNextResponseData()).append(" - for request[");
                    for (GenericMessageContent reqContent : request.getBody()) {
                        if (reqContent.getContentType() == GenericMessageContentType.PLAIN_TEXT) {
                            scratch.append(new String(reqContent.getValue()));
                        }
                    }
                    scratch.append("]");

                    GenericMessageBuilder responseBuilder = GenericMessageBuilder.responseBuilder(topicName, request.getOperationName());
                    responseBuilder.addPlainTextContent(scratch.toString(), "RESP-TAG-101");
                    response = responseBuilder.build();

                    // GenericMessageContent content = new GenericMessageContent();
                    // content.getContentTags().add("RESP-TAG-101");
                    // content.setContentType(GenericMessageContentType.PLAIN_TEXT);
                    // content.setValue(scratch.toString().getBytes());
                    //
                    // response.setOperationName(request.getOperationName());
                    // response.getBody().add(content);
                }
            } else {
                BaseError error = new BaseError();
                error.setDescription("Unable to handle the request received - not a GenericMessage type");
                response.setError(error);
            }

            System.out.println("Returning response: " + displayMessage(response));
            return response;
        }
    }

    class PublisherTask implements Runnable {
        private Iterator<String> pubDataIt;
        private int              count;

        PublisherTask() {
            pubDataIt = publishDataSet.iterator();
            count = 0;
        }

        private String getNextPubData() {
            if (!pubDataIt.hasNext()) {
                pubDataIt = publishDataSet.iterator();
            }
            return pubDataIt.next();
        }

        private void publishData() throws GCLException {
            StringBuilder scratch = new StringBuilder("NOTIFICATION[");
            scratch.append(System.currentTimeMillis()).append("]");
            scratch.append(getNextPubData());

            GenericMessageBuilder builder = GenericMessageBuilder.notificationBuilder(topicName, "sampleNotification");
            GenericMessage notif = builder.addPlainTextContent(scratch.toString(), "NOTIF-TAG-201").build();

            // GenericMessageContent content = new GenericMessageContent();
            // content.getContentTags().add("NOTIF-TAG-201");
            // content.setContentType(GenericMessageContentType.PLAIN_TEXT);
            // content.setValue(scratch.toString().getBytes());
            //
            // GenericMessage notif = new GenericMessage();
            // notif.setCapabilityName(topicName);
            // notif.setMessageType(GenericMessageType.NOTIFICATION);
            // notif.getBody().add(content);

            if (gridConnection != null) {
                System.out.println("Publishing notification: " + displayMessage(notif));
                gridConnection.notify(capRef, notif);
            }
        }

        @Override
        public void run() {
            try {
                while (count < iterations) {
                    count++;
                    publishData();
                    Thread.sleep(sleepInterval);
                }
            } catch (Exception e) {
                System.err.println("Error while publishing : " + e);
            }
        }

    }

    class RequestTask implements Runnable {
        private Set<String>      nameSet;
        private Set<String>      dataSet;
        private Iterator<String> nameIt;
        private Iterator<String> dataIt;
        private int              count;
        private String           tag;

        RequestTask(String tag, Set<String> nameSet, Set<String> dataSet) {
            this.tag = tag;
            this.nameSet = nameSet;
            this.dataSet = dataSet;
            nameIt = nameSet.iterator();
            dataIt = dataSet.iterator();
            count = 0;
        }

        private String getNextName() {
            if (!nameIt.hasNext()) {
                nameIt = nameSet.iterator();
            }
            return nameIt.next();
        }

        private String getNextData() {
            if (!dataIt.hasNext()) {
                dataIt = dataSet.iterator();
            }
            return dataIt.next();
        }

        private void sendRequest() throws GCLException {
            StringBuilder scratch = new StringBuilder(tag).append("[");
            scratch.append(System.currentTimeMillis()).append("]");
            scratch.append(getNextData());
            
            GenericMessageBuilder builder = GenericMessageBuilder.requestBuilder(topicName, getNextName());
            GenericMessage request = builder.addPlainTextContent(scratch.toString(), tag + "-TAG-301").build();

            // GenericMessageContent content = new GenericMessageContent();
            // content.getContentTags().add(tag + "-TAG-301");
            // content.setContentType(GenericMessageContentType.PLAIN_TEXT);
            // content.setValue(scratch.toString().getBytes());
            //
            // GenericMessage request = new GenericMessage();
            // request.setCapabilityName(topicName);
            // request.setMessageType(GenericMessageType.REQUEST);
            // request.setOperationName(getNextName());
            // request.getBody().add(content);

            if (gridConnection != null) {
                System.out.println("Sending request: " + displayMessage(request));
                BaseMsg resp = gridConnection.query(capRef, request);
                System.out.println("Received response: " + displayMessage(resp));
            }
        }

        @Override
        public void run() {
            try {
                while (count < iterations) {
                    count++;
                    try {
                    	sendRequest();
                    } catch (Exception e) {
                        System.err.println("Error while sending request : " + e);
                    }
                    Thread.sleep(sleepInterval);
                }
            } catch (Exception e) {
                System.err.println("Thread got interrupted : " + e);
            }
        }

    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        GenericClient client = new GenericClient();
        client.init(args);
        try {
            client.run();
        } catch (Exception e) {
            System.err.println("Error while running client : " + e);
        }
    }

}
```



<a name="dynamicTopicCSample1"></a>  

## Dynamic Topic C Sample 1  

> Propose Capability

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}

static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
}

const char change_elname[] = "change";
const char capability_elname[] = "capability";
const char name_elname[] = "name";
const char version_elname[] = "version";

static void print_first_element_text(jw_dom_node *node, const char *element_name) {
    jw_dom_node *element = jw_dom_get_first_element(node, element_name);
    if (element) {
        const char *text = jw_dom_get_first_text(element);
        if (text) {
            printf("%s: %s, ", element_name, text);
        }
    }
}

static void print_capabilities(jw_dom_node *capability_el) {
    while (capability_el) {
        print_first_element_text(capability_el, name_elname);
        print_first_element_text(capability_el, version_elname);

        capability_el = jw_dom_get_sibling(capability_el);
        printf("\n");
    }
    printf("\n");
}

static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
    printf("Notification - ");
    //helper_print_jw_dom(node);
    print_first_element_text(node, change_elname);
    jw_dom_node *capability_el = jw_dom_get_first_element(node, capability_elname);
    print_capabilities(capability_el);
}

static void get_all_capabilities(pxgrid_connection *connection) {
    PXGRID_STATUS status;

    printf("Registered Capabilities - \n");

    jw_dom_node *response = NULL;
    status = pxgrid_connection_query_capabilities(connection, &response);
    if (PXGRID_STATUS_OK == status) {
        if (NULL != response) {
            //helper_print_jw_dom(response);
            jw_dom_node *capability_el = jw_dom_get_first_element(response, capability_elname);
            print_capabilities(capability_el);

            // Free the response structure.
            jw_dom_context_destroy(jw_dom_get_context(response));
        }
    }
}

int main(int argc, char **argv) {
    PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE);
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);
	pxgrid_connection_set_connect_cb(connection, _on_connected);

    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

	pxgrid_connection_register_topic_notification_handler(connection,  message_callback, NULL);


    pxgrid_connection_connect(connection);

    // Get and print all capabilities using core capability.
    get_all_capabilities(connection);

	pxgrid_capability *capability;
	pxgrid_capability_create(&capability);
    if(!capability) exit(EXIT_FAILURE);
    
    const char ns_iden[] = "http://www.cisco.com/pxgrid/core";
	pxgrid_capability_set_namespace(capability, ns_iden);

	const char* cap_name = hconfig->cap_name;
	const char* cap_version = hconfig->cap_version;

	char* tf = NULL;
	char *capquerynames[20];
	int nCapQueries = 0;
	tf = NULL;
	tf = strtok(hconfig->cap_query ,",");	
	while (tf != NULL)
	{
	    capquerynames[nCapQueries] = strdup(tf);
	    tf = strtok (NULL,",");
	    nCapQueries++;
	}

	char *capactionnames[20];
	int nCapActions = 0;
	tf = NULL;
	tf = strtok(hconfig->cap_action ,",");
	while (tf != NULL)
	{
	    capactionnames[nCapActions] = strdup(tf);
	    tf = strtok (NULL,",");
	    nCapActions++;
	}

	const char* cap_description = hconfig->cap_description;
	const char* cap_vendorplatform = hconfig->cap_vendorplatform;

   	status = pxgrid_capability_propose(capability, connection, cap_name, cap_version, 
					(const char **) capquerynames, nCapQueries, 
					(const char **) capactionnames, nCapActions,
                                        cap_description, cap_vendorplatform);
	if (status != PXGRID_STATUS_OK)
    {
        helper_print_error(status);
    }
	else
	{
		printf("capability: %s create request sent successfully\n", cap_name);
	}

	printf("press <enter> to disconnect...\n");
	getchar();

   	if (connection) {
		pxgrid_connection_disconnect(connection);
		pxgrid_connection_destroy(connection);
	}

	if (capability) pxgrid_capability_destroy(capability);
	if (conn_config) pxgrid_config_destroy(conn_config);
   	if (hconfig) helper_config_destroy(hconfig);
        return 0;
}
```





<a name="dynamicTopicCSample2"></a>

## Dynamic Topic C Sample 2

> Modify capability

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);
}

static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
}


const char change_elname[] = "change";
const char capability_elname[] = "capability";
const char name_elname[] = "name";
const char version_elname[] = "version";

static void print_first_element_text(jw_dom_node *node, const char *element_name) {
    jw_dom_node *element = jw_dom_get_first_element(node, element_name);
    if (element) {
        const char *text = jw_dom_get_first_text(element);
        if (text) {
            printf("%s: %s, ", element_name, text);
        }
    }
}

static void print_capabilities(jw_dom_node *capability_el) {
    while (capability_el) {
        print_first_element_text(capability_el, name_elname);
        print_first_element_text(capability_el, version_elname);

        capability_el = jw_dom_get_sibling(capability_el);
        printf("\n");
    }
    printf("\n");
}

static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
    printf("Notification - ");
    //helper_print_jw_dom(node);
    print_first_element_text(node, change_elname);
    jw_dom_node *capability_el = jw_dom_get_first_element(node, capability_elname);
    print_capabilities(capability_el);
}

static void get_all_capabilities(pxgrid_connection *connection) {
    PXGRID_STATUS status;

    printf("Registered Capabilities - \n");

    jw_dom_node *response = NULL;
    status = pxgrid_connection_query_capabilities(connection, &response);
    if (PXGRID_STATUS_OK == status) {
        if (NULL != response) {
            //helper_print_jw_dom(response);
            jw_dom_node *capability_el = jw_dom_get_first_element(response, capability_elname);
            print_capabilities(capability_el);

            // Free the response structure.
            jw_dom_context_destroy(jw_dom_get_context(response));
        }
    }
}

int main(int argc, char **argv) {
    PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv);
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE);
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );

    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);

    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

	pxgrid_connection_register_topic_notification_handler(connection,  message_callback, NULL);

    pxgrid_connection_connect(connection);

    // Get and print all capabilities using core capability.
    get_all_capabilities(connection);

	pxgrid_capability *capability;
	pxgrid_capability_create(&capability);
    if(!capability) exit(EXIT_FAILURE);
    
    const char ns_iden[] = "http://www.cisco.com/pxgrid/core";
	pxgrid_capability_set_namespace(capability, ns_iden);

	const char* cap_name = hconfig->cap_name;
	const char* cap_version = hconfig->cap_version;

	char* tf = NULL;
	char *capquerynames[20];
	int nCapQueries = 0;
	tf = NULL;
	tf = strtok(hconfig->cap_query ,",");
	while (tf != NULL)
	{
	    capquerynames[nCapQueries] = strdup(tf);
	    tf = strtok (NULL,",");
	    nCapQueries++;
	}

	char *capactionnames[20];
	int nCapActions = 0;
	tf = NULL;
	tf = strtok(hconfig->cap_action ,",");
	while (tf != NULL)
	{
	    capactionnames[nCapActions] = strdup(tf);
	    tf = strtok (NULL,",");
	    nCapActions++;
	}

	const char* cap_description = hconfig->cap_description;
	const char* cap_vendorplatform = hconfig->cap_vendorplatform;

   	status = pxgrid_capability_modify(capability, connection, cap_name, cap_version, 
					(const char **) capquerynames, nCapQueries, 
					(const char **) capactionnames, nCapActions,
                                        cap_description, cap_vendorplatform);
	if (status != PXGRID_STATUS_OK)
        {
                helper_print_error(status);
        }
	else
	{
		printf("capability: %s update request sent successfully\n", cap_name);
	}

	printf("press <enter> to disconnect...\n");
	getchar();

   	if (connection) {
		pxgrid_connection_disconnect(connection);
		pxgrid_connection_destroy(connection);
	}

	if (capability) pxgrid_capability_destroy(capability);
	if (conn_config) pxgrid_config_destroy(conn_config);
   	if (hconfig) helper_config_destroy(hconfig);
        return 0;
}
```



<a name="dynamicTopicCSample3"></a>  

## Dynamic Topic C Sample 3  

> Query capability

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);   
}

static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
	printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
}


const char change_elname[] = "change";
const char capability_elname[] = "capability";
const char name_elname[] = "name";
const char version_elname[] = "version";
const char description_elname[] = "description";
const char vendorplatform_elname[] = "vendorPlatform";
const char querymethods_elname[] = "queryMethods";
const char operation_elname[] = "operation";
const char methodname_elname[] = "methodName";
const char methodpermissions_elname[] = "methodPermissions";
const char pendingstatus_elname[] = "pendingStatus";
const char topicstatus_elname[] = "topicStatus";
const char status_elname[] = "status";

static void print_first_element_text(jw_dom_node *node, const char *element_name) {
    jw_dom_node *element = jw_dom_get_first_element(node, element_name);
    if (element) {
        const char *text = jw_dom_get_first_text(element);
        if (text) {
            printf("%s=%s, ", element_name, text);
        }
    }
}

static void print_querymethods(jw_dom_node *querymethods_element) {
    jw_dom_node *operation_el = jw_dom_get_first_element(querymethods_element, operation_elname);

    if (operation_el) {
        printf("%s=", operation_elname); 
    }
    
    while (operation_el) {
        jw_dom_node *methodname_el = jw_dom_get_first_element(operation_el, methodname_elname);
        if (methodname_el) {
            const char *method_name = jw_dom_get_first_text(methodname_el);
            if (method_name) {
                printf("%s", method_name);
            }

        }

        jw_dom_node *methodpermissions_el = jw_dom_get_first_element(operation_el, methodpermissions_elname);
        if (methodpermissions_el) {
            const char *method_permission = jw_dom_get_first_text(methodpermissions_el);
            if (method_permission) {
                printf("(%s)", method_permission);
            }
        }

        printf(",");
        operation_el = jw_dom_get_sibling(operation_el);    
    }        
}

static void print_capabilities(jw_dom_node *capability_el) {
    while (capability_el) {
        print_first_element_text(capability_el, name_elname);
        print_first_element_text(capability_el, version_elname);
        print_first_element_text(capability_el, description_elname);
        print_first_element_text(capability_el, vendorplatform_elname);

        jw_dom_node *querymethods_el = jw_dom_get_first_element(capability_el, querymethods_elname);
        if(querymethods_el) {
            print_querymethods(querymethods_el);
        }

        capability_el = jw_dom_get_sibling(capability_el);
        printf("\n\n");
    }
}

static void print_capability_status(jw_dom_node *element) {
    print_first_element_text(element, status_elname);

    jw_dom_node *capability_el = jw_dom_get_first_element(element, capability_elname);
    if (capability_el) {
        print_capabilities(capability_el);
    }
}


static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
    printf("Notification - ");
    //helper_print_jw_dom(node);
    print_first_element_text(node, change_elname);
    jw_dom_node *capability_el = jw_dom_get_first_element(node, capability_elname);
    print_capabilities(capability_el);
}

static void get_all_capabilities(pxgrid_connection *connection) {
    PXGRID_STATUS status;

    printf("Registered Capabilities - \n");

    jw_dom_node *response = NULL;
    status = pxgrid_connection_query_capabilities(connection, &response);
    if (PXGRID_STATUS_OK == status) {
        if (NULL != response) {
            //helper_print_jw_dom(response);
            jw_dom_node *capability_el = jw_dom_get_first_element(response, capability_elname);
            print_capabilities(capability_el);

            // Free the response structure.
            jw_dom_context_destroy(jw_dom_get_context(response));
        }
    }
}

static void get_capability_status(pxgrid_connection *connection, const char *name, 
                                                    const char *version) {
    printf("\n");
    PXGRID_STATUS status;

    jw_dom_node *response = NULL;
    status = pxgrid_connection_query_capability_status(connection, name, version, &response);
    if (PXGRID_STATUS_OK == status) {
        if (NULL != response) {
            //helper_print_jw_dom(response);
            jw_dom_node *status_el = jw_dom_get_first_element(response, status_elname);
            if (status_el) {
                jw_dom_node *pendingstatus_el = jw_dom_get_first_element(status_el, pendingstatus_elname);
                if (pendingstatus_el) {
                    printf("%s: ", pendingstatus_elname);
                    print_capability_status(pendingstatus_el);
                }

                jw_dom_node *topicstatus_el = jw_dom_get_first_element(status_el, topicstatus_elname);
                if (topicstatus_el) {
                    printf("%s: ", topicstatus_elname);
                    print_capability_status(topicstatus_el);
                }
            }

            // Free the response structure.
            jw_dom_context_destroy(jw_dom_get_context(response));
        }
    }
}

int main(int argc, char **argv) {
    PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
	{
	    printf("Unable to create hconfig object\n");
		exit(EXIT_FAILURE);
	} 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );
     
    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
	pxgrid_connection_set_connect_cb(connection, _on_connected);

    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

	pxgrid_connection_register_topic_notification_handler(connection,  message_callback, NULL);

    pxgrid_connection_connect(connection);

    // Get and print all capabilities using core capability.
    get_all_capabilities(connection);

    char cap_query[128];
    while (helper_prompt("\nCapability name[,version] to query (or <enter> to quit): ", cap_query)) {
        char *cap_name = NULL;
        char *cap_version = NULL;
        char *tf = NULL;

        tf = strtok(cap_query,",");
        cap_name = strdup(tf);
        tf = strtok (NULL,",");	
	if (tf != NULL)
        {	
	    cap_version = strdup(tf);
	}

        // Get and print status for a single capability
        get_capability_status(connection, (const char *) cap_name, (const char *) cap_version);
    }

	//printf("press <enter> to disconnect...\n");
	//getchar();

   	if (connection) {
		pxgrid_connection_disconnect(connection);
		pxgrid_connection_destroy(connection);
	}

	if (conn_config) pxgrid_config_destroy(conn_config);
   	if (hconfig) helper_config_destroy(hconfig);
        return 0;
}
```



<a name="dynamicTopicCSample4"></a>  

## Dynamic Topic C Sample 4

> Multigroupclient

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)


int _pem_key_password_cb(char *buf, int size, int rwflag, void *userdata) {
    UNUSED(rwflag);
    helper_config *hconfig = userdata;
    strncpy(buf, hconfig->client_cert_key_password, size);
    buf[size - 1] = '\0';
    return (int)strlen(buf);
}

static void _user_ssl_ctx_cb( pxgrid_connection *connection, void *_ssl_ctx, void *user_data ) {
   
    helper_config *hconfig = user_data;
    SSL_CTX *ssl_ctx = _ssl_ctx;
    printf("_user_ssl_ctx_cb calling \n");
    SSL_CTX_set_default_passwd_cb(ssl_ctx, _pem_key_password_cb);
    SSL_CTX_set_default_passwd_cb_userdata(ssl_ctx, hconfig);  
    SSL_CTX_use_certificate_chain_file(ssl_ctx, hconfig->client_cert_chain_filename);
    SSL_CTX_use_PrivateKey_file(ssl_ctx, hconfig->client_cert_key_filename, SSL_FILETYPE_PEM);
    SSL_CTX_load_verify_locations(ssl_ctx, hconfig->server_cert_chain_filename, NULL);    
    SSL_CTX_set_verify(ssl_ctx, SSL_VERIFY_PEER, NULL);
}
static void _on_disconnected(pxgrid_connection *connection, PXGRID_STATUS status, void *user_data) {
    UNUSED(connection);
    UNUSED(user_data);
    printf("disconnected!!! status=%s\n", pxgrid_status_get_message(status));
}

static void _on_connected(pxgrid_connection *connection, void *user_data) {
   UNUSED(connection);
   UNUSED(user_data);
   printf("wow connected!!!\n");
 }

static void message_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
	helper_print_jw_dom(node);
}

static void session_query(pxgrid_connection *connection, pxgrid_capability *capability, char *ip) {
    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *request;
    jw_dom_node *ip_interface;
    jw_dom_node *ip_address;
    jw_dom_node *ip_address_text;
    jw_dom_node *response;

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}getActiveSessionByIPAddressRequest", &request, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/identity}ipInterface", &ip_interface, &err)
        || !jw_dom_add_child(request, ip_interface, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}ipAddress", &ip_address, &err)
        || !jw_dom_add_child(ip_interface, ip_address, &err)
        || !jw_dom_text_create(ctx, ip, &ip_address_text, &err)
        || !jw_dom_add_child(ip_address, ip_address_text, &err)
          )
    {
        jw_log_err(JW_LOG_ERROR, &err, "query");
        return;
    }

    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
    if (status == PXGRID_STATUS_OK) {
        helper_print_jw_dom(response);
        printf("\nSessionDirectory Capability successfully queried\n\n");
    }
    else {
        printf("\nSessionDirectoryCapability status=%s\n\n", pxgrid_status_get_message(status));
    }
}

static void anc_getAllPolicies(pxgrid_connection *connection, pxgrid_capability *capability) {
    PXGRID_STATUS status = PXGRID_STATUS_OK;
    
    jw_err err;
    jw_dom_ctx_type *ctx;
    jw_dom_node *request;
    jw_dom_node *response;

    /*
    <getAllPoliciesRequest xmlns='http://www.cisco.com/pxgrid/anc'/>
    */

    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid/anc}getAllPoliciesRequest", &request, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "ANC query");
        return;
    }

    status = pxgrid_connection_query(connection, capability, request, &response);
    if (status == PXGRID_STATUS_OK) {
        helper_print_jw_dom(response);
        printf("\nANC Policies successfully queried\n\n");
    }
    else {
        printf("\nANC getAllPoliciesRequest status=%s\n\n", pxgrid_status_get_message(status));
    }
}

int main(int argc, char **argv) {
    PXGRID_STATUS status;
    helper_config *hconfig = NULL;
    pxgrid_config *conn_config = NULL;
    pxgrid_connection *connection = NULL;
    helper_config_create(&hconfig, argc, argv); 
    if(!hconfig) 
    {
       printf("Unable to create hconfig object\n");
       exit(EXIT_FAILURE);
    } 
    helper_pxgrid_config_create(hconfig , &conn_config);
    pxgrid_connection_create( &connection );

    // Set connection configuration data
    pxgrid_connection_set_config(connection , conn_config);

    // Set Call back
    pxgrid_connection_set_disconnect_cb(connection, _on_disconnected);	
    pxgrid_connection_set_connect_cb(connection, _on_connected);
    
    pxgrid_connection_set_ssl_ctx_cb(connection, (pxgrid_connection_ssl_ctx_cb)_user_ssl_ctx_cb);
    pxgrid_connection_set_ssl_ctx_cb_user_data(connection, (helper_config *)hconfig);

    pxgrid_connection_connect(connection);

    pxgrid_capability *capability;
    pxgrid_capability_create(&capability);
    
    if(!capability) exit(EXIT_FAILURE);
    
    const char ns_iden[] = "http://www.cisco.com/pxgrid/identity";
    const char cap_name[] = "SessionDirectoryCapability";
    
    pxgrid_capability_set_namespace(capability, ns_iden);
    pxgrid_capability_set_name(capability, cap_name);
    pxgrid_capability_subscribe(capability, connection);
    char ip_address[128];
    if (helper_prompt("\nip_address to query (or <enter> to quit): ", ip_address))
    session_query(connection, capability, ip_address);


    pxgrid_capability *anc_capability;
    pxgrid_capability_create(&anc_capability);

    if(!anc_capability) exit(EXIT_FAILURE);
  
    char namespacebuf[] = "http://www.cisco.com/pxgrid/anc";
    char namebuf[] = "AdaptiveNetworkControlCapability";
    
    pxgrid_capability_set_namespace(anc_capability, namespacebuf);
    pxgrid_capability_set_name(anc_capability, namebuf);
    pxgrid_capability_subscribe(anc_capability, connection);
    anc_getAllPolicies(connection, anc_capability);

    //printf("press <enter> to disconnect...\n");
    //getchar();

    if (connection) {
        pxgrid_connection_disconnect(connection);
        pxgrid_connection_destroy(connection);
    }

    if (capability) pxgrid_capability_destroy(capability);
    if (anc_capability) pxgrid_capability_destroy(anc_capability);
    if (conn_config) pxgrid_config_destroy(conn_config);
    if (hconfig) helper_config_destroy(hconfig);
    return 0;
}
```




<a name="dynamicTopicCSample5"></a>  

## Dynamic Topic C Sample 5  

> Generic publisher

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

PXGRID_STATUS _dynamic_capability_publish_data(pxgrid_connection *connection, pxgrid_capability *capability, const char* capability_name, const char* operation_name, char *publish_data) {jw_err err;
    jw_dom_ctx_type *ctx = NULL;
    jw_dom_node *notf = NULL;
    jw_dom_node *body = NULL;
    
    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}genericMessage", &notf, &err)
        || !jw_dom_put_namespace(notf, "", "http://www.cisco.com/pxgrid", &err)
        || !helper_jw_dom_add_child_with_text(notf, "{http://www.cisco.com/pxgrid}capabilityName", capability_name, &err)
        || !helper_jw_dom_add_child_with_text(notf, "{http://www.cisco.com/pxgrid}operationName", operation_name, &err)
        || !helper_jw_dom_add_child_with_text(notf, "{http://www.cisco.com/pxgrid}messageType", "notification", &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}body", &body, &err)
        || !jw_dom_add_child(notf, body, &err)
        || !helper_jw_dom_add_child_with_text(body, "{http://www.cisco.com/pxgrid}content", publish_data, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "capability publish error");
        return PXGRID_STATUS_PXGRID_ERROR;
    }
    
    printf("Sent notification\n");
    helper_print_jw_dom(notf);
    
    PXGRID_STATUS status = pxgrid_connection_notify(connection, capability, notf);
    if (status != PXGRID_STATUS_OK) {
        printf("capability publish data status=%d\n", status);
    }
    return status;
}

int main(int argc, char **argv) {
    helper_connection *hconn;
    helper_connection_create(&hconn, argc, argv);
    helper_connection_connect(hconn);
    
    char cap_name[128];
    helper_prompt("Enter capability name for publishing: ", cap_name);
    
    pxgrid_connection *connection = hconn->connection;

    pxgrid_capability *capability;
    pxgrid_capability_create(&capability);
    
    const char pxgrid_ns[] = "http://www.cisco.com/pxgrid";
    pxgrid_dynamic_capability_set_name(capability, cap_name);
    pxgrid_capability_set_namespace(capability, pxgrid_ns);
    pxgrid_dynamic_capability_publish(capability, connection);
    
    char *notification_name = "sampleNotification";
    char capability_publish_data[4096];
    while ((helper_prompt("Publish data (or <enter> to quit): ", capability_publish_data)))  {
       _dynamic_capability_publish_data(connection, capability, cap_name,  notification_name, capability_publish_data);
    }

    helper_connection_disconnect(hconn);
    helper_connection_destroy(hconn);
    
    return 0;
}
```




<a name="dynamicTopicCSample6"></a>  

## Dynamic Topic C Sample 6  

> Generic subscriber 

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>
#define UNUSED(x) (void)(x)

static void subscribe_callback(jw_dom_node *node, void *arg) {
    UNUSED(arg);
    printf("Received notification\n");
    helper_print_jw_dom(node);
}

int main(int argc, char **argv) {
    helper_connection *hconn;
    helper_connection_create(&hconn, argc, argv);
    helper_connection_connect(hconn);
    
    char cap_name[128];
    helper_prompt("Enter capability name for subscription: ", cap_name);
    
    pxgrid_connection *connection = hconn->connection;
    
    const char pxgrid_ns[] = "http://www.cisco.com/pxgrid";
    
    pxgrid_capability *capability;
    pxgrid_capability_create(&capability);
    pxgrid_dynamic_capability_set_name(capability, cap_name);
    pxgrid_capability_set_namespace(capability, pxgrid_ns);

    pxgrid_dynamic_capability_subscribe(capability, connection);
    pxgrid_connection_register_notification_handler(connection, pxgrid_ns, "genericMessage", subscribe_callback, NULL);
    
    helper_prompt("press <enter> to disconnect...\n", NULL);

    helper_connection_disconnect(hconn);
    helper_connection_destroy(hconn);

    return 0;
}
```



<a name="dynamicTopicCSample7"></a>  

## Dynamic Topic C Sample 7  

> Generic query action handler  

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include <openssl/ssl.h>

#include "pxgrid.h"
#include "helper.h"

#define UNUSED(x) (void)(x)

static jw_dom_node *create_response(const char *capability_name, const char *operation_name, const char *data) {
    jw_err err;
    jw_dom_ctx_type *ctx = NULL;
    jw_dom_node* response = NULL;
    jw_dom_node *body = NULL;
    
    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}genericMessage", &response, &err)
        || !jw_dom_put_namespace(response, "", "http://www.cisco.com/pxgrid", &err)
        || !helper_jw_dom_add_child_with_text(response, "{http://www.cisco.com/pxgrid}capabilityName", capability_name, &err)
        || !helper_jw_dom_add_child_with_text(response, "{http://www.cisco.com/pxgrid}operationName", operation_name, &err)
        || !helper_jw_dom_add_child_with_text(response, "{http://www.cisco.com/pxgrid}messageType", "response", &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}body", &body, &err)
        || !jw_dom_add_child(response, body, &err)
        || !helper_jw_dom_add_child_with_text(body, "{http://www.cisco.com/pxgrid}content", data, &err)
       )
    {
       jw_log_err(JW_LOG_ERROR, &err, "create_response failure");
       return NULL;
    }
    
    return response;
}

static jw_dom_node *create_unauthorized_response() {
    jw_err err;
    jw_dom_ctx_type *ctx = NULL;
    jw_dom_node *response = NULL;
    jw_dom_node *error_node = NULL;
    
    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}genericMessage", &response, &err)
        || !jw_dom_put_namespace(response, "", "http://www.cisco.com/pxgrid", &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}error", &error_node, &err)
        || !helper_jw_dom_add_child_with_text(error_node, "{http://www.cisco.com/pxgrid}description", "not authorized", &err)
        || !jw_dom_add_child(response, error_node, &err)
        || !helper_jw_dom_add_child_with_text(response, "{http://www.cisco.com/pxgrid}messageType", "response", &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "create_error failure");
        return NULL;
    }
    return response;
}

static jw_dom_node* query_handler_cb(jw_dom_node *request, void *arg) {
    pxgrid_connection *connection = (pxgrid_connection *)arg;
    if (!connection) return NULL;

    printf("Received request\n");
    helper_print_jw_dom(request);

    // To be filled in by user - Sample Data
    char *response_data = "SampleData";

    char user[128];
    if (pxgrid_xml_get_sender(request, user) != PXGRID_STATUS_OK) return NULL;

    jw_dom_node *genericmsg = request;

    jw_dom_node *capability_node = jw_dom_get_first_element(genericmsg, "capabilityName");
    if (!capability_node) {
        jw_log(JW_LOG_ERROR, "get capability_node failed");
        return NULL;
    }
    const char *capability_name = jw_dom_get_first_text(capability_node);

    jw_dom_node *operation_node = jw_dom_get_first_element(genericmsg, "operationName");
    if (!operation_node) {
        jw_log(JW_LOG_ERROR, "get operation_node failed");
        return NULL;
    }
    const char *operation_name = jw_dom_get_first_text(operation_node);

    jw_dom_node* response = NULL; 

    bool is_authz = pxgrid_connection_is_authorized(connection, capability_name, operation_name, user);
    if (is_authz) {
        response = create_response(capability_name, operation_name, response_data);
    }
    else {
        response = create_unauthorized_response();
    }

    printf("Sent response\n");
    helper_print_jw_dom(response);
    return response;
}

int main(int argc, char **argv) {
    helper_connection *hconn;
    helper_connection_create(&hconn, argc, argv);
    helper_connection_connect(hconn);
    
    char cap_name[128];
    helper_prompt("Enter capability name for query handling: ", cap_name);
    
    pxgrid_connection *connection = hconn->connection;
    
    pxgrid_capability *capability;
    pxgrid_capability_create(&capability);
    pxgrid_capability_set_namespace(capability, "http://www.cisco.com/pxgrid");
    pxgrid_dynamic_capability_set_name(capability, cap_name);
    pxgrid_dynamic_capability_publish(capability, connection);
    
    pxgrid_connection_register_query_handler(connection, "http://www.cisco.com/pxgrid", "genericMessage", query_handler_cb, connection);

    helper_prompt("press <enter> to disconnect...\n", NULL);
    
    helper_connection_disconnect(hconn);
    helper_connection_destroy(hconn);
    return 0;
}
```



<a name="dynamicTopicCSample8"></a>  

## Dynamic Topic C Sample 8  

> Generic query caller 

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>

static PXGRID_STATUS query_call(pxgrid_connection *connection, pxgrid_capability *capability, const char* capability_name, const char* operation_name, char *query_action_data) {
    jw_err err;
    jw_dom_ctx_type *ctx = NULL;
    jw_dom_node *request = NULL;
    jw_dom_node *body = NULL;
    
    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}genericMessage", &request, &err)
        || !jw_dom_put_namespace(request, "", "http://www.cisco.com/pxgrid", &err)
        || !helper_jw_dom_add_child_with_text(request, "{http://www.cisco.com/pxgrid}capabilityName", capability_name, &err)
        || !helper_jw_dom_add_child_with_text(request, "{http://www.cisco.com/pxgrid}operationName", operation_name, &err)
        || !helper_jw_dom_add_child_with_text(request, "{http://www.cisco.com/pxgrid}messageType", "request", &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}body", &body, &err)
        || !jw_dom_add_child(request, body, &err)
        || !helper_jw_dom_add_child_with_text(body, "{http://www.cisco.com/pxgrid}content", query_action_data, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "xgrid generic client request create dom");
        return PXGRID_STATUS_PXGRID_ERROR;
    }

    printf("Sent request\n");
    helper_print_jw_dom(request);

    jw_dom_node *response = NULL;
    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
    
    if (status == PXGRID_STATUS_OK) {
        printf("Received response\n");
        helper_print_jw_dom(response);
    }
    else {
        helper_print_error(status);
    }
    return status;
}

int main(int argc, char **argv) {
    helper_connection *hconn;
    helper_connection_create(&hconn, argc, argv);
    helper_connection_connect(hconn);
    
    char cap_name[128];
    helper_prompt("Enter capability name for query operation: ", cap_name);

    pxgrid_connection *connection = hconn->connection;

    pxgrid_capability *capability;
    pxgrid_capability_create(&capability);
    pxgrid_capability_set_namespace(capability, "http://www.cisco.com/pxgrid");
    pxgrid_dynamic_capability_set_name(capability, cap_name);

    pxgrid_dynamic_capability_subscribe(capability, connection);
    
    char operation_name[128];
    char capability_query_data[4096];
    while ((helper_prompt("\nQuery operation (or <enter> to quit): ", operation_name))
            && (helper_prompt("Query data (or <enter> to quit): ", capability_query_data))) {
        query_call(connection, capability, cap_name, operation_name, capability_query_data);
    }

    helper_connection_disconnect(hconn);
    helper_connection_destroy(hconn);
    
    return 0;
}
```




<a name="dynamicTopicCSample9"></a>  

## Dynamic Topic C Sample 9  

> Generic action caller

```output
#include <stdlib.h>
#include <unistd.h>
#include <memory.h>
#include "pxgrid.h"
#include "helper.h"

#include <openssl/ssl.h>

static PXGRID_STATUS action_call(pxgrid_connection *connection, pxgrid_capability *capability, const char* capability_name, const char* operation_name, char *query_action_data) {
    jw_err err;
    jw_dom_ctx_type *ctx = NULL;
    jw_dom_node *request = NULL;
    jw_dom_node *body = NULL;
    
    if (!jw_dom_context_create(&ctx, &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}genericMessage", &request, &err)
        || !jw_dom_put_namespace(request, "", "http://www.cisco.com/pxgrid", &err)
        || !helper_jw_dom_add_child_with_text(request, "{http://www.cisco.com/pxgrid}capabilityName", capability_name, &err)
        || !helper_jw_dom_add_child_with_text(request, "{http://www.cisco.com/pxgrid}operationName", operation_name, &err)
        || !helper_jw_dom_add_child_with_text(request, "{http://www.cisco.com/pxgrid}messageType", "request", &err)
        || !jw_dom_element_create(ctx, "{http://www.cisco.com/pxgrid}body", &body, &err)
        || !jw_dom_add_child(request, body, &err)
        || !helper_jw_dom_add_child_with_text(body, "{http://www.cisco.com/pxgrid}content", query_action_data, &err)
        )
    {
        jw_log_err(JW_LOG_ERROR, &err, "xgrid generic client request create dom");
        return PXGRID_STATUS_PXGRID_ERROR;
    }

    printf("Sent request\n");
    helper_print_jw_dom(request);

    jw_dom_node *response = NULL;
    PXGRID_STATUS status = pxgrid_connection_query(connection, capability, request, &response);
    
    if (status == PXGRID_STATUS_OK) {
        printf("Received response\n");
        helper_print_jw_dom(response);
    }
    else {
        helper_print_error(status);
    }
    return status;
}

int main(int argc, char **argv) {
    helper_connection *hconn;
    helper_connection_create(&hconn, argc, argv);
    helper_connection_connect(hconn);
    
    char cap_name[128];
    helper_prompt("Enter capability name for action operation: ", cap_name);

    pxgrid_connection *connection = hconn->connection;

    pxgrid_capability *capability;
    pxgrid_capability_create(&capability);
    pxgrid_capability_set_namespace(capability, "http://www.cisco.com/pxgrid");
    pxgrid_dynamic_capability_set_name(capability, cap_name);

    pxgrid_dynamic_capability_refresh_publisher_jids(capability, connection);

    char operation_name[128];
    char capability_action_data[4096];
    while ((helper_prompt("\nAction operation (or <enter> to quit): ", operation_name))
            && (helper_prompt("Action data (or <enter> to quit): ", capability_action_data))) {
        action_call(connection, capability, cap_name, operation_name, capability_action_data);
    }

    helper_connection_disconnect(hconn);
    helper_connection_destroy(hconn);
    
    return 0;
}
```



