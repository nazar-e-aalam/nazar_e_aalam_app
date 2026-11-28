#!/usr/bin/env bash
set -euo pipefail
: "${IOS_ID:?Set PROD_IOS_BUNDLE_ID}" "${CERT:?Missing certificate}" "${CERT_PASSWORD:?Missing certificate password}" "${PROFILE:?Missing provisioning profile}"
printf '%s' "$CERT" | base64 -D > "$RUNNER_TEMP/production.p12"
printf '%s' "$PROFILE" | base64 -D > "$RUNNER_TEMP/production.mobileprovision"
KC="$RUNNER_TEMP/production.keychain-db"
PASS=$(openssl rand -hex 24)
security create-keychain -p "$PASS" "$KC"
security unlock-keychain -p "$PASS" "$KC"
security set-keychain-settings -lut 21600 "$KC"
security list-keychains -d user -s "$KC" login.keychain-db
security import "$RUNNER_TEMP/production.p12" -k "$KC" -P "$CERT_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple: -s -k "$PASS" "$KC"
security cms -D -i "$RUNNER_TEMP/production.mobileprovision" > "$RUNNER_TEMP/profile.plist"
python3 - <<'PY'
import os,plistlib,pathlib,shutil,datetime
p=pathlib.Path(os.environ['RUNNER_TEMP']); profile=plistlib.loads((p/'profile.plist').read_bytes()); team=profile['TeamIdentifier'][0]; bundle=os.environ['IOS_ID']; name=profile['Name']
assert profile['Entitlements']['application-identifier']==team+'.'+bundle,'Profile bundle ID mismatch'
assert profile['ExpirationDate']>datetime.datetime.utcnow(),'Expired profile'
assert not profile.get('ProvisionedDevices') and not profile.get('ProvisionsAllDevices') and not profile['Entitlements'].get('get-task-allow'),'App Store profile required'
for folder in ['Library/MobileDevice/Provisioning Profiles','Library/Developer/Xcode/UserData/Provisioning Profiles']:
    d=pathlib.Path.home()/folder; d.mkdir(parents=True,exist_ok=True); shutil.copy(p/'production.mobileprovision',d/(profile['UUID']+'.mobileprovision'))
(p/'production-export.plist').write_bytes(plistlib.dumps(dict(method='app-store-connect',teamID=team,signingStyle='manual',signingCertificate='Apple Distribution',provisioningProfiles={bundle:name})))
(p/'signing.json').write_text(__import__('json').dumps(dict(team=team,bundle=bundle,profile=name)))
PY
ruby -r xcodeproj -r json - <<'RUBY'
s=JSON.parse(File.read(File.join(ENV['RUNNER_TEMP'],'signing.json')))
p=Xcodeproj::Project.open('ios/Runner.xcodeproj')
t=p.targets.find{|x| x.name=='Runner'} or abort 'Runner target missing'
t.build_configurations.each do |c|
  next unless c.name=='Release'
  c.build_settings.merge!({'PRODUCT_BUNDLE_IDENTIFIER'=>s['bundle'],'DEVELOPMENT_TEAM'=>s['team'],'CODE_SIGN_STYLE'=>'Manual','CODE_SIGN_IDENTITY'=>'Apple Distribution','PROVISIONING_PROFILE_SPECIFIER'=>s['profile']})
end
p.save
RUBY
