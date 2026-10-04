# Third-Party Licensing Information

The code in this repository is covered with GPLv3 license as described in [LICENSE](LICENSE) except for the following cases:

1. NATS library  
Locations:  
   - [Scripts/Hooks/External/nats.lua](Scripts/Hooks/External/nats.lua)  
Origin:  
  - [https://github.com/DawnAngel/lua-nats](https://github.com/DawnAngel/lua-nats)  
  - [https://github.com/rgacogne/lua-nats/tree/tls](https://github.com/rgacogne/lua-nats/tree/tls)  
Version: 0.0.2  
License: [https://github.com/DawnAngel/lua-nats/blob/master/LICENSE](https://github.com/DawnAngel/lua-nats/blob/master/LICENSE)  
Notes: Original code was augmented by unmerged PR, which additionally got extended within this repository

2. luasocket library  
Locations:  
  - [Scripts/Hooks/External/ssl/lua/socket/](Scripts/Hooks/External/ssl/lua/socket/)  
  - [Scripts/Hooks/External/ssl/lua/socket.lua](Scripts/Hooks/External/ssl/lua/socket.lua)  
  - [Scripts/Hooks/External/ssl/lua/ltn12.lua](Scripts/Hooks/External/ssl/lua/ltn12.lua)  
  - [Scripts/Hooks/External/ssl/lua/mime.lua](Scripts/Hooks/External/ssl/lua/mime.lua)  
  - [Scripts/Hooks/External/ssl/dll/socket/core.dll](Scripts/Hooks/External/ssl/dll/socket/core.dll)  
  - [Scripts/Hooks/External/ssl/dll/mime/core.dll](Scripts/Hooks/External/ssl/dll/mime/core.dll)  
Origin: [https://github.com/lunarmodules/luasocket](https://github.com/lunarmodules/luasocket)
Version: 3.1.0-1  
License: [https://github.com/lunarmodules/luasocket/blob/master/LICENSE](https://github.com/lunarmodules/luasocket/blob/master/LICENSE)

3. luasec library  
Locations:  
  - [Scripts/Hooks/External/ssl/lua/ssl.lua](Scripts/Hooks/External/ssl/lua/ssl.lua)  
  - [Scripts/Hooks/External/ssl/lua/ssl/](Scripts/Hooks/External/ssl/lua/ssl/)  
  - [Scripts/Hooks/External/ssl/dll/ssl.dll](Scripts/Hooks/External/ssl/dll/ssl.dll)  
Origin: [https://github.com/lunarmodules/luasec](https://github.com/lunarmodules/luasec)
Version: 1.3.2  
License: [https://github.com/lunarmodules/luasec/blob/master/LICENSE](https://github.com/lunarmodules/luasec/blob/master/LICENSE)

4. OpenSSL library for Windows
Locations:
  - [Scripts/Hooks/External/ssl/dll/libssl-4-x64.dll](Scripts/Hooks/External/ssl/dll/libssl-4-x64.dll)
  - [Scripts/Hooks/External/ssl/dll/libssl-4-x64.dll](Scripts/Hooks/External/ssl/dll/libcrypto-4-x64.dll)
Origin:
  - [https://github.com/openssl/installer/releases/tag/testing_release](https://github.com/openssl/installer/releases/tag/testing_release)
  - [https://github.com/openssl/openssl](https://github.com/openssl/openssl)
Version: 4.0.1
License: [https://github.com/openssl/openssl/blob/master/LICENSE.txt](https://github.com/openssl/openssl/blob/master/LICENSE.txt)

5. Lua uuid library  
Locations:  
  - [Scripts/Hooks/External/uuid.lua](Scripts/Hooks/External/uuid.lua)  
  - [Scripts/Hooks/External/uuid/](Scripts/Hooks/External/uuid/)
Origin: https://github.com/Tieske/uuid  
Version: 1.0.0  
License: https://github.com/Tieske/uuid/blob/master/LICENSE.md

6. bitops and function  
Locations:  
  - [Scripts/Hooks/External/bitops.lua](Scripts/Hooks/External/bitops.lua)  
Origin: https://stackoverflow.com/a/32387452  
Version: N/A  
License: License - CC BY-SA 3.0

7. cjson library which was original dependency of the nats library has been replaced by own wrapper utilizing DCS supplied JSON encoder/decoder
