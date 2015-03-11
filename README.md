# Installation:

```shell
git clone git@github.com:dpeek/hvm.git ~/.hvm
echo "source ~/.hvm/hvm.sh" >> ~/.profile
source ~/.profile
hvm install
```

# What does it do?

Running `hvm install` creates these symlinks:

```shell
sudo ln -sf ~/.vhm/haxe.sh /usr/bin/haxe
sudo ln -sf ~/.vhm/haxelib.sh /usr/bin/haxelib
sudo ln -sf ~/.vhm/neko.sh /usr/bin/neko
sudo ln -sf ~/.vhm/nekotools.sh /usr/bin/nekotools
sudo ln -sf ~/.vhm/nekoc.sh /usr/bin/nekoc
sudo ln -sf ~/.vhm/nekoml.sh /usr/bin/nekoml
```

Each of those scripts sources `config.sh`, which figures out which binary to use.

The config sources `~/.hvm/versions.sh`, then `~/.hvm/current.sh` and then `./hvmrc` if it exists. The first defines default versions, the second defines the currently selectec global versions (as set with `hvm use`) and the third allows projects to specify specific versions to use.

The config script uses the versions to determine the path to the right install, located in `~/.hvm/versions/$(neko|haxe|haxelib)/$version`. If that path does not exist, hvm will install it.

Stable versions of Neko are installed from the [here](http://nekovm.org/download) while dev versions are installed from [here](http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/neko/mac/).

Stable versions of Haxe are installed from the [here](http://old.haxe.org/file/) while dev versions are installed from [here](http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/mac/).

Stable versions of Haxelib are installed from the [here](http://lib.haxe.org/p/haxelib_client) while dev versions are installed from [here](https://github.com/HaxeFoundation/haxelib).

To set the current global version in `~/.hvm/current.sh`, run:

```shell
hvm use $tool $version
```

Where `$tool` is one of `neko`, `haxe` or `haxelib` and `$version` is either `dev` for the latest development release, or a released version. An error will be printed if you specify a version that does not exist.

If you run `hvm use $tool dev` the currently installed `dev` version of `$tool` will be deleted so that the next time you run the tool `dev` will be reinstalled.

Note that tools are only installed on demand, so if you run `haxe` and the current specified version is not installed hvm will install it.

