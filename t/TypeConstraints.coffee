Jackalope = require '../lib/TypeConstraints'

[test, ok, throws_ok] = require('./lib/test')
    .export 'test','ok','throws_ok'

test 'Boolean', 6, ()->
    args = { isa: 'Bool' }

    cases =
        throws_ok: [ 1, 'true', {}, [] ]
        ok: [ true, false ]
                        
    for value in cases.throws_ok
        do ( value )=>
            throws_ok ()->
                Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isnt a boolean"

    for value in cases.ok
        do ( value )=>
            ok Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isa boolean"

test 'Number', 8, ()->
    args = { isa: 'Number' }

    cases =
        throws_ok: [ '1', 'true', {}, [] ]
        ok: [ 1, 0.1, 1.2, 42 ]
            
    for value in cases.throws_ok
        do ( value )=>
            throws_ok ()->
                Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isnt a number"

    for value in cases.ok
        do ( value )=>
            ok Jackalope.TypeConstraints.check_type( value, '', args  )
            , "#{value} isa number"

test 'Int', 2, ()->
    args = { isa: 'Int' }

    throws_ok ()->
        args = { isa: 'Int' }
        Jackalope.TypeConstraints.check_type( 'not int', 'test bool', args  )
    , 'not an int'
            
    ok Jackalope.TypeConstraints.check_type( 1, 'test bool', args  )
    , 'is a int'
