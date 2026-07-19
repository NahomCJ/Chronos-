"""
Build script: creates blockhub-deploy.zip for EB upload.

Run from the repo root after:
  npm run build:blockhub      (compiles TypeScript → dist-blockhub/)
  npx prisma generate         (ensures Linux binary is in node_modules)
"""

import zipfile
import os

OUTPUT = 'blockhub-deploy.zip'

# Files / dirs to include
entries = [
    ('dist-blockhub', True),
    ('node_modules',  True),
    ('prisma',        True),
    ('.ebextensions', True),
    ('package.json',  False),
    ('package-lock.json', False),
]

# Inline Procfile for BlockHub — overrides the root one
PROCFILE_CONTENT = b'web: node dist-blockhub/main.js\n'

print(f'Creating {OUTPUT} ...')
with zipfile.ZipFile(OUTPUT, 'w', zipfile.ZIP_DEFLATED) as zf:
    # Procfile
    zf.writestr('Procfile', PROCFILE_CONTENT)

    for name, is_dir in entries:
        if is_dir:
            for root, dirs, files in os.walk(name):
                for f in files:
                    fp = os.path.join(root, f)
                    arc = fp.replace(os.sep, '/')
                    zf.write(fp, arc)
        else:
            if os.path.exists(name):
                zf.write(name, name)

size_mb = os.path.getsize(OUTPUT) / 1_048_576
print(f'Done! {OUTPUT} — {size_mb:.1f} MB')
print()
print('Next steps:')
print('  1. Go to EB console - Create new environment (Web server, Node.js 20)')
print('  2. App name: chronos-blockhub  /  env name: blockhub-env')
print('  3. Upload blockhub-deploy.zip')
print('  4. Set environment variables:')
print('       NODE_ENV = production')
print('       DATABASE_URL = <same as main app RDS>')
print('       JWT_SECRET = <same as main app>')
