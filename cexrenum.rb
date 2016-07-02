#

RE_PTN1 = /\Amfet[1-9][0-9]* (0|[1-9][0-9]*) (0|[1-9][0-9]*) (0|[1-9][0-9]*) (0|[1-9][0-9]*) [np]ch w=[1-9][0-9]*u l=[1-9][0-9]*u\z/
RE_PTN2 = /\A\*\$ [^\t]+\t(0|[1-9][0-9]*)\z/

def main
    fets_buf = []
    nets_buf = []

    template "* SPICE FET model"
    template ".lib 'mos_tt.lib'"

    buf = nil
    loop {
        buf = getline
        if buf == nil then
            bout "unexpected EOF"
        end
        if RE_PTN1.match buf then
            fets_buf << buf
        else
            break
        end
    }
    if buf == nil then
        bout "unexpected EOF"
    end
    if buf != ".end" then
        unexpected buf, ".end"
    end
    template "** Net name table **"
    loop {
        buf = getline
        if buf == nil then
            break
        end
        if RE_PTN2.match buf then
            nets_buf << buf
        else
            bout('syntax error: "' + buf + '"')
        end
    }
    mangle fets_buf, nets_buf
    emit fets_buf, nets_buf
end

def mangle fets_buf, nets_buf
    fets_buf.each {|buf|
        m = RE_PTN1.match buf
        ofs = 0
        (1...m.size).each {|i|
            n = m[i].to_i + 1
            sz0 = buf.size
            buf[(m.begin(i)+ofs)...(m.end(i)+ofs)] = n.to_s
            sz1 = buf.size
            ofs += sz1 - sz0
        }
    }

    nets_buf.each {|buf|
        m = RE_PTN2.match buf
        ofs = 0
        (1...m.size).each {|i|
            n = m[i].to_i + 1
            sz0 = buf.size
            buf[(m.begin(i)+ofs)...(m.end(i)+ofs)] = n.to_s
            sz1 = buf.size
            ofs += sz1 - sz0
        }
    }
end

def emit fets_buf, nets_buf
    puts "* SPICE FET model"
    puts ".lib 'mos_tt.lib'"
    fets_buf.each {|buf|
        puts buf
    }
    puts ".end"
    puts "** Net name table **"
    nets_buf.each {|buf|
        puts buf
    }
end

def template tmpl
    buf = getline
    if buf == nil then
        bout "unexpected EOF"
    end
    if buf != tmpl then
        unexpected buf, tmpl
    end
end

def getline
    buf = gets
    if buf != nil then
        buf.chomp!
    end
    return buf
end

def bout msg
    STDERR.puts("ERROR: " + msg)
    exit 2
end

def unexpected s1, s2
    bout('unexpected "' + s1 + '", expected is "' + s2 + '"')
end

main
