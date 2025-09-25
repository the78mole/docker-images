#!/bin/sh
#-------------------------------------------------------------------------------------------------------------
# Docker-in-Docker initialization script
# Based on: https://github.com/devcontainers/features/src/docker-in-docker/install.sh
#-------------------------------------------------------------------------------------------------------------

set -e

AZURE_DNS_AUTO_DETECTION=true
DOCKER_DEFAULT_ADDRESS_POOL=""
DOCKER_DEFAULT_IP6_TABLES=""

dockerd_start="AZURE_DNS_AUTO_DETECTION=${AZURE_DNS_AUTO_DETECTION} DOCKER_DEFAULT_ADDRESS_POOL=${DOCKER_DEFAULT_ADDRESS_POOL} DOCKER_DEFAULT_IP6_TABLES=${DOCKER_DEFAULT_IP6_TABLES} $(cat << 'INNEREOF'
    # explicitly remove dockerd and containerd PID file to ensure that it can start properly if it was stopped uncleanly
    find /run /var/run -iname 'docker*.pid' -delete || :
    find /run /var/run -iname 'container*.pid' -delete || :

    # -- Start: dind wrapper script --
    # Maintained: https://github.com/moby/moby/blob/master/hack/dind

    export container=docker

    if [ -d /sys/kernel/security ] && ! mountpoint -q /sys/kernel/security; then
        mount -t securityfs none /sys/kernel/security || {
            echo >&2 'Could not mount /sys/kernel/security.'
            echo >&2 'AppArmor detection and --privileged mode might break.'
        }
    fi

    # Mount /tmp (conditionally)
    if ! mountpoint -q /tmp; then
        mount -t tmpfs none /tmp
    fi

    set_cgroup_nesting()
    {
        # cgroup v2: enable nesting
        if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
            # move the processes from the root group to the /init group,
            # otherwise writing subtree_control fails with EBUSY.
            # An error during moving non-existent process (i.e., "cat") is ignored.
            mkdir -p /sys/fs/cgroup/init
            xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
            # enable controllers
            sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers \
                > /sys/fs/cgroup/cgroup.subtree_control
        fi
    }

    # Set cgroup nesting, if needed
    set_cgroup_nesting

    # -- End: dind wrapper script --

    # Handle DNS
    set +e
        cat /etc/resolv.conf | grep -i 'internal.cloudapp.net' > /dev/null 2>&1
        if [ $? -eq 0 ] && [ "${AZURE_DNS_AUTO_DETECTION}" = "true" ]
        then
            echo "Setting dockerd Azure DNS."
            CUSTOMDNS="--dns 168.63.129.16"
        else
            echo "Not setting dockerd DNS manually."
            CUSTOMDNS=""
        fi
    set -e

    if [ -z "$DOCKER_DEFAULT_ADDRESS_POOL" ]
    then
        DEFAULT_ADDRESS_POOL=""
    else
        DEFAULT_ADDRESS_POOL="--default-address-pool $DOCKER_DEFAULT_ADDRESS_POOL"
    fi

    # Start docker/moby engine
    ( dockerd $CUSTOMDNS $DEFAULT_ADDRESS_POOL $DOCKER_DEFAULT_IP6_TABLES > /tmp/dockerd.log 2>&1 ) &
INNEREOF
)"

sudo_if() {
    COMMAND="$*"

    if [ "$(id -u)" -ne 0 ]; then
        if type sudo > /dev/null 2>&1; then
            sudo $COMMAND
        elif type su > /dev/null 2>&1; then
            su -c "$COMMAND"
        else
            echo "(!) No sudo or su available! Attempting to run as-is..."
            eval "$COMMAND"
        fi
    else
        eval "$COMMAND"
    fi
}

# Log whether this script is being run as root
if [ "$(id -u)" -eq 0 ]; then
    echo "(*) Script is running as root"
    user_name=$(cat /etc/passwd | grep ":1000:" | cut -d: -f1)
    if [ -n "$user_name" ]; then
        echo "(*) Default user detected: $user_name"
    fi
else
    echo "(*) Script is running as non-root user: $(id -un)"
fi

retry_docker_start_count=0
while [ $retry_docker_start_count -lt 3 ]; do
    set +e
    eval "$dockerd_start"

    # Wait for docker to be ready
    retry_count=0
    while [ $retry_count -lt 30 ]; do
        sleep 1
        docker info > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Docker daemon is ready"
            break
        fi
        retry_count=$((retry_count + 1))
        echo "Waiting for Docker daemon... ($retry_count/30)"
    done

    set -e
    
    # Check if daemon is running properly
    if docker info > /dev/null 2>&1; then
        echo "Docker daemon started successfully"
        break
    else
        echo "Docker daemon failed to start (attempt $((retry_docker_start_count + 1))/3)"
        set +e
            sudo_if pkill dockerd
            sudo_if pkill containerd
        set -e
    fi

    retry_docker_start_count=$((retry_docker_start_count + 1))
done

if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker daemon failed to start after 3 attempts"
    exit 1
fi

# Execute whatever commands were passed in (if any). This allows us
# to set this script to ENTRYPOINT while still executing the default CMD.
exec "$@"