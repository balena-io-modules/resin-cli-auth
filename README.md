resin-cli-auth
--------------

[![npm version](https://badge.fury.io/js/resin-cli-auth.svg)](http://badge.fury.io/js/resin-cli-auth)
[![dependencies](https://david-dm.org/resin-io/resin-cli-auth.png)](https://david-dm.org/resin-io/resin-cli-auth.png)
[![Build Status](https://travis-ci.org/resin-io/resin-cli-auth.svg?branch=master)](https://travis-ci.org/resin-io/resin-cli-auth)
[![Build status](https://ci.appveyor.com/api/projects/status/mdi6ogfrmu6ef5dn/branch/master?svg=true)](https://ci.appveyor.com/project/resin-io/resin-cli-auth/branch/master)

Join our online chat at [![Gitter chat](https://badges.gitter.im/resin-io/chat.png)](https://gitter.im/resin-io/chat)

Resin.io CLI authentication handler.

Role
----

The intention of this module is to provide a mechanism for the Resin CLI to automatically exchange the session token with the Resin.io web application.

**THIS MODULE IS LOW LEVEL AND IS NOT MEANT TO BE USED BY END USERS DIRECTLY**.

Unless you know what you're doing, use the [Resin CLI](https://github.com/resin-io/resin-cli) instead.

Installation
------------

Install `resin-cli-auth` by running:

```sh
$ npm install --save resin-cli-auth
```

Documentation
-------------

<a name="module_auth.login"></a>
### auth.login() ⇒ <code>Promise</code>
This function opens the user's default browser and points it
to the Resin.io dashboard where the session token exchange will
take place.

Once the the token is retrieved, it's automatically persisted.

**Kind**: static method of <code>[auth](#module_auth)</code>  
**Summary**: Login to the Resin CLI using the web dashboard  
**Access:** public  
**Fulfil**: <code>String</code> - session token  
**Example**  
```js
auth.login().then (sessionToken) ->
  console.log('I\'m logged in!')
  console.log("My session token is: #{sessionToken}")
```

Support
-------

If you're having any problem, please [raise an issue](https://github.com/resin-io/resin-cli-auth/issues/new) on GitHub and the Resin.io team will be happy to help.

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/resin-io/resin-cli-auth/issues](https://github.com/resin-io/resin-cli-auth/issues)
- Source Code: [github.com/resin-io/resin-cli-auth](https://github.com/resin-io/resin-cli-auth)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

License
-------

The project is licensed under the Apache 2.0 license.
