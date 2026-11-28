import os,re,pathlib
root=pathlib.Path('android'); candidates=[p for p in [root/'app/build.gradle',root/'app/build.gradle.kts'] if p.exists()]
if len(candidates)!=1: raise SystemExit('Expected exactly one app Gradle file')
p=candidates[0]; text=p.read_text(); app_id=os.environ['ANDROID_ID']
pattern=r'(?m)^(\s*applicationId\s*(?:=\s*)?)[\"\'][^\"\']+[\"\']'
text,n=re.subn(pattern,lambda m:m[1]+'"'+app_id+'"',text)
if n!=1: raise SystemExit('Expected one literal applicationId; inspect Gradle configuration')
p.write_text(text)
# Java properties escaping, preserving passwords literally.
def escape(s):
    return ''.join('\\'+c if c in '\\ :=#!' else '\\u%04x'%ord(c) if ord(c)<32 or ord(c)>126 else c for c in s)
(root/'key.properties').write_text(''.join(k+'='+escape(v)+'\n' for k,v in {'storeFile':'upload-keystore.jks','storePassword':os.environ['STORE_PASSWORD'],'keyAlias':os.environ['KEY_ALIAS'],'keyPassword':os.environ['KEY_PASSWORD']}.items()))
