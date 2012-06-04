global = exports

Suite =
    count: 1
    
    throws_ok: ( fn, message )->
        ok = false
        try
            fn()
        catch error
            console.log "  ok #{count} - #{message}"
            ok = true
        throw "  not ok #{count} - #{message}" unless ok

        @count++
    
    ok: ( value, message )->
        throw "  not ok #{count} - #{message}" unless value
        console.log "  ok #{count} - #{message}"    

        @count++

    is: ( expected, value, message )->
        throw "  not ok #{count} - #{message}" unless value == expected
        console.log "  ok #{count} - #{message}"    
        
        @count++
        
    isnt: ( expected, value, message )->
        throw "  not ok #{count} - #{message}" if value == expected
        console.log "  ok #{count} - #{message}"    
        
        @count++

    isa_ok: ( expected, value, message )->
        message ?= "isa " + ( expected.constructor?.name || expected )
            
        throw "  not ok #{count} - #{message}" unless value instanceof expected
        console.log "  ok #{count} - #{message}"    

        @count++

    test: ( name, count, fn )->
        @count = 1
        
        console.log "1..#{count}"
        
        if fn() != false
            console.log "Test OK #{name}"
        else
            console.log "Failed #{name}"

global.export = (args...)->
    Suite[name] for name in args

for name, fn in Suite
    do ()->
        global[name] = fn
