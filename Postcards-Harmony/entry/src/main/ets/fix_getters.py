import re, os, sys

def process_file(path):
    with open(path, 'r') as f:
        content = f.read()
    
    # Find all private get definitions: private get name(): Type {
    pattern = re.compile(r'private get (\w+)\(\)\s*:\s*([^\{]+)\{')
    getters = []
    for m in pattern.finditer(content):
        name = m.group(1)
        ret_type = m.group(2).strip()
        getters.append((name, ret_type))
    
    if not getters:
        return 0
    
    # Replace definitions
    new_content = content
    for name, ret_type in getters:
        # Replace private get name(): Type {  ->  private getName(): Type {
        old_def = f'private get {name}(): {ret_type} {{'
        new_def = f'private get{name[0].upper()}{name[1:]}(): {ret_type} {{'
        new_content = new_content.replace(old_def, new_def)
    
    # Replace this.name references (but not this.getName which would already be correct)
    for name, ret_type in getters:
        method_name = f'get{name[0].upper()}{name[1:]}'
        # Match this.name where name is a whole word, not preceded by get
        # Use regex to replace this.name -> this.getName()
        ref_pattern = re.compile(rf'this\.{name}\b(?!\s*\()')
        new_content = ref_pattern.sub(f'this.{method_name}()', new_content)
    
    with open(path, 'w') as f:
        f.write(new_content)
    
    return len(getters)

count = 0
for root, dirs, files in os.walk('.'):
    for f in files:
        if f.endswith('.ets'):
            path = os.path.join(root, f)
            n = process_file(path)
            if n:
                print(f'Fixed {n} getters in {path}')
                count += n

print(f'Total getters fixed: {count}')
