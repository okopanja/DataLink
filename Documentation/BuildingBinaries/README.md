1. Download lua 5.1.5 from [https://www.lua.org/ftp/lua-5.1.5.tar.gz][lua-5.1.5.tar.gz]
2. Unpack the tar.gz to: c:\lua\5.1.5\x86_64 (note: you may need to prune topmost folder)
3. Copy luavs-dcs.bat into c:\lua\5.1.5\x86_64\etc (changes were made to ensure we have same naming sheme as DCS)
4. Execute "x64 Native Tools Command Prompt for VS"
5. Build lua
```
cd c:\lua\5.1.5\x86_64
etc\lua-dcs.bat
```
6. If all goes well you have lua compiled with binaries being placed in c:\lua\5.1.5\x86_64\etc
7. Download luarocks.exe from: https://luarocks.github.io/luarocks/releases/ and unpack the exe files into c:\lua\5.1.5\x86_64\src (yes exe files must be placed together!!!)
8. Copy config-5.1.lua into: %APPDATA%\Roaming\luarocks
9. Download and install OpenSSL for Windows: https://github.com/openssl/installer/releases/tag/testing_release E.g: OpenSSL-x64-VS-4.0.1.exe
10. Start fresh "x64 Native Tools Command Prompt for VS"
11. build luasocket with following command:
```
cd c:\lua\5.1.5\x86_64\src
copy lua.lib lua51.lib
luarocks.exe --lua-version=5.1 install luasocket
luarocks.exe --lua-version=5.1 install luasec OPENSSL_DIR="C:\Program Files\OpenSSL Library\openssl-4.0"
cd c:\lua
git clone https://github.com/lunarmodules/luasec
cd luasec
git switch tags/v1.3.2
copy luasec-1.3.2-2.rockspec c:\lua\luasec 
c:\lua\5.1.5\x86_64\src\luarocks.exe --lua-version=5.1 make luasec-1.3.2-2.rockspec OPENSSL_DIR="c:\Program Files\OpenSSL Library\openssl-4.0" --force
```