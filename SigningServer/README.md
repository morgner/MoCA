# nginx
## nginx.conf (partial)

Ensure the directory is present, writable for the flask user and the socket is rw for nginx

```nginx.conf
user nginx;

    server {
        listen       127.0.0.1:80;
        server_name  localhost;

	location / {
            try_files $uri @moca;
	}
	location @moca {
	    include uwsgi_params;
	    uwsgi_pass unix:/var/run/moca/moca.sock;
	}
    }
```


## SE Linux (like fedora)

```bash
setenforce 0
grep nginx /var/log/audit/audit.log | audit2allow -m nginx > nginx.te
grep nginx /var/log/audit/audit.log | audit2allow -M nginx
semodule -i nginx.pp
setenforce 1
#!usermod -a -G uswgi-user-name nginx
```
## Prepare signing-server

```bash
cd MoCA/SigningServer
virtualenv -p python2 env-moca
. env-moca/bin/activate 
pip install --editable .
pip install pyopenssl

./create-CA-ec.sh
```
# Run
## application

`./run.sh`

## uwsgi

For productive use, this script need to get some security adaptions:

`./urun.sh`

