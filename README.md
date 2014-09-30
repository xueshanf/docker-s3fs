docker-s3fs
===========

Docker build for s3fs v1.78. 

To run the image:

    docker pull xueshanf/s3fs
    docker run --rm --privileged=true -it xueshanf/s3fs

You are dropped to /bin/bash command inside of the container.

If the system is built on AWS with role-based IAM profile, you can run the s3fs like so:

    /usr/bin/s3fs -o allow_other -o use_cache=/tmp -o iam_role=<iam role> <mybucker> <mountpoint>

Or save accessId:acessSecrect to a file, e.g. /root/.s3fs, then:

    chmod 400 /root/.s3fs
    /usr/bin/s3fs -o passwd_file=/root/.s3fs -o allow_other -o use_cache=/tmp -o <budket> <mountpoint>

The s3fs mounted volumes (FUSE-based file system) in the container are not visiable from docker host through -v <hostvol>:<containervol> option, nor from other containsers through --volumes-from <containername>. 
    
It is not possible to run the container without --privileged=true mode. It may change in future. See some discussions [here](https://github.com/docker/docker/pull/4833).

