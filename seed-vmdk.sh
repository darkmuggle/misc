#!/bin/bash

# Temp place for creating the meta-data
seed_d=$(mktemp -d)

# Create the default user-data
cat >> ${seed_d}/user-data <<"END"
#cloud-config
ssh_authorized_keys:
    - <KEY>
END

# Create the fake meta-data
cat >> ${seed_d}/meta-data <<END
instance-id: $(uuidgen)
local-hostname: ubuntu-vmware
END

# To make the cloud-config big enough, otherwise VMDK won't import
dd if=/dev/zero of=${seed_d}/bloat_file bs=1M count=10

# Create the ISO
genisoimage \
    -output seed.iso \
    -volid cidata \
    -joliet -rock \
    ${seed_d}/user-data \
    ${seed_d}/meta-data \
    ${seed_d}/bloat_file ||
        fail "Failed to create seed.iso"

# Make a VMDK out of the seed file
qemu-img convert -O vmdk seed.iso seed.vmdk

