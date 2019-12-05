# Testing API calls with molecule

Problem:

Our tasks include some specific logic:
* First we obtain a list of apps
* We delete all but the first one

Writing this using `uri` module is fairly simple.

But how to test this with molecule without the actual service?

**Write a mock!**

Mocking web servers using flask:
* Allows to test your ansible modules against living APIs
* Flask is so simple that it requires no additional config
* Google-driven development works flawlessly


In order to run the demo:
```
pip install -r requirements.txt
molecule test -s apps
```