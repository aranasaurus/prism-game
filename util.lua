Utils = {
    removeAndReplace = function( t, i, sz, name )
        local sz = sz or #t
        t[i] = t[sz]
        t[sz] = nil
        print( string.format( "removed item %d from %s. Size is now %d.", i, name or tostring(t), sz-1 ) )
    end
}
