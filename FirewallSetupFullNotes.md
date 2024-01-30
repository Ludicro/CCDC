Meg's Notes:
	Suggested logging into web interface first and turning on anti-virus scanning
	Add it to any2any rule
	Then proceed with following instructions

# Firewall Initial Setup (CLI)

1. Turn off Management Interface Temporarily
   	~~~
 	> configure
	set device config system permitted-ip 127.0.0.1
	
	commit
	~~~
3. Turn off Data External Interface Temporarily - Red Team could manage our FW via data interface
	~~~
 	> configure
	#set network interface ethernet ethernet1/1 link-state down
	
	#commit
	~~~
4. Delete create new admin user and delete all other accounts
	````
	> configure
	#set mgt-config users <name> password
	#set mgt-confg users <name> permission role-based superuser yes
	#commit
	#exit
	````
	Log into new user then:
	````
	> configure
	# show mgt-config users
	# delete mgt-config users <name>
	# commit
	````	
	
	Setting up SSH Key: https://docs.paloaltonetworks.com/pan-os/10-1/pan-os-admin/firewall-administration/manage-firewall-administrators/configure-administrative-accounts-and-authentication/configure-ssh-key-based-administrator-authentication-to-the-cli

5. Review System Info
   	````
	> show system info
	(default will be dhcp client, will need to turn off dhcp before configuring a static address)
    	> configure
	#set deviceconfig system type _____
	(hitting tab will allow dropdown selection)
	#set deviceconfig system type static
	#commit
	````
7. Only allow secure protocols to connect - ssh, https, ping(for troubleshooting)
	````
 	> show system services
 	> configure
	#set deviceconfig system service disable-[service](hit tab after the "-" to see list) no
	#commit
	````
8. Show all Admin Accounts
	````
 	> show admins all
	>configure
	#delete mgt-config users [account]
	#commit
 	````
9. Turn Data Interface Back On
	````
 	> configure
	#set network interface ethernet ethernet1/1 link-state up
	
	#commit
	````
10. Turn on Management Interface 
	````
 	> configure
	#set device config system permitted-ip x.x.x.x
	
	#commit
	(should now be able to access web-ui again)
	````
Meg's Notes:	
	Configure Profiles
 
 	
	>configure
	#set network profiles interface-management-profile <name> [service] yes
		([service should be changed to allow_ping and allow_https, hit TAB to view options)
		(I recommend making the names like allow_ping)
	#set network interface ethernet ethernet1/4 layer 3 interface-management-profile <name>
		(1/4 is interchangeable for 1/1, 1/2, 1/3)
	
9. Backup FW Config
   	````
	>scp export configuration to user@ip:/path/here from running-config.xml
	````

11. Revoke all login sessions
	````
	>delete admin-sessions
	````


# Setting Up Firewall (WebUI)

1. Licensing FW - Didn't work at invitational so may not need to do this, but it is good to try this anyway
	Go to Device tab
	On the left, scroll down to Licenses
	Retrieve License Keys
	Reboot
	
2. Download latest malware signatures
	Go to Device tab
	On the left, scroll down to Dynamic Updates
	Click Check Now at the bottom
	Download and intstall latest updates and schedule future downloads/installations

3. Configure inbound/outbound rule to block unknown and bad urls
	
4. Assign Security Profiles to all Allow rules
	Firewalll will not block malware without Security Profiles assigned to Security Policies
	
5. Use Custom Reports to Determine What Apps are in the Network
	Monitor Tab -> Manage Custom Reports (bottom of far left menu) -> Select Report Settings -> Run Now

6. Creating Anti-Virus Profiles (Meg's Notes show some specifics, but hers have all reset-both)
	Enable Reset-Both:
		http
		SMTP
		imap
		pop3
		FTP
		smb
	Enable inline Machine Learning
		Helps prevent 0 Day attacks

7. Creating Anti-Spyware Profiles (Meg's Notes show some specifics)
	Enable Following Rules:
		Name			Threat Name	Severity 	Action 		Packet Capture
		simple-critical		any 		critical	reset-both  	enable
		simple-high		any 		high		reset-both  	enable
		simple-medium		any 		medium		reset-both  	enable
		simple-informational	any 		informational	reset-both  	enable
		simple-low		any 		low 		reset-both  	enable
	Set DNS Security policy to sinkhole
		Consider setting up sinkhole server to capture intel on Red team or use loopback address as sinkhole

8. Creating Vulnerability Protection Profiles (Meg's Notes show some specifics)
	Enable Following:
		Name				Threat Name	Severity 	Action 		Packet Capture
		simple-client-critical		any 		critical	reset-both  	enable
		simple-client-high		any 		high		reset-both  	enable
		simple-client-medium		any 		critical	reset-both 	enable
		simple-client-informational	any 		critical	reset-both  	enable
		simple-client-low		any 		critical	reset-both  	enable
		simple-server-critical		any 		critical	reset-both  	enable
		simple-server-high		any 		high		reset-both  	enable
		simple-server-medium		any 		critical	reset-both  	enable
		simple-server-informational	any 		critical	reset-both  	enable
		simple-server-low		any 		critical	reset-both  	enable
9. Creating URL Filtering Profiles (Meg's Notes don't have specifics, but her block has 3 more than my list so try to get anything that could be unsafe)
	1. Block the following categories:
		Command and control
		Grayware
		Hacking
		Malware
		Newly registered domains
		Proxy avoidance and anonymizers
		Ransomware
		Any others that are not needed
	2. Set all other categories to alert
	3. Inline ML
		Stop 0 day attacks by enabling inline machine learning action to block
	
10. Creating File Blocking Profiles (Meg's Notes show some specifics)
		Block downloading and uploading dangerous files
		Alert on all file uploads and downloads 
	
11. Creating Wildfire Analysis Profiles
		Use default
		
12. Security Groups (order placement may be wrong)
	Assign Security Profiles with Action Drop to North-South SG
	Assign the SG to North-South Allow Security Policies

13. Configure inbound security rules for scored services
	Make as specific as possible by using allowed applications and secure IP addresses

14. Configure outbound allow security rules
	Make rules as specific as possible
	Only allow outbound traffic from specific IP addresses that are absolutely necessary for scoring and the organization

15. Turn on Decryption (this caused a lot of issues in competition with people unable to access websites, may not be worth it) - main use is to stop red team from sending encrypted malware
	Create Certificate Authority:
		Device -> Certificate Management -> Certificate -> Generate
			Type: Local
			Certificate Name: Trusted (any name really works)
			Common Name: Firewall IP
			Mark: Certificate Authority
			Attributes:
				Country: US
				State: Kentucky
				IP: Firewall IP
	Forward Trust Decryption for Outbound Traffic:
		Create Trust Certificate:
			Device -> Certificate Management -> Check Certificate Authority
			Add Certificate
				Name: Forward-Trust
				Common Name: IP of the Firewall
				Check Certificate Authority then Forward Trust Certificate
		Create Untrust Certificate:
			Name: Forward-Untrust
			Common Name: forward-untrust
			Check Certificate Authority
			Add Certificate
				Name: Forward-untrust 
				Check Certificate Authority then Forward Untrust Certificate
	Configure Decryption Profile 
		Objects -> Decryption Profile
		SSL Decryption Check:
			Blocks sessions with expired certificates
			Block sessions with untrusted users
			Block sessions with unknown certificate status
			Block sessions with unsupported versions
			Block sessions with unsupported cipher suites
		No Decryption Check: (block bad certs for traffic we aren't decrypting)
			Block sessions with epxired certificate
			Block sessions with untrusted issuers 
	Configure Forward Decryption Policy for Outbound Traffic
		Policies -> Decryption
		In the Rule:
			Define source and destination by zone and IP address
			Service/URL Category:
				Use url categories to define traffic to decrypt 
			Options:
				Decrypt
				Type: SSL Forward Policy
				Profile: Decrypt Profile
				Check: Log Unsuccessful SSL Handshake
				
(Check page 52 of quick start)

16. Set Management to only be from specific IP
	Device -> Interfaces -> Click on Interface Name and add the permitted IP address (XXX.XXX.XXX.XXX/XX)

17. Setting up NTP and DNS
	Go to Device -> Setup -> Services -> Click the Gear Icon
	From here you can setup the DNS server and the NTP server
	
18. Setup Login Banner:
	Device -> Management -> General Settings Gear Icon
	WARNING: This system is for the user of authorized clients only. Individuals using the computer network system without authorization, or in excess of their authorization, are subject to having all of their activity on this computer network system monitored and recorded by system personnel. To protect the computer network system from unauthorized usage and to ensure the computer network systems are functioning properly, system administrators monitor this system. Anyone using this system expressly consents to such monitoring and is advised that if this monitoring reveals possible conduct of criminal activity, system personnel may provide the evidence of such activity to law enforcement officers. 

	Access is restricted to authorized users only. Unauthorized access is a violation of state and federal, civil and criminal laws. 
	
19. Check for New Updates:
	Device -> Scroll on left down to Software -> Click Check Now
	(the lab said to not update software but that might have been for their lab only, not CCDC)

# Nat Rules

No source translation, only destination
External source to external destination 
Internal source to destination translation
Any for incoming 
Dest = external IP of service 
Service for application = port
Destination translation = external to internal

Creating NAT/Security Policy:
NAT - defines how IPs are translated, has nothing to do with connections
NAT:
1. What is the ORIGINAL source address of computers initiating the connection?
2. What zone is that address in?
3. What is my ORIGINAL destination address?
4. What zone is that address, or collection of addresses in?
Security:
1. What is the ORIGINAL source address of computers initiating the connection?
2. What zone is that address in?
3. What is my ORIGINAL destination address?
4. What zone will the packet FINALLY come to rest in?\
Don't use bi-directional as it will mess up configuration, better to manually create the rules and combine for back and forth traffic

#  Security Rules (In GUI): 
```
Service = Port
Zone = Zone of Asset
Each section of the rules works as an “and” together and within each section it is an “or”
	Internet Access
		Internal to External
		Source: Internal
		Dest: External
		Source address: Internal 
		Application: Any
		Service: Any
	Box General Controls (One Rule for Each Line Under Application)
	Source: “External” “Any”
	Destination: “Zone” “Public”
	Application: 
		Fedora: SMTP/Pop3 - Webmail
		Splunk: ssl/web-browsing
		CentOS: web-browsing - ecomm
		Debian: DNS
		2012 AD/DNS: DNS
		Service: (all are listed here, not just the ones for the box general controls. Use the ones that go with each application in each corresponding rule ie. 110 and 25 for SMTP and pop3 on the fedora box)
			Splunk: 8000 - TCP
			DNS: 53 - UDP
			FTP: 20/21 - TCP
			HTTPS: 443 - TCP
			HTTP: 80 - TCP
			SMTP: 25 - TCP
			Pop3: 110 - TCP
			SSH: 22 
			MySQL: 3306 
		SSH Block Rules
			2 rules, one for the application and one for the port. Need two because of how the “and” and “or” works with the rules
			“Any” “any” “deny” - ssh in application
			“Any” “any” “deny” - ssh in service
```

# Setting Password Policy:
```
Min Length: 			10
Min Uppercase: 			1
Min Lowercase: 			1
Min Numeric Characters: 	1
Min Special Characters: 	1

Prevent Password Reuse Limit: 	3
Required Password Change Period: 90 days
```
	
# Sys Log Server Profile Splunk:
```
Syslog Server Profile
	Servers
		Name	Syslog Server	Transport	Port	Format	Facility
		splunk	172.20.241.20	TCP			514		BSD		LOG_USER
```
# Additional Notes:
```
Terms:
	Universal:
		local can talk to remote/local
		remote can talk to local/remote
	Intrazone:
		local can talk to local
		remote can talk to remote
	Interzone:
		local can talk to remote
		remote can talk to local
```

# Useful tips:
## Application Filter:
Set "groups" of applications that can be denied or allowed all at once as a rule.
	Included filtering subcatgory, technology used, and risk factor

## Create custom security profiles
When creating, can set up for various categories, assign actions, do extended packet capture, and capture DNS sinkholes\
	DNS Sinkholes: Will identify if a connection is going to a malicious source, will then change the IP that is actually sent out, ruining command and control and will allow for hostile detection on hosts. (Change to IP that is NOT actually used on network) then enable Passive DNS monitoring.

 
# Importing/Exporting Configuration Files:
	Exporting:
		save config to <config_file_name>
		scp export configuration from <config_file_name> to <username@host:path>
	Importing:
		scp import configuration from <username@host:path_to_named_config_file)
