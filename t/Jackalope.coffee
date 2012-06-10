Jackalope = require('../lib/Jackalope').Jackalope

[test, ok, eq, ne, throws_ok ] = require('./lib/test')
    .export 'test','ok', 'is', 'isnt', 'throws_ok'

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

class Student extends Jackalope
    @has 'name',
        isa: 'Str'

    @has 'age',
        isa: 'Int'

    @has 'grade',
        isa: 'Number'
        

test 'Factory sets attributes', 3, ()->
    defaults =
        name: 'Tester',
        age:    42,
        grade: 6.5

    student = new Student defaults
        
    for key, value of defaults
        eq( value, student[key](), "#{key} has expected value '#{value}'")
        
test 'Constructor checks type constraints', 1, ()->        
    throws_ok ()->
        student = new Student( age: 1.4 )
    , /Assertion failed for 'age', '1.4' is not a Int/
    , 'Typeconstraints work on constructor'
    
test 'Accessor', 1, ()->
    class Writer extends Jackalope
        @has 'name'
            writer: 'set_name'
            isa: 'Str'
            
    writer = new Writer( name: 'Lewis Carrol' )    
    eq writer.name(), 'Lewis Carrol', 'Name was set as expected'

test 'Writer', 1, ()->
    class Writer extends Jackalope
        @has 'name'
            writer: 'set_name'
            isa: 'Str'
            
    writer = new Writer()
    writer.set_name 'Lewis Carrol'
    
    eq writer.name(), 'Lewis Carrol', 'Name was set as expected'

test 'Prototype and instance', 2, ()->
    class Book extends Jackalope
        @has 'pages',
            isa: 'Int'
            
    [ novel, novella ] = [ new Book( pages: 1000 ), new Book( pages: 10 ) ]
        
    eq 1000, novel.pages(), 'One instance has expected value'
    ne novel.pages(), novella.pages(), 'Instances have different values'

test 'Lazy build', 1, ()->    
    class Lazy extends Jackalope
        @has 'answer',
            isa: 'Int'
            lazy_build: true
            
        _build_answer: ()->
            return 42
        
    lazy = new Lazy
    eq 42, lazy.answer(), 'Expected value for lazy build'    
    
