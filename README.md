docker-s3fs
===========

Docker build for s3fs v1.78. 

* To run the image:

        docker pull xueshanf/s3fs
        docker run --rm --cap-add mknod --cap-add sys_admin --device=/dev/fuse -it xueshanf/s3fs

  You are dropped to /bin/bash command inside of the container.

  If the system is built on AWS with role-based IAM profile, you can run the s3fs like so:

        /usr/bin/s3fs -o allow_other -o use_cache=/tmp -o iam_role=<iam role> <bucket> <mountpoint>

  Or save accessId:acessSecrect to a file, e.g. /root/.s3fs, then:

        chmod 400 /root/.s3fs
        /usr/bin/s3fs -o passwd_file=/root/.s3fs -o allow_other -o use_cache=/tmp <bucket> <mountpoint>

  The bucket name should not be in s3://.. format, otherwise you get Transport endpoint is not connected error. 

* Usage exmaple

 s3fs mounted volumes (FUSE-based file system) in the container are not visiable from docker host through -v `<hostvol`>:`<s3fsvol`> option, nor from other containsers through --volumes-from `<containername`>.

  However, you can still copy data out and make it available on the docker hosts and other containers. Here is an example.

  Mount an entire bucket and copy files to a bind-mount volume _/opt/data_ on host:

        docker run --rm --cap-add mknod --cap-add sys_admin --device=/dev/fuse -v /opt/data:/data -it xueshanf/s3fs
        /usr/bin/s3fs -o allow_other -o use_cache=/tmp -o iam_role=controller mybucket /mnt
        cp -r /mnt/ /data
    
  To umount:

        umount /mnt
        
* Debugging mount problems

         /usr/bin/s3fs -f -d -o allow_other -o use_cache=/tmp -o iam_role=<iam role> <bucket> <mountpoint>

* Note
----

  You need to add extra sys-capabilities to use fuse:

        --cap-add mknod --cap-add sys_admin --device=/dev/fuse

  You can always run it with `--privileged`.  However this should be avoided if possible.  Run with the
  more restricted set above.

  See [Issue 6616](https://github.com/docker/docker/issues/6616).
