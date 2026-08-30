once the server boots you have to make a username
`sudo tctl users add bowyn --roles=access,editor --logins=root,johndoe` after
that go to 192.168.1.11 https

to add a token that can be used to join any host statically run the following
commands

openssl rand -hex 32

````cat <<'EOF' | sudo tctl create -f -
kind: token
version: v2
metadata:
  name: 3f9a...your-hex...c21
spec:
  roles: [Node]
  join_method: token
EOF```
````

then verify

sudo tctl tokens ls
