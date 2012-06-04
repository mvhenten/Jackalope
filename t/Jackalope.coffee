Jackalope = require('../lib/Jackalope').Jackalope

[test, ok, eq, ne ] = require('./lib/test')
    .export 'test','ok', 'is', 'isnt'

class Foo extends Jackalope
    @has 'one',
        lazy_build: true
        isa: 'Number'

    @has 'two',
        default: 56
        writer: 'set_two'
        isa: 'Number'

    _build_one: ()->
        return 98

    _build_ala: ()->
        #pass

test 'Constructor', 1, ()->    
    n = new Foo()

    eq n.one(), 98, 'Expected lazy built value'
    ok n.two() == 56, 'Expected default value'
    
    
    n = new Foo()
    m = new Foo()
    
    n.set_two( 42 )
    m.set_two( 60 )

    eq n.two(), 42, 'Getter returned value set'
    eq m.two(), 60, 'Getter returned value set'
    
    ne m.two(), n.two(), 'Values are not the same'    
