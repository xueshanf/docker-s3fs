docker-s3fs
===========

Docker build for s3fs v1.78. 

To run the image:

    docker pull xueshanf/s3fs
    docker run --rm --cap-add mknod --cap-add sys_admin --device=/dev/fuse -it xueshanf/s3fs

You are dropped to /bin/bash command inside of the container.

If the system is built on AWS with role-based IAM profile, you can run the s3fs like so:

    /usr/bin/s3fs -o allow_other -o use_cache=/tmp -o iam_role=<iam role> <bucket> <mountpoint>

Or save accessId:acessSecrect to a file, e.g. /root/.s3fs, then:

    chmod 400 /root/.s3fs
    /usr/bin/s3fs -o passwd_file=/root/.s3fs -o allow_other -o use_cache=/tmp <bucket> <mountpoint>

The s3fs mounted volumes (FUSE-based file system) in the container are not visiable from docker host through -v `<hostvol`>:`<containervol`> option, nor from other containsers through --volumes-from `<containername`>. 

Note
----

You need to add extra sys-capabilities to use fuse:

    --cap-add mknod --cap-add sys_admin --device=/dev/fuse

You can always run it with `--privileged`.  However this should be avoided if possible.  Run with the
more restricted set above.

See [Issue 6616](https://github.com/docker/docker/issues/6616).
