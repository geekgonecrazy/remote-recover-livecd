# Remote Recover LiveCD

This is provided as-is.  Basically to document for my self in case I ever need to do it again.  It solved a need for me to be able to gain access to a remote machine over 450 miles (~720km) and reset the admin password for a family member that didn't have any other way to get into their machine.

Some disclaimers:
1. Only tested creation on ubuntu
2. Several security concerns.. this should be a quick use sort of thing not a permanent setup.
3. Expects they can hardwire via ethernet to router and have DHCP on router

### Generate ssh-key
We need to generate a pre-shared key

```
ssh-keygen -t rsa -f baked-in-key
```

### Prepare Ubuntu 20.04 server iso for modification

Now we need to a few things.
1. Install some dependencies
1. Download the Ubuntu 20.04 server iso
2. Extract the main filesystem squashfs from the iso
3. Import that filesystem into docker so we can extend it easily

```
./prepare.sh
```

### Use docker to make modifications

Now that its loaded in to docker as `ubuntulive:base` we can use the Dockerfile to extend that and make modifications to it.

Once you have added any further changes you want:
```
docker build -t ubuntulive:image .
```

### Configure

Edit `remote-recover.service` and set the environment variables to point to some dns address your server will look at

### Repack into iso

Now that we have the image like we want it thanks to Docker we need to squash it back up and put it back in an ISO

```
./repack.sh
```

### Prepare the server

Create a user for them. Ideally lock the user down so they can't open a shell but can still expose their local port.

Copy the `baked-in-key.pub` contents into that users `./ssh/authorized_keys` file and chown and chmod 0600 that file.

### Ship to remote user

Now burn to CD or load on a flash drive.  Found that [rufus](https://rufus.ie) did a great job.

### Get the connection

Pop CD or flash drive in and have them spam f12 (or the key for boot menu on that hardware)

Select the USB Storage

### Access their machine

Once they get to the login screen.. on the VPS they are pointing to do:

```
ssh -i baked-in-key -p 43002 root@localhost
```

Now you should be able to work as if you are at the keyboard
