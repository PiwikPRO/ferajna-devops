### dbdeployer
- sandbox for MySQL/MariaDB/Percona
- clusters: PXC/InnoDB/NDB/TiDB
- operate on tarballs
- remote donwload
- cookbooks
- replication topology
- simple usage


### MySQL shell
- advanced client
- processes code in the following languages: JavaScript, Python and SQL.
- provides an integrated solution for InnoDB Cluster
- sandbox deployment of InnoDB Cluster

### MySQL clone plugin
- physical snapshot of data stored in InnoDB
- locally or remotely 
- very simple and fast!
```
db-1:
INSTALL PLUGIN CLONE SONAME "mysql_clone.so"; 
SHOW PLUGINS;
CREATE USER clone_user IDENTIFIED BY "clone_password";
GRANT BACKUP_ADMIN ON *.* to clone_user;
GRANT SELECT ON performance_schema.* TO clone_user;
GRANT EXECUTE ON *.* to clone_user;

db-2:
INSTALL PLUGIN CLONE SONAME "mysql_clone.so"; 
SHOW PLUGINS;
CREATE USER clone_user IDENTIFIED BY "clone_password";
GRANT CLONE_ADMIN ON *.* to clone_user;
GRANT SELECT ON performance_schema.* TO clone_user;
GRANT EXECUTE ON *.* to clone_user;
SET GLOBAL clone_valid_donor_list = "127.0.0.1:25718"; 

#
CLONE INSTANCE FROM clone_user@127.0.0.1:25718 IDENTIFIED BY "clone_password";

# replication
SELECT BINLOG_FILE, BINLOG_POSITION FROM performance_schema.clone_status;
CHANGE MASTER TO MASTER_HOST = '127.0.0.1', MASTER_PORT = 25718,MASTER_USER='root',MASTER_PASSWORD='msandbox',master_log_file='mysql-bin.000001',master_log_pos=2739174;

```
- benchmark: https://mydbops.wordpress.com/2019/11/14/mysql-clone-plugin-speed-test/

### InnoDB Cluster
- automatic failover
- multi-master capabilities
- proxysql support

#### MySQL shell sandboxes
```
dba.help()
# create mysql sandbox
dba.deploySandboxInstance(1111);
dba.deploySandboxInstance(2222);
dba.deploySandboxInstance(3333);

# create InnoDB custer
shell.connect("root:root@127.0.0.1:1111")
dba.checkInstanceConfiguration("root:root@127.0.0.1:1111")
cluster= dba.createCluster("Test");
cluster.help()
cluster.status()

# add node
dba.addInstance("root:root@127.0.0.1:2222")
dba.addInstance("root:root@127.0.0.1:3333")
cluster.status()
```

#### dbdeployer
```
dbdeployer cookbook list
dbdeployer cookbook  create replication_single_group
recipes/replication-single-group.sh
./mysqlsh (on node1)
dba.createCluster("Test")
cluster = dba.getCluster()
cluster.status()

# create new single instance
dbdeployer deploy single 8.0.17
dbdeployer sandboxes

# from InnoDB cluster mysqlsh
# create additional user cluster_admin with pass cluster_admin
dba.configureInstance("root:msandbox@localhost:8017")
dba.checkInstanceConfiguration("cluster_admin:cluster_admin@127.0.0.1:8017");
```
