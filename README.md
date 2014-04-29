encrypt-tool
============

Bash script to encrypt/decrypt arbitrary files using OpenSSL.  Useful for maintaining encrypted versions of files in the cloud (such as Dropbox), such that local plaintext edits never appear in Dropbox's "previous versions" history.

# Features
* Uses OpenSSL to perform file encryption
    * Uses AES-256 in Cipher-Block Chaining (CBC mode)
    * Key and IV are derived from a user-defined passphrase
    * Every encryption operation is salted, to avoid having same file encrypt to the same ciphertext on successive runs
* Plaintext file is deleted upon encryption
    * Uses 'shred' utility to overwrite the plaintext file repeatedly, in order to make it harder for even very expensive hardware probing to recover the data
* Compresses file before encrypting (increases entropy before encryption)
* Runs on any OS having a Bash environment

# Environment
* Any OS running Bash
* The following tools must be installed and in the PATH:  openssl, shred, gzip, zcat

# Prerequisites
To install necessary prerequisites on Ubuntu:

    sudo apt-get install openssl coreutils gzip

# Installation
Simply copy encrypt-tool.sh to a directory of your choosing.  Don't forget to make it executable:

    chmod +x encrypt-tool.sh

# Usage
```
./encrypt-tool.sh encrypt <plaintextFile> [outputDir]
./encrypt-tool.sh decrypt <encryptedFile> <outputFile>
```

# Example usage
```
user@computer:~$ echo "this is secret data" > file.txt
user@computer:~$ xxd -g4 file.txt 
0000000: 74686973 20697320 73656372 65742064  this is secret d
0000010: 6174610a                             ata.
user@computer:~$ ls -la file*
-rw-rw-r-- 1 user user 20 Apr 29 15:20 file.txt
user@computer:~$ ./encrypt-tool.sh encrypt file.txt ~/Dropbox/
enter aes-256-cbc encryption password:
Verifying - enter aes-256-cbc encryption password:
shred: file.txt: pass 1/4 (random)...
shred: file.txt: pass 2/4 (random)...
shred: file.txt: pass 3/4 (random)...
shred: file.txt: pass 4/4 (000000)...
shred: file.txt: removing
shred: file.txt: renamed to 00000000
shred: 00000000: renamed to 0000000
shred: 0000000: renamed to 000000
shred: 000000: renamed to 00000
shred: 00000: renamed to 0000
shred: 0000: renamed to 000
shred: 000: renamed to 00
shred: 00: renamed to 0
shred: file.txt: removed
'file.txt' has been encrypted and shredded.  Encrypted file exists at '/home/user/Dropbox//file.bin'.
user@computer:~$ ls -la file*
ls: cannot access file*: No such file or directory
user@computer:~$ xxd -g4 /home/user/Dropbox//file.bin
0000000: 53616c74 65645f5f 616efb1c 9ebfe333  Salted__an.....3
0000010: 1c8ae442 352ed64c a0944b4a f492722e  ...B5..L..KJ..r.
0000020: f60440dc 7268bd65 4b7110db cc26e905  ..@.rh.eKq...&..
0000030: 11aba058 9805cac4 10c143b0 7845232b  ...X......C.xE#+
user@computer:~$ ./encrypt-tool.sh decrypt /home/user/Dropbox//file.bin file.txt
enter aes-256-cbc decryption password:
'/home/user/Dropbox//file.bin' has been decrypted.  Plaintext file exists at 'file.txt'.
user@computer:~$ xxd -g4 /home/user/Dropbox//file.bin
0000000: 53616c74 65645f5f 616efb1c 9ebfe333  Salted__an.....3
0000010: 1c8ae442 352ed64c a0944b4a f492722e  ...B5..L..KJ..r.
0000020: f60440dc 7268bd65 4b7110db cc26e905  ..@.rh.eKq...&..
0000030: 11aba058 9805cac4 10c143b0 7845232b  ...X......C.xE#+
user@computer:~$ ls -la file*
-rw-rw-r-- 1 user user 20 Apr 29 15:21 file.txt
user@computer:~$ xxd -g4 file.txt 
0000000: 74686973 20697320 73656372 65742064  this is secret d
0000010: 6174610a                             ata.
```
