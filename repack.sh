# run an instance of the Docker image
CONTAINER_ID=$(sudo docker run -d ubuntulive:image /usr/bin/tail -f /dev/null)
# delete the auto-created .dockerenv marker file so it doesn't end up in the squashfs image
sudo docker exec "${CONTAINER_ID}" rm /.dockerenv
# extract the Docker image contents to a tarball
sudo docker cp "${CONTAINER_ID}:/" - > newfilesystem.tar
# get the package listing for installation from ISO
sudo docker exec "${CONTAINER_ID}" dpkg-query -W --showformat='${Package} ${Version}\n' > newfilesystem.manifest
# kill the container instance of the Docker image
sudo docker rm -f "${CONTAINER_ID}"
# convert the image tarball into a squashfs image
tar2sqfs --quiet newfilesystem.squashfs < newfilesystem.tar

# create a directory to build the ISO from
mkdir iso

# extract the contents of the ISO to the directory, except the original squashfs image
# UBUNTU_ISO_PATH=path to the Ubuntu live ISO downloaded earlier
7z x '-xr!filesystem.squashfs' -oiso "ubuntu-20.04.iso"

# copy our custom squashfs image and manifest into place
cp newfilesystem.squashfs iso/casper/filesystem.squashfs
stat --printf="%s" iso/casper/filesystem.squashfs > iso/casper/filesystem.size
cp newfilesystem.manifest iso/casper/filesystem.manifest

# remove obsolete files
rm iso/casper/filesystem.squashfs.gpg

# remove installer.squashfs
rm iso/casper/installer.squashfs installer.squashfs.gpg

# add in our grub file
cp grub.cfg iso/boot/grub/

# update state files
(cd iso; find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt)

# build the ISO image using the image itself
sudo docker run \
    -it \
    --rm \
    -v "$(pwd):/app" \
    ubuntulive:image \
    grub-mkrescue -v -o /app/remoterecover.iso /app/iso/ -- -volid RemoteRecoverLiveCD

