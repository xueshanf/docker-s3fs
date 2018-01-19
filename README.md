docker-s3fs
===========

**[S3fs][s3fs]** docker build for version 1.83.

- [Docker engine after 1.10](#docker-egnine-after-1.10)
- [Docker engine before 1.10](#docker-engine-before-1.10)

### <a name="docker-engine-after-1.10" ></a> Docker engine after 1.10

Docker engine 1.10 added a new feature which allows containers to share the host mount namespace. This feature makes it possible to mount a s3fs container file system to a host file system through a shared mount, providing a persistent network storage with S3 backend.

**Prerequsites**

* Docker engine 1.10.x
* If the docker service is managed by systemd, you need to remove __MountFlags=slave__. See [issue](https://github.com/docker/docker/pull/22806). Example to fix this on CoreOS:

		# cp /usr/lib/systemd/system/docker.service /etc/systemd/system/
		# sed -i 's/MountFlags=slave/#MountFlags=slave/' /etc/systemd/system/docker.service
		# systemctl daemon-reload
		# systemctl restart docker.service

* Make a shared mountpoint on host

		# mkdir /mnt/mydata
		# mount --bind /mnt/mydata /mnt/mydata
		# mount --make-shared /mnt/mydata
		# findmnt -o TARGET,PROPAGATION /mnt/mydata
		TARGET            PROPAGATION
		/mnt/mydata		 shared

* Create AWS credential file (or use role-based crentials)

		# echo "<accessId>:<acessSecrect>" > /root/.s3fs
		# chmod 400 /root/.s3fs

**Run the S3fs container**

**As a systemd service**

Create a systemd unit /etc/systemd/system/s3fs.service with the following content:

	[Unit]
	Description=S3fs Service

	[Service]
	ExecStartPre=-/usr/bin/docker kill %n
	ExecStartPre=-/usr/bin/docker rm %n
	ExecStart=/usr/bin/docker run --rm --name %n -v /root/.s3fs:/root/.s3fs --security-opt apparmor:unconfined --cap-add mknod --cap-add sys_admin --device=/dev/fuse -v /mnt/mydata:/m
	nt/mydata:shared xueshanf/s3fs /usr/bin/s3fs -f -o allow_other -o use_cache=/tmp -o passwd_file=/root/.s3fs <bucket> /mnt/mydata
	TimeoutStartSec=5min
	ExecStop=-/usr/bin/docker stop %n
	RestartSec=5
	Restart=always

It is important to use the **-f** flag to keep the s3fs container running in foreground.

Start the unit:

	# systemctl start s3fs.service

Now you should be able to see file system under /mnt/mydata on host. Changes you make there will be reflected on the S3 bucket, and shared by other hosts using the system s3fs.service unit.

Note that, if you previously created the files in the S3 bucket with other tools such as s3cmd, awscli, the s3fs file system won't be able to get file ownership and mode correctly. You will see directories listed with permissions like  "d------". To fix this, you can correct the permissions under /mnt/mydata on host. s3fs will re-upload s3fs specific z-amz-metadata-* headers.

**With docker-compose**

Get [docker-compose](https://docs.docker.com/compose/install/)

Create a shared mount on the host as described above.

You can use the `docker-compose.yml` for starting the s3fs container with a simple command

	docker-compose up -d

You have to edit it first and set `AWSACCESSKEYID` and `AWSSECRETACCESSKEY` and replace `S3_BUCKET_NAME` with the name of your S3 bucket.

For mounting the S3 folder into other containers, you have to define the host mount path as a volume. `volumes-from` does _not_ work with a FUSE-based mount.
So this way the s3fs container mounts the S3 bucket to a folder on the host which is then mapped into other containers.

### <a name="docker-engine-before-1.10" ></a> Docker engine before 1.10

Before Docker version 1.10, s3fs mounted volumes (FUSE-based file system) in the container are not visiable from docker host through -v `<hostvol`>:`<s3fsvol`> option, nor from other containsers through --volumes-from `<containername`>.  However, you can still copy data out and make it available on the docker hosts and other containers.

The following examples show how to start s3fs container with EC2 IAM role-based credential or with an IAM user that has permission to access your AWS s3 bucket.

Note: You should not include _s3://_ in the bucket name, otherwise, you get _Transport endpoint is not connected error_.

* Run the image with IAM role-based credential

        docker pull xueshanf/s3fs
        docker run --rm --name s3fs-container --cap-add mknod --cap-add sys_admin --device=/dev/fuse xueshanf/s3fs /usr/bin/s3fs -o allow_other -o use_cache=/tmp -o iam_role=<role name> <bucket> /mnt/mydata

* Run the image as an IAM user

		$ cat accessId:acessSecrect > /root/.s3fs
		$ chmod 400 /root/.s3fs
		$ docker run -v /root/.s3fs:/root/.s3fs --name s3fs-container --rm --cap-add mknod --cap-add sys_admin --device=/dev/fuse xueshanf/s3fs /usr/bin/s3fs -o allow_other -o use_cache=/tmp -o passwd_file=/root/.s3fs <bucket> /mnt/mydata

Keep the container running in the above foreground window, start another terminal to run the following example operations.

  * List file system and copy a file

 		$ docker exec s3fs-container ls /mnt/mydata
 		$ docker exec s3fs-container cat /mnt/mydata/file1 > /tmp/file1

* Mount an entire bucket and copy files to a bind-mount volume _/opt/data_ on host:

        $ docker run --rm --cap-add mknod --cap-add sys_admin --device=/dev/fuse -v /root/.s3fs:/root/.s3fs -v /opt/data:/data -it xueshanf/s3fs
        root@88c090451cce:/# /usr/bin/s3fs -o allow_other -o use_cache=/tmp -o iam_role=controller mybucket /mnt/mydata
        cp -r /mnt/mydata /data
        umount /mnt/mydata
        exit

* Debugging mount problems

         /usr/bin/s3fs -f -d -o allow_other -o use_cache=/tmp -o iam_role=<iam role> <bucket> <mountpoint>

Note
----

  You need to add extra sys-capabilities to use fuse:

        --cap-add mknod --cap-add sys_admin --device=/dev/fuse

  You can always run it with `--privileged`.  However this should be avoided if possible.  Run with the more restricted set above.

  See [Issue 6616](https://github.com/docker/docker/issues/6616).

[s3fs]: https://github.com/s3fs-fuse/s3fs-fuse
