Jackalope = require '../lib/TypeConstraints'

[test, ok, throws_ok] = require('./lib/test')
    .export 'test','ok','throws_ok'

class Foo
    constructor: ()->
        # pass

cases =
    Boolean:
        isa: 'Bool'
        throws_ok: [ '' , 1, 'true', {}, [] ]
        ok: [ true, false ]

    Number:
        isa: 'Number'
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null ]
        ok: [ 1, 0.1, 1.2, 42 ]

    Int:
        isa: 'Int'
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null ]
        ok: [ 1, 0 ]

    Str:
        isa: 'Str'
        throws_ok: [ 1, 0, true, {}, [], NaN, undefined, null ]
        ok: [ '', '1', ( new String('') ) ]

    Function:
        isa: 'Function'
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null, (new Object()) ]
        ok: [ (->) ]

    Object:
        isa: 'Object'
        throws_ok: [ '', '1', true, NaN, undefined, null ]
        ok: [ {}, ( new Object() ) ]

    Array:
        isa: 'Array'
        throws_ok: [ '', '1', true, {}, NaN, undefined, null, (new Object()) ]
        ok: [ [1,2], [null, 1, true], new Array() ]

    InstanceOf:
        isa: Foo
        throws_ok: [ '', '1', true, {}, [], NaN, undefined, null, (new Object()), -> ]
        ok: [ (new Foo()) ]


runTestCase = ( name, cases )->
    for key, value of cases
      n_tests = ( n_tests ? 0 ) + value.length

    test "#{name}", n_tests, ()->
        args = { isa: test_case.isa }

        for value in test_case.throws_ok
            do ( value )=>
                throws_ok ()->
                    Jackalope.TypeConstraints.check_type( value, 'isa', args  )
                , /is not a/

        for value in test_case.ok
            do ( value )=>
                console.log value instanceof Array, 'ok'

                ok Jackalope.TypeConstraints.check_type( (value), 'isa', args  )
                , "#{value} isa #{args.isa}"


runTestCase( name, test_case ) for name, test_case of cases
