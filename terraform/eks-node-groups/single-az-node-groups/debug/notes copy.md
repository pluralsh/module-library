ubuntu@ip-10-0-40-195:/etc/kubernetes/pki$ cat ca.crt
-----BEGIN CERTIFICATE-----
MIIC5zCCAc+gAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
cm5ldGVzMB4XDTIyMTEwODE0NDgwM1oXDTMyMTEwNTE0NDgwM1owFTETMBEGA1UE
AxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPRo
5RjduvAq/6GTvQGrFRXy+atHVf1VBLX7o4PMSjSjwYAppysjBe1h573525wKBcbc
z6MhfJOk28y88tvLAAvjRDo752NSD0K6de8lrTeII3S7YcNwGSTBs5Y+ngBH6M8k
wwzXXJ3cnwKVhUiTZTvL5zE7yw9tCmlKSgGNxnxsb8SWa9UCmLI+PhSVytmshpBC
1yQLdgoMHKNIMn68jPDZtUmF9wsZG22mhv/J1aJPSjO/KT+0SGtQnCDRU0HMXbzJ
JtJHqlZwBXdyusKFbL9P4FQI+anOY0zr/kRJt+yd4eH/fiaNB55Gb9deJcumHjaB
kKgnwSmdXuKkKcamOncCAwEAAaNCMEAwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB
/wQFMAMBAf8wHQYDVR0OBBYEFE1zgsz0km+USlvPm7nT1yvwA5lQMA0GCSqGSIb3
DQEBCwUAA4IBAQA5IBo0c4Ae9I7p+80LbGxjK8LeGH0KMLL2QRN1KcmO+gy7bgfb
rDNu+uPB4nWB+EE17WWHIdimBi4BtNFaxk0eaj7quEpmujLkxGXHBPStyvPwDdZq
QEFqMphP03mXr07i6wuY5Icjvebg2OnDdlYKskFDERDueiLLPYZxQfO2Ym7fTMWj
E/+HhRtwULibBZWYazH6zmDvMSnBu+0Fo8InZEOSZaL7y0IWTFvANSyOSnfdCmJP
aCqpn1B3gwn1ozjRxn6PHjh7JjNkZ/U3rh8gAtrYOVupfxqttd198tILIymMJvQh
D3R5mRj7n0o5WkCSuLQdDb9UV+uF3ziLViAk
-----END CERTIFICATE-----


kubelet is actually not started??
```
ubuntu@ip-10-0-40-195:~$ systemctl status kubelet
Unit kubelet.service could not be found.
ubuntu@ip-10-0-40-195:~$ sudo journalctl -u kubelet
-- Logs begin at Wed 2023-08-02 12:30:35 UTC, end at Wed 2023-08-02 12:50:46 UTC. --
-- No entries --
```

```
ubuntu@ip-10-0-40-195:~$ systemctl status
● ip-10-0-40-195
    State: degraded
     Jobs: 0 queued
   Failed: 1 units
    Since: Wed 2023-08-02 12:30:22 UTC; 20min ago
   CGroup: /
           ├─2538 bpfilter_umh
           ├─user.slice 
           │ └─user-1000.slice 
           │   ├─user@1000.service 
           │   │ ├─init.scope 
           │   │ │ ├─12787 /lib/systemd/systemd --user
           │   │ │ └─12788 (sd-pam)
           │   │ └─dbus.service 
           │   │   └─28560 /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
           │   └─session-1.scope 
           │     ├─12784 sshd: ubuntu [priv]
           │     ├─12873 sshd: ubuntu@pts/0
           │     ├─12875 -bash
           │     ├─30320 systemctl status
           │     └─30321 pager
           ├─init.scope 
           │ └─1 /sbin/init
           └─system.slice 
             ├─containerd.service 
             │ └─23578 /usr/bin/containerd
             ├─systemd-networkd.service 
             │ └─420 /lib/systemd/systemd-networkd
             ├─systemd-udevd.service 
             │ └─203 /lib/systemd/systemd-udevd
             ├─system-serial\x2dgetty.slice 
             │ └─serial-getty@ttyS0.service 
             │   └─508 /sbin/agetty -o -p -- \u --keep-baud 115200,38400,9600 ttyS0 vt220
             ├─docker.service 
             │ └─894 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
             ├─networkd-dispatcher.service 
             │ └─491 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
             ├─snap.amazon-ssm-agent.amazon-ssm-agent.service 
             │ ├─ 855 /snap/amazon-ssm-agent/6563/amazon-ssm-agent
             │ └─2297 /snap/amazon-ssm-agent/6563/ssm-agent-worker
             ├─systemd-journald.service 
             │ └─172 /lib/systemd/systemd-journald
```

obviously it's running on the healthy nodes:

```
[root@ip-10-0-37-87 kubernetes]# sudo systemctl status kubelet
● kubelet.service - Kubernetes Kubelet
   Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: disabled)
  Drop-In: /etc/systemd/system/kubelet.service.d
           └─10-kubelet-args.conf, 30-kubelet-extra-args.conf
   Active: active (running) since Tue 2023-05-30 22:04:37 UTC; 2 months 2 days ago
     Docs: https://github.com/kubernetes/kubernetes
  Process: 3099 ExecStartPre=/sbin/iptables -P FORWARD ACCEPT -w 5 (code=exited, status=0/SUCCESS)
 Main PID: 3117 (kubelet)
    Tasks: 24
   Memory: 221.9M
   CGroup: /system.slice/kubelet.service
           └─3117 /usr/bin/kubelet --cloud-provider aws --image-credential-provider-config /etc/eks/ecr-credential-provider/ecr-credential-provider-config --image-credential-provider-bin-dir /etc/eks/ecr-credential-provider --config /etc/kubernetes/kubelet/kubelet-config.json --kubeco...

Aug 02 13:14:43 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: I0802 13:14:43.496431    3117 scope.go:110] "RemoveContainer" containerID="1ab839879248a9e0212df3f0675d11b8fb008f346e27a3f0c7a80782d6a6b6eb"
Aug 02 13:14:43 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: E0802 13:14:43.497502    3117 pod_workers.go:965] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"haystack-api-api\" with CrashLoopBackOff: \"back-off 5m0s restarting failed container=haystac...
Aug 02 13:14:54 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: I0802 13:14:54.500209    3117 scope.go:110] "RemoveContainer" containerID="1ab839879248a9e0212df3f0675d11b8fb008f346e27a3f0c7a80782d6a6b6eb"
Aug 02 13:14:54 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: E0802 13:14:54.500634    3117 pod_workers.go:965] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"haystack-api-api\" with CrashLoopBackOff: \"back-off 5m0s restarting failed container=haystac...
Aug 02 13:15:06 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: I0802 13:15:06.497423    3117 scope.go:110] "RemoveContainer" containerID="1ab839879248a9e0212df3f0675d11b8fb008f346e27a3f0c7a80782d6a6b6eb"
Aug 02 13:15:06 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: E0802 13:15:06.498363    3117 pod_workers.go:965] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"haystack-api-api\" with CrashLoopBackOff: \"back-off 5m0s restarting failed container=haystac...
Aug 02 13:15:20 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: I0802 13:15:20.499096    3117 scope.go:110] "RemoveContainer" containerID="1ab839879248a9e0212df3f0675d11b8fb008f346e27a3f0c7a80782d6a6b6eb"
Aug 02 13:15:20 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: E0802 13:15:20.501228    3117 pod_workers.go:965] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"haystack-api-api\" with CrashLoopBackOff: \"back-off 5m0s restarting failed container=haystac...
Aug 02 13:15:35 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: I0802 13:15:35.496233    3117 scope.go:110] "RemoveContainer" containerID="1ab839879248a9e0212df3f0675d11b8fb008f346e27a3f0c7a80782d6a6b6eb"
Aug 02 13:15:35 ip-10-0-37-87.us-east-2.compute.internal kubelet[3117]: E0802 13:15:35.496846    3117 pod_workers.go:965] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"haystack-api-api\" with CrashLoopBackOff: \"back-off 5m0s restarting failed container=haystac...
Hint: Some lines were ellipsized, use -l to show in full.
```

```
[root@ip-10-0-37-87 kubernetes]# sudo systemctl status
● ip-10-0-37-87.us-east-2.compute.internal
    State: running
     Jobs: 0 queued
   Failed: 0 units
    Since: Tue 2023-05-30 22:04:11 UTC; 2 months 2 days ago
   CGroup: /
           ├─   1 /usr/lib/systemd/systemd --switched-root --system --deserialize 21
           ├─2957 bpfilter_umh
           ├─kubepods
           │ ├─pode68edf95-66ac-43a5-8929-939185ec966f
           │ │ ├─0b97ed0aa204860ff9fc7f8826df1bbff0af4820187db864eafaee3777860c50
           │ │ │ └─6760 /pause
           │ │ └─5195bdf8d2918198b72d6b9aa2898e0207789ebd1f229f1c1fa5d30c5de30339
           │ │   └─7901 /usr/lib/jvm/java-19-amazon-corretto/bin/java -XX:+ExitOnOutOfMemoryError -XX:MaxRAMPercentage=75.0 -classpath /app/airbyte-app/lib/io.airbyte-airbyte-server-0.50.8.jar:/app/airbyte-app/lib/io.airbyte-airbyte-commons-server-0.50.8.jar:/app/airbyte-app/lib/io.airby
           │ ├─burstable
           │ │ ├─podb985e321-e984-4ae5-bb5c-9e812ac1a405
           │ │ │ ├─4dc949a7cb993af2506aded50ae808161273722e0f71a2b0e86bcfe040e09e02
           │ │ │ │ ├─15307 /usr/bin/dumb-init -- /nginx-ingress-controller --publish-service=ingress-nginx/internal-ingress-nginx-controller --election-id=internal-ingress-controller-leader --controller-class=k8s.io/internal-ingress-nginx --ingress-class=k8s.io/internal-nginx --configmap
           │ │ │ │ ├─15462 /nginx-ingress-controller --publish-service=ingress-nginx/internal-ingress-nginx-controller --election-id=internal-ingress-controller-leader --controller-class=k8s.io/internal-ingress-nginx --ingress-class=k8s.io/internal-nginx --configmap=ingress-nginx/interna
           │ │ │ │ ├─17245 nginx: master process /usr/bin/nginx -c /etc/nginx/nginx.conf
           │ │ │ │ ├─20198 nginx: worker process                  
           │ │ │ │ ├─20199 nginx: worker process                  
           │ │ │ │ └─20200 nginx: cache manager process           
           │ │ │ └─66c7b1169705398d303be47cd03ef7045bfbe90f6433e18527c072d2555d9cc6
           │ │ │   └─14260 /pause
           │ │ ├─pod7ff2d5f4-c4b7-4731-9376-f3209c3723c1
           │ │ │ ├─c98e0c3025a1ca365162e152ec09073dacf8ed1940ffc2da077e031b19578b69
           │ │ │ │ └─21347 /bin/aws-ebs-csi-driver node --endpoint=unix:/csi/csi.sock --logging-format=text --v=2
           │ │ │ ├─1efec41aa060c6667d897db303029d8efce8ded7f00157de6de254be01174cbf
           │ │ │ │ └─6664 /livenessprobe --csi-address=/csi/csi.sock
           │ │ │ ├─fc603610c59ee6d64bde703d70026c316ddc2e44a9451c6d8c5aa64dc0eccea3
           │ │ │ │ └─6537 /csi-node-driver-registrar --csi-address=/csi/csi.sock --kubelet-registration-path=/var/lib/kubelet/plugins/ebs.csi.aws.com/csi.sock --v=2
           │ │ │ └─502b23a764b775a1eddf79d8bbb7cf1b49bee0269194983fb1366cb9ad532af0
           │ │ │   └─5809 /pause
           │ │ ├─podb928e976-11a6-45e7-8695-e5885e0e5893
           │ │ │ ├─7ffd8feae039ba119f2fe0b9608c04159fc2c75c26cd4ad68ce988a50017b638
           │ │ │ │ └─13301 /pause
           │ │ │ └─fb4a6466890d95bda1d98c63ce6b4d77523241289831ee1101c6d05e582be907
           │ │ │   └─20846 /harbor/harbor_core
           │ │ ├─podd275464c-e153-4a9c-93cc-a38e15d1acd7
           │ │ │ ├─f746203739f37d0122bfa0a7db8fafdce2e977e6873937ad60c74a24a23ed399
           │ │ │ │ └─15016 /pause
           │ │ │ └─aaaefe5ead681b58e5616637ba0adc0213e9795013fbd88131bbd6c45317e78d
```

healthy node envs:

```
[root@ip-10-0-37-87 kubernetes]# env
HOSTNAME=ip-10-0-37-87.us-east-2.compute.internal
KUBE_DNS_PORT_53_UDP_ADDR=172.20.0.10
KUBE_DNS_PORT_53_UDP_PROTO=udp
TERM=xterm
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT=tcp://172.20.0.1:443
KUBE_DNS_SERVICE_PORT=53
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_HOST=172.20.0.1
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.axa=01;36:*.oga=01;36:*.spx=01;36:*.xspf=01;36:
KUBE_DNS_SERVICE_PORT_DNS_TCP=53
KUBE_DNS_PORT_53_TCP_PORT=53
KUBE_DNS_PORT_53_TCP_PROTO=tcp
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PWD=/etc/kubernetes
KUBE_DNS_SERVICE_PORT_DNS=53
LANG=en_US.UTF-8
KUBE_DNS_PORT_53_UDP_PORT=53
KUBE_DNS_PORT=udp://172.20.0.10:53
KUBE_DNS_PORT_53_UDP=udp://172.20.0.10:53
HOME=/root
SHLVL=2
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBE_DNS_PORT_53_TCP_ADDR=172.20.0.10
LESSOPEN=||/usr/bin/lesspipe.sh %s
KUBERNETES_PORT_443_TCP_ADDR=172.20.0.1
KUBE_DNS_PORT_53_TCP=tcp://172.20.0.10:53
KUBE_DNS_SERVICE_HOST=172.20.0.10
KUBERNETES_PORT_443_TCP=tcp://172.20.0.1:443
_=/usr/bin/env
OLDPWD=/etc/kubernetes/node-feature-discovery
```

```
ubuntu@ip-10-0-19-85:~$ sudo snap logs kubelet-eks
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:                 Insecure values: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_ECDSA_WITH_RC4_128_SHA, TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_RSA_WITH_RC4_128_SHA, TLS_RSA_WITH_3DES_EDE_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA256, TLS_RSA_WITH_RC4_128_SHA. (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:       --tls-min-version string                                   Minimum TLS version supported. Possible values: VersionTLS10, VersionTLS11, VersionTLS12, VersionTLS13 (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:       --tls-private-key-file string                              File containing x509 private key matching --tls-cert-file. (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:       --topology-manager-policy string                           Topology Manager policy to use. Possible values: 'none', 'best-effort', 'restricted', 'single-numa-node'. (default "none") (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:       --topology-manager-scope string                            Scope to which topology hints applied. Topology Manager collects hints from Hint Providers and applies them to defined scope to ensure the pod admission. Possible values: 'container', 'pod'. (default "container") (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:   -v, --v Level                                                  number for the log level verbosity
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:       --version version[=true]                                   Print version information and quit
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:       --vmodule pattern=N,...                                    comma-separated list of pattern=N settings for file-filtered logging (only works for text log format)
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:       --volume-plugin-dir string                                 The full path of the directory in which to search for additional third party volume plugins (default "/usr/libexec/kubernetes/kubelet-plugins/volume/exec/") (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
2023-08-02T14:00:53Z kubelet-eks.daemon[11625]:       --volume-stats-agg-period duration                         Specifies interval for kubelet to calculate and cache the volume disk usage for all pods and volumes.  To disable volume calculations, set to a negative number. (default 1m0s) (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag. See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)
```


```
-- Logs begin at Wed 2023-08-02 13:54:28 UTC, end at Wed 2023-08-02 14:20:15 UTC. --
Aug 02 13:55:13 ip-10-0-19-85 systemd[1]: Started Service for snap application kubelet-eks.daemon.
Aug 02 13:55:16 ip-10-0-19-85 kubelet-eks.daemon[9402]: E0802 13:55:16.730812    9402 server.go:158] "Failed to parse kubelet flag" err="invalid argument \"plural.sh/sysbox=true:NO_SCHEDULE,plural.sh/capacityType=ON_DEMAND:NO_SCHEDULE\" for \"--register-with-taints\" flag: invalid taint>
Aug 02 13:55:16 ip-10-0-19-85 kubelet-eks.daemon[9402]: Usage:
```

```
ubuntu@ip-10-0-19-85:~$ sudo journalctl -u snap.kubelet-eks.daemon
-- Logs begin at Wed 2023-08-02 13:54:28 UTC, end at Wed 2023-08-02 14:20:15 UTC. --
Aug 02 13:55:13 ip-10-0-19-85 systemd[1]: Started Service for snap application kubelet-eks.daemon.
Aug 02 13:55:16 ip-10-0-19-85 kubelet-eks.daemon[9402]: E0802 13:55:16.730812    9402 server.go:158] "Failed to parse kubelet flag" err="invalid argument \"plural.sh/sysbox=true:NO_SCHEDULE,plural.sh/capacityType=ON_DEMAND:NO_SCHEDULE\" for \"--register-with-taints\" flag: invalid taint>
Aug 02 13:55:16 ip-10-0-19-85 kubelet-eks.daemon[9402]: Usage:
```
