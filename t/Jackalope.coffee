[test, ok, eq, ne, throws_ok ] = require('./lib/test')
    .export 'test','ok', 'is', 'isnt', 'throws_ok'

# // run tests pure coffee
# lib = require "../src/Jackalope"

# // run tests on compiled library
Jackalope = require '../'

class Student extends Jackalope.Class
    @has 'name',
        isa: 'Str'

    @has 'age',
        isa: 'Int'

    @has 'grade',
        isa: 'Number'
        

test 'Constructor sets attributes', 3, ()->
    defaults =
        name: 'Tester',
        age:    42,
        grade: 6.5

    student = new Student defaults
        
    for key, value of defaults
        eq( value, student[key](), "#{key} has expected value '#{value}'")
        
test 'Regression falsish arguments', 2, ()->
    class Foo extends Jackalope.Class
        @has 'zero',
            isa: 'Int'
            required: true
        
        @has 'yes'
            isa: 'Bool'
            required: true
            
    obj = new Foo zero: 0, yes: false
    eq( obj.zero(), 0, 'Constructor arg "0" is set' )
    eq( obj.yes(), false, 'Constructor arg "false" is set' )
    

test 'External constructor', 2, ()->    
    class Book
        Jackalope.extend Book
        
        @has 'pages',
            isa: 'Int'
            default: 42
            
    book = Book.create()

    eq 42, book.pages(), "pages has expected value"

test 'External constructor sets values', 1, ()->
    class Book
        Jackalope.extend Book
        
        @has 'pages',
            isa: 'Int'
            default: 42
            
    book = Book.create pages: 4
    eq 4, book.pages(), "pages has expected value"

    book = Book.create pages: 9
    eq 9, book.pages(), "different instance, different value"

test 'Constructor checks type constraints', 1, ()->        
    throws_ok ()->
        student = new Student( age: 1.4 )
    , /Assertion failed for 'age', '1.4' is not an Int/
    , 'Typeconstraints work on constructor'
    
test 'Accessor', 1, ()->
    class Writer extends Jackalope.Class
        @has 'name'
            writer: 'set_name'
            isa: 'Str'
            
    writer = new Writer( name: 'Lewis Carrol' )    
    eq writer.name(), 'Lewis Carrol', 'Name was set as expected'

test 'Writer', 1, ()->
    class Writer extends Jackalope.Class
        @has 'name'
            writer: 'set_name'
            isa: 'Str'
            
    writer = new Writer()
    writer.set_name 'Lewis Carrol'
    
    eq writer.name(), 'Lewis Carrol', 'Name was set as expected'

test 'Prototype and instance', 2, ()->
    class Book extends Jackalope.Class
        @has 'pages',
            isa: 'Int'
            
    [ novel, novella ] = [ new Book( pages: 1000 ), new Book( pages: 10 ) ]
        
    eq 1000, novel.pages(), 'One instance has expected value'
    ne novel.pages(), novella.pages(), 'Instances have different values'

test 'Prototype and instance, extends', 2, ()->
    class Book extends Jackalope.Class
        @has 'pages',
            isa: 'Int'
            
    class Novella extends Book
        # pass
            
    [ novel, novella ] = [ new Book( pages: 1000 ), new Novella( pages: 10 ) ]
        
    eq 1000, novel.pages(), 'One instance has expected value'
    ne novel.pages(), novella.pages(), 'Instances have different values'


test 'Lazy build', 1, ()->    
    class Lazy extends Jackalope.Class
        @has 'answer',
            isa: 'Int'
            lazy_build: true
            
        _build_answer: ()->
            return 42
        
    lazy = new Lazy
    eq 42, lazy.answer(), 'Expected value for lazy build'    
    
test 'Default', 1, ()->    
    class Foo extends Jackalope.Class
        @has 'answer',
            isa: 'Int'
            default: 89

    foo = new Foo()
    
    eq 89, foo.answer(), 'Expected value for default'

test 'Trigger', 1, ()->
    trigger_called = false
    
    class Trig extends Jackalope.Class
        @has 'answer',
            isa: 'Int'
            writer: 'setAnswer'
            trigger: ( value )->
                trigger_called = value
                
    trig = new Trig()
    trig.setAnswer( 42 )
    
    eq trig.answer(), trigger_called, 'Trigger was called'

test 'Init args', 2, ()->
    class Foo extends Jackalope.Class
        @has 'answer',
            isa: 'Int'
            init_arg: 'solution'
            default: 89
            
                
    foo = new Foo solution: 42
    
    eq foo.answer(), 42, 'Init arg is used in constructor'

    foo = new Foo answer: 42
    
    eq foo.answer(), 89, 'name is ignored in favour of init_arg'



test 'Handles', 1, ()->
    class Delegate extends Jackalope.Class
        @has 'answer',
            isa: 'Int'
            default: 42
    
    class Handler extends Jackalope.Class
        @has 'delegate',
            isa: Delegate
            lazy_build: true
            handles:
                amount: 'answer'
                
        _build_delegate: ()->
            new Delegate()
                
    handler = new Handler()    
    eq 42, handler.amount(), 'Expected value returned by handles'
    
test 'Maybe', 3, ()->
    class Might extends Jackalope.Class
        @has 'something',
            isa: @Maybe 'Int'
    

    might = new Might()
        
    eq undefined, might.something(), 'Maybe something returns null'
    
    might = new Might( something: 90 )
    
    eq 90, might.something(), 'Maybe something returns value'
    
    throws_ok ()->
        new Might( something: 0.5 )
    , /is not a/
    

test 'Trait: Object', 13, ()->
    defaults = { one: 2, two: {a:'b'}, three: [3] }
        
    class Foo extends Jackalope.Class
        @has 'things',
            isa: 'Object'
            traits: [ 'Object' ]
            default: defaults
            handles:
                getKeys: 'keys'
                getValues: 'values'
                copyThings: 'copy'
                thingsPairs: 'kv'

    foo = new Foo()
    
    copy = foo.copyThings()
    
    for key, value of defaults
        eq value, copy[key], "#{key} matches values of default"

    expected_values = ( value for key, value of defaults )
    values = foo.getValues()

    for i, value of expected_values
        eq value, values[i], "#{i}: value is identical and values is an array"

    expected_keys = ( key for key, value of defaults )
    keys = foo.getKeys()

    for i, key of expected_keys
        eq key, keys[i], "#{i}: key is identical and keys is an array"

    pairs = foo.thingsPairs()
    
    for pair in pairs
        [key, value] = pair
        eq defaults[key], value, "#{key} matches and data has expected structure"
        
    copy.one = 99    
    ne copy.one, foo.things().one, "copy is a proper copy"
    
