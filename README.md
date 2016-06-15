dalias
======
Dynamic bash aliases (loosely based on [rbenv](https://github.com/rbenv/rbenv)).

Installation
------------
The simplest method is a git checkout:
```sh
$ git checkout https://github.com/t3hpr1m3/dalias.git ~/.dalias
$ echo 'export PATH="$HOME/.dalias/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval $(dalias init)' >> ~/.bash_profile
```

License
-------
*dalias* is released under the [MIT License](https://github.com/t3hpr1m3/dalias/blob/master/LICENSE).
