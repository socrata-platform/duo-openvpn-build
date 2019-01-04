Duo-OpenVPN Build Project
=========================
[![Build Status](https://img.shields.io/travis/socrata-platform/duo-openvpn-build.svg)][travis]

[travis]: https://travis-ci.org/socrata-platform/duo-openvpn-build

A project for packaging the Duo OpenVPN plugin.

This project currently builds packages for Ubuntu 18.04/16.04/14.04 and
RHEL/CentOS/Scientific/etc. 7.

Requirements
------------

This project is distributed as a Chef cookbook that contains an FPM Cookery
packaging recipe. This allows for automated builds in Vagrant or Docker
environments using Test Kitchen.

Usage
-----

The included Test Kitchen config handles all the builds automatically for the
supported platforms. Normally, these builds will be kicked off and run on the
CI server, which will use Test Kitchen to assemble new packages, install them,
verify them, and publish them to PackageCloud.io.

Should the need arise, `fpm-cook` commands can still be run from the project
directory in `files/default/fpm-recipes`.

Recipes
-------

***default***

Configures the included helper libraries and ties the below recipes together.

***_build***

Installs build dependencies and runs `fpm-cook`.

***_verify***

Installs the newly-built package and runs a set of ServerSpec tests against it.

***_deploy***

If an attribute is set to enable it, uploads the artifact to PackageCloud.io.

Libraries
---------

***helpers***

Helper methods for interacting with the PackageCloud API and handling the
generated package files.

Attributes
----------

***default***

Includes attributes for enabling artifact publishing, a PackageCloud API token,
and the package version and revision to use in the build.

Contributing
------------

Pull requests are welcome!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for the new feature; ensure they pass (`rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

License & Authors
=================
- Author: Jonathan Hartman <jonathan.hartman@tylertech.com>

Copyright 2016, Tyler Technologies

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
