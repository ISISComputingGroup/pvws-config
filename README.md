# pvws-config

we run a `PVWS` instance on `NDAEXTWEB4` for the [Web Dashboard](https://github.com/ISISComputingGroup/WebDashboard)

This is done with a native tomcat service (rather than a container) following the [PVWS instructions](https://github.com/ornl-epics/pvws?tab=readme-ov-file#running-under-tomcat), though it could be run as a container in the future. 

## Updating
Things to consider when updating `Tomcat/PVWS`:
- Tomcat installer from https://tomcat.apache.org/download-90.cgi installed in `C:\Program Files\Apache Software Foundation\Tomcat 9.0` 
- [`pvws`](https://github.com/ornl-epics/pvws) - we are using the latest nightly .war as of 01/11/24 - to update download this and place in the tomcat `dir\webapps` folder and restart the service
- jdk 21 from https://adoptium.net/en-GB/ installed in `C:\Program Files\Eclipse Adoptium\jdk-21.0.5.11-hotspot`

## Setting up PVWS on a machine from scratch

1) install tomcat as a windows service, using the defaults set by the wizard. Note the shutdown port to `-1`, this disables it as per [the security guidelines](https://tomcat.apache.org/tomcat-9.0-doc/security-howto.html#Server): 

<img width="373" alt="image" src="https://github.com/user-attachments/assets/a6d31707-139b-41ee-9069-38c682ced46c" />

During the installer expand `+Tomcat` when it asks you which components to install, and tick the option which starts tomcat on startup.


2) copy `pvws.war` to the `webapps` directory in the tomcat directory (usually `C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps`)
3) in your `tomcat\bin` directory, we need to add the `EPICS_CA` variables that specify the gateway address so PVWS knows where to look for PVs. this is done by running `Tomcat9.exe` with the `//US` (update server) flag ie: 
 `C:\Program Files\Apache Software Foundation\Tomcat 9.0\bin>Tomcat9.exe //US ++Environment EPICS_CA_AUTO_ADDR_LIST=NO;EPICS_CA_ADDR_LIST=<ip>` where ip is the gateway address. (more info on this command [here](https://tomcat.apache.org/tomcat-9.0-doc/windows-service-howto.html)) _note, don't do this in powershell as it tries to interpret the arguments as separate commands._ 
3) create a `.pfx` file if you need a new certificate by using Windows' `certificate manager -> wherever the cert is -> all tasks -> export`
  -  no, do not export the private key
  - "personal information exchange", `include all certificates in the certification path if possible: true, delete the private key if export is successful: false, export all extended properties: false, enable certificate privacy: false`

> [!NOTE]  
> when finished you'll need to add `local service` to the users that can read this file like so: 
>
> ![image](https://github.com/user-attachments/assets/1d040def-06fe-4e0d-b6cd-126a27797658)

4) edit `server.xml` to contain these lines, removing the default connector: 

```xml
<Connector port="443" protocol="org.apache.coyote.http11.Http11NioProtocol"
               maxThreads="150" SSLEnabled="true"
               maxParameterCount="1000" Server=" " 
			   scheme="https" secure="true" clientAuth="false" sslProtocol="TLS" keystoreFile="file:///C:/PROGRA~1/APACHE~1/TOMCAT~1.0/dataweb.pfx" keystoreType="PKCS12" keystorePass="<keeper:.pfx keystore password for PVWS tomcat instance on NDAEXTWEB3>"
               >
    </Connector>
```

this will start a https connector using the `.pfx` file generated from the certificate. 

5) go to `services.msc` and hit restart on the tomcat service then navigate to `https://<machine name>:7777/pvws` - this should present the PVWS test page. 
6) update the max message size to `131072` as per "increasing maximum message size" of https://github.com/ornl-epics/pvws?tab=readme-ov-file#running-under-tomcat - this should be done in `C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\pvws\WEB-INF\web.xml`
7) restart the service again
8) if you want the web dashboard to permanently use this, update https://github.com/ISISComputingGroup/WebDashboard/blob/main/.env
9) Add the following in `C:\Program Files\Apache Software Foundation\Tomcat 9.0\conf\web.xml` (or equivalent path if you've updated tomcat):

```
  <security-constraint>
    <web-resource-collection>
      <web-resource-name>restricted methods</web-resource-name>
      <url-pattern>/*</url-pattern>       
      <http-method>OPTIONS</http-method>
      <http-method>DELETE</http-method>
    </web-resource-collection>
    <auth-constraint/>
  </security-constraint>
```

## Gateway

A gateway runs on NDAEXTWEB4 which is needed to only allow PVWS to access some PVs but not others. 

This runs under the task scheduler as making a `.bat` run as a Windows service is not trivial. 

the files in the top level (`gw_*` and `start_gateway.bat`) of this repo are located in `C:\gateway` on the machine it is running on. A static gateway build is also required (ie. from the latest static build of EPICS)

This points at `control-svcs` gateway, but denies everything that isn't in the gateway pvlist. It also only gives read-only access to any clients (in this case PVWS itself)


## Useful reading
https://tomcat.apache.org/tomcat-9.0-doc/windows-service-howto.html

