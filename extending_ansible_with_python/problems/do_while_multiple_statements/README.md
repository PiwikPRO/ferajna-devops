# Running do-while loop on several dependent tasks

A problem: 
* We have two API endpoints
* We need to call first one, get some intermediate result (like token that can expire in several seconds) and call second one
* We should retry from scratch if the second one fails

How to do this in Ansible?
* If it would be a single task, we could use until
```
- shell: /usr/bin/foo
  register: result
  until: result.stdout.find("all systems go") != -1
  retries: 5
  delay: 10
```

* We can try approach with `block`, but it turns out it does not work, you can not put `until` on `block` statements. 
    * https://github.com/ansible/ansible/issues/46203

* We try with include, but this does not work neither, it silently does only one loop or crashes with error, depending on ansible version.

* Recursive include works, but does not seem to be very ellegant.

* We can also write a module, the output is more readable, the module is reusable and easily configurable, the configuration can be validated. It adds a whole new layer of complexity, but sometimes it may be worth giving a try.


In order to run the demo:
```
pip install -r requirements.txt
python server.py&
ansible-playbook main.yml
```
