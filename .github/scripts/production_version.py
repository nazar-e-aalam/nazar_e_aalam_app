import json, os, re, subprocess
inputs=json.loads(os.environ['INPUTS_JSON'])
rows=[]
for platform, initial, runner, channel in [('android','2.0.0','ubuntu-24.04','playstore'),('ios','1.0.0','macos-15','appstore')]:
    if not inputs['build_'+platform]: continue
    tags=subprocess.check_output(['git','tag','--list',f'prod-{platform}-v*'],text=True).splitlines()
    versions=[]
    for tag in tags:
        m=re.fullmatch(r'prod-'+platform+r'-v(\d+\.\d+\.\d+)-b(\d+)',tag)
        if m: versions.append((int(m[2]),m[1]))
    previous=max(versions,default=None)
    override=inputs[platform+'_version'].strip(); number=inputs[platform+'_build'].strip()
    skip=inputs['skip_version_bump']
    if skip:
        if not previous or override or number: raise SystemExit('Skip requires existing production tag and no overrides')
        build,version=previous
    else:
        if previous:
            old,ver=previous; a,b,c=map(int,ver.split('.')); version=override or f'{a}.{b}.{c+1}'; build=int(number) if number else old+1
            if build<=old or tuple(map(int,version.split('.')))<tuple(map(int,ver.split('.'))): raise SystemExit('Production version cannot decrease; build must increase')
        else:
            version=override or initial
            if platform=='android' and not number: raise SystemExit('First Android build requires version code greater than Play Console maximum')
            build=int(number or '1')
    if not re.fullmatch(r'\d+\.\d+\.\d+',version) or not 0<build<=2100000000: raise SystemExit('Invalid version/build')
    rows.append(dict(platform=platform,version=version,build=build,os=runner,channel=channel))
if not rows: raise SystemExit('Select at least one platform')
with open(os.environ['GITHUB_OUTPUT'],'a') as f: f.write('matrix='+json.dumps({'include':rows},separators=(',',':'))+'\n')
