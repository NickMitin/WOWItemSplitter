from urllib.request import urlopen
from io import BytesIO
import zipfile
import ssl
import platform
import os
import shutil

def copytree(src, dst, symlinks=False, ignore=None):
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, symlinks, ignore)
        else:
            shutil.copy2(s, d)

system = platform.system()
if (system == 'Darwin'):
    root_directory = '/Applications/World of Warcraft/_classic_/Interface/AddOns/'
elif (system == 'Windows'):
    root_directory = 'C:\Program Files (x86)\World of Warcraft\_classic_\Interface\Addons'

context = ssl.create_default_context()
context.check_hostname = False
context.verify_mode = ssl.CERT_NONE

filedata = urlopen('https://github.com/NickMitin/WOWItemSplitter/archive/v0.1.zip', context=context)
zip_archive = filedata.read()
zip_data = BytesIO()
zip_data.write(zip_archive)
zip_file = zipfile.ZipFile(zip_data)
zip_file.extractall(root_directory)

addon_directory = root_directory + "ItemSplitter"
os.makedirs(addon_directory, 0o777, True)
temp_directory = root_directory + "WOWItemSplitter-0.1"
copytree(temp_directory, addon_directory)
shutil.rmtree(temp_directory)

