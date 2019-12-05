# Parsing a complex JSON response

The problem:

- rancher returns a list of running services for the stack
- we need to wait unitl all instances of specific service are stopped


How do we solve this?

* use built-in filters
    * It's good because it does not complicate things by introducing actual code
    * It's not very readable
    * You may start thinking of alternatives, if you plan to use something similiar elsewhere, eg. wait for different service

* write a simple custom filter
    * A major downside is complicating thigs, when we already have a native, working solution
    * Can be more usable if you are using similar filter pipe monsters in different places
    * Is definitely more readable from yaml perspective
    * Testable!


In order to run the demo:
```
pip install -r requirements.txt
python server.py&
ansible-playbook main.yml
```

In order to run the test:
```
python -m unittest filter_plugins/*.py
```