global = exports

Suite =
    count: 1
    
    throws_ok: ( fn, re, message )->
        @count++
        try
            fn()
        catch error
            Suite.ok "#{error}".match( re ), "\"#{error}\" matches #{re}"
            return

        throw "  not ok #{count} - #{message}"

    
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
        
        if @count != count + 1
            console.log "# Dubious: expected #{count} tests, got #{@count-1}"

global.export = (args...)->
    Suite[name] for name in args

for name, fn in Suite
    do ()->
        global[name] = fn
