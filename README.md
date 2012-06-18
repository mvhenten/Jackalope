# Jackalope
**Javascript with antlers**

## Introduction

Jackalope is a class extension system with an API based entirely on Moose, the
post-modern class system for perl.

Jackalope is written in Coffeescript, and has primarily been written with a
server-side environment in mind. That being said, Coffeescript **is just javascript**
so Jackalope should be fairly portable.

Implementation is kept as close to the Moose API as is in Javascript sane, and
possible. Fortunately, surprisingly little trickery is needed to implement a nearly identical
vocabulary and appearance usage using basic Javascript techniques.

## Usage

Jackalope comes in two flavours: as a base class for coffeescript objects to extend from,
and as set of mixins that extend your object on the fly.

It does not mess with your constructor or any other properties of our object, but
offers a factory method for constructing instead, as well as new object methods
to declare attributes.

**Using `Jackalope.Class` class as a base-class in Coffeescript**
```coffeescript
Jackalope = require('../lib/Jackalope')

class Circle extends Jackalope.Class
    @has 'radius',
        isa:        'Int'
        required:   true
        writer:     'setRadius'
        trigger: ( value ) ->
            @clearCircumference()
        
    @has 'circumference',
        isa:        'Number'
        lazy_build: true
        clearer: '  clearCircumference'

    _build_radius: () ->
        return (2 * @diameter()) * Math.PI
    
```

** alternative using mixin (works for non-Coffeescript classes**
```coffeescript
Foo = ()->
    # things in constructor
    
Jackalope.extend Foo

Foo.has 'name',
    isa: 'Str'
    default: 'Bar'

foo = Foo.create()
```
        



