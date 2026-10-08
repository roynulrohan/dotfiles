import sys, re
p = sys.argv[1]
lines = open(p).read().split('\n')
out, skip = [], False
for l in lines:
    s = l.strip()
    if s.startswith('['):
        skip = s.startswith('[lockscreen_widgets')
    if not skip:
        out.append(l)
open(p, 'w').write('\n'.join(out))
