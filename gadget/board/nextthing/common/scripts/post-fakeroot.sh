#!/bin/bash -ex

echo "##############################################################################"
echo "## $0 "
echo "##############################################################################"

echo "# PWD=$PWD"
echo "# BASE_DIR=$BASE_DIR"


## Move modifiable data to /data and make the output tar
## before removing the local content
TARGET_RO_DIR="${BASE_DIR}/target_ro"

TMP_DIR=$(mktemp -d)
TMP_DATA="${TMP_DIR}/data"
DATA_ETC="${TMP_DATA}/etc"
DATA_VAR="${TMP_DATA}/var"
DATA_ROOT="${TMP_DATA}/root"

echo "# TARGET_RO_DIR=${TARGET_RO_DIR}"

rm -rf "${TARGET_RO_DIR}"
cp -al "${TARGET_DIR}" "${TARGET_RO_DIR}"
mkdir -p "${TARGET_RO_DIR}/data"

mkdir -p "${DATA_ETC}/docker"
mkdir -p "${DATA_ROOT}"

pushd "${TARGET_RO_DIR}/etc"
mv ssh "${DATA_ETC}/ssh"
mv dnsmasq.conf "${DATA_ETC}/"
ln -sf ../data/etc/ssh ssh
ln -sf ../data/etc/dnsmasq.conf dnsmasq.conf
ln -sf ../data/etc/docker docker
popd

pushd "${TARGET_RO_DIR}/"

mv var "${TMP_DATA}/"

INJECT_ARCHIVE="${BINARIES_DIR}/inject.tar"
mkdir -p "${TMP_DATA}"
if [[ -f "${INJECT_ARCHIVE}" ]]; then
echo "## found gadget project to inject..."
pushd "${TMP_DATA}"
tar xf "${INJECT_ARCHIVE}"
popd
fi

ln -sf data/var var
mkdir -p "${DATA_VAR}/lib/gadget"
mkdir -p "${DATA_VAR}/lib/docker"
mkdir -p "${DATA_VAR}/empty"


pushd "${TMP_DATA}/"
ln -sf ../tmp tmp
ln -sf ../run run
popd

ls -lsah "${TARGET_RO_DIR}/root/.ssh"
mv ${TARGET_RO_DIR}/root/.ssh ${DATA_ROOT}/
ls -lsah ${DATA_ROOT}/.ssh/authorized_keys
chmod 0600 ${DATA_ROOT}/.ssh/authorized_keys
pushd ${TARGET_RO_DIR}/root
ln -sf ../data/root/.ssh .ssh
popd

popd

# Create tar ball for ro rootfs
echo "# generating '${BINARIES_DIR}/rootfs_ro.tar'..."
tar -C "${TARGET_RO_DIR}" -c -f "${BINARIES_DIR}/rootfs_ro.tar" .

# Create tar ball for writable partition
echo "# generating '${BINARIES_DIR}/data.tar'..."
tar -C "${TMP_DATA}" -c -f "${BINARIES_DIR}/data.tar" .

# Cleanup
rm -rf "${TMP_DIR}"
