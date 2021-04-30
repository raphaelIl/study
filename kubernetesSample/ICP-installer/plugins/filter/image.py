def rreplace(s, old, new, occurrence):
    li = s.rsplit(old, occurrence)
    return new.join(li)

def image_name(arch, name):
    if arch == 'x86_64':
        return name
    else:
        # ibmcom/etcd:v3.1.5 => ibmcom/etcd-ppc64le:v3.1.5
        # mycluster.icp:8500/etcd:v3.1.5 => mycluster.icp:8500/etcd-ppc64le:v3.1.5
        return rreplace(name, ':', '-' + arch + ':', 1)

class FilterModule(object):

    def filters(self):
        return {'image_name': image_name}
