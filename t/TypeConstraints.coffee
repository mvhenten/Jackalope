Jackalope = require '../lib/TypeConstraints'

[test, ok, throws_ok] = require('./lib/test')
    .export 'test','ok','throws_ok'
    
# TODO remove duplication!

test 'Boolean', 7, ()->
    args = { isa: 'Bool' }

    cases =
        throws_ok: [ '' , 1, 'true', {}, [] ]
        ok: [ true, false ]
                        
    for value in cases.throws_ok
        do ( value )=>
            throws_ok ()->
                Jackalope.TypeConstraints.check_type( value, 'isa', args  )
            , /is not a Bool/

    for value in cases.ok
        do ( value )=>
            ok Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isa boolean"

test 'Number', 12, ()->
    args = { isa: 'Number' }

    cases =
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null ]
        ok: [ 1, 0.1, 1.2, 42 ]
            
    for value in cases.throws_ok
        do ( value )=>
            throws_ok ()->
                Jackalope.TypeConstraints.check_type( value, '', args  )
            , /is not a Number/

    for value in cases.ok
        do ( value )=>
            ok Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isa number"

test 'Int', 10, ()->
    args = { isa: 'Int' }

    cases =
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null ]
        ok: [ 1, 0 ]
            
    for value in cases.throws_ok
        do ( value )=>
            throws_ok ()->
                Jackalope.TypeConstraints.check_type( value, '', args  )
            , /is not a Int/

    for value in cases.ok
        do ( value )=>
            ok Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isa number"

test 'instance of class', 12, ()->
    class Foo
        constructor: ()->            
            # pass
        
    args = { isa: Foo }

    cases =
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null, (new Object()), -> ]
        ok: [ (new Foo()) ]
            
    for value in cases.throws_ok
        do ( value )=>
            throws_ok ()->
                Jackalope.TypeConstraints.check_type( value, 'Foo', args  )
            , /is not a function Foo/

    for value in cases.ok
        do ( value )=>
            ok Jackalope.TypeConstraints.check_type( value, 'Foo', args  )
            , "#{value} isa Foo"


test 'Function', 12, ()->        
    args = { isa: 'Function' }

    cases =
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null, (new Object()) ]
        ok: [ (->) ]
            
    for value in cases.throws_ok
        do ( value )=>
            throws_ok ()->
                Jackalope.TypeConstraints.check_type( value, 'Foo', args  )
            , /is not a Function/

    for value in cases.ok
        do ( value )=>
            ok Jackalope.TypeConstraints.check_type( value, 'Foo', args  )
            , "#{value} isa function"
