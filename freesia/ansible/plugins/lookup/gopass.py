import os
import subprocess

import ansible


class LookupModule(ansible.plugins.lookup.LookupBase):
    def run(self, terms, variables, **kwargs):
        result = []
        for term in terms:
            cmd = ["gopass", "show", term]
            r = subprocess.run(cmd,
                               cwd=self._loader.get_basedir(),
                               env=os.environ.copy(),
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
            if r.returncode == 0:
                result.append(r.stdout.decode("utf-8").rstrip())
            else:
                raise ansible.errors.AnsibleError(
                    "lookup gopass({term}) returned {return_code}".format(
                        term=term, return_code=r.returncode))
        return result
