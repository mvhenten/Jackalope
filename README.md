# Jackalope
**Javascript with antlers**

## Introduction

Jackalope is a class extension system with an API based entirely on Moose, the post-modern class system for perl.Jackalope is written in Coffeescript, and has primarily been written with a server-side environment in mind.

That being said, Coffeescript **is just javascript** so Jackalope should be fairly portable. Implementation is kept as close to the Moose API as is in Javascript sane, and possible. Fortunately, surprisingly little trickery is needed to implement a nearly identical vocabulary and appearance usage using basic Javascript techniques.

## Usage

Jackalope comes in two flavours: as a base class for coffeescript objects to extend from, and as set of mixins that extend your object on the fly. The `Jackalope.Class` offers a base class with constructor that initializes
attributes when needed.

The `Jackalope.extend` function mixes Jackalope features into your object. It does not mess with your constructor or any other properties of our object, but offers a factory method for constructing instead, as well as new object methods to declare attributes.

*Using `Jackalope.Class` class as a base-class in Coffeescript*
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

    _build_circumference: () ->
        return (2 * @diameter()) * Math.PI

# built in constructor

circle = new Circle( radius: 23 );
cf = circle.circumference();

circle.setRadius 90
cf2 = circle.circumference();

    
```

*Alternative using mixin ( also works for non-Coffeescript classes)*
```coffeescript
Foo = ()->
    # your things in constructor
    
Jackalope.extend Foo

Foo.has 'name',
    isa: 'Str'
    required: true

foo = Foo.create( name: 'Harry' )
```
## Typeconstraints

Jackalope implements a typeconstraint similar to Moose, but javascript flavoured. Basic types are equal to Javascript's built-in types, but with additional checks for `null` and `NaN`.

* Str:
    Javascript 'string' type, not `null` or `undefined`
* Bool:
    Javascript 'boolean', not `null` or `undefined`
* Number:
    Javascript 'number', not `NaN`, `null` or `undefined`
* Int:
    Javascript 'number', without any decimal points
* Object:
    Anything that answers to `typeof === 'object'` and not `null`  
* Function:
    Anything that answers to `typeof === 'function'`  
* Instance:
    Value must be an `instanceof` this type

*Example of the `Instance` type*
```coffeescript
class Point extends Jackalope.Class
    @has 'x',
        isa: 'Int'
        required: true
        
    @has 'y',
        isa: 'Int'
        required: true
        
class Line extends Jackalope.Class
    @has 'start',
        isa: Point
        required: true
        
    @has 'end'
        isa: Point
        required: true
        

# now do:
[a, b] = [new Point( x: 0, y: 0 ), new Point( x: 10, y: 5 )]

line = new Line( start: a, end: b )

```



