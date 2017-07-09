from fabric.api import env

host1 = 'root@1.1.1.1'
host2 = 'root@1.1.1.2'

ext_routers = []
router_asn = 64512
host_build = host1

env.roledefs = {
    'all': [host1],
    'cfgm': [host1],
    'openstack': [host1],
    'control': [host1],
    'compute': [host2],
    'collector': [host1],
    'webui': [host1],
    'database': [host1],
    'build': [host_build],
    'storage-master': [host1],
    'storage-compute': [host1],
}

env.openstack_admin_password = 'secret123'
env.hostnames = {
    'all': ['localhost']
}

env.passwords = {
    host1: 'c0ntrail123',
    host2: 'c0ntrail123',
  #  backup_node: 'secret',
    host_build: 'c0ntrail123',
}

minimum_diskGB = 30
